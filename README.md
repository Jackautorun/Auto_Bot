# Full-Auto GitHub Preset (Fixed)

แก้ไขแล้ว:
- แก้ `promptfooconfig.yaml` ให้พาร์สได้
- เอา `|| true` ออกจาก pytest
- เพิ่ม cache: pip ใน CI และ Security

วิธีใช้
1) นำเข้าไฟล์ทั้งชุด
2) เปิด Secret scanning + Push protection
3) เพิ่ม `OPENAI_API_KEY` หากใช้ LLM eval
4) รัน `npm run eval` หรือ `./scripts/run_promptfoo.sh` เพื่อสร้างรายงานที่ `reports/`

> เคล็ดลับ: สคริปต์ `scripts/run_promptfoo.sh` จะสร้างโฟลเดอร์รายงานตามเวลา UTC และส่งต่ออาร์กิวเมนต์ทั้งหมดให้ `promptfoo eval`

อัปเดต: 2025-10-19Z
