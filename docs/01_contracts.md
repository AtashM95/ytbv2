# Contract Spesifikasiyası

## Contract invariants
Aşağıdakı sahə adları dəyişməzdir və bütün sənədlərdə eyni qalmalıdır:
- `run_id`
- `mode`
- `scene_assets`
- `voiceover_url_signed`
- `render_id`
- `youtube_video_id`
- `manifest`

## Run Contract (əsas payload)
**Məqsəd:** run-ın bütün istehsal vəziyyətini saxlayan mərkəzi payload.

| Field | Type | Required | Description | Producer WF | Consumer WF |
| --- | --- | --- | --- | --- | --- |
| run_id | string | yes | Unikal run identifikatoru | WF-01 | WF-02…WF-10 |
| mode | string | yes | `dry_run`, `staging`, `production` | WF-01 | WF-02…WF-10 |
| scene_assets | array | yes | Scene asset siyahısı | WF-06 | WF-07, WF-08 |
| voiceover_url_signed | string/null | no | Signed voiceover URL | WF-05 | WF-06, WF-07 |
| render_id | string/null | no | Render job ID | WF-07 | WF-08 |
| youtube_video_id | string/null | no | YouTube video ID | WF-08 | WF-08, Audit |
| manifest | object | yes | SSOT manifest | WF-01…WF-08 | WF-01…WF-10 |

## Scene Asset obyekti
| Field | Type | Required | Description |
| --- | --- | --- | --- |
| asset_id | string | yes | Asset ID |
| type | string | yes | `image`, `video`, `audio`, `subtitle`, `overlay` |
| source_url | string | yes | Orijinal source URL |
| local_path | string | yes | Lokal storage path |
| checksum_sha256 | string | yes | SHA256 checksum (64 hex) |
| duration_sec | number | yes | Asset müddəti |
| metadata | object | yes | License, attribution, tags |

## JSON Schema (Run Contract)
```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://ytb-helal-automation.local/schemas/run-contract.json",
  "title": "RunContract",
  "type": "object",
  "required": ["run_id", "mode", "scene_assets", "manifest"],
  "additionalProperties": false,
  "properties": {
    "run_id": {"type": "string", "minLength": 8},
    "mode": {"type": "string", "enum": ["dry_run", "staging", "production"]},
    "scene_assets": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["asset_id", "type", "source_url", "local_path", "checksum_sha256", "duration_sec", "metadata"],
        "additionalProperties": false,
        "properties": {
          "asset_id": {"type": "string"},
          "type": {"type": "string", "enum": ["image", "video", "audio", "subtitle", "overlay"]},
          "source_url": {"type": "string", "format": "uri"},
          "local_path": {"type": "string"},
          "checksum_sha256": {"type": "string", "pattern": "^[a-f0-9]{64}$"},
          "duration_sec": {"type": "number", "minimum": 0},
          "metadata": {
            "type": "object",
            "required": ["license", "attribution", "tags"],
            "properties": {
              "license": {"type": "string"},
              "attribution": {"type": "string"},
              "tags": {"type": "array", "items": {"type": "string"}}
            },
            "additionalProperties": true
          }
        }
      }
    },
    "voiceover_url_signed": {"type": ["string", "null"], "format": "uri"},
    "render_id": {"type": ["string", "null"]},
    "youtube_video_id": {"type": ["string", "null"]},
    "manifest": {"$ref": "https://ytb-helal-automation.local/schemas/manifest.json"}
  }
}
```

## JSON Nümunə 1 — new_run
```json
{
  "run_id": "run_20250201_0001",
  "mode": "staging",
  "scene_assets": [],
  "voiceover_url_signed": null,
  "render_id": null,
  "youtube_video_id": null,
  "manifest": {
    "manifest_version": "2.0",
    "topic": {
      "title": "Yer kürəsinin nəfəs aldığı kimi görünən hadisələr",
      "category": "education",
      "language": "az",
      "keywords": ["yer", "atmosfer", "elm"],
      "summary": "Qısa maarifləndirici video üçün ideya",
      "source_references": []
    },
    "script": {
      "draft": "",
      "approved": "",
      "review_notes": [],
      "last_reviewed_at": null
    },
    "assets": {
      "scene_plan": [],
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
    "audit": {
      "created_by": "wf-01",
      "updated_by": "wf-01",
      "change_log": [
        {
          "at": "2025-02-01T09:00:00Z",
          "by": "wf-01",
          "change": "run created"
        }
      ]
    },
    "timestamps": {
      "created_at": "2025-02-01T09:00:00Z",
      "updated_at": "2025-02-01T09:00:00Z",
      "phase": "ideation"
    }
  }
}
```

