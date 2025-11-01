<#
 Line Auto Save — all-in-one (PowerShell 5.1)
 • คัดลอกจาก LINE PC (หรือโฟลเดอร์ใด ๆ) ไปยังปลายทาง โดย:
    - เลือกประเภทไฟล์ (image/video/audio/all)
    - ตัวเลือกกรองตามชื่อห้อง/ชื่อไฟล์ (regex สร้างให้อัตโนมัติจาก keyword)
    - ถ้าไฟล์ปลายทางมีอยู่แล้ว และใหม่กว่าน้อยกว่า → เก็บตัวใหม่ (ล่าสุด)
    - กันรูปซ้ำด้วย perceptual hash (pHash) + เลือกรูปคมสุด (Laplacian variance)
    - เดดุปด้วย SHA-256 index (ตัวเลือก) เก็บที่ <Destination>\.hash_index.json
    - (ตัวเลือก) เข้ารหัส AES-256-CBC → .aes
 • สร้างไอคอน/ตัวลัดรันเดียวแบบซ่อนคอนโซล (VBS wrapper)
 • รองรับ webhook (LINE OA) แบบเบา ๆ ผ่าน HttpListener (ปิดค่าเริ่มต้น)

 ตัวอย่าง:
   powershell -NoProfile -ExecutionPolicy Bypass -File \
     "C:\LineAutoSave\line_auto_save_all_in_one.ps1" \
     -Source "$env:USERPROFILE\Downloads" -Destination "D:\Backups\Line" \
     -Mode image -Deduplicate -IncludeNames 'ครอบครัว','โครงการA' -CreateShortcut

 หมายเหตุ: รันด้วยสิทธิ์ปกติได้ แต่ถ้าเปิด webhook อาจต้องตั้ง URLACL/Firewall
#>

param(
    [Parameter(Mandatory=$true)][string]$Source,
    [string]$Destination = 'C:\LineAutoSave\inbox',
    [ValidateSet('image','video','audio','all')] [string]$Mode = 'all',
    [string[]]$IncludeNames,
    [switch]$Deduplicate,
    [switch]$Encrypt,
    [string]$KeyFile,
    [switch]$StartWebhook,
    [string]$ChannelAccessToken,
    [string]$ChannelSecret,
    [int]$Port = 8080,
    [switch]$CreateShortcut
)

# ---------- Utilities ----------
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

function Ensure-Path([string]$Path){ if(-not (Test-Path $Path)){ New-Item -ItemType Directory -Path $Path -Force | Out-Null } }

$Global:LAS_Paths = [ordered]@{
  Root  = 'C:\LineAutoSave'
  Logs  = 'C:\LineAutoSave\logs'
}
$Global:LAS_Paths.GetEnumerator() | ForEach-Object { Ensure-Path $_.Value }

function Write-Log {
    param(
        [Parameter(Mandatory=$true)][string]$Message,
        [ValidateSet('INFO','WARN','ERROR')][string]$Level = 'INFO'
    )

    $ts = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logDir = $Global:LAS_Paths.Logs
    if (-not (Test-Path $logDir -PathType Container)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }
    $log = Join-Path $logDir 'cli.log'

    # หมุนไฟล์ log แบบปลอดภัย: เช็คเฉพาะเมื่อไฟล์มีอยู่จริง
    if (Test-Path $log -PathType Leaf) {
        try {
            $len = (Get-Item -LiteralPath $log -ErrorAction Stop).Length
            if ($len -gt 5MB) {
                $bak = Join-Path $logDir ("cli_{0:yyyyMMdd_HHmmss}.log" -f (Get-Date))
                Move-Item -LiteralPath $log -Destination $bak -Force
            }
        } catch {
            # อย่าให้การเขียน log ทำงานหลักล้ม
        }
    }

    $line = "[$ts] [$Level] $Message"
    Add-Content -LiteralPath $log -Value $line -Encoding UTF8
    $line
}

function New-AesKeyBase64(){ $rng = New-Object System.Security.Cryptography.RNGCryptoServiceProvider; $bytes = New-Object byte[] 32; $rng.GetBytes($bytes); [Convert]::ToBase64String($bytes) }

