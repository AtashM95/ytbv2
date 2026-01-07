# WF-10 Get Config Spesifikasiyası

## Məqsəd
WF-10 bütün workflow-lar üçün vahid formatda konfiqurasiya qaytarır. Config resolve edilir və workflow-lar vahid çıxış formatından istifadə edir.

## Behavior
1. `environment` dəyərinə əsasən config DB/Data Table-dan aktiv entries toplanır.
2. `credential_ref` dəyərləri açılmır; yalnız referans qaytarılır.
3. Default-lar tətbiq edilir və çıxış formatı standartlaşdırılır.
4. Log-larda secret dəyəri yoxdur.

## Output format
WF-10 çıxışı aşağıdakı formatdadır (bütün workflow-lara eyni):

```json
{
  "environment": "production",
  "settings": {
    "youtube": {
      "channel_id": "channel_987",
      "privacy_default": "public",
      "api_credentials": {
        "type": "credential_ref",
        "ref": "cred_youtube_api"
      }
    },
    "storage": {
      "base_url": "https://storage.example.com",
      "signing_key": {
        "type": "credential_ref",
        "ref": "cred_storage_signing"
      }
    },
    "tts": {
      "provider": "acme-tts",
      "api_key": {
        "type": "credential_ref",
        "ref": "cred_tts_api"
      }
    },
    "render": {
      "endpoint": "https://render.example.com",
      "api_key": {
        "type": "credential_ref",
        "ref": "cred_render_api"
      }
    },
    "branding": {
      "default_tags": ["elm", "maarif", "azərbaycanca"]
    }
  },
  "resolved_at": "2025-01-10T12:00:00Z",
  "schema_version": "1.0"
}
```

## Error handling
- Config DB bağlantısı uğursuz olarsa `config_unavailable` statusu qaytarılır.
- Əgər required key-lər yoxdursa `config_incomplete` statusu qaytarılır.
- Credential provider unreachable olduqda WF-10 yalnız `credential_ref` qaytarır və warning log yazır.

## Integration qaydaları
- WF-01…WF-08 hər işə başlamazdan əvvəl WF-10 çağırmalıdır.
- WF-09 yalnız config yazır, WF-10 isə oxuyur və normalizasiya edir.
- WF-10 çıxışı contract-lardan asılı deyil, lakin bütün workflow-lar bu çıxışı istifadə edir.
