# WF-11 Settings Panel Spesifikasiyası

## Məqsəd
WF-11 Settings Panel sistemin bütün konfiqurasiyalarını idarə edir. Bu workflow config DB/Data Table üzərindən işləyir və secrets yalnız credentials/ENV referansları kimi saxlanılır.

## Əsas prinsiplər
- Secrets plain text kimi DB-də saxlanılmır.
- Secrets yalnız credentials provider-də (məsələn n8n Credentials) və ya ENV referanslarında saxlanılır.
- DB/Data Table yalnız non-secret metadata və referansları saxlayır.

## Config DB/Data Table Sxemi
**Table adı:** `yt_studio_config`

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| id | string (uuid) | yes | Unikal setting ID |
| key | string | yes | Setting açarı (məs. `youtube.channel_id`) |
| value | string | no | Non-secret dəyər (secret olmamalıdır) |
| value_type | string | yes | `string`, `number`, `boolean`, `json`, `credential_ref`, `env_ref` |
| credential_ref | string | no | Credentials provider-də saxlanan secret ID-si |
| env_ref | string | no | ENV variable referansı |
| scope | string | yes | `global`, `channel` |
| environment | string | yes | `test`, `production` |
| channel_key | string | no | `scope=channel` üçün unique channel identifier |
| notes | string | no | Əlavə qeyd |
| updated_by | string | no | Dəyişiklik edən istifadəçi |
| updated_at | string | no | Son dəyişiklik zamanı |
| scope | string | yes | `global`, `channel` |
| environment | string | yes | `test`, `production` |
| notes | string | no | Əlavə qeyd |
| updated_by | string | no | Dəyişiklik edən istifadəçi |
| is_active | boolean | yes | Aktivlik statusu |

## Credentials policy
- `credential_ref` yalnız `value_type = credential_ref` olduqda istifadə edilir.
- `env_ref` yalnız `value_type = env_ref` olduqda istifadə edilir.
- WF-11 heç bir halda credential dəyərini plain text qaytarmır.
- Log-larda credential ID-ləri maskalanır.

## WF-11 Input/Output
### Input
- Admin UI vasitəsilə form submissions
- Import/Export üçün JSON payload

### Output
- Yalnız config DB/Data Table üzərində dəyişikliklər
- Audit log entries (əgər audit sistemi aktivdirsə)

## Valid settings (nümunə siyahı)
- `publish.default_category_id` (string)
- `storage.provider` (string)
- `storage.base_url` (string)
- `storage.cloudinary.cloud_name` (string)
- `storage.cloudinary.upload_preset` (string)
- `storage.cloudinary.api_key_ref` (env_ref)
- `storage.generic_http.upload_endpoint` (string)
- `tts.model` (string)
- `tts.voices` (json)
- `render.endpoint` (string)
- `render.default_resolution` (string)
- `openai.model` (string)
- `youtube.credential_ref` (credential_ref)

## WF-11 Error handling
- Validasiyada `value_type` mismatch olduqda request rədd edilir.
- `credential_ref` olmayan key üçün secret dəyəri daxil edilərsə rədd edilir.
- Mühit (`environment`) uyğun olmadıqda update bloklanır.

## Audit
- Hər update `updated_by` və `updated_at` ilə log edilə bilər.
- Hər update `updated_by` ilə log edilə bilər.

## Security
- UI yalnız authorized admin istifadəçilərə açıqdır.
