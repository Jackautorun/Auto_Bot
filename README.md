# Full-Auto GitHub Preset (Fixed)

แก้ไขแล้ว:
- แก้ `promptfooconfig.yaml` ให้พาร์สได้
- เอา `|| true` ออกจาก pytest
- เพิ่ม cache: pip ใน CI และ Security
- เพิ่ม workflow สำหรับ `ci`, `security`, `codeql`, `gitleaks`, `llm-eval` พร้อมรายงานสถานะ commit

วิธีใช้
1) นำเข้าไฟล์ทั้งชุด
2) เปิด Secret scanning + Push protection
3) เพิ่ม `OPENAI_API_KEY` หากใช้ LLM eval

อัปเดต: 2025-10-19Z
