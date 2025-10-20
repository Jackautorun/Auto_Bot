# Full-Auto GitHub Preset (Fixed)

แก้ไขแล้ว:
- แก้ `promptfooconfig.yaml` ให้พาร์สได้
- เอา `|| true` ออกจาก pytest
- เพิ่ม cache: pip ใน CI และ Security

วิธีใช้
1) นำเข้าไฟล์ทั้งชุด
2) เปิด Secret scanning + Push protection
3) เพิ่ม `OPENAI_API_KEY` หากใช้ LLM eval

อัปเดต: 2025-10-19Z

## บันทึกการรันสำหรับ OEC และ Guardrails
ทุกครั้งที่มีการรันการทดสอบหรือทดลองใหม่ ต้องบันทึกข้อมูลในรูปแบบที่ตรวจสอบย้อนกลับได้ดังนี้

- **feature**: ชื่อฟีเจอร์ที่ทดสอบ เช่น `{feature}`
- **code**: `repo=<url> commit=<hash> branch=<name> PR=<id>`
- **data**: `snapshot_id=<id> split=train/val/test(%) preprocessing=<desc>`
- **config**: `lr=… bs=… epochs=… seed=… flags={deterministic:on/off}`
- **hardware**: `GPU=… CPU=… RAM=… runtime=… cost≈…`
- **protocol**: `sample_size=<n> horizon=<days> test_type=<fixed|sequential>` (กำหนดล่วงหน้า)
- **metrics**:
  - `OEC=<name> value=<v> delta=<Δ%> CI95=[l,u] decision=<pass|fail>`
  - `guardrails: {latency_p95, error_rate, fairness_segment…}` (ระบุ threshold)
- **segments**: `{device, country, cohort}` พร้อม delta และ CI95
- **outcome**: `{deploy|hold|rollback} owner=@user rationale=<สรุป 1-2 บรรทัด>`
- **links**: `dashboard=<url> notebook=<url> model_card=<url> datasheet=<url>`

นอกจากนี้ ต้องควบคุม FDR เมื่อมีการตรวจหลายเมตริกหรือหลายกลุ่ม และรายงานค่าเฉลี่ยพร้อมช่วงความเชื่อมั่นทุกครั้ง เพื่อยึดหลัก OEC และ Guardrails ที่กำหนดไว้เสมอ
