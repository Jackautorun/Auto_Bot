# Full-Auto GitHub Preset (Fixed)

แก้ไขแล้ว:
- แก้ `promptfooconfig.yaml` ให้พาร์สได้
- เอา `|| true` ออกจาก pytest
- เพิ่ม cache: pip ใน CI และ Security

วิธีใช้
1) นำเข้าไฟล์ทั้งชุด
2) เปิด Secret scanning + Push protection
3) เพิ่ม `OPENAI_API_KEY` หากใช้ LLM eval

การบันทึกผลรัน
- ใช้ `python scripts/run_log_template.py` เพื่อสร้างเทมเพลตบันทึกผลรันตามข้อกำหนด OEC/Guardrails
- ระบุอาร์กิวเมนต์ที่ทราบ เช่น `--feature`, `--repo`, `--oec-name` เพื่อเติมข้อมูลอัตโนมัติ หรือปล่อยค่าเริ่มต้นไว้เพื่อเติมภายหลัง
- ใช้ `--output path/to/file.md` หากต้องการบันทึกเทมเพลตลงไฟล์โดยตรง

สคริปต์เพิ่มเติม
- `scripts/list_workflow_runs.sh` เรียก GitHub Actions API เพื่อตรวจสอบสถานะ workflow ล่าสุด (ต้องตั้งค่า `AUTH`, `ACCEPT`, `BASE`, `OWNER`, `REPO` ในสภาพแวดล้อมก่อนรัน และสามารถระบุจำนวนรายการที่ต้องการด้วยอาร์กิวเมนต์แรก ค่าเริ่มต้นคือ 10)

อัปเดต: 2025-10-19Z