## JSON Nümunə 2 — rendered
```json
{
  "run_id": "run_20250202_0012",
  "mode": "production",
  "scene_assets": [
    {
      "asset_id": "asset_0401",
      "type": "image",
      "source_url": "https://cdn.example.com/source/clouds.png",
      "local_path": "/mnt/assets/run_20250202_0012/clouds.png",
      "checksum_sha256": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
      "duration_sec": 6.0,
      "metadata": {
        "license": "CC-BY-4.0",
        "attribution": "NOAA",
        "tags": ["clouds", "atmosphere", "image"]
      }
    }
  ],
  "voiceover_url_signed": "https://storage.example.com/voiceover/run_20250202_0012.mp3?sig=vo123",
  "render_id": "render_00ab91",
  "youtube_video_id": null,
  "manifest": {
    "manifest_version": "2.0",
    "topic": {
      "title": "Buludların yaranması",
      "category": "education",
      "language": "az",
      "keywords": ["bulud", "su dövranı", "atmosfer"],
      "summary": "Buludların necə yarandığını izah edən video",
      "source_references": [
        {
          "title": "Cloud Formation",
          "url": "https://example.org/clouds",
          "license": "CC-BY-4.0"
        }
      ]
    },
    "script": {
      "draft": "Ssenari yazılıb və təsdiq üçün hazırdır.",
      "approved": "Ssenari təsdiqlənib.",
      "review_notes": ["Terminlər sadələşdirildi"],
      "last_reviewed_at": "2025-02-02T11:00:00Z"
    },
    "assets": {
      "scene_plan": [
        {"scene": 1, "description": "Bulud şəkli", "duration_sec": 6.0}
      ],
      "items": [
        {
          "asset_id": "asset_0401",
          "type": "image",
          "source_url": "https://cdn.example.com/source/clouds.png",
          "local_path": "/mnt/assets/run_20250202_0012/clouds.png",
          "checksum_sha256": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
          "duration_sec": 6.0,
          "metadata": {
            "license": "CC-BY-4.0",
            "attribution": "NOAA",
            "tags": ["clouds", "atmosphere", "image"]
          }
        }
      ],
      "voiceover": {
        "provider": "acme-tts",
        "voice_id": "az-01",
        "speed": 1.0,
        "pitch": 0.0,
        "output_format": "mp3",
        "voiceover_url_signed": "https://storage.example.com/voiceover/run_20250202_0012.mp3?sig=vo123"
      }
    },
    "render": {
      "resolution": "1920x1080",
      "fps": 30,
      "codec": "h264",
      "bitrate_kbps": 9000,
      "render_id": "render_00ab91",
      "render_status": "completed"
    },
    "publish": {
      "channel_id": "channel_456",
      "title": "Buludlar Necə Yaranır?",
      "description": "Buludların yaranma prosesi haqqında qısa video",
      "tags": ["elm", "atmosfer"],
      "privacy": "public",
      "scheduled_at": null,
      "youtube_video_id": null,
      "publish_status": "not_published"
    },
    "analytics": {
      "enabled": true,
      "tracking_tags": ["foundation"],
      "first_publish_at": null,
      "last_metrics_pull_at": null,
      "metrics": {}
    },
    "audit": {
      "created_by": "wf-01",
      "updated_by": "wf-07",
      "change_log": [
        {"at": "2025-02-02T09:00:00Z", "by": "wf-01", "change": "run created"},
        {"at": "2025-02-02T11:00:00Z", "by": "wf-04", "change": "script approved"},
        {"at": "2025-02-02T13:00:00Z", "by": "wf-05", "change": "voiceover generated"},
        {"at": "2025-02-02T14:00:00Z", "by": "wf-06", "change": "assets prepared"},
        {"at": "2025-02-02T15:30:00Z", "by": "wf-07", "change": "render completed"}
      ]
    },
    "timestamps": {
      "created_at": "2025-02-02T09:00:00Z",
      "updated_at": "2025-02-02T15:30:00Z",
      "phase": "render_ready"
    }
  }
}
```

