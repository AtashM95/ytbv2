# WF-10 Config Manager / Get Config Spesifikasiyası

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
  "resolved_config": {
    "youtube": {
      "channel_id": "channel_987",
      "privacy_default": "public",
      "api_credentials": {
        "type": "credential_ref",
        "ref": "cred_youtube_api"
      }
    },
    "storage": {
      "provider": "cloudinary",
      "base_url": "https://cdn.example.com",
      "cloudinary": {
        "cloud_name": "demo",
        "upload_preset": "ytb_unsigned",
        "api_key_ref": { "type": "env", "ref": "CLOUDINARY_API_KEY" },
        "api_secret_ref": { "type": "env", "ref": "CLOUDINARY_API_SECRET" }
      },
      "generic_http": {
        "upload_endpoint": "https://my-uploader/upload",
        "auth_header_ref": { "type": "env", "ref": "STORAGE_AUTH_HEADER" }
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
  "config_resolved_at": "2025-01-10T12:00:00Z",
  "schema_version": "2.0"
}
```

## Error handling
- Config DB bağlantısı uğursuz olarsa `config_unavailable` statusu qaytarılır.
- Production modda storage config əskikdirsə `FAILED_CONFIG_STORAGE` qaytarılır.
- Credential provider unreachable olduqda WF-10 yalnız `credential_ref` qaytarır və warning log yazır.

## Integration qaydaları
- WF-01…WF-08 hər işə başlamazdan əvvəl WF-10 çağırmalıdır.
- WF-11 yalnız config yazır, WF-10 isə oxuyur və normalizasiya edir.
- WF-10 çıxışı contract-lardan asılı deyil, lakin bütün workflow-lar bu çıxışı istifadə edir.