function Protect-AesFile([string]$InPath,[string]$OutPath,[string]$KeyBase64){
  $key = [Convert]::FromBase64String($KeyBase64)
  $aes = [System.Security.Cryptography.Aes]::Create(); $aes.Key = $key; $aes.Mode='CBC'; $aes.Padding='PKCS7'; $aes.GenerateIV();
  $iv = $aes.IV
  $in  = [IO.File]::Open($InPath,[IO.FileMode]::Open,[IO.FileAccess]::Read,[IO.FileShare]::Read)
  try{
    $out = [IO.File]::Open($OutPath,[IO.FileMode]::Create,[IO.FileAccess]::Write,[IO.FileShare]::None)
    try{
      $magic = [byte[]](65,69,83,49) # AES1
      $out.Write($magic,0,4); $out.Write($iv,0,$iv.Length)
      $ext = [IO.Path]::GetExtension($InPath).TrimStart('.')
      $extBytes = [Text.Encoding]::UTF8.GetBytes($ext); $out.WriteByte([byte]$extBytes.Length)
      if($extBytes.Length -gt 0){ $out.Write($extBytes,0,$extBytes.Length) }
      $enc = $aes.CreateEncryptor(); $cs = New-Object System.Security.Cryptography.CryptoStream($out,$enc,'Write')
      try{ $in.CopyTo($cs); $cs.FlushFinalBlock() } finally{ $cs.Dispose() }
    } finally{ $out.Dispose() }
  } finally{ $in.Dispose(); $aes.Dispose() }
}

# Safe relative path for .NET Framework (PS 5.1)
function Get-RelPath([string]$Base,[string]$Path){
  $b = (Resolve-Path $Base).Path; if(-not $b.EndsWith('\\')){ $b += '\\' }
  $uBase = New-Object System.Uri($b)
  $uPath = New-Object System.Uri((Resolve-Path $Path).Path)
  return [System.Uri]::UnescapeDataString($uBase.MakeRelativeUri($uPath).ToString()).Replace('/','\\')
}

function Get-AllowedExtensions([string]$mode){
  switch($mode.ToLower()){
    'image' { return @('.jpg','.jpeg','.png','.gif','.bmp','.heic','.webp') }
    'video' { return @('.mp4','.mov','.avi','.mkv','.webm') }
    'audio' { return @('.m4a','.mp3','.wav','.aac') }
    default { return @(
      '.jpg','.jpeg','.png','.gif','.bmp','.heic','.webp',
      '.mp4','.mov','.avi','.mkv','.webm',
      '.m4a','.mp3','.wav','.aac',
      '.pdf','.zip','.rar','.7z','.txt','.doc','.docx','.xls','.xlsx','.ppt','.pptx'
    )}
  }
}

# --- perceptual hash / sharpness (PS 5.1 friendly) ---
function Get-PerceptualHash([string]$path){
  try{
    $bmp = [Drawing.Bitmap]::FromFile($path)
    $small = New-Object Drawing.Bitmap 8,8
    $g = [Drawing.Graphics]::FromImage($small); $g.DrawImage($bmp,0,0,8,8); $g.Dispose(); $bmp.Dispose()
    $sum=0; $px=@()
    for($y=0;$y -lt 8;$y++){ for($x=0;$x -lt 8;$x++){ $p=$small.GetPixel($x,$y); $gval=[int](0.2126*$p.R+0.7152*$p.G+0.0722*$p.B); $px+=$gval; $sum+=$gval } }
    $small.Dispose(); $avg=[int]($sum/64); ($px | ForEach-Object { if($_ -ge $avg){'1'} else{'0'} }) -join ''
  } catch { return $null }
}
function Get-Hamming($a,$b){ if(-not $a -or -not $b -or $a.Length -ne $b.Length){ return 64 }; $c=0; for($i=0;$i -lt $a.Length;$i++){ if($a[$i] -ne $b[$i]){ $c++ } }; return $c }
function Get-ImageSharpness([string]$Path){
  try{
    $bmp = [Drawing.Bitmap]::FromFile($Path)
    $fmt = [Drawing.Imaging.PixelFormat]::Format24bppRgb
    if($bmp.PixelFormat -ne $fmt){ $bmp = $bmp.Clone([Drawing.Rectangle]::new(0,0,$bmp.Width,$bmp.Height),$fmt) }
    $b = $bmp.LockBits([Drawing.Rectangle]::new(0,0,$bmp.Width,$bmp.Height),[Drawing.Imaging.ImageLockMode]::ReadOnly,$fmt)
    $stride=$b.Stride; $w=$bmp.Width; $h=$bmp.Height
    $buf = New-Object byte[] ($stride*$h); [Runtime.InteropServices.Marshal]::Copy($b.Scan0,$buf,0,$buf.Length)
    $bmp.UnlockBits($b); $bmp.Dispose()
    $sum=0.0; $sum2=0.0; $n=0
    for($y=1;$y -lt $h-1;$y++){
      for($x=1;$x -lt $w-1;$x++){
        $i=$y*$stride+$x*3; $c=$buf[$i+1]
        $l=$buf[$y*$stride+($x-1)*3+1]; $r=$buf[$y*$stride+($x+1)*3+1]
        $u=$buf[($y-1)*$stride+$x*3+1]; $d=$buf[($y+1)*$stride+$x*3+1]
        $lap = [double](4*$c - $l - $r - $u - $d)
        $sum += $lap; $sum2 += $lap*$lap; $n++
      }
    }
    if($n -eq 0){ return 0 }; $mean=$sum/$n; $var=$sum2/$n - $mean*$mean; [math]::Sqrt([math]::Max(0,$var))
  } catch { 0 }
}
$SharpThreshold = 18  # ปรับตาม dataset จริง
$DupThreshold   = 6   # <=6 ถือว่าใกล้เคียงมาก

