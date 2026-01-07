# n8n Export Proseduru

Bu qovluqda WF-01…WF-10 üçün n8n export JSON-ları saxlanılır. Cari mərhələdə bu JSON-lar yalnız referens üçündür və canlı import üçün dəyişdirilməməlidir.

## Export qaydası (gələcək mərhələlər üçün)
1. n8n-də workflow-u açın və **Export → Download** seçin.
2. Faylı `WF-XX.json` adı ilə bu qovluğa əlavə edin.
3. Export etdikdən sonra `docs/05_testing_checklist.md` faylındakı import ardıcıllığını yoxlayın.
4. Workflow-larda istifadə olunan environment dəyişənləri və credentials ID-ləri gizli saxlanılmalıdır.

## Qeydlər
- JSON faylları dəyişdikdə versiya tarixi üçün commit mesajında WF nömrəsini qeyd edin.
- Bu qovluqda yalnız export JSON-ları və bu README saxlanılmalıdır.
