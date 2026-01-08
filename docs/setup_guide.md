# YouTube Helal Otomasyon Sistemi v2 - Qurulum Təlimatı

## Ümumi Baxış

Bu sənəd YouTube Helal Otomasyon Sistemi v2-nin tam qurulmasını əhatə edir. Sistem 10 n8n workflow-dan ibarətdir və aşağıdakı xidmətlərlə inteqrasiya olunur:

- **OpenAI** (GPT-4o-mini, DALL-E 3)
- **ElevenLabs** (Text-to-Speech)
- **Shotstack** (Video Render)
- **YouTube Data API v3** (Video Upload)
- **PostgreSQL** (Konfiqurasiya saxlama)

---

## 1. Ön Tələblər

### 1.1 n8n Qurulumu
```bash
# Docker ilə n8n qurulumu
docker run -d \
  --name n8n \
  -p 5678:5678 \
  -e N8N_BASIC_AUTH_ACTIVE=true \
  -e N8N_BASIC_AUTH_USER=admin \
  -e N8N_BASIC_AUTH_PASSWORD=your_password \
  -v n8n_data:/home/node/.n8n \
  n8nio/n8n
```

### 1.2 PostgreSQL Qurulumu
```bash
# Docker ilə PostgreSQL
docker run -d \
  --name postgres_ytb \
  -p 5432:5432 \
  -e POSTGRES_USER=ytb_user \
  -e POSTGRES_PASSWORD=your_secure_password \
  -e POSTGRES_DB=ytb_automation \
  -v postgres_data:/var/lib/postgresql/data \
  postgres:15
```

---

## 2. PostgreSQL Database Schema

Aşağıdakı SQL-i PostgreSQL-də icra edin:

```sql
-- Settings table for WF-09 and WF-10
CREATE TABLE IF NOT EXISTS ytb_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    key VARCHAR(255) NOT NULL,
    value TEXT,
    value_type VARCHAR(50) NOT NULL DEFAULT 'string',
    credential_ref VARCHAR(255),
    scope VARCHAR(50) NOT NULL DEFAULT 'global',
    environment VARCHAR(50) NOT NULL DEFAULT 'staging',
    notes TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(100) DEFAULT 'system',
    CONSTRAINT unique_key_env_scope UNIQUE (key, environment, scope)
);

-- Index for faster queries
CREATE INDEX idx_ytb_settings_env_active
ON ytb_settings (environment, is_active);

CREATE INDEX idx_ytb_settings_scope
ON ytb_settings (scope);

-- Optional: Runs history table
CREATE TABLE IF NOT EXISTS ytb_runs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    run_id VARCHAR(255) UNIQUE NOT NULL,
    mode VARCHAR(50) NOT NULL,
    environment VARCHAR(50) NOT NULL,
    status VARCHAR(100) NOT NULL,
    manifest JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_ytb_runs_status ON ytb_runs (status);
CREATE INDEX idx_ytb_runs_created ON ytb_runs (created_at DESC);

-- Insert default settings
INSERT INTO ytb_settings (key, value, value_type, scope, environment, notes, is_active)
VALUES
    ('branding.channel_name', 'Helal Elm', 'string', 'global', 'production', 'Default channel name', true),
    ('branding.default_tags', '["elm", "maarif", "azərbaycanca"]', 'json', 'global', 'production', 'Default video tags', true),
    ('runtime.publish_off', 'false', 'boolean', 'global', 'production', 'Enable publishing in production', true),
    ('runtime.publish_off', 'true', 'boolean', 'global', 'staging', 'Disable publishing in staging', true),
    ('publish.privacy_default', 'unlisted', 'string', 'global', 'staging', 'Default privacy for staging', true),
    ('publish.privacy_default', 'public', 'string', 'global', 'production', 'Default privacy for production', true)
ON CONFLICT (key, environment, scope) DO NOTHING;
```

---

## 3. n8n Credentials Qurulumu

### 3.1 PostgreSQL Credential