function Load-HashIndex([string]$Destination){ $p = Join-Path $Destination '.hash_index.json'; if(Test-Path $p){ try{ Get-Content $p -Raw | ConvertFrom-Json }catch{ @() } } else { @() } }
function Save-HashIndex([string]$Destination,$Index){ $p = Join-Path $Destination '.hash_index.json'; $Index | ConvertTo-Json -Depth 4 | Set-Content -Path $p -Encoding UTF8 }

# ---------- Backup core ----------
function Start-LineBackup{
  param([string]$Source,[string]$Destination,[string]$Mode,[string[]]$IncludeNames,[switch]$Deduplicate,[switch]$Encrypt,[string]$KeyFile)

  if(-not (Test-Path $Source)){ throw "Source not found: $Source" }
  Ensure-Path $Destination

  $start = Get-Date
  Write-Log "Backup started: Source=$Source, Dest=$Destination, Mode=$Mode"

  $allowed = Get-AllowedExtensions $Mode
  $extSet = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
  $allowed | ForEach-Object { [void]$extSet.Add($_) }

  $files = Get-ChildItem -Path $Source -Recurse -File -Force
  if($extSet.Count -gt 0){ $files = $files | Where-Object { $extSet.Contains([IO.Path]::GetExtension($_.Name)) } }

  if($IncludeNames -and $IncludeNames.Count -gt 0){
    $rx = ($IncludeNames | ForEach-Object {[regex]::Escape($_)}) -join '|'
    $files = $files | Where-Object { $_.FullName -match $rx }
  }

  $hashIndex = if($Deduplicate){ [System.Collections.ArrayList](Load-HashIndex $Destination) } else { @() }
  $byPHash = @{}

  $copied=0; $skipped=0; $encrypted=0
  foreach($f in $files){
    $rel = Get-RelPath $Source $f.FullName
    $out = Join-Path $Destination $rel
    $dir = [IO.Path]::GetDirectoryName($out); if(-not (Test-Path $dir)){ New-Item -ItemType Directory -Path $dir -Force | Out-Null }

    $ext = [IO.Path]::GetExtension($f.Name)
    $isImg = $ext -match '^(?i)\.(jpg|jpeg|png|gif|bmp|heic|webp)$'

    # pHash dedup + sharpness select
    if($isImg){
      $ph = Get-PerceptualHash $f.FullName
      if($ph){
        foreach($k in $byPHash.Keys){
          if((Get-Hamming $ph $k) -le $DupThreshold){
            $prev = $byPHash[$k]
            $sNew = Get-ImageSharpness $f.FullName
            if($sNew -le $prev.sharp -and $f.LastWriteTime -le $prev.time){ $skipped++; Write-Log ("Skip (dupe image, weaker) {0}" -f $rel) 'WARN'; continue }
            else { $byPHash.Remove($k); break }
          }
        }
        $byPHash[$ph] = @{ sharp = (Get-ImageSharpness $f.FullName); time = $f.LastWriteTime }
      }
    }

    # เดดุปด้วย sha index (ข้ามไฟล์ที่เคยคัดแล้ว)
    $sha = $null
    if($Deduplicate){
      $shaProv = [System.Security.Cryptography.SHA256]::Create()
      $fs = [IO.File]::Open($f.FullName,[IO.FileMode]::Open,[IO.FileAccess]::Read,[IO.FileShare]::Read)
      try{ $sha = -join ($shaProv.ComputeHash($fs) | ForEach-Object { $_.ToString('x2') }) } finally { $fs.Dispose(); $shaProv.Dispose() }
      if($hashIndex -contains $sha){ $skipped++; Write-Log ("Skip (dedup hash) {0}" -f $rel) 'INFO'; continue }
    }

    # เก็บไฟล์ใหม่กว่าเท่านั้น
    if(Test-Path $out){ $destTime=(Get-Item $out).LastWriteTime; if($f.LastWriteTime -le $destTime){ $skipped++; Write-Log ("Skip (older than dest) {0}" -f $rel) 'INFO'; continue } }

    if($Encrypt){
      if(-not $KeyFile -or -not (Test-Path $KeyFile)){ throw 'Encryption enabled but key file not found. ใช้ -KeyFile ชี้ไฟล์ Base64 คีย์' }
      $keyB64 = Get-Content $KeyFile -Raw
      $aesOut = $out + '.aes'
      Protect-AesFile -InPath $f.FullName -OutPath $aesOut -KeyBase64 $keyB64
      $encrypted++; Write-Log ("Encrypted: {0} -> {1}" -f $rel,[IO.Path]::GetFileName($aesOut)) 'INFO'
    } else {
      Copy-Item $f.FullName $out -Force
      $copied++; Write-Log ("Copied: {0}" -f $rel) 'INFO'
    }

    if($Deduplicate -and $sha){ [void]$hashIndex.Add($sha) }
  }

  if($Deduplicate){ Save-HashIndex $Destination $hashIndex }
  $end = Get-Date
  Write-Log ("Backup finished. Scanned={0} Copied={1} Enc={2} Skipped={3} Duration={4}s" -f $files.Count,$copied,$encrypted,$skipped,[math]::Round(($end-$start).TotalSeconds,2)) 'INFO' | Out-Null
}

