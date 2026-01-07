# Manifest Spesifikasiyası

## Məqsəd
Manifest video istehsalının bütün metadata və statuslarını saxlayan əsas strukturudur. Bu sənəd manifest-in dəqiq strukturunu müəyyən edir.

## Manifest strukturu
```json
{
  "manifest_version": "2.0",
  "project": {
    "title": "",
    "language": "az",
    "category": "",
    "created_at": ""
  },
  "content": {
    "topic": "",
    "keywords": [],
    "summary": "",
    "script": "",
    "sources": [
      {
        "title": "",
        "url": "",
        "license": ""
      }
    ]
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
      "theme": "",
      "aspect_ratio": "16:9",
      "palette": []
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
    "last_updated": "",
    "checks": {
      "script_reviewed": false,
      "voiceover_ready": false,
      "assets_ready": false,
      "render_ready": false,
      "published": false
    }
  }
}
```

## Sahələr və qaydalar
### manifest_version
- Dəyər: `2.0`
- Dəyişməzdir və bütün workflow-larda eyni saxlanılır.

### project
- `title`: video layihəsinin adı.
- `language`: ISO 639-1 (`az`, `en`, `tr`).
- `category`: YouTube kategoriya adı.
- `created_at`: ISO-8601 formatı.

### content
- `topic`: video mövzusu.
- `keywords`: açar sözlər siyahısı.
- `summary`: qısa məzmun təsviri.
- `script`: tam ssenari məzmunu.
- `sources`: mənbələr siyahısı (title, url, license).

### production
- `voiceover`: səs parametrləri.
- `visual_style`: tema və rəng palitrası.
- `render`: render parametrləri.

### publication
- `channel_id`: YouTube channel ID.
- `title`: YouTube title.
- `description`: YouTube description.
- `tags`: YouTube tags.
- `privacy`: `public`, `unlisted`, `private`.
- `scheduled_at`: ISO-8601 və ya `null`.

### status
- `phase`: cari mərhələ (`ideation`, `research`, `script_draft`, `script_approved`, `voiceover_ready`, `assets_ready`, `rendering`, `render_ready`, `published`).
- `last_updated`: statusun son yenilənmə vaxtı.
- `checks`: boolean flag-lar.
