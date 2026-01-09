# YouTube Helal Otomasyon Sistemi v2 - Quraşdırma Bələdçisi

Bu sənəd sistemin tam qurulması üçün lazım olan bütün addımları izah edir.

## İcmal

Sistem 13 n8n workflow-dan ibarətdir:
- **WF-00**: Main Router - giriş sorğularını yönləndirir
- **WF-01**: Orchestrator - bütün pipeline-ı idarə edir
- **WF-02**: Research & Source Intake - mənbə araşdırması
- **WF-03**: Script Draft - OpenAI ilə ssenari yaradılması
- **WF-04**: Script Review & Approval - ssenarinin təsdiqi
- **WF-05**: Voiceover Generation - ElevenLabs ilə səsləndirmə
- **WF-06**: Scene Asset Build - Pexels/DALL-E ilə vizual asset-lər
- **WF-07**: Render Orchestration - Shotstack ilə video render
- **WF-08**: Thumbnail Generator - thumbnail yaradılması
- **WF-09**: YouTube Publish - YouTube-a yükləmə
- **WF-10**: Get Config - konfiqurasiya oxuma
- **WF-11**: Settings Panel - konfiqurasiya UI
- **WF-12**: Short Extractor - shorts çıxarılması

## 1. Tələb Olunan API Key-lər

### 1.1 OpenAI API Key
**İstifadə olunur**: WF-03 (ssenari), WF-06 (DALL-E fallback)

1. https://platform.openai.com/api-keys səhifəsinə daxil olun
2. "Create new secret key" düyməsini vurun
3. Key-i qeyd edin

```bash
export OPENAI_API_KEY="sk-..."
```

### 1.2 ElevenLabs API Key
**İstifadə olunur**: WF-05 (voiceover)

1. https://elevenlabs.io səhifəsinə daxil olun
2. Profile → API Keys bölməsinə gedin
3. "Create API Key" düyməsini vurun

```bash
export ELEVENLABS_API_KEY="..."
```

**Tövsiyə edilən Voice ID-lər:**
- `pNInz6obpgDQGcFmaJgB` - Adam (multilingual)
- `21m00Tcm4TlvDq8ikWAM` - Rachel (English)

### 1.3 Pexels API Key
**İstifadə olunur**: WF-06 (video və şəkil axtarışı)

1. https://www.pexels.com/api/ səhifəsinə daxil olun
2. Qeydiyyatdan keçin
3. API key-i alın

```bash
export PEXELS_API_KEY="..."
```

### 1.4 Shotstack API Key
**İstifadə olunur**: WF-07 (video render)

1. https://dashboard.shotstack.io/ səhifəsinə daxil olun
2. Qeydiyyatdan keçin
3. Settings → API Keys bölməsindən key-i götürün

```bash
export SHOTSTACK_API_KEY="..."
export SHOTSTACK_ENDPOINT="https://api.shotstack.io/stage"  # və ya /v1 production üçün
```

### 1.5 YouTube OAuth2 Credentials
**İstifadə olunur**: WF-09 (video yükləmə)

1. Google Cloud Console-a daxil olun: https://console.cloud.google.com
2. Yeni layihə yaradın
3. YouTube Data API v3-ü aktivləşdirin
4. OAuth 2.0 credentials yaradın
5. Consent screen-i konfiqurasiya edin
6. Refresh token əldə edin

```bash
export YOUTUBE_CLIENT_ID="..."
export YOUTUBE_CLIENT_SECRET="..."
export YOUTUBE_REFRESH_TOKEN="..."
```

**Refresh Token Almaq üçün:**
```bash
# OAuth2 playground istifadə edin:
# https://developers.google.com/oauthplayground
# Scope: https://www.googleapis.com/auth/youtube.upload
```

## 2. PostgreSQL Database Setup

### 2.1 Database Yaradılması

```sql
CREATE DATABASE ytb_automation;
```

### 2.2 Settings Table Schema

```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS yt_studio_config (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    key VARCHAR(255) NOT NULL,
    value TEXT,
    value_type VARCHAR(50) NOT NULL DEFAULT 'string',
    credential_ref VARCHAR(255),
    scope VARCHAR(50) NOT NULL DEFAULT 'global',
    environment VARCHAR(50) NOT NULL DEFAULT 'production',
    notes TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_by VARCHAR(100),
    
    CONSTRAINT yt_config_unique UNIQUE (key, scope, environment)
);

-- İndekslər
CREATE INDEX idx_config_env ON yt_studio_config(environment);
CREATE INDEX idx_config_scope ON yt_studio_config(scope);
CREATE INDEX idx_config_active ON yt_studio_config(is_active);
CREATE INDEX idx_config_key ON yt_studio_config(key);
```