# ---------- Webhook (optional) ----------
function Start-LineWebhookListener{
  param([string]$Token,[string]$Secret,[int]$Port,[string]$SaveDir)
  Ensure-Path $SaveDir
  $listener = New-Object System.Net.HttpListener
  $prefix = "http://+:$Port/line/webhook/"; $listener.Prefixes.Add($prefix); $listener.Start()
  Write-Log ("Webhook listening at {0}" -f $prefix)
  $job = Start-Job -ScriptBlock {
    param($tk,$sec,$save)
    Add-Type -AssemblyName System.Drawing | Out-Null
    function Compute-HmacBase64([string]$Secret,[byte[]]$BodyBytes){ $key=[Text.Encoding]::UTF8.GetBytes($Secret); $h=New-Object System.Security.Cryptography.HMACSHA256($key); try{ [Convert]::ToBase64String($h.ComputeHash($BodyBytes)) } finally{ $h.Dispose() } }
    function Get-ContentExtensionFromType([string]$ct){ switch -Regex ($ct){ 'image/jpeg'{'.jpg';break};'image/png'{'.png';break};'image/gif'{'.gif';break};'video/mp4'{'.mp4';break};'audio/m4a'{'.m4a';break};'audio/mpeg'{'.mp3';break}; default{''} } }
    $ln = New-Object System.Net.HttpListener; $ln.Prefixes.Add("http://+:$using:Port/line/webhook/"); $ln.Start()
    while($ln.IsListening){
      try{
        $ctx=$ln.GetContext(); $req=$ctx.Request; $res=$ctx.Response
        $ms = New-Object IO.MemoryStream; $req.InputStream.CopyTo($ms); $bytes=$ms.ToArray(); $ms.Dispose()
        $sig=$req.Headers['X-Line-Signature']; $calc=Compute-HmacBase64 -Secret $sec -BodyBytes $bytes
        if(-not [string]::Equals($sig,$calc,[StringComparison]::Ordinal)) { $res.StatusCode=403; $res.Close(); continue }
        $obj = ([Text.Encoding]::UTF8.GetString($bytes)) | ConvertFrom-Json
        foreach($ev in $obj.events){
          if($ev.type -eq 'message' -and $ev.message){ $m=$ev.message; if($m.type -in @('image','video','audio','file')){
            $mid=$m.id; $name = if($m.type -eq 'file' -and $m.PSObject.Properties.Name -contains 'fileName'){ $m.fileName } else { $null }
            $ts = Get-Date -Format 'yyyyMMdd_HHmmss'; $tmp = Join-Path $save ("$ts-$mid.tmp")
            try{
              $uri = "https://api-data.line.me/v2/bot/message/$mid/content"
              $headers = @{ Authorization = "Bearer $tk" }
              $resp = Invoke-WebRequest -Uri $uri -Headers $headers -Method Get -OutFile $tmp -PassThru -ErrorAction Stop
              $ext = if($name){ [IO.Path]::GetExtension($name) } else { Get-ContentExtensionFromType $resp.ContentType }
              if(-not $ext){ $ext = '.bin' }
              $final = if($name){ Join-Path $save $name } else { Join-Path $save ("$ts-$mid$ext") }
              if(Test-Path $final){ Remove-Item $final -Force }
              Move-Item $tmp $final -Force; Write-Log ("Webhook saved: {0}" -f $final)
            } catch {
              Write-Log ("Webhook download failed for {0}: {1}" -f $mid, $_) 'ERROR'
              if(Test-Path $tmp){ Remove-Item $tmp -Force }
            }
          }}
        }
        $res.StatusCode=200; $res.Close()
      } catch { try{ $ctx.Response.StatusCode=500; $ctx.Response.Close() }catch{}; Write-Log ("Webhook error: {0}" -f $_) 'ERROR' }
    }
  } -ArgumentList $ChannelAccessToken,$ChannelSecret,$Destination
  return $job
}

