# Contract Spesifikasiyası

## Ümumi prinsiplər
- Bütün workflow-lar standart contract strukturuna əsaslanır.
- Contract sahə adları dəyişməzdir: `run_id`, `mode`, `scene_assets`, `voiceover_url_signed`, `render_id`, `youtube_video_id`, `manifest`.
- Hər workflow yalnız lazım olan sahələri yazır və oxuyur, lakin struktur eynidir.

## Contract obyektləri
### 1) Run Contract (əsas payload)
**Məqsəd:** run-ın bütün istehsal vəziyyətini saxlayan mərkəzi payload.

**Sahələr:**
- `run_id` (string, required): Global unikal run identifikatoru.
- `mode` (string, required): İşləmə rejimi. Dəyərlər: `test`, `auto_trend`, `manual`.
- `scene_assets` (array, required): Səhnə asset-lərinin siyahısı.
- `voiceover_url_signed` (string, nullable): İmzalanmış voiceover URL-i.
- `render_id` (string, nullable): Render sistemində yaradılmış render ID.
- `youtube_video_id` (string, nullable): YouTube video ID.
- `manifest` (object, required): İstehsal manifest-i.

### 2) Scene Asset obyekti
**Məqsəd:** video səhnələrində istifadə olunan asset-in idarəsi.

**Sahələr:**
- `asset_id` (string, required): Asset ID.
- `type` (string, required): `image`, `video`, `audio`, `subtitle`, `overlay`.
- `source_url` (string, required): Orijinal source URL.
- `local_path` (string, required): Lokal storage path.
- `checksum_sha256` (string, required): Asset tamlığı üçün checksum.
- `duration_sec` (number, required): Asset müddəti.
- `metadata` (object, required): əlavə metadata (license, attribution, tags).

### 3) Manifest obyekti
Manifest strukturu `docs/06_manifest_spec.md` sənədində dəqiq təyin edilib.

## JSON Schema (Run Contract)
```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://ytb-helal-automation.local/schemas/run-contract.json",
  "title": "RunContract",
  "type": "object",
  "required": [
    "run_id",
    "mode",
    "scene_assets",
    "manifest"
  ],
  "additionalProperties": false,
  "properties": {
    "run_id": {
      "type": "string",
      "minLength": 8,
      "description": "Global unikal run identifikatoru"
    },
    "mode": {
      "type": "string",
      "enum": ["test", "auto_trend", "manual"],
      "description": "İşləmə rejimi"
    },
    "scene_assets": {
      "type": "array",
      "minItems": 0,
      "items": {
        "type": "object",
        "required": [
          "asset_id",
          "type",
          "source_url",
          "local_path",
          "checksum_sha256",
          "duration_sec",
          "metadata"
        ],
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
            "additionalProperties": true,
            "properties": {
              "license": {"type": "string"},
              "attribution": {"type": "string"},
              "tags": {
                "type": "array",
                "items": {"type": "string"}
              }
            }
          }
        }
      }
    },
    "voiceover_url_signed": {
      "type": ["string", "null"],
      "format": "uri",
      "description": "İmzalanmış voiceover URL"
    },
    "render_id": {
      "type": ["string", "null"],
      "description": "Render sistemində yaradılmış ID"
    },
    "youtube_video_id": {
      "type": ["string", "null"],
      "description": "YouTube video ID"
    },
    "manifest": {
      "$ref": "https://ytb-helal-automation.local/schemas/manifest.json"
    }
  }
}
```

## JSON Nümunə 1 — Yeni run
```json
{
  "run_id": "run_20250105_0001",
  "mode": "staging",
  "scene_assets": [],
  "voiceover_url_signed": null,
  "render_id": null,
  "youtube_video_id": null,
  "manifest": {
    "manifest_version": "2.0",
    "project": {
      "title": "Faydalı Elm Faktları",
      "language": "az",
      "category": "education",
      "created_at": "2025-01-05T10:00:00Z"
    },
    "content": {
      "topic": "Kosmosda vaxtın nisbiliyi",
      "keywords": ["kosmos", "relativlik", "elm"],
      "summary": "Qısa, maarifləndirici video üçün ideya",
      "script": "",
      "sources": []
    },
    "production": {
      "voiceover": {
        "provider": "",
        "voice_id": "",
        "speed": 1.0,
        "pitch": 0.0,
        "output_format": "mp3"
      },
      "visual_style": {
        "theme": "minimal",
        "aspect_ratio": "16:9",
        "palette": ["#0B1F3A", "#F5C518", "#FFFFFF"]
      },
      "render": {
        "resolution": "1920x1080",
        "fps": 30,
        "codec": "h264",
        "bitrate_kbps": 8000
      }
    },
    "publication": {
      "channel_id": "",
      "title": "",
      "description": "",
      "tags": [],
      "privacy": "unlisted",
      "scheduled_at": null
    },
    "status": {
      "phase": "ideation",
      "last_updated": "2025-01-05T10:00:00Z",
      "checks": {
        "script_reviewed": false,
        "voiceover_ready": false,
        "assets_ready": false,
        "render_ready": false,
        "published": false
      }
    }
  }
}
```

