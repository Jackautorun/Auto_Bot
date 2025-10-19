# Autorun CI Skeleton

รีโปนี้เตรียมเวิร์กโฟลว์ GitHub Actions สำหรับ:
- CI Node (build/lint/test)
- CodeQL code scanning
- Gitleaks สแกนความลับ
- Promptfoo ประเมิน LLM หลายโมเดล

## ใช้งาน
1. สร้างรีโปใหม่บน GitHub แล้วอัปโหลดไฟล์ชุดนี้ หรือใช้ **Import repository**.
2. ไปที่ **Settings → Security** เปิด *Secret scanning* และ *Push protection*.
3. เพิ่ม Secrets ที่ต้องใช้ (ถ้ามี):
   - `OPENAI_API_KEY` สำหรับงาน LLM eval

## Trigger
- CI: push/pull_request ไปที่ `main` + schedule ทุกวัน 03:00 UTC
- CodeQL: push/PR + จันทร์ 14:20 UTC
- Gitleaks: ทุก push/PR + รายวัน 04:00 UTC
- LLM eval: PR และ manual dispatch

อัปเดต: 2025-10-19Z
