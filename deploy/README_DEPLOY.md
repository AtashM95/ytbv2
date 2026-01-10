# Deploy Runbook (n8n + Postgres)

## Quick Runbook (≤10 addım)
1) `cd deploy`
2) `cp .env.example .env`
3) `.env` faylında bütün “replace_me” dəyərlərini öz API/credential açarlarınızla doldurun.
4) `docker compose up -d`
5) Brauzerdə `http://localhost:5678` ünvanını açın və n8n-ə daxil olun.
6) Credentials yaradın (aşağıdakı adlarla).
7) `exports/n8n-workflows/` qovluğundan WF-10 → WF-11 → WF-00/WF-01, sonra qalan workflow-ları import edin.
8) WF-00 və WF-01-i aktivləşdirin (digərləri lazımsa aktivləşdirilir).
9) Smoke test göndərin (aşağıda).

## Credential Mapping
- **PostgreSQL credential**: Name = `PostgreSQL YT Studio`
- **YouTube OAuth2 credential**: Name = `YouTube OAuth2`

## Minimal Permissions / Notes
- **YouTube OAuth2 scope**: `https://www.googleapis.com/auth/youtube.upload`
- **OAuth Redirect URL** (n8n): `http://localhost:5678/rest/oauth2-credential/callback`

## Smoke Test
- Golden sample faylı: `exports/golden_samples/new_run.json`
- Test çağırışı:
  ```bash
  curl -X POST "$WEBHOOK_URL/webhook/wf-00-main-router" \
    -H "Content-Type: application/json" \
    -d @../exports/golden_samples/new_run.json
  ```
- Gözlənilən nəticə: `manifest.status` mərhələli şəkildə `IN_PROGRESS` → `SUCCESS` və ya mənalı `FAILED_*` kodları ilə yenilənir.