1. n8n-də **Settings > Credentials** bölməsinə keçin
2. **Add Credential > PostgreSQL** seçin
3. Aşağıdakı məlumatları daxil edin:

| Sahə | Dəyər |
|------|-------|
| Name | `PostgreSQL YTB` |
| Host | `localhost` (və ya PostgreSQL server IP) |
| Port | `5432` |
| Database | `ytb_automation` |
| User | `ytb_user` |
| Password | `your_secure_password` |
| SSL | Disable (lokal üçün) |

**Vacib**: Credential ID-ni `postgres_ytb` olaraq saxlayın və ya workflow-larda credential reference-ı yeniləyin.

### 3.2 HTTP Header Auth (OpenAI, ElevenLabs)

Bu workflow-lar environment variable-lardan API key alır, lakin istəsəniz n8n credential-larından da istifadə edə bilərsiniz.

---

## 4. Environment Variables

n8n üçün aşağıdakı environment variable-ları quraşdırın:

### 4.1 Docker Compose nümunəsi

```yaml
version: '3.8'
services:
  n8n:
    image: n8nio/n8n
    ports:
      - "5678:5678"
    environment:
      # n8n Config
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=admin
      - N8N_BASIC_AUTH_PASSWORD=your_password
      - WEBHOOK_URL=https://your-domain.com

      # Custom Environment Variables
      - N8N_BASE_URL=https://your-n8n-domain.com
      - STORAGE_BASE_URL=https://your-storage.com

      # API Keys
      - OPENAI_API_KEY=sk-your-openai-api-key
      - ELEVENLABS_API_KEY=your-elevenlabs-api-key
      - SHOTSTACK_API_KEY=your-shotstack-api-key

      # Shotstack Endpoint (stage or v1 for production)
      - SHOTSTACK_ENDPOINT=https://api.shotstack.io/stage

      # YouTube OAuth2
      - YOUTUBE_CLIENT_ID=your-google-client-id
      - YOUTUBE_CLIENT_SECRET=your-google-client-secret
      - YOUTUBE_REFRESH_TOKEN=your-refresh-token
    volumes:
      - n8n_data:/home/node/.n8n
```

### 4.2 Lazım olan API Key-lər

| Service | Environment Variable | Necə Almaq |
|---------|---------------------|------------|
| OpenAI | `OPENAI_API_KEY` | https://platform.openai.com/api-keys |
| ElevenLabs | `ELEVENLABS_API_KEY` | https://elevenlabs.io/app/settings/api-keys |
| Shotstack | `SHOTSTACK_API_KEY` | https://dashboard.shotstack.io/api-keys |
| YouTube | `YOUTUBE_CLIENT_ID` | Google Cloud Console |
| YouTube | `YOUTUBE_CLIENT_SECRET` | Google Cloud Console |
| YouTube | `YOUTUBE_REFRESH_TOKEN` | OAuth2 flow ilə alınır |

---

## 5. YouTube OAuth2 Qurulumu

### 5.1 Google Cloud Console

1. https://console.cloud.google.com/ açın
2. Yeni layihə yaradın və ya mövcud layihəni seçin
3. **APIs & Services > Library** bölməsində "YouTube Data API v3" aktivləşdirin
4. **APIs & Services > Credentials** bölməsində:
   - **Create Credentials > OAuth 2.0 Client ID** seçin
   - Application type: **Web application**
   - Authorized redirect URIs: `https://your-n8n-domain.com/rest/oauth2-credential/callback`

### 5.2 Refresh Token Almaq

OAuth2 Playground istifadə edərək:

1. https://developers.google.com/oauthplayground/ açın
2. Settings (dişli icon) > "Use your own OAuth credentials" seçin
3. Client ID və Client Secret daxil edin
4. Step 1-də "YouTube Data API v3" scope-larını seçin:
   - `https://www.googleapis.com/auth/youtube.upload`
   - `https://www.googleapis.com/auth/youtube`
5. Authorize edin və refresh token alın

---

## 6. Workflow Import

### 6.1 Import Prosesi

