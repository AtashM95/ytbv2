# WF-09 Settings Panel Spesifikasiyası

## Məqsəd
WF-09 Settings Panel config DB/Data Table üzərində konfiqurasiyanı idarə edir və secrets yalnız Credentials provider-də saxlanılır.

## WF-09 Form field-lər
| fieldName | Label | Type | Default | Validation |
| --- | --- | --- | --- | --- |
| environment | Environment | select | staging | `dry_run`, `staging`, `production` |
| key | Config Key | text |  | `^[a-z0-9_.-]+$`, min 3, max 120 |
| value_type | Value Type | select | string | `string`, `number`, `boolean`, `json`, `credential_ref` |
| value | Value | text/textarea |  | `value_type`-ə uyğun format |
| credential_ref | Credential Ref | text |  | `value_type = credential_ref` olduqda required |
| scope | Scope | select | global | `global`, `channel`, `workflow`, `run` |
| notes | Notes | textarea |  | max 500 |
| is_active | Active | boolean | true | boolean |
| change_reason | Change Reason | text |  | min 5, max 200 |
| dry_run | Dry Run | boolean | false | boolean |
| updated_by | Updated By | text | wf-09 | min 2, max 80 |
| run_id | Run ID | text |  | optional, min 8, max 64 |

## Config DB/Data Table schema
**Table adı:** `ytb_settings`

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| id | string (uuid) | yes | Unikal setting ID |
| key | string | yes | Setting açarı (məs. `youtube.channel_id`) |
| value | string | no | Non-secret dəyər (secret olmamalıdır) |
| value_type | string | yes | `string`, `number`, `boolean`, `json`, `credential_ref` |
| credential_ref | string | no | Credentials provider-də saxlanan secret ID-si |
| scope | string | yes | `global`, `channel`, `workflow`, `run` |
| environment | string | yes | `dry_run`, `staging`, `production` |
| notes | string | no | Qeyd və izah |
| is_active | boolean | yes | Aktivlik statusu |
| created_at | string (ISO-8601) | yes | Yaradılma vaxtı |
| updated_at | string (ISO-8601) | yes | Son dəyişiklik vaxtı |
| updated_by | string | yes | Dəyişiklik edən istifadəçi |

## Credentials siyasəti
- Secrets yalnız Credentials provider-də saxlanılır.
- Config DB/Data Table heç bir halda plain text secret saxlamır.
- `value_type = credential_ref` olduqda `credential_ref` tələb olunur.
- WF-09 credential dəyərini oxumur və göstərmir, yalnız referans saxlayır.
- Audit log-larda credential ID-ləri maskalanır.

## WF-09 UI davranışı
1. Admin istifadəçi config açarı və dəyərini daxil edir.
2. `value_type` `credential_ref` seçilərsə `value` boş qalır, `credential_ref` tələb olunur.
3. `change_reason` boş ola bilməz.
4. `is_active = false` olduqda WF-10 həmin entry-ni nəzərə almır.
5. `dry_run = true` olduqda DB yazma simulyasiya edilir və yalnız audit çıxışı qaytarılır.

## Error handling
- `value_type` ilə uyğun olmayan dəyər daxil edilərsə `invalid_value_type`.
- Secret plain text daxil edilərsə `secret_not_allowed`.
- `environment` düzgün olmadıqda `invalid_environment`.
- DB yazma xətası olduqda retry (3 dəfə), sonra `settings_update_failed`.
