# Testing Checklist

## Import/Quraşdırma Ardıcıllığı
1. WF-09 Settings Panel
2. WF-10 Get Config
3. WF-01 Ideation Intake
4. WF-02 Research & Source Intake
5. WF-03 Script Draft
6. WF-04 Script Review & Approval
7. WF-05 Voiceover Generation
8. WF-06 Scene Asset Build
9. WF-07 Render Orchestration
10. WF-08 YouTube Publish

## Manual test addımları və gözlənən nəticələr
### WF-09
- Addım: `youtube.channel_id` üçün setting yaradın.
- Gözlənən: DB-də entry yaranır, `value_type=string`.
- Addım: `youtube.api_credentials` üçün `credential_ref` əlavə edin.
- Gözlənən: `value` boş, `credential_ref` doludur.

### WF-10
- Addım: `environment=staging` ilə çağırın.
- Gözlənən: `resolved_config.environment=staging` və `schema_version` mövcuddur.
- Addım: `runtime_overrides.publish.publish_enabled=false` göndərin.
- Gözlənən: çıxışda `publish.publish_enabled=false`.

### WF-01
- Addım: Yeni topic ilə run yaradın.
- Gözlənən: `run_id` yaranır, `timestamps.phase=ideation`.

### WF-02
- Addım: 2 mənbə əlavə edin.
- Gözlənən: `topic.source_references` 2 elementdən ibarətdir.

### WF-03
- Addım: Script draft yaradın.
- Gözlənən: `script.draft` dolur, `timestamps.phase=script_draft`.

### WF-04
- Addım: Script approval edin və review notes yazın.
- Gözlənən: `script.approved` və `script.review_notes` yenilənir, `timestamps.phase=script_approved`.

### WF-05
- Addım: Voiceover yaradın.
- Gözlənən: `assets.voiceover.voiceover_url_signed` dolur, `timestamps.phase=voiceover_ready`.

### WF-06
- Addım: Asset download və timeline qurun.
- Gözlənən: `assets.items` və `scene_assets` dolur, `timestamps.phase=assets_ready`.

### WF-07
- Addım: Render job göndərin və statusu tamamlayın.
- Gözlənən: `render.render_id` və `render.render_status=completed`, `timestamps.phase=render_ready`.

### WF-08
- Addım: Publish enable olduqda upload edin.
- Gözlənən: `publish.youtube_video_id` dolur, `publish.publish_status=published`, `timestamps.phase=published`.

## Golden sample yoxlamaları
- `exports/golden_samples/new_run.json` run yaradılması ilə uyğun olmalıdır.
- `exports/golden_samples/rendered.json` render tamamlanması ilə uyğun olmalıdır.
- `exports/golden_samples/published.json` publish mərhələsi ilə uyğun olmalıdır.
