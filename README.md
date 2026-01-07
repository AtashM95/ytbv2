# YouTube Helal Otomasyon Sistemi — Full Production v2

Bu repo, n8n üzərində qurulan modul YouTube avtomasiya sisteminin (Full Production v2) **sənədləşməsi, contract-ları, test planı və workflow export-ları** üçün standart “single source of truth” (SSOT) rolunu oynayır.

Sistem dizaynı: **WF-01 Orchestrator** mərkəzdədir, **WF-02…WF-08 worker** axınlarını idarə edir; **WF-09 Settings Panel** konfiqurasiyanı idarə edir; **WF-10 Get Config** runtime-da konfiqi yükləyib bütün axınlara eyni formatda verir.

## 1) Əsas prinsiplər

### 1.1. “İtki yoxdur” qaydası
Bu repo üçün əsas məqsəd: Codex / agent yazdırmalarında **heç bir hissənin qısaldılmaması**, contract-ların pozulmaması və hər fazanın ayrıca idarə oluna bilməsidir.

QADAĞANDIR:
- `...`, `omitted`, `placeholder`, `TODO later`, `sketch`, “sonra doldur” kimi ifadələr
- contract field adlarının dəyişdirilməsi
- n8n Code node-larda “items array” qaytarılmaması

### 1.2. Dəyişməyən Contract sahələri (mütləq sabit)
Aşağıdakı field adları bütün workflow-larda eyni qalır:

- `run_id`
- `mode`
- `scene_assets`
- `voiceover_url_signed`
- `render_id`
- `youtube_video_id`
- `manifest`

Ətraflı spesifikasiya: `docs/01_contracts.md`

### 1.3. Təhlükəsizlik / Secrets siyasəti
- API key / secret-lər workflow JSON-larında **plain text** saxlanılmır.
- Secrets yalnız **n8n Credentials** ilə idarə olunur.
- WF-09 Settings Panel yalnız “seçim/preset/limit” kimi parametrləri DB/Data Table-a yazır; secrets-ə toxunmur.

Ətraflı: `docs/02_settings_panel_spec.md`

## 2) Repo strukturu. ├─ README.md ├─ docs/ │  ├─ 00_overall_architecture.md │  ├─ 01_contracts.md │  ├─ 02_settings_panel_spec.md │  ├─ 03_get_config_spec.md │  ├─ 04_workflows/ │  │  ├─ WF-01.md │  │  ├─ WF-02.md │  │  ├─ ... │  │  └─ WF-10.md │  ├─ 05_testing_checklist.md │  └─ 06_manifest_spec.md ├─ exports/ │  ├─ golden_samples/ │  │  ├─ new_run.json │  │  ├─ rendered.json │  │  └─ published.json │  └─ n8n/ │     ├─ WF-01.json │     ├─ WF-02.json │     ├─ ... │     └─ WF-10.json └─ (optional) CHANGELOG.md## 3) Workflow xəritəsi (WF-01…WF-10)

Detallı izah: `docs/00_overall_architecture.md`

- **WF-01 Orchestrator**
  - run init (`run_id`), `mode` qəbul edir
  - WF-10 ilə config yükləyir
  - WF-02…WF-08 ardıcıllığını idarə edir
  - contract obyektini mərhələ-mərhələ yeniləyir

- **WF-02…WF-08 Worker flows**
  - hər biri yalnız öz məsuliyyət sahələrini doldurur, qalanlarını ötürür
  - Dry-Run rejimində “publish” kimi riskli əməliyyatlar icra edilmir, yalnız simulyasiya/manifest update edilir

- **WF-09 Settings Panel**
  - UI (n8n Form) + config DB/Data Table yazma/yeniləmə
  - secrets yalnız Credentials olduğu üçün panel plain key saxlamır

- **WF-10 Get Config**
  - defaults + DB + runtime overrides → “resolved config”
  - bütün worker-lərə eyni formatda verir

## 4) Quraşdırma ardıcıllığı (n8n import sırası)

n8n-də import və test həmişə bu sırada aparılır:

