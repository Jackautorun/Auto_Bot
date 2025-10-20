# Full-Auto GitHub Preset (Fixed)

แก้ไขแล้ว:
- แก้ `promptfooconfig.yaml` ให้พาร์สได้
- เอา `|| true` ออกจาก pytest
- เพิ่ม cache: pip ใน CI และ Security

วิธีใช้
1) นำเข้าไฟล์ทั้งชุด
2) เปิด Secret scanning + Push protection
3) เพิ่ม `OPENAI_API_KEY` หากใช้ LLM eval

<<<<<<< ours
=======
สคริปต์เพิ่มเติม (ต้องติดตั้ง `jq` และตั้งค่า `AUTH`, `ACCEPT`, `BASE`, `OWNER`, `REPO` ในสภาพแวดล้อมก่อนรัน)
- `scripts/list_workflow_runs.sh` เรียก GitHub Actions API เพื่อตรวจสอบสถานะ workflow ล่าสุด (สามารถระบุจำนวนรายการที่ต้องการด้วยอาร์กิวเมนต์แรก ค่าเริ่มต้นคือ 10)
- `scripts/watch_latest_workflow_run.sh [interval] [run_id]` โพลสถานะ workflow run ล่าสุดหรือรันที่ระบุ และส่งคืนโค้ดออก `0` เมื่อสำเร็จหรือ `1` เมื่อไม่สำเร็จ

>>>>>>> theirs
อัปเดต: 2025-10-19Z
- smoke
