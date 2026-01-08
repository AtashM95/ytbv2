# Manifest Spesifikasiyası v2.0

## Məqsəd
Manifest video istehsalının bütün metadata və statuslarını saxlayan əsas strukturudur. Bu sənəd manifest-in dəqiq strukturunu müəyyən edir.

## Tam Manifest Strukturu

```json
{
  "manifest_version": "2.0",
  "topic": {
    "title": "",
    "category": "",
    "language": "az",
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
      {
        "scene": 1,
        "description": "",
        "duration_sec": 0.0
      }
    ],
    "items": [
      {
        "asset_id": "",
        "type": "image",
        "source_url": "",
        "local_path": "",
        "checksum_sha256": "",
        "duration_sec": 0.0,
        "metadata": {
          "license": "",
          "attribution": "",
          "tags": []
        }
      }
    ],
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
      {
        "at": "",
        "by": "",
        "change": ""
      }
    ]
  },
  "timestamps": {
    "created_at": "",
    "updated_at": "",
    "phase": "ideation"
  }
}
```

## Sahələr və Qaydalar

### manifest_version
- **Dəyər**: `2.0`
- **Dəyişməzdir** və bütün workflow-larda eyni saxlanılır.

---

### topic
Video mövzusu haqqında əsas məlumatlar.

| Sahə | Tip | Məcburi | Təsvir |
|------|-----|---------|--------|
| `title` | string | ✓ | Video layihəsinin adı |
| `category` | string | ✓ | YouTube kategoriya adı (education, entertainment, etc.) |
| `language` | string | ✓ | ISO 639-1 kodu (`az`, `en`, `tr`) |
| `keywords` | array | ✓ | Açar sözlər siyahısı |
| `summary` | string | ✓ | Qısa məzmun təsviri |
| `source_references` | array | ✗ | İstifadə edilən mənbələr |

#### source_references elementi
```json
{
  "title": "Mənbə başlığı",
  "url": "https://example.com/source",
  "license": "CC-BY-4.0"
}
```

---

### script
Ssenari mərhələsi məlumatları.

| Sahə | Tip | Məcburi | Təsvir |
|------|-----|---------|--------|
| `draft` | string | ✗ | WF-03 tərəfindən yaradılan ilkin ssenari |
| `approved` | string | ✗ | WF-04 tərəfindən təsdiqlənmiş ssenari |
| `review_notes` | array | ✗ | Rəy qeydləri siyahısı |
| `last_reviewed_at` | string/null | ✗ | Son rəy tarixi (ISO-8601) |

---

### assets
Video aktivləri (şəkillər, voiceover).

#### scene_plan elementi
```json
{
  "scene": 1,
  "description": "Səhnə təsviri",
  "duration_sec": 6.0
}
```

#### items elementi (asset)
```json
{
  "asset_id": "asset_run_xxx_001",
  "type": "image",
  "source_url": "https://cdn.example.com/image.png",
  "local_path": "/mnt/assets/run_xxx/image.png",
  "checksum_sha256": "e3b0c44298fc1c149afbf4c8996fb924...",
  "duration_sec": 6.0,
  "metadata": {
    "license": "CC-BY-4.0",
    "attribution": "Source Name",
    "tags": ["tag1", "tag2"]
  }
}
```

#### voiceover
| Sahə | Tip | Default | Təsvir |
|------|-----|---------|--------|
| `provider` | string | "" | TTS provider adı (elevenlabs, acme-tts) |
| `voice_id` | string | "" | Səs identifikatoru |
| `speed` | number | 1.0 | Səs sürəti |
| `pitch` | number | 0.0 | Səs tonu |
| `output_format` | string | "mp3" | Çıxış formatı |
| `voiceover_url_signed` | string/null | null | İmzalanmış audio URL |

---

### render
Video render parametrləri.

| Sahə | Tip | Default | Təsvir |
|------|-----|---------|--------|
| `resolution` | string | "1920x1080" | Video həlli |
| `fps` | number | 30 | Kadr sürəti |
| `codec` | string | "h264" | Video codec |
| `bitrate_kbps` | number | 8000 | Bitrate (kbps) |
| `render_id` | string/null | null | Render job ID |
| `render_status` | string | "not_started" | Status (not_started, rendering, completed, failed) |

---

### publish
YouTube publish parametrləri.

| Sahə | Tip | Default | Təsvir |
|------|-----|---------|--------|
| `channel_id` | string | "" | YouTube channel ID |
| `title` | string | "" | Video başlığı |
| `description` | string | "" | Video təsviri |
| `tags` | array | [] | Video etiketləri |
| `privacy` | string | "unlisted" | `public`, `unlisted`, `private` |
| `scheduled_at` | string/null | null | Planlaşdırılmış vaxt (ISO-8601) |
| `youtube_video_id` | string/null | null | Upload sonrası video ID |
| `publish_status` | string | "not_published" | Status |

