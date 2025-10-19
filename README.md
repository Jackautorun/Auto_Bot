# Full-Auto GitHub Preset (Fixed)

แก้ไขแล้ว:
- แก้ `promptfooconfig.yaml` ให้พาร์สได้
- เอา `|| true` ออกจาก pytest
- เพิ่ม cache: pip ใน CI และ Security

วิธีใช้
1) นำเข้าไฟล์ทั้งชุด
2) เปิด Secret scanning + Push protection
3) เพิ่ม `OPENAI_API_KEY` หากใช้ LLM eval

## วิเคราะห์เส้นโค้งโคช (Koch Snowflake)

สคริปต์ `koch_analysis.py` ช่วยคำนวณคุณสมบัติของเส้นโค้งโคชในแต่ละรอบ เช่น จำนวนเส้นรอบรูป ความยาวรอบรูป และพื้นที่ที่เพิ่มขึ้นในแต่ละขั้น สามารถเรียกใช้งานผ่านคำสั่งต่อไปนี้:

```bash
python koch_analysis.py 3 --initial-length 2.5
```

ผลลัพธ์จะพิมพ์ค่าต่าง ๆ ของรอบที่ระบุ ทำให้สามารถวิเคราะห์การเติบโตของรูปเรขาคณิตแฟร็กทัลนี้ได้อย่างสะดวก

อัปเดต: 2025-10-19Z
