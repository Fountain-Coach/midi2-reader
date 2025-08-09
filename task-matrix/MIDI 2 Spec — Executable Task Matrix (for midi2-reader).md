# MIDI 2 Spec — Executable Task Matrix (for `midi2-reader`)

> Goal: 100% machine-readable MIDI 2.0 spec to enable LLM-driven Swift implementations.

## Legend
- **P**: Priority (1 = highest)
- **Est**: Estimated effort (S=1–2d, M=3–5d, L=1–2w, XL=>2w)
- **Owner**: Default `@Contexter` unless reassigned
- **DoD**: Definition of Done
- **Deps**: Dependencies (IDs)

---

## Phase 0 — Repo Hardening & CI

| ID | Task | Why | Steps | Deliverable | DoD | P | Est | Owner | Deps |
|---|---|---|---|---|---|---|---|---|---|
| 0.1 | Select canonical spec set & version | Establish single source of truth | List all MIDI 2 docs; record version numbers; commit `SPEC_SOURCES.md` | `docs/SPEC_SOURCES.md` | All spec docs & versions listed; links verified | 1 | S |  |  |
| 0.2 | Project scaffolding & tooling | Consistent dev env | Add `make`, `poetry`/`uv`, `ruff`, `mypy`, `pre-commit` | `Makefile`, `pyproject.toml`, hooks | CI green on lint+type | 1 | S |  |  |
| 0.3 | CI pipeline | Reproducibility | GitHub Actions: test, lint, type, build JSON artifact | `.github/workflows/ci.yml` | CI runs on PRs; artifacts attached | 1 | S |  | 0.2 |
| 0.4 | Spec corpus cache | Immutable inputs | `data/spec/` with hashes; downloader script | `scripts/fetch_specs.py` | Hash-locked inputs; reruns are deterministic | 2 | S |  | 0.1 |

---

## Phase 1 — Domain Model & JSON Schema

| ID | Task | Why | Steps | Deliverable | DoD | P | Est | Owner | Deps |
|---|---|---|---|---|---|---|---|---|---|
| 1.1 | Define core schema (JSON) | LLM-ready structure | Model Messages, Fields, Enums, Ranges, Notes, Provenance | `schema/midi2.schema.json` | Valid JSON Schema; example passes validation | 1 | M |  | 0.x |
| 1.2 | Provenance & versioning fields | Traceability | Add `source_doc`, `section`, `spec_version`, `last_verified` | Schema + docs | All entities carry provenance | 1 | S |  | 1.1 |
| 1.3 | Swift mapping hints | Aid codegen | Add `swift.typeHint`, `naming`, `bitWidth`, `range` | Schema + examples | LLM can map to Swift types from hints | 2 | S |  | 1.1 |
| 1.4 | Category taxonomy | Navigation | ChannelVoice/System/Utility/CI/Profiles/PropertyExchange | `schema/enums.json` | All items categorized | 2 | S |  | 1.1 |

---

## Phase 2 — Parsing Pipeline (Robust, Layout-Aware)

| ID | Task | Why | Steps | Deliverable | DoD | P | Est | Owner | Deps |
|---|---|---|---|---|---|---|---|---|---|
| 2.1 | PDF → structured blocks | Avoid brittle regex | Use pdfminer/pdfplumber: extract headings, tables, paragraphs | `reader/ingest_pdf.py` | Unit tests show stable block recovery on sample pages | 1 | M |  | 0.4 |
| 2.2 | Table extractor | Capture message tables | Column detection; merged cells; page breaks | `reader/parse_tables.py` | Golden tests for known tables | 1 | M |  | 2.1 |
| 2.3 | Message DSL normalizer | Normalize rows → fields | Map spec phrasing to schema (bits, ranges, flags) | `reader/normalize.py` | 95%+ of target tables normalize without manual edits | 1 | L |  | 2.2, 1.1 |
| 2.4 | Provenance stamping | Trust & diff | Stamp each entity with doc+section+hash | Integrated in pipeline | All JSON nodes have provenance | 1 | S |  | 1.2, 2.3 |
| 2.5 | Manual override layer | Fill hard cases | YAML overlays for exceptions | `overrides/*.yml` | Parser + overrides produce identical JSON deterministically | 2 | S |  | 2.3 |

---

## Phase 3 — Coverage Tracks (All MIDI 2 Areas)

| ID | Track | Scope | Steps | Deliverable | DoD | P | Est | Deps |
|---|---|---|---|---|---|---|---|---|
| 3.1 | UMP & Protocol | Packet format, Channel Voice 2.0, Utility/System | Parse core tables; define enums; bit layouts | `json/ump.json` | 100% of UMP message types & fields | 1 | L | 2.x |
| 3.2 | MIDI-CI | Discovery, negotiation | Parse CI messages, states | `json/midi_ci.json` | All CI messages & state machines captured | 1 | L | 2.x |
| 3.3 | Profiles | Enable/disable, rules | Catalog profiles, IDs, constraints | `json/profiles.json` | Profile metadata & rules complete | 2 | L | 2.x |
| 3.4 | Property Exchange | Resources & JSON shapes | Extract property IDs, types, schemas | `json/property_exchange.json` | All properties + schemas represented | 1 | XL | 2.x |
| 3.5 | File/Clip (SMF 2 compat) | File-level | Model chunks/metadata if spec’d | `json/file_format.json` | If applicable, fully captured | 3 | M | 2.x |
| 3.6 | Enumerations & Ranges | Cross-cutting | Consolidate controllers, status codes | `json/enums.json` | Single source for enums, deduped | 1 | M | 3.1–3.4 |