---

### analytics
Analitika konfiqurasiyası.

| Sahə | Tip | Default | Təsvir |
|------|-----|---------|--------|
| `enabled` | boolean | true | Analitika aktiv? |
| `tracking_tags` | array | [] | İzləmə etiketləri |
| `first_publish_at` | string/null | null | İlk publish tarixi |
| `last_metrics_pull_at` | string/null | null | Son metrik çəkilmə tarixi |
| `metrics` | object | {} | Metrik məlumatları |

---

### final
Son nəticə məlumatları.

| Sahə | Tip | Təsvir |
|------|-----|--------|
| `status` | string | Son status (COMPLETED, FAILED, etc.) |
| `summary` | string | Xülasə mesajı |
| `completed_at` | string/null | Tamamlanma tarixi |

---

### audit
Dəyişiklik izləmə.

| Sahə | Tip | Təsvir |
|------|-----|--------|
| `created_by` | string | Yaradan workflow (wf-01) |
| `updated_by` | string | Son yeniləyən workflow |
| `change_log` | array | Dəyişiklik tarixçəsi |

#### change_log elementi
```json
{
  "at": "2025-02-01T09:00:00Z",
  "by": "wf-01",
  "change": "step=init status=ok run_id=run_xxx mode=dry_run"
}
```

---

### timestamps
Zaman damğaları və mərhələ.

| Sahə | Tip | Təsvir |
|------|-----|--------|
| `created_at` | string | Yaradılma tarixi (ISO-8601) |
| `updated_at` | string | Son yenilənmə tarixi |
| `phase` | string | Cari mərhələ |

#### Mərhələlər (phase)
1. `ideation` - İlkin fikir mərhələsi
2. `research` - Araşdırma (WF-02)
3. `script_draft` - Ssenari layihəsi (WF-03)
4. `script_approved` - Ssenari təsdiqi (WF-04)
5. `voiceover_ready` - Voiceover hazır (WF-05)
6. `assets_ready` - Aktivlər hazır (WF-06)
7. `rendering` - Render prosesi
8. `render_ready` - Render hazır (WF-07)
9. `published` - YouTube-da yayımlandı (WF-08)
10. `failed_*` - Xəta mərhələləri (failed_wf_02, failed_wf_03, etc.)

---

## Workflow Contract Strukturu

Hər workflow arasında ötürülən əsas contract:

```json
{
  "run_id": "run_20250201_0001",
  "mode": "dry_run|staging|production",
  "scene_assets": [],
  "voiceover_url_signed": null,
  "render_id": null,
  "youtube_video_id": null,
  "manifest": { /* Tam manifest */ },
  "resolved_config": { /* WF-10-dan gələn config */ },
  "environment": "staging",
  "scope": "global|channel|workflow|run",
  "channel_id": null,
  "runtime_overrides": {},
  "status": "IN_PROGRESS|COMPLETED|FAILED_*",
  "halt": false
}
```

---

## Resolved Config Strukturu

WF-10 tərəfindən qaytarılan konfiqurasiya:

```json
{
  "environment": "staging",
  "publish": {
    "publish_enabled": true,
    "privacy_default": "unlisted",
    "channel_id": "",
    "credentials": {
      "type": "credential_ref",
      "ref": "youtube_oauth2"
    }
  },
  "storage": {
    "base_url": "https://storage.example.com",
    "signing_key": {
      "type": "credential_ref",
      "ref": "storage_signing"
    },
    "asset_bucket": "ytb-assets"
  },
  "openai": {
    "api_key": {
      "type": "credential_ref",
      "ref": "openai_api"
    },
    "model": "gpt-4o-mini",
    "max_tokens": 2000
  },
  "tts": {
    "provider": "elevenlabs",
    "api_key": {
      "type": "credential_ref",
      "ref": "elevenlabs_api"
    },
    "model": "eleven_multilingual_v2",
    "default_voice_id": "pNInz6obpgDQGcFmaJgB"
  },
  "image_gen": {
    "provider": "dalle",
    "api_key": {
      "type": "credential_ref",
      "ref": "openai_api"
    },
    "model": "dall-e-3",
    "size": "1792x1024",
    "quality": "standard"
  },
  "render": {
    "provider": "shotstack",
    "api_key": {
      "type": "credential_ref",
      "ref": "shotstack_api"
    },
    "endpoint": "https://api.shotstack.io/v1",
    "timeout_sec": 1800
  },
  "branding": {
    "default_tags": ["elm", "maarif", "azərbaycanca"],
    "channel_name": "Helal Elm"
  },
  "runtime": {
    "dry_run": false,
    "publish_off": false
  },
  "n8n": {
    "base_url": "https://n8n.example.com"
  }
}
```
