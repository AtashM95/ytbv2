---

## 3) Workflow xəritəsi (WF-01…WF-10)

> Detallı izah: `docs/00_overall_architecture.md`

- **WF-01 Orchestrator**
  - run init (`run_id`), `mode` qəbul edir
  - WF-10 ilə config yükləyir
  - WF-02…WF-08 ardıcıllığını idarə edir
  - contract obyektini mərhələ-mərhələ yeniləyir

- **WF-02…WF-08 Worker flows**
  - Hər biri yalnız öz məsuliyyət sahələrini doldurur, qalanlarını ötürür
  - Dry-Run rejimində “publish” kimi riskli əməliyyatlar icra edilmir, yalnız simulyasiya/manifest update edilir

- **WF-09 Settings Panel**
  - UI (n8n Form) + config DB/Data Table yazma/yeniləmə
  - secrets yalnız Credentials olduğu üçün panel plain key saxlamır

- **WF-10 Get Config**
  - defaults + DB + runtime overrides → “resolved config”
  - bütün worker-lərə eyni formatda verir

---

## 4) Quraşdırma ardıcıllığı (n8n import order)

n8n-də import və test həmişə bu sırada aparılır:

1) `exports/n8n/WF-09.json`  → Settings Panel
2) `exports/n8n/WF-10.json`  → Get Config
3) `exports/n8n/WF-01.json`  → Orchestrator
4) `exports/n8n/WF-02.json`  → Worker
5) `exports/n8n/WF-03.json`
6) ...
7) `exports/n8n/WF-08.json`

Ətraflı checklist: `docs/05_testing_checklist.md`

---

## 5) İş rejimləri (Mode)

`mode` contract sahəsi ilə idarə olunur (detallar contract-da göstərilir). Tipik rejimlər:

- `DRY_RUN` / `TEST` — xarici publish əməliyyatları OFF
- `PROD` — publish aktiv ola bilər (əlavə safety gates tövsiyə olunur)
- `SERIES` — seriya davamı, əvvəlki video konteksti istifadə olunur
- `NEW` — yeni müstəqil video

Rejimlərin dəqiq davranışı: `docs/01_contracts.md` + hər workflow spec (`docs/04_workflows/*.md`)

---

## 6) Manifest standardı

Bütün pipeline nəticəsi `manifest` sahəsində toplanır.

- Manifest formatı: `docs/06_manifest_spec.md`
- Golden nümunələr: `exports/golden_samples/*.json`

---

## 7) Codex / Agent ilə yazdırma strategiyası (fazalara bölmək)

Bu repo üçün tövsiyə olunan “itkisiz” yazdırma modeli:

### Phase 0 — FOUNDATION (docs + contract + test)
- Sənəd və contract-lar yazılır, workflow export hələ yazılmır.

### Phase 1 — WF-09 export
- `exports/n8n/WF-09.json` yaradılır
- n8n import + test

### Phase 2 — WF-10 export
- `exports/n8n/WF-10.json` yaradılır
- n8n import + test

### Phase 3 — WF-01 export
- Orchestrator minimal (Dry-Run)
- n8n import + test

### Phase 4…10 — WF-02…WF-08 export-lar tək-tək
- Hər WF: export → import → test → növbəti

Bu metod “uzun JSON yarıda kəsildi” riskini ciddi azaldır.

---

## 8) n8n Code node qaydası (kritik)

n8n Code node-lar **mütləq** bu formatda nəticə qaytarmalıdır:

- həmişə `items array`:
  - `return [{ json: {...} }];`

Əks halda n8n xəta verə bilər:
- “Code doesn't return items properly”

---

## 9) Test etmə (qısa qayda)

Hər workflow import edildikdən sonra:

1) Manual Trigger ilə `exports/golden_samples/new_run.json` tipli input ver
2) Çıxışda contract field-lər qorunurmu yoxla
3) Log-da `run_id` görünürmü
4) Dry-Run rejimində publish/extern call bloklanırmı
5) Manifest yenilənirmi

Tam test plan: `docs/05_testing_checklist.md`

---

## 10) Versiyalama və dəyişiklik qaydası

- Contract field adları dəyişməzdir.
- Contract-a əlavə field lazımdırsa:
  1) `docs/01_contracts.md` yenilənir
  2) `docs/06_manifest_spec.md` yenilənir
  3) təsir edən WF spec-lər yenilənir
  4) sonra yalnız həmin WF export-ları yenidən çıxarılır

---

## 11) Troubleshooting (ən çox rastlanan)

### Repo “empty” xətası (Codex)
Codex işləməsi üçün repo-da ən azı:
- `main` branch
- 1 initial commit
olmalıdır.

Həll:
- GitHub UI ilə `README.md` yaradıb commit edin.

### n8n import alınmır
- JSON kəsilmiş ola bilər (uzun export-larda olur).
- Workflow export-ları faza-faza çıxarın (WF-09 → WF-10 → WF-01 → WF-02…).

### Code node error
- `return` formatını yoxlayın: `return [{ json: ... }]`.

---

## 12) Bu repoda növbəti addım
1) `docs/01_contracts.md` tamam və kilidli olsun.
2) `WF-09` və `WF-10` spec-ləri dəqiq olsun.
3) Sonra `exports/n8n/WF-09.json` → import/test.
4) Ardınca `exports/n8n/WF-10.json` → import/test.
5) Sonra Orchestrator və worker-lər.

Uğurlu testlərdən sonra pipeline end-to-end Dry-Run edilə bilər.
