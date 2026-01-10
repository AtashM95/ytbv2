# WF-10 Config Manager / Get Config Spesifikasiyası

## Məqsəd
WF-10 bütün workflow-lar üçün vahid formatda konfiqurasiya qaytarır. Config resolve edilir və workflow-lar vahid çıxış formatından istifadə edir.

## Behavior
1. `environment` dəyərinə əsasən config DB/Data Table-dan aktiv entries toplanır.
2. Əvvəl `scope=global`, sonra `scope=channel` (channel_key uyğun olduqda) override edilir.
3. `credential_ref` və `env_ref` dəyərləri açılmır; yalnız referans qaytarılır.
4. Default-lar tətbiq edilir və çıxış formatı standartlaşdırılır.

## Output format
WF-10 çıxışı aşağıdakı formatdadır (bütün workflow-lara eyni):

```json
{
  "environment": "production",
  "scope": "global",
  "channel_key": null,
  "resolved_config": {
    "storage": {
      "provider": "cloudinary",
      "cloudinary": {
        "cloud_name": "demo",
        "upload_preset": "ytb_unsigned",
        "api_key_ref": { "type": "env_ref", "ref": "CLOUDINARY_API_KEY" },
        "api_secret_ref": { "type": "env_ref", "ref": "CLOUDINARY_API_SECRET" }
      }
    }
  },
  "resolved_at": "2025-01-10T12:00:00Z",
  "schema_version": "2.0",
  "storage_validation": {
    "status": "OK",
    "provider": "cloudinary",
    "missing_fields": []
  }
}
```

## Error handling
- Invalid environment/scope/channel_key → validation error.
- Production modda storage config əskikdirsə `FAILED_CONFIG_STORAGE` qaytarılır.
- Credential provider unreachable olduqda WF-10 yalnız `credential_ref` qaytarır və warning log yazır.

## Integration qaydaları
- WF-01…WF-08 hər işə başlamazdan əvvəl WF-10 çağırmalıdır.
- WF-11 yalnız config yazır, WF-10 isə oxuyur və normalizasiya edir.
- WF-10 çıxışı contract-lardan asılı deyil, lakin bütün workflow-lar bu çıxışı istifadə edir.
