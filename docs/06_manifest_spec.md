# Manifest Spesifikasiyası

## Məqsəd
Manifest video istehsalının SSOT (Single Source of Truth) strukturu kimi bütün məlumatları saxlayır.

## Manifest strukturu
```json
{
  "manifest_version": "2.0",
  "topic": {
    "title": "",
    "category": "",
    "language": "",
    "keywords": [],
    "summary": "",
    "source_references": [
      {
        "title": "",
        "url": "",
        "license": ""
      }
    ]
  },
  "script": {
    "draft": "",
    "approved": "",
    "review_notes": [],
    "last_reviewed_at": null
  },
  "assets": {
    "scene_plan": [
      {"scene": 1, "description": "", "duration_sec": 0}
    ],
    "items": [],
    "voiceover": {
      "provider": "",
      "voice_id": "",
      "speed": 1.0,
      "pitch": 0.0,
      "output_format": "mp3",
      "voiceover_url_signed": null
    }
  },
  "render": {
    "resolution": "1920x1080",
    "fps": 30,
    "codec": "h264",
    "bitrate_kbps": 8000,
    "render_id": null,
    "render_status": "not_started"
  },
  "publish": {
    "channel_id": "",
    "title": "",
    "description": "",
    "tags": [],
    "privacy": "unlisted",
    "scheduled_at": null,
    "youtube_video_id": null,
    "publish_status": "not_published"
  },
  "analytics": {
    "enabled": true,
    "tracking_tags": [],
    "first_publish_at": null,
    "last_metrics_pull_at": null,
    "metrics": {}
  },
  "final": {
    "status": "",
    "summary": "",
    "completed_at": null
  },
  "audit": {
    "created_by": "",
    "updated_by": "",
    "change_log": [
      {"at": "", "by": "", "change": ""}
    ]
  },
  "timestamps": {
    "created_at": "",
    "updated_at": "",
    "phase": "ideation"
  }
}
```

## Bölmələr
### topic
- `title`, `category`, `language`, `keywords`, `summary`, `source_references` saxlanır.

### script
- `draft` WF-03 tərəfindən yazılır.
- `approved` və `review_notes` WF-04 tərəfindən yenilənir.

### assets
- `scene_plan` və `items` WF-06 tərəfindən doldurulur.
- `voiceover` WF-05 tərəfindən yenilənir.

### render
- `render_id` WF-07 tərəfindən yazılır.
- `render_status` `not_started`, `in_progress`, `completed`, `failed` dəyərlərini alır.

### publish
- `youtube_video_id` WF-08 tərəfindən yazılır.
- `publish_status` `not_published`, `scheduled`, `published`, `failed` dəyərlərini alır.

### analytics
- Nəşrdən sonra metriklər saxlanılır, bu mərhələdə boş qala bilər.

### final
- Workflow yekun statusu üçün istifadə olunur.
- `status` `COMPLETED_DRY_RUN`, `COMPLETED`, `FAILED_AT_WF_XX` dəyərlərini ala bilər.
- `summary` qısa yekun xülasəni saxlayır.
- `completed_at` yekun zamanını saxlayır.

### audit
- `change_log` hər WF update zamanı əlavə olunur.

### timestamps
- `phase` run mərhələsini göstərir və WF-01…WF-08 tərəfindən yenilənir.
- Xəta halında `phase` `failed_preconfig`, `failed_wf_02`, `failed_wf_03`, `failed_wf_04`, `failed_wf_05`, `failed_wf_06`, `failed_wf_07` və ya `failed_wf_08` kimi işarələnə bilər.

## Manifest update qaydaları
- **WF-01:** `topic`, `timestamps.phase`, `audit` başlanğıc qeydini yazır. WF-10 uğursuz olduqda `timestamps.phase = failed_preconfig` yazılır.
- **WF-02:** `topic.source_references` yenilənir. Xəta halında `timestamps.phase = failed_wf_02` yazılır.
- **WF-03:** `script.draft` yenilənir, `timestamps.phase = script_draft`. Xəta halında `timestamps.phase = failed_wf_03` yazılır.
- **WF-04:** `script.approved`, `script.review_notes`, `script.last_reviewed_at` yenilənir, `timestamps.phase = script_approved`. Xəta halında `timestamps.phase = failed_wf_04` yazılır.
- **WF-05:** `assets.voiceover` və `assets.voiceover.voiceover_url_signed` yenilənir, `timestamps.phase = voiceover_ready`. Xəta halında `timestamps.phase = failed_wf_05` yazılır.
- **WF-06:** `assets.scene_plan`, `assets.items` və `scene_assets` yenilənir, `timestamps.phase = assets_ready`. Xəta halında `timestamps.phase = failed_wf_06` yazılır.
- **WF-07:** `render.render_id`, `render.render_status` yenilənir, `timestamps.phase = rendering` və `render_ready`. Xəta halında `timestamps.phase = failed_wf_07` yazılır.
- **WF-08:** `publish.youtube_video_id`, `publish.publish_status` yenilənir, `timestamps.phase = published`. Xəta halında `timestamps.phase = failed_wf_08` yazılır.
- **WF-01 (finalization):** `final.status`, `final.summary`, `final.completed_at` doldurulur.