# ---------- Create single-click launcher (hidden console via VBS) ----------
function New-LineAutoSaveShortcut{
  param([string]$Args)
  $desk = [Environment]::GetFolderPath('Desktop')
  $vbs  = Join-Path $desk 'Run Line Auto Save.vbs'
  $ps1  = $MyInvocation.MyCommand.Path
  $cmd  = 'powershell -NoProfile -ExecutionPolicy Bypass -File ' + '"' + $ps1 + '" ' + $Args
  $vbsBody = "Set o=CreateObject(\"WScript.Shell\")\r\no.Run \"" + $cmd + "\"",0\r\n"
  Set-Content -Path $vbs -Value $vbsBody -Encoding ASCII
  Write-Log ("Shortcut created: {0}" -f $vbs)
}

# ---------- Run ----------
$Source = (Resolve-Path $Source).Path
Ensure-Path $Destination

Start-LineBackup -Source $Source -Destination $Destination -Mode $Mode -IncludeNames $IncludeNames -Deduplicate:$Deduplicate -Encrypt:$Encrypt -KeyFile $KeyFile

if($StartWebhook){
  if(-not $ChannelAccessToken -or -not $ChannelSecret){ Write-Log 'Webhook requested but token/secret missing' 'ERROR' } else { Start-LineWebhookListener -Token $ChannelAccessToken -Secret $ChannelSecret -Port $Port -SaveDir $Destination | Out-Null }
}

if($CreateShortcut){
  # ประกอบอาร์กิวเมนต์ปัจจุบันกลับเป็นสตริงสำหรับ VBS
  $argList = @()
  $argList += ('-Source "{0}"' -f $Source)
  $argList += ('-Destination "{0}"' -f $Destination)
  $argList += ('-Mode {0}' -f $Mode)
  if($IncludeNames){ $IncludeNames | ForEach-Object { $argList += ('-IncludeNames "{0}"' -f $_) } }
  if($Deduplicate){ $argList += '-Deduplicate' }
  if($Encrypt){ $argList += '-Encrypt'; if($KeyFile){ $argList += ('-KeyFile "{0}"' -f $KeyFile) } }
  if($StartWebhook){ $argList += '-StartWebhook'; $argList += ('-ChannelAccessToken "{0}"' -f $ChannelAccessToken); $argList += ('-ChannelSecret "{0}"' -f $ChannelSecret); $argList += ('-Port {0}' -f $Port) }
  New-LineAutoSaveShortcut -Args ($argList -join ' ')
}

Write-Log 'Done.' 'INFO' | Out-Null
