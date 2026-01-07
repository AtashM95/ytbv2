# WF-10 Get Config Spesifikasiyası

## Məqsəd
WF-10 konfiqurasiyanı defaults + DB + runtime overrides ilə resolve edir və bütün workflow-lara eyni formatda `resolved_config` obyektini qaytarır.

## Input
WF-10 kontrakt obyektini qəbul edir və aşağıdakı sahələri qoruyur:
- `run_id`
- `mode`
- `scene_assets`
- `voiceover_url_signed`
- `render_id`
- `youtube_video_id`
- `manifest`

Əlavə parametrlər:
- `environment` (`dry_run`, `staging`, `production`)
- `scope` (`global`, `channel`, `workflow`, `run`)
- `channel_id` (optional)
- `runtime_overrides` (object, optional) — yalnız həmin run üçün tətbiq olunur

## Resolve qaydası
1. **Defaults** — daxili default-lar yüklənir.
2. **DB** — `ytb_settings` cədvəlindən `environment` və `is_active = true` olan dəyərlər oxunur.
3. **Runtime overrides** — requestdə gələn override-lar tətbiq olunur.

Prioritet: `runtime_overrides` > `DB` > `defaults`.

## Fallback (no DB available)
- DB əlaqəsi yoxdursa və ya query nəticəsi boşdursa, WF-10 yalnız defaults ilə `resolved_config` hazırlayır.
- Bu halda `config_source = defaults` qeyd olunur və audit summary-də DB istifadəsi `false` olaraq görünür.

## Output
WF-10 çıxışı aşağıdakı standart strukturdadır:

```json
{
  "run_id": "run_20250210_0003",
  "mode": "staging",
  "scene_assets": [],
  "voiceover_url_signed": null,
  "render_id": null,
  "youtube_video_id": null,
  "manifest": null,
  "resolved_config": {
    "environment": "production",
    "publish": {
      "publish_enabled": true,
      "privacy_default": "public",
      "channel_id": "channel_789",
      "credentials": {
        "type": "credential_ref",
        "ref": "cred_youtube_api"
      }
    },
    "storage": {
      "base_url": "https://storage.example.com",
      "signing_key": {
        "type": "credential_ref",
        "ref": "cred_storage_signing"
      },
      "asset_bucket": "ytb-assets"
    },
    "tts": {
      "provider": "acme-tts",
      "api_key": {
        "type": "credential_ref",
        "ref": "cred_tts_api"
      },
      "default_voice_id": "az-01"
    },
    "render": {
      "endpoint": "https://render.example.com",
      "api_key": {
        "type": "credential_ref",
        "ref": "cred_render_api"
      },
      "timeout_sec": 1800
    },
    "branding": {
      "default_tags": ["elm", "maarif", "azərbaycanca"],
      "channel_name": "Helal Elm"
    },
    "runtime": {
      "dry_run": false,
      "publish_off": false
    }
  },
  "config_source": "defaults+db+override",
  "effective_config_summary": {
    "used_defaults": true,
    "used_db": true,
    "used_overrides": true,
    "scope": "global",
    "channel_id": "channel_789",
    "resolved_keys": ["publish", "storage", "tts", "render", "branding", "runtime"]
  },
  "resolved_at": "2025-02-01T12:00:00Z",
  "schema_version": "1.0"
}
```

## Error handling
- DB bağlantısı uğursuz olarsa `config_unavailable` statusu qaytarılır və defaults istifadə olunur.
- Required key-lər yoxdursa `config_incomplete` statusu qaytarılır.
- `environment` yanlış olarsa `invalid_environment` statusu qaytarılır.

## Security
- Secrets yalnız `credential_ref` kimi qaytarılır.
- WF-10 heç bir zaman plain text secret qaytarmır.
