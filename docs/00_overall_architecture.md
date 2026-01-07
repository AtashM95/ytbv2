# Ümumi Arxitektura (WF-01…WF-10)

## Sistem məqsədi
“YouTube Helal Otomasyon Sistemi — Full Production v2” kontent istehsalını ideyadan YouTube nəşrinə qədər avtomatlaşdırır. Arxitektura 10 workflow-dan ibarətdir və hər workflow sabit contract və manifest spesifikasiyasına əsaslanır.

## Workflow xəritəsi və qısa məqsədlər
1. **WF-01 Ideation Intake** — yeni run yaradır, topic və ilkin manifest qurur.
2. **WF-02 Research & Source Intake** — mənbələri toplayır və manifest content bölməsini zənginləşdirir.
3. **WF-03 Script Draft** — ssenari layihəsi yaradır.
4. **WF-04 Script Review & Approval** — ssenarini yoxlayır və təsdiqləyir.
5. **WF-05 Voiceover Generation** — ssenariyə əsasən voiceover yaradır.
6. **WF-06 Scene Asset Build** — scene asset-lər və timeline hazır edir.
7. **WF-07 Render Orchestration** — render job-u göndərir və tamamlanmanı izləyir.
8. **WF-08 YouTube Publish** — render nəticəsini YouTube-a yükləyir.
9. **WF-09 Settings Panel** — config və credentials idarəsi.
10. **WF-10 Get Config** — bütün workflow-lar üçün vahid `resolved_config` qaytarır.

## Data flow
- **run_id** hər workflow üçün dəyişməzdir və run tarixçəsini birləşdirir.
- **manifest** istehsalın SSOT (Single Source of Truth) obyektidir.
- **scene_assets** asset siyahısını saxlayır və render üçün istifadə olunur.
- **voiceover_url_signed** WF-05 tərəfindən yaradılır və WF-06/WF-07-də istifadə edilir.
- **render_id** WF-07 nəticəsi kimi WF-08-də istifadə edilir.
- **youtube_video_id** WF-08 nəticəsi kimi yekun nəşri göstərir.

## Dry-Run və PUBLISH_OFF prinsipi
- **Dry-Run:** `mode = dry_run` olduqda heç bir xarici sistemə yazma əməliyyatı edilməz. Workflow-lar yalnız daxili log və mock nəticələr yaradır.
- **PUBLISH_OFF:** WF-08 publish əməliyyatını yalnız `resolved_config.publish.publish_enabled = true` olduqda icra edir. Əks halda run `published` mərhələsinə keçmir və audit qeydində “publish disabled” qeyd olunur.

## Təhlükəsizlik və secrets
- Secrets yalnız WF-09 vasitəsilə Credentials provider-də saxlanılır.
- Config DB/Data Table heç bir plain text secret saxlamır.
- WF-10 yalnız credential referansları qaytarır.

## İzləmə və dayanıqlılıq
- Hər workflow `run_id` əsasında audit log yazır.
- Retry siyasətləri workflow səviyyəsində tətbiq olunur.
- Manual approval nöqtələri WF-04 və WF-08 mərhələlərində saxlanılır.
