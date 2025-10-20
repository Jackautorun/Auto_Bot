# Full-Auto GitHub Preset (Fixed)

แก้ไขแล้ว:
- แก้ `promptfooconfig.yaml` ให้พาร์สได้
- เอา `|| true` ออกจาก pytest
- เพิ่ม cache: pip ใน CI และ Security

วิธีใช้
1) นำเข้าไฟล์ทั้งชุด
2) เปิด Secret scanning + Push protection
3) เพิ่ม `OPENAI_API_KEY` หากใช้ LLM eval

## การบันทึกผลการรัน (Experiment Logging)
- ใช้ไฟล์ [`docs/experiment-log-template.md`](docs/experiment-log-template.md) เป็นแม่แบบบันทึกผลทุกการรัน
- เติมข้อมูลให้ครบทุกหัวข้อ รวมถึง OEC, guardrails, ขนาดตัวอย่าง, และลิงก์อาร์ติแฟกต์ที่เกี่ยวข้อง
- ควบคุม FDR เมื่อมีการทดสอบหลายเมตริกหรือหลายกลุ่ม และรายงานช่วงความเชื่อมั่น 95% เสมอ

สคริปต์เพิ่มเติม
- `scripts/list_workflow_runs.sh` เรียก GitHub Actions API เพื่อตรวจสอบสถานะ workflow ล่าสุด (ต้องตั้งค่า `AUTH`, `ACCEPT`, `BASE`, `OWNER`, `REPO` ในสภาพแวดล้อมก่อนรัน และสามารถระบุจำนวนรายการที่ต้องการด้วยอาร์กิวเมนต์แรก ค่าเริ่มต้นคือ 10)

อัปเดต: 2025-10-19Z
