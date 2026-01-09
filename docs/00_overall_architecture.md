# Ümumi Arxitektura (WF-00…WF-12)

## Sistem məqsədi
“YouTube Helal Otomasyon Sistemi — Full Production v2” kontent istehsalını ideyadan YouTube nəşrinə qədər avtomatlaşdırır. Arxitektura 13 workflow-dan ibarətdir və hər workflow standart contract formatı ilə məlumat paylaşır.

## Workflow xəritəsi
1. **WF-00 Main Router** — giriş sorğularını yönləndirir.
2. **WF-01 Ideation Intake** — ideya daxil edilir və run yaradılır.
3. **WF-02 Research & Source Intake** — mənbələr toplanır və run-ın tədqiqat hissəsi zənginləşdirilir.
4. **WF-03 Script Draft** — ssenari hazırlanır.
5. **WF-04 Script Review & Approval** — ssenari yoxlanılır və təsdiq edilir.
6. **WF-05 Voiceover Generation** — voiceover yaradılır və URL imzalanır.
7. **WF-06 Scene Asset Build** — səhnə asset-ləri və timeline qurulur.
8. **WF-07 Render Orchestration** — render sifarişi yaradılır və izlənir.
9. **WF-08 Thumbnail Generator** — thumbnail yaradılır və upload edilir.
10. **WF-09 YouTube Publish** — render nəticəsi YouTube-a yüklənir.
11. **WF-10 Get Config** — bütün workflow-lar üçün vahid config çıxışı verir.
12. **WF-11 Settings Panel** — konfiqurasiya və credentials idarə edilir.
13. **WF-12 Short Extractor** — uzun videodan shorts çıxarılır.

## Məlumat axını
- **run_id** hər workflow üçün dəyişməzdir və bütün hadisələri birləşdirir.
- **manifest** və **scene_assets** ilə media, metadata və istehsal elementləri izlənir.
- **mode** işləmə rejimini təyin edir: `test`, `auto_trend`, `manual`.
- **voiceover_url_signed** WF-05 nəticəsi kimi yaradılır və WF-06 tərəfindən istifadə olunur.
- **render_id** WF-07 nəticəsidir və WF-08 tərəfindən istifadə olunur.
- **youtube_video_id** WF-08 nəticəsidir və yekun statusu göstərir.

## Standart contract qaydaları
- Contract-lar `docs/01_contracts.md` sənədində sabitləşdirilib.
- Hər workflow həmin contract-ların uyğun alt-setindən istifadə edir.
- Contract sahə adları dəyişdirilə bilməz.

## Təhlükəsizlik
- Secrets yalnız WF-11 Settings Panel vasitəsilə credentials olaraq saxlanılır.
- Heç bir workflow plain text secret saxlamır.
- WF-10 Get Config credentials dəyərlərini açıqlamır, yalnız referans qaytarır.

## Dayanıqlılıq və izləmə
- Hər workflow `run_id` əsasında audit log saxlayır.
- Hər workflow error handling-də retry qaydalarını tətbiq edir.
- Kritikal mərhələlərdə manual approval nöqtələri mövcuddur.

## Test strategiyası
- `docs/05_testing_checklist.md` ardıcıllığına uyğun test edilir.
- Golden sample JSON-lar müqayisə üçün istifadə olunur.