## JSON Nümunə 3 — published
```json
{
  "run_id": "run_20250203_0020",
  "mode": "production",
  "scene_assets": [
    {
      "asset_id": "asset_0801",
      "type": "video",
      "source_url": "https://cdn.example.com/source/earth.mp4",
      "local_path": "/mnt/assets/run_20250203_0020/earth.mp4",
      "checksum_sha256": "1f40fc92da241694750979ee6cf582f2d5d7d28e18335de05abc54d0560e0f53",
      "duration_sec": 10.0,
      "metadata": {
        "license": "CC0",
        "attribution": "ESA",
        "tags": ["earth", "rotation", "video"]
      }
    }
  ],
  "voiceover_url_signed": "https://storage.example.com/voiceover/run_20250203_0020.mp3?sig=vo789",
  "render_id": "render_4d129b",
  "youtube_video_id": "yt_final_20250203",
  "manifest": {
    "manifest_version": "2.0",
    "topic": {
      "title": "Yer kürəsinin fırlanması",
      "category": "science",
      "language": "az",
      "keywords": ["yer", "fırlanma", "astronomiya"],
      "summary": "Yer kürəsinin fırlanma mexanizmi haqqında video",
      "source_references": [
        {
          "title": "Earth Rotation",
          "url": "https://example.org/earth-rotation",
          "license": "CC-BY-SA-4.0"
        }
      ]
    },
    "script": {
      "draft": "Ssenari yazılıb.",
      "approved": "Ssenari təsdiqlənib və istifadə edilib.",
      "review_notes": ["Terminlər təsdiqləndi"],
      "last_reviewed_at": "2025-02-03T10:00:00Z"
    },
    "assets": {
      "scene_plan": [
        {"scene": 1, "description": "Yer kürəsinin fırlanması", "duration_sec": 10.0}
      ],
      "items": [
        {
          "asset_id": "asset_0801",
          "type": "video",
          "source_url": "https://cdn.example.com/source/earth.mp4",
          "local_path": "/mnt/assets/run_20250203_0020/earth.mp4",
          "checksum_sha256": "1f40fc92da241694750979ee6cf582f2d5d7d28e18335de05abc54d0560e0f53",
          "duration_sec": 10.0,
          "metadata": {
            "license": "CC0",
            "attribution": "ESA",
            "tags": ["earth", "rotation", "video"]
          }
        }
      ],
      "voiceover": {
        "provider": "acme-tts",
        "voice_id": "az-03",
        "speed": 1.0,
        "pitch": 0.0,
        "output_format": "mp3",
        "voiceover_url_signed": "https://storage.example.com/voiceover/run_20250203_0020.mp3?sig=vo789"
      }
    },
    "render": {
      "resolution": "1920x1080",
      "fps": 24,
      "codec": "h264",
      "bitrate_kbps": 8500,
      "render_id": "render_4d129b",
      "render_status": "completed"
    },
    "publish": {
      "channel_id": "channel_789",
      "title": "Yer Kürəsi Necə Fırlanır?",
      "description": "Yer kürəsinin fırlanması və gecə-gündüz dövranı",
      "tags": ["elm", "astronomiya"],
      "privacy": "public",
      "scheduled_at": "2025-02-03T19:00:00Z",
      "youtube_video_id": "yt_final_20250203",
      "publish_status": "published"
    },
    "analytics": {
      "enabled": true,
      "tracking_tags": ["publish"],
      "first_publish_at": "2025-02-03T19:05:00Z",
      "last_metrics_pull_at": "2025-02-03T19:30:00Z",
      "metrics": {
        "views": 0,
        "likes": 0,
        "comments": 0
      }
    },
    "audit": {
      "created_by": "wf-01",
      "updated_by": "wf-08",
      "change_log": [
        {"at": "2025-02-03T08:30:00Z", "by": "wf-01", "change": "run created"},
        {"at": "2025-02-03T10:00:00Z", "by": "wf-04", "change": "script approved"},
        {"at": "2025-02-03T12:00:00Z", "by": "wf-05", "change": "voiceover generated"},
        {"at": "2025-02-03T13:30:00Z", "by": "wf-06", "change": "assets prepared"},
        {"at": "2025-02-03T15:00:00Z", "by": "wf-07", "change": "render completed"},
        {"at": "2025-02-03T19:05:00Z", "by": "wf-08", "change": "published"}
      ]
    },
    "timestamps": {
      "created_at": "2025-02-03T08:30:00Z",
      "updated_at": "2025-02-03T19:05:00Z",
      "phase": "published"
    }
  }
}
```
