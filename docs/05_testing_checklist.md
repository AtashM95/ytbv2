# Testing Checklist

## Import/Quraşdırma Ardıcıllığı
1. WF-00 Main Router
2. WF-01 Orchestrator
3. WF-02 Trend Analyzer
4. WF-03 Script Generator
5. WF-04 Script Reviewer
6. WF-05 Voiceover Generation
7. WF-06 Asset Collector
8. WF-07 Video Renderer
9. WF-08 Thumbnail Generator
10. WF-09 YouTube Publisher
11. WF-10 Get Config
12. WF-11 Settings Panel
13. WF-12 Short Extractor

## Ümumi yoxlamalar
- Config DB bağlantısı işləkdir.
- Credentials provider aktivdir və referanslar işləyir.
- Storage endpoint-lər əlçatandır.
- Run registry (`yt_run_registry`) yazılır.

## Workflow-specific testlər
### WF-01
- Yeni run yaradılması və registry `RUNNING` yazılması.
- Policy gate fail → `FAILED_POLICY`.
- Uniqueness gate fail → `FAILED_UNIQUENESS`.

### WF-05
- Voiceover output-da `voiceover_url_signed` real və qalıcı URL-dir.

### WF-09
- OAuth/refresh token error → retry + `FAILED_YT_AUTH`.
- Quota/rate-limit error → retry + `FAILED_YT_QUOTA`.
- Upload sonrası manifest `upload_response` update olunur.

### WF-10
- Config resolve və storage required key yoxlaması.
- Output-da `resolved_at` field mövcuddur.
- Production modda storage config əskikdirsə `FAILED_CONFIG_STORAGE` qaytarılır.

### WF-11
- Form input-larına uyğun `key/value` satırları DB-yə yazılır.
- Upsert conflict target: `environment + scope + channel_key + key`.
- Secrets yalnız `credential_ref`/`env_ref` kimi saxlanılır.

## Contract yoxlamaları
- Contract field adları dəyişməyib: run_id, mode, scene_assets, voiceover_url_signed, render_id, youtube_video_id, manifest.

## Golden sample yoxlamaları
- `exports/golden_samples/new_run.json` yeni run strukturu ilə müqayisə olunur.
- `exports/golden_samples/rendered.json` render mərhələsi ilə müqayisə olunur.
- `exports/golden_samples/published.json` publish mərhələsi ilə müqayisə olunur.
