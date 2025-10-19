# Full-Auto GitHub Preset (Fixed)

แก้ไขแล้ว:
- แก้ `promptfooconfig.yaml` ให้พาร์สได้
- เอา `|| true` ออกจาก pytest
- เพิ่ม cache: pip ใน CI และ Security

วิธีใช้
1) นำเข้าไฟล์ทั้งชุด
2) เปิด Secret scanning + Push protection
3) เพิ่ม `OPENAI_API_KEY` หากใช้ LLM eval

## การรันชุดทดสอบ Promptfoo

โปรเจกต์เตรียม `package.json` ไว้สำหรับติดตั้งและรัน [promptfoo](https://github.com/promptfoo/promptfoo) เพื่อประเมินผลลัพธ์ของพรอมต์
1. ติดตั้ง dependencies ด้วย `npm install`
2. รัน `npm test` หรือ `npx promptfoo eval` เพื่อประเมินพรอมต์ตามไฟล์ `promptfooconfig.yaml`

อัปเดต: 2025-10-19Z
