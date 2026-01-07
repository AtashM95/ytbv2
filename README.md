# YouTube Helal Otomasyon Sistemi — Full Production v2 (Foundation)

Bu repo, WF-01…WF-10 arxitekturası üçün “YouTube Helal Otomasyon Sistemi — Full Production v2” skeletini təmin edir. Məqsəd tam istehsal mühitinə uyğun contract-ları, workflow spesifikasiyalarını, test planını və golden sample JSON-ları standartlaşdırmaqdır. Bu mərhələ yalnız foundation sənədlərini və strukturunu təmin edir.

## Məqsədlər
- WF-01…WF-10 üçün struktur və spesifikasiya çərçivəsi
- Dəyişməz contract sahələri və manifest spesifikasiyası
- Settings Panel (WF-09) və Get Config (WF-10) davranışı
- Test checklist və golden sample JSON-lar
- n8n exports qovluğu üçün prosedur (bu mərhələdə export yoxdur)

## Struktur
- `docs/00_overall_architecture.md` — ümumi arxitektura
- `docs/01_contracts.md` — contract spesifikasiyası, JSON schema və nümunələr
- `docs/02_settings_panel_spec.md` — WF-09 spesifikasiyası və DB sxemi
- `docs/03_get_config_spec.md` — WF-10 davranışı və çıxış formatı
- `docs/04_workflows/` — WF-01…WF-10 ayrı-ayrı workflow spesifikasiyaları
- `docs/05_testing_checklist.md` — test checklist və import sırası
- `docs/06_manifest_spec.md` — manifest strukturu
- `exports/golden_samples/` — golden sample JSON-lar
- `exports/n8n/` — n8n export proseduru (README ilə)

## İş qaydası
1. Spesifikasiyaları oxuyun və contract-ları dəyişməyin.
2. WF-09 və WF-10 import ardıcıllığına riayət edin.
3. Golden sample JSON-ları testdə müqayisə üçün istifadə edin.
4. n8n export-ları bu mərhələdə yaradılmır.

## Lisensiya
Bu repo daxili istifadə üçün nəzərdə tutulur.