1. `exports/n8n/WF-09.json` — Settings Panel
2. `exports/n8n/WF-10.json` — Get Config
3. `exports/n8n/WF-01.json` — Orchestrator
4. `exports/n8n/WF-02.json` — Worker
5. `exports/n8n/WF-03.json`
6. ...
7. `exports/n8n/WF-08.json`

Ətraflı checklist: `docs/05_testing_checklist.md`

## 5) İş rejimləri (Mode)

`mode` contract sahəsi ilə idarə olunur (detallar `docs/01_contracts.md` faylında göstərilir). Tipik rejimlər:

- `DRY_RUN` / `TEST` — xarici publish əməliyyatları KAPALI
- `PROD` — publish aktiv ola bilər (əlavə safety gates tövsiyə olunur)
- `SERIES` — seriya davamı, əvvəlki video konteksti istifadə olunur
- `NEW` — yeni müstəqil video

Rejimlərin dəqiq davranışı: `docs/01_contracts.md` + hər workflow spec (`docs/04_workflows/*.md`)

## 6) Manifest standardı

Bütün pipeline nəticəsi `manifest` sahəsində toplanır.

- Manifest formatı: `docs/06_manifest_spec.md`
- Golden nümunələr: `exports/golden_samples/*.json`

## 7) Codex / Agent ilə yazdırma strategiyası (fazalara bölmək)

Bu repo üçün tövsiyə olunan “itkisiz” yazdırma modeli:

### Phase 0 — FOUNDATION (docs + contract + test)
Sənəd və contract-lar yazılır, workflow export hələ yazılmır.

### Phase 1 — WF-09 export
`exports/n8n/WF-09.json` yaradılır → n8n import + test

### Phase 2 — WF-10 export
`exports/n8n/WF-10.json` yaradılır → n8n import + test

### Phase 3 — WF-01 export
Orchestrator minimal (Dry-Run) → n8n import + test

### Phase 4…10 — WF-02…WF-08 export-lar tək-tək
Hər WF: export → import → test → növbəti

## 8) n8n Code node qaydası (kritik)

n8n Code node-lar **mütləq** `items array` qaytarmalıdır:

- `return [{ json: {...} }];`

Əks halda n8n xəta verə bilər:
- “Code doesn't return items properly”

## 9) Test etmə (qısa qayda)

Hər workflow import edildikdən sonra:

1) Manual Trigger ilə `exports/golden_samples/new_run.json` tipli input ver  
2) Çıxışda contract field-lər qorunurmu yoxla  
3) Log-da `run_id` görünürmü  
4) Dry-Run rejimində publish/extern call bloklanırmı  
5) Manifest yenilənirmi  

Tam test plan: `docs/05_testing_checklist.md`

## 10) Versiyalama və dəyişiklik qaydası

- Contract field adları dəyişməzdir.
- Contract-a əlavə field lazımdırsa:
  1) `docs/01_contracts.md` yenilənir
  2) `docs/06_manifest_spec.md` yenilənir
  3) təsir edən WF spec-lər yenilənir
  4) sonra yalnız həmin WF export-ları yenidən çıxarılır

## 11) Troubleshooting (ən çox rastlanan)

### 11.1. Repo “empty” xətası (Codex)
Codex işləməsi üçün repo-da ən azı:
- `main` branch
- 1 initial commit
olmalıdır.

Həll:
- GitHub UI ilə `README.md` yaradıb commit edin.

### 11.2. n8n import alınmır
- JSON kəsilmiş ola bilər (uzun export-larda olur).
- Workflow export-ları faza-faza çıxarın (WF-09 → WF-10 → WF-01 → WF-02…).

### 11.3. Code node error
- `return` formatını yoxlayın: `return [{ json: ... }]`.

## 12) Növbəti addım

1) `docs/01_contracts.md` tamam və kilidli olsun.  
2) `WF-09` və `WF-10` spec-ləri dəqiq olsun.  
3) Sonra `exports/n8n/WF-09.json` → import/test.  
4) Ardınca `exports/n8n/WF-10.json` → import/test.  
5) Sonra Orchestrator və worker-lər.

Uğurlu testlərdən sonra pipeline end-to-end Dry-Run edilə bilər.
