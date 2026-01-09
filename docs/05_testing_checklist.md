# Testing Checklist

## Import/Quraşdırma Ardıcıllığı
1. WF-00 Main Router
2. WF-01 Ideation Intake
3. WF-02 Research & Source Intake
4. WF-03 Script Draft
5. WF-04 Script Review & Approval
6. WF-05 Voiceover Generation
7. WF-06 Scene Asset Build
8. WF-07 Render Orchestration
9. WF-08 Thumbnail Generator
10. WF-09 YouTube Publish
11. WF-10 Get Config
12. WF-11 Settings Panel
13. WF-12 Short Extractor

## Ümumi yoxlamalar
- Config DB bağlantısı işləkdir.
- Credentials provider aktivdir və referanslar işləyir.
- Storage endpoint-lər əlçatandır.
- Audit log-lar yazılır.

## Workflow-specific testlər
### WF-01
- Yeni run yaradılması və manifest-in dolması.
- Invalid input ssenariləri.

### WF-02
- Mənbə əlavə edilməsi və license yoxlaması.

### WF-03
- Script generation və min/max söz sayı validasiyası.

### WF-04
- Review approval flow və script dəyişiklikləri.

### WF-05
- ElevenLabs response=file binary upload edilir.
- Voiceover output-da `voiceover_url_signed` real və qalıcı URL-dir.
- `storage.example.com` placeholder URL qalmayıb.

### WF-06
- Asset download və checksum təsdiqi.

### WF-07
- Render job submission və status polling.

### WF-08
- DALL-E URL-i əvvəlcə endirilir, sonra storage-a upload olunur.
- Output-da `thumbnail_url` qalıcı URL-dir (expire olmur).
- Fallback işləyirsə status `THUMBNAIL_FALLBACK`, yoxdursa `FAILED_THUMBNAIL` olur.

### WF-09
- YouTube upload və metadata tətbiqi.

### WF-10
- Config resolve və storage required key yoxlaması.
- Production modda storage config əskikdirsə `FAILED_CONFIG_STORAGE` qaytarılır.
- Test modda storage config əskikdirsə xəbərdarlıqla davam edir.

### WF-11
- Settings update və credential policy yoxlaması.

### WF-12
- Shorts extraction job-ları və çıxış contract-i yoxlanır.

## Contract yoxlamaları
- Contract field adları dəyişməyib: run_id, mode, scene_assets, voiceover_url_signed, render_id, youtube_video_id, manifest.

## Golden sample yoxlamaları
- `exports/golden_samples/new_run.json` yeni run strukturu ilə müqayisə olunur.
- `exports/golden_samples/rendered.json` render mərhələsi ilə müqayisə olunur.
- `exports/golden_samples/published.json` publish mərhələsi ilə müqayisə olunur.
