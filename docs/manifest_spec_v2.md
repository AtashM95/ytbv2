# Manifest Spesifikasiyası v2.0

## Məqsəd
Manifest video istehsalının bütün metadata və statuslarını saxlayan əsas strukturdur. Bu sənəd workflow-larda istifadə olunan ətraflı manifest strukturunu müəyyən edir.

## Manifest strukturu

```json
{
  "manifest_version": "2.0",

  "topic": {
    "title": "Video başlığı",
    "category": "education",
    "language": "az",
    "keywords": ["açar", "sözlər"],
    "summary": "Qısa məzmun təsviri",
    "source_references": [
      {
        "title": "Mənbə adı",
        "url": "https://example.com/source",
        "license": "CC-BY-4.0"
      }
    ]
  },

  "script": {
    "draft": "İlkin ssenari mətni...",
    "approved": "Təsdiqlənmiş ssenari mətni...",
    "review_notes": ["Qeyd 1", "Qeyd 2"],
    "last_reviewed_at": "2024-01-15T10:30:00Z"
  },

  "assets": {
    "scene_plan": [
      {
        "scene": 1,
        "description": "Səhnə təsviri",
        "duration_sec": 25.0
      }
    ],
    "items": [
      {
        "asset_id": "asset_run123_001",
        "type": "video|image",
        "source": "pexels_video|pexels_photo|dalle_generated",
        "source_url": "https://...",
        "local_path": "/mnt/assets/run123/scene_1.mp4",
        "checksum_sha256": "abc123...",
        "duration_sec": 25.0,
        "resolution": "1920x1080",
        "license": "Pexels|DALL-E",
        "metadata": {
          "pexels_id": "12345",
          "photographer": "John Doe",
          "scene_number": 1,
          "scene_description": "...",
          "generation_error": null
        }
      }
    ],
    "voiceover": {
      "provider": "elevenlabs",
      "voice_id": "pNInz6obpgDQGcFmaJgB",
      "speed": 1.0,
      "pitch": 0.0,
      "output_format": "mp3",
      "voiceover_url_signed": "https://storage.example.com/voiceover/run123.mp3"
    }
  },

  "render": {
    "resolution": "1920x1080",
    "fps": 30,
    "codec": "h264",
    "bitrate_kbps": 8000,
    "render_id": "render_run123",
    "render_status": "not_started|rendering|completed|failed",
    "render_url": "https://cdn.shotstack.io/..."
  },

  "publish": {
    "channel_id": "UC...",
    "title": "YouTube video başlığı",
    "description": "Video təsviri...",
    "tags": ["tag1", "tag2"],
    "privacy": "public|unlisted|private",
    "scheduled_at": "2024-01-20T12:00:00Z",
    "youtube_video_id": "dQw4w9WgXcQ",
    "publish_status": "not_published|published|scheduled|failed"
  },

  "analytics": {
    "enabled": true,
    "tracking_tags": ["campaign_2024"],
    "first_publish_at": "2024-01-15T12:00:00Z",
    "last_metrics_pull_at": "2024-01-16T10:00:00Z",
    "metrics": {
      "views": 1000,
      "likes": 50,
      "comments": 10
    }
  },

  "final": {
    "status": "COMPLETED|FAILED_WF_XX|COMPLETED_DRY_RUN",
    "summary": "Pipeline completed successfully",
    "completed_at": "2024-01-15T15:30:00Z"
  },

  "audit": {
    "created_by": "wf-01",
    "updated_by": "wf-08",
    "change_log": [
      {
        "at": "2024-01-15T10:00:00Z",
        "by": "wf-01",
        "change": "step=init status=ok run_id=run123 mode=dry_run"
      }
    ]
  },

  "timestamps": {
    "created_at": "2024-01-15T10:00:00Z",
    "updated_at": "2024-01-15T15:30:00Z",
    "phase": "ideation|research|script_draft|script_approved|voiceover_ready|assets_ready|render_ready|published|failed_wf_XX"
  }
}
```

## Sahələr və Qaydalar

### manifest_version
- **Dəyər**: `"2.0"`
- Dəyişməzdir və bütün workflow-larda eyni saxlanılır.

### topic
| Sahə | Tip | Məcburi | Təsvir |
|------|-----|---------|--------|
| title | string | Bəli | Video mövzusunun başlığı |
| category | string | Bəli | YouTube kategoriyası |
| language | string | Bəli | ISO 639-1 kodu |
| keywords | string[] | Bəli | Açar sözlər massivi |
| summary | string | Xeyr | Qısa məzmun təsviri |
| source_references | object[] | Xeyr | Mənbələr siyahısı |

### script
| Sahə | Tip | Məcburi | Təsvir |
|------|-----|---------|--------|
| draft | string | Xeyr | WF-03 tərəfindən yaradılan ilkin ssenari |
| approved | string | Xeyr | WF-04 tərəfindən təsdiqlənmiş ssenari |
| review_notes | string[] | Xeyr | Rəy qeydləri |
| last_reviewed_at | ISO-8601 | Xeyr | Son rəy tarixi |

### assets.items (Asset metadata)
| Sahə | Tip | Məcburi | Təsvir |
|------|-----|---------|--------|
| asset_id | string | Bəli | Unikal asset ID |
| type | string | Bəli | video və ya image |
| source | string | Bəli | pexels_video, pexels_photo, dalle_generated |
| source_url | string | Bəli | Orijinal mənbə URL-i |
| local_path | string | Bəli | Yerli fayl yolu |
| duration_sec | number | Bəli | Asset müddəti |
| license | string | Bəli | Lisenziya |

### render
| Sahə | Tip | Məcburi | Təsvir |
|------|-----|---------|--------|
| resolution | string | Bəli | 1920x1080 |
| fps | number | Bəli | Frame per second |
| render_id | string | Xeyr | Render job ID |
| render_status | string | Xeyr | Render statusu |
| render_url | string | Xeyr | Final video URL-i |

### publish
| Sahə | Tip | Məcburi | Təsvir |
|------|-----|---------|--------|
| channel_id | string | Bəli | YouTube channel ID |
| title | string | Bəli | YouTube video başlığı |
| privacy | string | Bəli | public, unlisted, private |
| youtube_video_id | string | Xeyr | Yüklənmiş video ID-si |
| publish_status | string | Xeyr | Yayım statusu |

### timestamps.phase dəyərləri
- ideation - İlkin mərhələ
- research - Mənbə araşdırması (WF-02)
- script_draft - Ssenari yazılıb (WF-03)
- script_approved - Ssenari təsdiqlənib (WF-04)
- voiceover_ready - Voiceover hazırdır (WF-05)
- assets_ready - Asset-lər hazırdır (WF-06)
- render_ready - Render tamamlandı (WF-07)
- published - YouTube-da yayımlandı (WF-08)
- failed_wf_XX - Xəta baş verdi

## Asset Seçim Prioriteti (WF-06)

1. Pexels VIDEO (Birinci prioritet)
2. Pexels PHOTO (İkinci prioritet)
3. DALL-E (Son fallback)

## API Key Referansları

| Key | Env Variable | resolved_config path |
|-----|--------------|---------------------|
| OpenAI | OPENAI_API_KEY | resolved_config.openai.api_key |
| ElevenLabs | ELEVENLABS_API_KEY | resolved_config.tts.api_key |
| Pexels | PEXELS_API_KEY | resolved_config.pexels.api_key |
| Shotstack | SHOTSTACK_API_KEY | resolved_config.render.api_key |
| YouTube | YOUTUBE_REFRESH_TOKEN | resolved_config.publish.credentials |