---

## Phase 4 — Validation, Testing, Diffing

| ID | Task | Why | Steps | Deliverable | DoD | P | Est | Owner | Deps |
|---|---|---|---|---|---|---|---|---|---|
| 4.1 | Schema validators | Guardrail | JSON Schema validation in CI | `tests/test_schema.py` | Fails on any schema drift | 1 | S |  | 1.1 |
| 4.2 | Golden fixtures | Stability | Commit canonical JSON outputs | `tests/golden/*.json` | Parser reproduces goldens byte-identically | 1 | S |  | 2.5, 3.x |
| 4.3 | Cross-source sanity | Catch omissions | Counts, bit-sum checks, enum coverage | `tests/test_sanity.py` | All sanity checks pass | 1 | S |  | 3.x |
| 4.4 | External parity smoke | Confidence | Compare presence vs reputable libs (counts only) | `tests/test_parity.py` | No missing message classes | 2 | S |  | 3.x |
| 4.5 | Provenance diff tool | Upgrades | Diff JSON between spec versions | `tools/spec_diff.py` | Report lists adds/changes/removals | 2 | M |  | 1.2, 3.x |

---

## Phase 5 — LLM & Swift Integration

| ID | Task | Why | Steps | Deliverable | DoD | P | Est | Owner | Deps |
|---|---|---|---|---|---|---|---|---|---|
| 5.1 | Swift mapping guide | Aid generation | Document type hints, naming conventions | `docs/swift_mapping.md` | Examples for messages/enums/bitfields | 2 | S |  | 1.3 |
| 5.2 | Codegen prompts | Repeatable LLM use | Prompt templates consuming JSON | `prompts/swift_codegen.md` | Generates compilable Swift for samples | 2 | M |  | 3.x |
| 5.3 | Reference generator (optional) | Deterministic | Python → Swift emitter using JSON | `tools/gen_swift.py` | Emits Swift models for a subset (UMP) | 3 | M |  | 3.1, 1.3 |
| 5.4 | Playground proof | E2E | Sample Swift package using emitted code | `examples/SwiftMidi2Demo/` | Builds & runs tests locally | 3 | M |  | 5.2/5.3 |
| 5.5 | Docs site (auto) | Human ref | MkDocs/Docusaurus generated from JSON | `site/` | Up-to-date, searchable docs | 3 | M |  | 3.x, 4.x |

---

## Acceptance Criteria (Global)

- **A1 — Completeness:** JSON outputs exist for UMP/Protocol, MIDI-CI, Profiles, Property Exchange, Enums; no “TBD” placeholders.
- **A2 — Fidelity:** For a sampled set (≥ 30% per area), fields/bit widths/ranges match spec verbatim; discrepancies tracked via issues.
- **A3 — Provenance:** Every entity has `source_doc`, `section`, `spec_version`, and `source_hash`.
- **A4 — Determinism:** Running the pipeline on identical inputs reproduces byte-identical JSON.
- **A5 — CI Health:** Lint/type/tests pass; artifacts uploaded on tags.
- **A6 — LLM Usability:** Given a JSON slice, the prompt template yields correct Swift models for ≥ 10 representative messages without manual edits.

---

## Backlog / Nice-to-Haves

- **B1:** CLI: `midi2-reader export --area ump --format json|yaml`
- **B2:** JSON → Markdown doc generator with diagrams
- **B3:** Visual diff UI for spec updates
- **B4:** Protobuf/Avro schemas for downstream consumers

---

## Work Sequencing (Minimal Critical Path)

1. `0.1 → 0.2 → 0.3 → 0.4`
2. `1.1 → 1.2 → 1.3 → 1.4`
3. `2.1 → 2.2 → 2.3 → 2.4 → 2.5`
4. Parallel coverage: `3.1` + `3.2` + `3.4` (start 3.6 once one track stabilizes)
5. `4.1–4.4` then `4.5`
6. `5.1 → 5.2` (+ optional `5.3`) → `5.4` → `5.5`

---

## Machine-Readable Task List (JSON)

```json
{
  "phases": [
    {"id":"0","tasks":["0.1","0.2","0.3","0.4"]},
    {"id":"1","tasks":["1.1","1.2","1.3","1.4"]},
    {"id":"2","tasks":["2.1","2.2","2.3","2.4","2.5"]},
    {"id":"3","tasks":["3.1","3.2","3.3","3.4","3.5","3.6"]},
    {"id":"4","tasks":["4.1","4.2","4.3","4.4","4.5"]},
    {"id":"5","tasks":["5.1","5.2","5.3","5.4","5.5"]}
  ],
  "critical_path": [
    ["0.1","0.2","0.3","0.4"],
    ["1.1","1.2","1.3","1.4"],
    ["2.1","2.2","2.3","2.4","2.5"],
    ["3.1","3.2","3.4"],
    ["4.1","4.2","4.3","4.4","4.5"],
    ["5.1","5.2","5.4","5.5"]
  ]
}