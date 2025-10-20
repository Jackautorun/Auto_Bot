# Full-Auto GitHub Preset (Fixed)

แก้ไขแล้ว:
- แก้ `promptfooconfig.yaml` ให้พาร์สได้
- เอา `|| true` ออกจาก pytest
- เพิ่ม cache: pip ใน CI และ Security

วิธีใช้
1) นำเข้าไฟล์ทั้งชุด
2) เปิด Secret scanning + Push protection
3) เพิ่ม `OPENAI_API_KEY` หากใช้ LLM eval

สคริปต์เพิ่มเติม
- `scripts/list_workflow_runs.sh` เรียก GitHub Actions API เพื่อตรวจสอบสถานะ workflow ล่าสุด (ต้องตั้งค่า `AUTH`, `ACCEPT`, `BASE`, `OWNER`, `REPO` ในสภาพแวดล้อมก่อนรัน และสามารถระบุจำนวนรายการที่ต้องการด้วยอาร์กิวเมนต์แรกหรือ `-p/--per-page` ค่าเริ่มต้นคือ 10 พร้อมออปชัน `-s/--status`, `-b/--branch`, `-e/--event` เพื่อกรองผลลัพธ์)

อัปเดต: 2025-10-19Z
