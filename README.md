# YouTube Helal Otomasyon Sistemi — Full Production v2 (Foundation)

Bu repo, WF-00…WF-12 arxitekturası üçün “YouTube Helal Otomasyon Sistemi — Full Production v2” skeletini təmin edir. Məqsəd tam istehsal mühitinə uyğun contract-ları, workflow spesifikasiyalarını, test planını və golden sample JSON-ları standartlaşdırmaqdır.

## Məqsədlər
- WF-00…WF-12 üçün struktur və spesifikasiya çərçivəsi
- Dəyişməz contract sahələri və manifest spesifikasiyası
- Settings Panel (WF-11) və Config Manager (WF-10) davranışı
- Test checklist və golden sample JSON-lar
- n8n workflow export-ları (`exports/n8n-workflows/`)

## Struktur
- `docs/00_overall_architecture.md` — ümumi arxitektura
- `docs/01_contracts.md` — contract spesifikasiyası, JSON schema və nümunələr
- `docs/02_settings_panel_spec.md` — WF-11 spesifikasiyası və DB sxemi
- `docs/03_get_config_spec.md` — WF-10 davranışı və çıxış formatı
- `docs/04_workflows/` — WF-01…WF-12 ayrı-ayrı workflow spesifikasiyaları
- `docs/05_testing_checklist.md` — test checklist və import sırası
- `docs/06_manifest_spec.md` — manifest strukturu
- `exports/golden_samples/` — golden sample JSON-lar
- `exports/n8n-workflows/` — n8n workflow export-ları

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
2. WF-11 və WF-10 import ardıcıllığına riayət edin.
3. Golden sample JSON-ları testdə müqayisə üçün istifadə edin.

## Lisensiya
Bu repo daxili istifadə üçün nəzərdə tutulur.