### 2.3 İlkin Konfiqurasiya Məlumatları

```sql
-- OpenAI konfiqurasiyası
INSERT INTO yt_studio_config (key, value, value_type, scope, environment) 
VALUES ('openai.model', 'gpt-4o-mini', 'string', 'global', 'production');

INSERT INTO yt_studio_config (key, value, value_type, scope, environment) 
VALUES ('openai.max_tokens', '2000', 'number', 'global', 'production');

-- TTS konfiqurasiyası
INSERT INTO yt_studio_config (key, value, value_type, scope, environment) 
VALUES ('tts.model', 'eleven_multilingual_v2', 'string', 'global', 'production');

INSERT INTO yt_studio_config (key, value, value_type, scope, environment) 
VALUES ('tts.default_voice_id', 'pNInz6obpgDQGcFmaJgB', 'string', 'global', 'production');

-- Render konfiqurasiyası
INSERT INTO yt_studio_config (key, value, value_type, scope, environment) 
VALUES ('render.endpoint', 'https://api.shotstack.io/stage', 'string', 'global', 'test');

INSERT INTO yt_studio_config (key, value, value_type, scope, environment) 
VALUES ('render.endpoint', 'https://api.shotstack.io/v1', 'string', 'global', 'production');

-- Publish konfiqurasiyası
INSERT INTO yt_studio_config (key, value, value_type, scope, environment) 
VALUES ('publish.publish_enabled', 'false', 'boolean', 'global', 'test');

INSERT INTO yt_studio_config (key, value, value_type, scope, environment) 
VALUES ('publish.publish_enabled', 'true', 'boolean', 'global', 'production');

INSERT INTO yt_studio_config (key, value, value_type, scope, environment) 
VALUES ('publish.privacy_default', 'unlisted', 'string', 'global', 'production');

-- Branding
INSERT INTO yt_studio_config (key, value, value_type, scope, environment) 
VALUES ('branding.channel_name', 'Helal Elm', 'string', 'global', 'production');

INSERT INTO yt_studio_config (key, value, value_type, scope, environment) 
VALUES ('branding.default_tags', '["elm", "maarif", "azərbaycanca"]', 'json', 'global', 'production');
```

## 3. n8n Credential Setup

### 3.1 PostgreSQL Credential

1. n8n-də Credentials → Add Credential
2. "Postgres" seçin
3. Konfiqurasiya:
   - **Name**: `PostgreSQL YTB`
   - **Host**: `your-db-host`
   - **Database**: `ytb_automation`
   - **User**: `your-user`
   - **Password**: `your-password`
   - **Port**: `5432`
   - **SSL**: Production üçün aktivləşdirin

### 3.2 Environment Variables (n8n)

n8n-in `.env` faylına və ya docker-compose-a əlavə edin:

```env
# n8n Base URL
N8N_BASE_URL=http://localhost:5678

# OpenAI
OPENAI_API_KEY=sk-...

# ElevenLabs
ELEVENLABS_API_KEY=...

# Pexels
PEXELS_API_KEY=...

# Shotstack
SHOTSTACK_API_KEY=...
SHOTSTACK_ENDPOINT=https://api.shotstack.io/stage

# YouTube OAuth2
YOUTUBE_CLIENT_ID=...
YOUTUBE_CLIENT_SECRET=...
YOUTUBE_REFRESH_TOKEN=...

# Storage
STORAGE_PROVIDER=cloudinary
STORAGE_BASE_URL=
CLOUDINARY_CLOUD_NAME=
CLOUDINARY_UPLOAD_PRESET=
CLOUDINARY_API_KEY=
CLOUDINARY_API_SECRET=
STORAGE_UPLOAD_ENDPOINT=
STORAGE_AUTH_HEADER=
```

### 3.3 Docker Compose Nümunəsi