## JSON Nümunə 2 — Render mərhələsində run
```json
{
  "run_id": "run_20250106_0007",
  "mode": "production",
  "scene_assets": [
    {
      "asset_id": "asset_0001",
      "type": "image",
      "source_url": "https://cdn.example.com/source/nebula.jpg",
      "local_path": "/mnt/assets/run_20250106_0007/nebula.jpg",
      "checksum_sha256": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
      "duration_sec": 4.5,
      "metadata": {
        "license": "CC-BY-4.0",
        "attribution": "NASA",
        "tags": ["nebula", "space", "image"]
      }
    }
  ],
  "voiceover_url_signed": "https://storage.example.com/voiceover/run_20250106_0007.mp3?sig=abc123",
  "render_id": "render_9c3f1f",
  "youtube_video_id": null,
  "manifest": {
    "manifest_version": "2.0",
    "project": {
      "title": "Kosmosda Zaman",
      "language": "az",
      "category": "education",
      "created_at": "2025-01-06T09:10:00Z"
    },
    "content": {
      "topic": "Zamanın elastikliyi",
      "keywords": ["zaman", "kosmos", "relativlik"],
      "summary": "Relativlik nəzəriyyəsinin qısa izahı",
      "script": "Ssenari tam yazılıb və təsdiqlənib.",
      "sources": [
        {
          "title": "Relativity Overview",
          "url": "https://example.org/relativity",
          "license": "CC-BY-4.0"
        }
      ]
    },
    "production": {
      "voiceover": {
        "provider": "acme-tts",
        "voice_id": "az-01",
        "speed": 1.0,
        "pitch": -0.1,
        "output_format": "mp3"
      },
      "visual_style": {
        "theme": "modern",
        "aspect_ratio": "16:9",
        "palette": ["#111827", "#F59E0B", "#F9FAFB"]
      },
      "render": {
        "resolution": "1920x1080",
        "fps": 30,
        "codec": "h264",
        "bitrate_kbps": 9000
      }
    },
    "publication": {
      "channel_id": "channel_123",
      "title": "Kosmosda Zaman Nisbiliyi",
      "description": "Relativlik nəzəriyyəsi haqqında qısa video",
      "tags": ["elm", "kosmos"],
      "privacy": "public",
      "scheduled_at": null
    },
    "status": {
      "phase": "rendering",
      "last_updated": "2025-01-06T12:05:00Z",
      "checks": {
        "script_reviewed": true,
        "voiceover_ready": true,
        "assets_ready": true,
        "render_ready": false,
        "published": false
      }
    }
  }
}
```

## JSON Nümunə 3 — Nəşr olunmuş run
```json
{
  "run_id": "run_20250107_0012",
  "mode": "production",
  "scene_assets": [
    {
      "asset_id": "asset_0100",
      "type": "video",
      "source_url": "https://cdn.example.com/source/galaxy.mp4",
      "local_path": "/mnt/assets/run_20250107_0012/galaxy.mp4",
      "checksum_sha256": "1f40fc92da241694750979ee6cf582f2d5d7d28e18335de05abc54d0560e0f53",
      "duration_sec": 12.0,
      "metadata": {
        "license": "CC0",
        "attribution": "ESA",
        "tags": ["galaxy", "space", "video"]
      }
    }
  ],
  "voiceover_url_signed": "https://storage.example.com/voiceover/run_20250107_0012.mp3?sig=def456",
  "render_id": "render_7af21c",
  "youtube_video_id": "yt_9a8b7c6",
  "manifest": {
    "manifest_version": "2.0",
    "project": {
      "title": "Qara Dəliklər",
      "language": "az",
      "category": "science",
      "created_at": "2025-01-07T08:00:00Z"
    },
    "content": {
      "topic": "Qara dəliklərin quruluşu",
      "keywords": ["qara dəlik", "astronomiya"],
      "summary": "Maraqlı faktlar və izahlar",
      "script": "Ssenari təsdiqlənib və istifadə edilib.",
      "sources": [
        {
          "title": "Black Holes",
          "url": "https://example.org/black-holes",
          "license": "CC-BY-SA-4.0"
        }
      ]
    },
    "production": {
      "voiceover": {
        "provider": "acme-tts",
        "voice_id": "az-02",
        "speed": 0.95,
        "pitch": 0.0,
        "output_format": "mp3"
      },
      "visual_style": {
        "theme": "cinematic",
        "aspect_ratio": "16:9",
        "palette": ["#000000", "#F97316", "#E5E7EB"]
      },
      "render": {
        "resolution": "1920x1080",
        "fps": 24,
        "codec": "h264",
        "bitrate_kbps": 8500
      }
    },
    "publication": {
      "channel_id": "channel_987",
      "title": "Qara Dəliklər: Qısa İzah",
      "description": "Qara dəliklər haqqında maarifləndirici video",
      "tags": ["elm", "astronomiya"],
      "privacy": "public",
      "scheduled_at": "2025-01-08T18:00:00Z"
    },
    "status": {
      "phase": "published",
      "last_updated": "2025-01-08T18:05:00Z",
      "checks": {
        "script_reviewed": true,
        "voiceover_ready": true,
        "assets_ready": true,
        "render_ready": true,
        "published": true
      }
    }
  }
}
```
