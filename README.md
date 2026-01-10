# YouTube Helal Otomasyon Sistemi — Full Production v2 (Foundation)

Bu repo, WF-00…WF-12 arxitekturası üçün “YouTube Helal Otomasyon Sistemi — Full Production v2” skeletini təmin edir. Məqsəd tam istehsal mühitinə uyğun contract-ları, workflow spesifikasiyalarını, test planını və golden sample JSON-ları standartlaşdırmaqdır. Bu repo foundation olaraq qalır, amma `deploy/` qovluğu ilə 1-komanda ilə ayağa qaldırmaq olur.

## Məqsədlər
- WF-00…WF-12 üçün struktur və spesifikasiya çərçivəsi
- Dəyişməz contract sahələri və manifest spesifikasiyası
- Settings Panel (WF-11) və Config Manager (WF-10) davranışı
- Test checklist və golden sample JSON-lar
- n8n workflow export-ları (`exports/n8n-workflows/`, `exports/n8n/` deprecated)

## Struktur
- `docs/00_overall_architecture.md` — ümumi arxitektura
- `docs/01_contracts.md` — contract spesifikasiyası, JSON schema və nümunələr
- `docs/02_settings_panel_spec.md` — WF-11 spesifikasiyası və DB sxemi
- `docs/03_get_config_spec.md` — WF-10 davranışı və çıxış formatı
- `docs/04_workflows/` — WF-01…WF-12 ayrı-ayrı workflow spesifikasiyaları
- `docs/05_testing_checklist.md` — test checklist və import sırası
- `docs/06_manifest_spec.md` — manifest strukturu
- `exports/golden_samples/` — golden sample JSON-lar
- `exports/n8n-workflows/` — n8n workflow export-ları (kanonik)

## Quick Start
1. `deploy/README_DEPLOY.md` runbook-unu izləyin.
2. `.env` doldurun və `docker compose up -d` ilə servisləri qaldırın.
3. n8n UI-da credential-ları yaradın və workflow-ları import edin.

## Required env vars
Bu env dəyişənləri `deploy/.env` faylında user tərəfindən təmin edilməlidir:
- `N8N_ENCRYPTION_KEY`, `N8N_BASE_URL`, `WEBHOOK_URL`
- `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`
- `OPENAI_API_KEY`, `ELEVENLABS_API_KEY`, `YOUTUBE_API_KEY`
- `SHOTSTACK_API_KEY`, `SHOTSTACK_SANDBOX_KEY`
- `PEXELS_API_KEY`
- `CLOUDINARY_CLOUD_NAME`, `CLOUDINARY_API_KEY`, `CLOUDINARY_API_SECRET`
- (opsional) `CLOUDINARY_UPLOAD_PRESET`, `CLOUDINARY_UNSIGNED_UPLOAD`

## Required credentials (n8n)
- **PostgreSQL**: Name = `PostgreSQL YT Studio`
- **YouTube OAuth2**: Name = `YouTube OAuth2`

## Workflow-lar
- **WF-00 Main Router** — giriş sorğularını yönləndirir.
- **WF-01 Orchestrator** — bütün pipeline-ı koordinasiya edir.
- **WF-02 Trend Analyzer** — trend mövzuları analiz edir.
- **WF-03 Script Generator** — ssenari yaradır.
- **WF-04 Script Reviewer** — ssenarini yoxlayıb təsdiqləyir.
- **WF-05 Voiceover Generator** — ElevenLabs ilə voiceover yaradır.
- **WF-06 Asset Collector** — vizual asset-ləri toplayır.
- **WF-07 Video Renderer** — render job-larını idarə edir.
- **WF-08 Thumbnail Generator** — thumbnail yaradır və upload edir.
- **WF-09 YouTube Publisher** — YouTube-a upload və metadata tətbiq edir.
- **WF-10 Config Manager** — konfiqurasiyanı resolve edir.
- **WF-11 Settings Panel** — admin settings formu təmin edir.
- **WF-12 Short Extractor** — uzun videodan shorts çıxarır.

## İş qaydası
1. Spesifikasiyaları oxuyun və contract-ları dəyişməyin.
2. Import ardıcıllığı: əvvəl **WF-10 (Config Manager)** → **WF-11 (Settings Panel)** → **WF-00/WF-01**, sonra qalan workflow-lar.
3. Golden sample JSON-ları testdə müqayisə üçün istifadə edin.

## Lisensiya
Bu repo daxili istifadə üçün nəzərdə tutulur.