```yaml
version: '3.8'
services:
  n8n:
    image: n8nio/n8n
    ports:
      - "5678:5678"
    environment:
      - N8N_HOST=0.0.0.0
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - N8N_BASE_URL=http://localhost:5678
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - ELEVENLABS_API_KEY=${ELEVENLABS_API_KEY}
      - PEXELS_API_KEY=${PEXELS_API_KEY}
      - SHOTSTACK_API_KEY=${SHOTSTACK_API_KEY}
      - SHOTSTACK_ENDPOINT=${SHOTSTACK_ENDPOINT}
      - YOUTUBE_CLIENT_ID=${YOUTUBE_CLIENT_ID}
      - YOUTUBE_CLIENT_SECRET=${YOUTUBE_CLIENT_SECRET}
      - YOUTUBE_REFRESH_TOKEN=${YOUTUBE_REFRESH_TOKEN}
      - STORAGE_PROVIDER=${STORAGE_PROVIDER}
      - STORAGE_BASE_URL=${STORAGE_BASE_URL}
      - CLOUDINARY_CLOUD_NAME=${CLOUDINARY_CLOUD_NAME}
      - CLOUDINARY_UPLOAD_PRESET=${CLOUDINARY_UPLOAD_PRESET}
      - CLOUDINARY_API_KEY=${CLOUDINARY_API_KEY}
      - CLOUDINARY_API_SECRET=${CLOUDINARY_API_SECRET}
      - STORAGE_UPLOAD_ENDPOINT=${STORAGE_UPLOAD_ENDPOINT}
      - STORAGE_AUTH_HEADER=${STORAGE_AUTH_HEADER}
    volumes:
      - n8n_data:/home/node/.n8n

  postgres:
    image: postgres:15
    environment:
      - POSTGRES_USER=ytb_user
      - POSTGRES_PASSWORD=ytb_password
      - POSTGRES_DB=ytb_automation
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  n8n_data:
  postgres_data:
```

## 4. Workflow Import

### 4.1 Workflow-ları Import Etmək

1. n8n-ə daxil olun
2. Workflows → Import from File
3. Hər WF-XX.json faylını import edin
4. Credential-ları bağlayın (WF-11, WF-10 üçün PostgreSQL)

### 4.2 Workflow-ları Aktivləşdirmək

Aşağıdakı sırayla aktivləşdirin:
1. WF-10 (Get Config)
2. WF-11 (Settings Panel)
3. WF-02 - WF-09
4. WF-01 (Orchestrator)

## 5. Test Etmək

### 5.1 Test Mode

```bash
curl -X POST http://localhost:5678/webhook/wf-01 \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Video",
    "category": "education",
    "language": "az",
    "keywords_raw": "test, elm, maarif",
    "summary": "Bu test videosudur",
    "mode": "test",
    "environment": "test"
  }'
```

### 5.2 Manual Run

```bash
curl -X POST http://localhost:5678/webhook/wf-01 \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Günəş Sistemi haqqında",
    "category": "education",
    "language": "az",
    "keywords_raw": "günəş, planet, astronomiya",
    "summary": "Günəş sistemi və planetlər haqqında maarifləndirici video",
    "mode": "manual",
    "environment": "production",
    "channel_id": "UC..."
  }'
```

## 6. Troubleshooting

### 6.1 Ümumi Xətalar

| Xəta | Səbəb | Həll |
|------|-------|------|
| `OPENAI_API_KEY not configured` | API key yoxdur | Env variable-ı yoxlayın |
| `ELEVENLABS_API_KEY not configured` | API key yoxdur | Env variable-ı yoxlayın |
| `PEXELS_API_KEY not configured` | API key yoxdur | Env variable-ı yoxlayın |
| `PostgreSQL connection failed` | DB əlaqəsi yoxdur | Credential-ı yoxlayın |
| `Render timeout` | Shotstack gecikmə | Timeout artırın |

### 6.2 Log Yoxlama

n8n-də Executions bölməsindən hər workflow icrasını yoxlaya bilərsiniz. Hər workflow `manifest.audit.change_log`-da ətraflı log saxlayır.

## 7. API Rate Limits

| Servis | Limit | Qeyd |
|--------|-------|------|
| OpenAI | 60 RPM (free) | gpt-4o-mini üçün |
| ElevenLabs | 10K chars/ay (free) | Premium plan tövsiyə olunur |
| Pexels | 200 req/saat | Pulsuz |
| Shotstack | 100 renders/ay (free) | Production plan lazım ola bilər |
| YouTube | 10K quota/gün | Upload çox quota tələb edir |

## 8. Təhlükəsizlik Tövsiyələri

1. **API Key-ləri heç vaxt kodda saxlamayın** - yalnız env variables istifadə edin
2. **PostgreSQL üçün SSL aktivləşdirin** - production-da mütləq
3. **n8n-i proxy arxasında saxlayın** - HTTPS üçün
4. **YouTube credentials-ı refresh edin** - refresh token-ın müddəti bitə bilər
5. **Rate limit-lərə diqqət edin** - xüsusilə ElevenLabs üçün

---

*Son yenilənmə: 2024-01*
