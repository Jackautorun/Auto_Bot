# Auto_Bot Full Automation Helper
# ใช้สำหรับการจัดการ PR และ workflows อัตโนมัติ

function New-AutoPR {
    param(
        [string]$Title = "auto: automated changes",
        [string]$Body = "Automated changes created by Auto_Bot helper",
        [string]$Branch = "feat/auto-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    )
    
    Write-Host "🚀 Creating auto PR..." -ForegroundColor Cyan
    
    # สร้าง branch ใหม่
    git checkout -b $Branch
    
    # ถ้าไม่มี changes ให้สร้าง dummy change
    if (!(git diff --cached --quiet)) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        "# Auto update $timestamp" | Out-File -Append -FilePath "README.md"
        git add README.md
        git commit -m "auto: update timestamp $timestamp"
    }
    
    # Push branch
    git push origin $Branch
    
    # สร้าง PR
    $pr = gh pr create --title $Title --body $Body --base main --head $Branch
    Write-Host "✅ PR created: $pr" -ForegroundColor Green
    
    # Auto merge ทันที (ไม่ต้อง approve เพราะ workflow จะทำให้)
    $prNumber = ($pr -split '/')[-1]
    Write-Host "🔄 Setting up auto-merge..." -ForegroundColor Yellow
    
    # Workflow จะ auto approve และ merge เอง
    Write-Host "✅ Auto-approval and merge will be handled by workflow" -ForegroundColor Green
    
    return $prNumber
}

function Invoke-BulkPRs {
    param([int]$Count = 3)
    
    Write-Host "🔥 Creating $Count auto PRs..." -ForegroundColor Red
    
    for ($i = 1; $i -le $Count; $i++) {
        $title = "auto: bulk change #$i"
        $body = "Automated bulk change #$i of $Count created at $(Get-Date)"
        $branch = "auto/bulk-$i-$(Get-Date -Format 'HHmmss')"
        
        New-AutoPR -Title $title -Body $body -Branch $branch
        Start-Sleep -Seconds 2  # หน่วงเวลาไม่ให้ GitHub API ติดขัด
    }
}

function Remove-FailedWorkflows {
    Write-Host "🧹 Cleaning up failed workflows..." -ForegroundColor Yellow
    
    # ดึง workflow runs ที่ล้มเหลว
    $failedRuns = gh run list --repo Jackautorun/Auto_Bot --status failure --json databaseId --jq '.[].databaseId'
    
    foreach ($runId in $failedRuns) {
        if ($runId) {
            Write-Host "Deleting run: $runId" -ForegroundColor Gray
            gh api --method DELETE "repos/Jackautorun/Auto_Bot/actions/runs/$runId" 2>$null
        }
    }
    
    Write-Host "✅ Cleanup completed" -ForegroundColor Green
}

function Test-AutoSystem {
    Write-Host "🧪 Testing Auto System..." -ForegroundColor Magenta
    
    # ตรวจสอบ repository settings
    $repoInfo = gh repo view Jackautorun/Auto_Bot --json allowAutoMerge, deleteBranchOnMerge, allowSquashMerge | ConvertFrom-Json
    
    Write-Host "Repository Settings:" -ForegroundColor Cyan
    Write-Host "  Auto Merge: $($repoInfo.allowAutoMerge)" -ForegroundColor $(if ($repoInfo.allowAutoMerge) { 'Green' } else { 'Red' })
    Write-Host "  Delete Branch on Merge: $($repoInfo.deleteBranchOnMerge)" -ForegroundColor $(if ($repoInfo.deleteBranchOnMerge) { 'Green' } else { 'Red' })
    Write-Host "  Squash Merge: $($repoInfo.allowSquashMerge)" -ForegroundColor $(if ($repoInfo.allowSquashMerge) { 'Green' } else { 'Red' })
    
    # ตรวจสอบ workflows
    $workflows = gh workflow list --repo Jackautorun/Auto_Bot --json name, state
    Write-Host "Active Workflows:" -ForegroundColor Cyan
    foreach ($workflow in ($workflows | ConvertFrom-Json)) {
        $color = if ($workflow.state -eq 'active') { 'Green' } else { 'Red' }
        Write-Host "  $($workflow.name): $($workflow.state)" -ForegroundColor $color
    }
}

function Show-AutoHelp {
    Write-Host @"
🤖 Auto_Bot Full Automation Helper

Commands:
  New-AutoPR              - Create single auto PR
  Invoke-BulkPRs -Count 5 - Create multiple auto PRs  
  Remove-FailedWorkflows  - Clean up failed workflow runs
  Test-AutoSystem         - Test automation system status

Examples:
  New-AutoPR -Title "feat: new feature" -Body "Auto generated feature"
  Invoke-BulkPRs -Count 3
  Remove-FailedWorkflows
  Test-AutoSystem

The system is configured for FULL AUTOMATION:
  ✅ All PRs auto-approved (no conditions)
  ✅ All PRs auto-merged with admin bypass
  ✅ No required status checks
  ✅ No required reviews
  ✅ Auto branch deletion enabled

"@ -ForegroundColor Yellow
}

# Display help on import
Show-AutoHelp