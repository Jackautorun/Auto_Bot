# Full-Auto GitHub Preset (Fixed)

แก้ไขแล้ว:
- แก้ `promptfooconfig.yaml` ให้พาร์สได้
- เอา `|| true` ออกจาก pytest
- เพิ่ม cache: pip ใน CI และ Security

วิธีใช้
1) นำเข้าไฟล์ทั้งชุด
2) เปิด Secret scanning + Push protection
3) เพิ่ม `OPENAI_API_KEY` หากใช้ LLM eval

## บันทึกการรันทดสอบ/ทดลอง

ทุกการรันต้องบันทึกข้อมูลตามแบบฟอร์ม `EVAL_RUN_TEMPLATE.md` เพื่อยึด OEC เดียวของโปรเจกต์และตรวจสอบ Guardrails ที่กำหนดไว้ เช่น ขนาดตัวอย่าง/ช่วงเวลา, ช่วงความเชื่อมั่นของทุกเมตริก, และการควบคุม FDR เมื่อตรวจหลายเมตริกหรือหลายกลุ่ม

อัปเดต: 2025-10-19Z