1. n8n-də **Workflows** bölməsinə keçin
2. **Add Workflow > Import from File** seçin
3. Aşağıdakı faylları sıra ilə import edin:
   - `WF-10.json` (ilk öncə - digərləri buna müraciət edir)
   - `WF-09.json`
   - `WF-02.json` ... `WF-08.json`
   - `WF-01.json` (son - orchestrator)

### 6.2 Credential Bağlantısı

Import sonrası hər workflow-da PostgreSQL node-larını yoxlayın və credential-ı seçin.

### 6.3 Workflow Aktivləşdirmə

Bütün workflow-ları aktivləşdirin ki, webhook-lar işləsin:
1. Hər workflow-u açın
2. Sağ üst küncdə "Inactive" toggle-ı "Active" edin

---

## 7. Test Çalışdırma

### 7.1 Dry Run Test

```bash
curl -X POST https://your-n8n-domain.com/webhook/wf-01 \
  -H "Content-Type: application/json" \
  -d '{
    "mode": "dry_run",
    "environment": "staging",
    "title": "Su Dövranı",
    "category": "education",
    "language": "az",
    "keywords_raw": "su, dövran, təbiət",
    "summary": "Su dövranının əsas mərhələləri haqqında qısa izah"
  }'
```

### 7.2 Staging Test (API çağırışları ilə)

```bash
curl -X POST https://your-n8n-domain.com/webhook/wf-01 \
  -H "Content-Type: application/json" \
  -d '{
    "mode": "staging",
    "environment": "staging",
    "title": "Günəş Sistemi",
    "category": "education",
    "language": "az",
    "keywords_raw": "günəş, planet, kosmos",
    "summary": "Günəş sistemi haqqında maarifləndirici məlumat"
  }'
```

### 7.3 Production (YouTube upload ilə)

```bash
curl -X POST https://your-n8n-domain.com/webhook/wf-01 \
  -H "Content-Type: application/json" \
  -d '{
    "mode": "production",
    "environment": "production",
    "title": "Quran Möcüzələri",
    "category": "education",
    "language": "az",
    "keywords_raw": "quran, islam, möcüzə",
    "summary": "Quranda olan elmi möcüzələr haqqında",
    "channel_id": "UC_YOUR_CHANNEL_ID"
  }'
```

---

## 8. Xəta Aradan Qaldırma

### 8.1 Ümumi Xətalar

| Xəta | Səbəb | Həll |
|------|-------|------|
| `OPENAI_API_KEY not configured` | API key yoxdur | Environment variable yoxlayın |
| `ELEVENLABS_API_KEY not configured` | API key yoxdur | Environment variable yoxlayın |
| `PostgreSQL connection failed` | DB əlçatan deyil | Host/port/credentials yoxlayın |
| `YouTube OAuth2 failed` | Token etibarsız | Refresh token yeniləyin |
| `Shotstack render failed` | API key və ya assets problemi | Asset URL-lərini yoxlayın |

### 8.2 Log Yoxlama

```bash
# n8n logs
docker logs n8n -f

# PostgreSQL logs
docker logs postgres_ytb -f
```

---

## 9. Production Tövsiyələri

1. **SSL/TLS**: Bütün endpoint-ləri HTTPS arxasında yerləşdirin
2. **Backup**: PostgreSQL-i mütəmadi backup edin
3. **Monitoring**: n8n execution history-ni izləyin
4. **Rate Limiting**: API çağırışlarına limit qoyun
5. **Secrets Management**: API key-ləri vault/secrets manager ilə saxlayın

---

## 10. Əlaqə və Dəstək

Problem yaranarsa:
1. n8n execution log-larını yoxlayın
2. API provider dashboard-larını yoxlayın (quota, errors)
3. PostgreSQL query log-larını yoxlayın

---

## Changelog

- **v2.0** (2025-01-08)
  - Bütün workflow-lar yenidən yazıldı
  - Real API inteqrasiyaları əlavə edildi
  - SQL injection düzəldildi
  - Webhook trigger-lar əlavə edildi
  - Retry və timeout konfiqurasiyaları əlavə edildi
