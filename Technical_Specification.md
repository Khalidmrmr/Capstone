# Technical Specification — Smart Closet Mirror

**Team:** Bull Riders — Rehman Khalid, Jace Schubert, Clare Hooper, Arya Garg  
**Course:** Senior Design (CS 5001), University of Cincinnati  
**Faculty advisor:** Dr. Hrishikesh Bhide  
**Document:** `/Technical_Specification.md` · **Current version:** 0.9 (draft for advisor review) · 2026-11-17  
**Traces to:** [`Requirements_Document.md`](Requirements_Document.md) **version 0.9 (2026-11-17)**. Every REQ, NFR and CON ID below refers to that version.

Design sources (linked, not duplicated): [D0 High-Level Design](Design_Diagrams/D0_High_Level_Design.pdf) · [D1 Detailed Design](Design_Diagrams/D1_Detailed_Design.pdf) · [D2 Detailed Design](Design_Diagrams/D2_Detailed_Design.pdf) · [Peer review notes](Design_Diagrams/Peer_Review_Notes.md).

---

## 1. Version and change log

| Version | Date | Change | Author |
| --- | --- | --- | --- |
| 0.9 | 2026-11-17 | First consolidated draft from D0 (Week 5), D1 (Week 6), D2 + peer review (Week 7) and the Week 8 plan. Traces to Requirements v0.9. | Clare Hooper (drafted with AI assistance) |
| 1.0 | _[after advisor review]_ | _[Changes agreed at the advisor review, §7.]_ | _[name]_ |

**Design changes since the Week 7 review.** None to the design itself. Consolidation found five places where the Week 8 plan disagrees with D1/D2 (message broker, 3-D avatar mesh, presence wake, ES5 build step, Mirror board). This specification follows D1/D2 and logs each disagreement as an open question (Requirements §9.2, OQ-1 to OQ-5) rather than changing the design.

## 2. Architecture summary

The system has three physical parts (D0 block diagram, [`D0_block_diagram.svg`](Design_Diagrams/D0_block_diagram.svg)):

- **Brain PC** — a Ubuntu 24.04 desktop with an NVIDIA GPU in the user's home. It runs every component we build: eight layers **L1 Capture, L2 Perception, L3 Body, L4 Wardrobe, L5 Try-on, L6 Decision, L7 Connectors, L8 Presentation**; the shared **planes** (SQLite data store, ZeroMQ message bus `busd`, logging and health); and four **glue** components (Authentication, Notifications, Configuration, Logging/health). Each runs as a systemd service.
- **Gen 1 Mirror** — a thin client. Its shell app shows cards in WebView 44, plays try-on video in Media3, and sends touch and voice commands. It does no processing.
- **Kinect 360** — clipped over the Mirror's top edge, connected to the brain PC by USB 2.0.

A **paired phone** (web page) adds garments, and **outside providers** (Open-Meteo weather, calendar, Wikimedia Commons images, local catalogue file) are reached only through L7.

**Deployment model.** Single machine, single household, on-premises. A layered architecture governs the brain PC; a pipeline governs live try-on; client–server governs everything crossing the PC boundary (D0 §6). Nothing runs in the cloud (CON-01, CON-03).

**Data flow** ([`D0_data_flow.svg`](Design_Diagrams/D0_data_flow.svg)):

- **Flow A — live try-on, every frame, only after camera consent (REQ-06):** Kinect → L1 (frames into a shared-memory ring) → L2 (pose, mask) → L5 (2-D garment warp, H.264 encode) → Mirror Media3 player. Every stage keeps only the newest frame, which holds the 250 ms budget (NFR-03).
- **Flow B — decisions, on request:** touch/voice → L8 → L6, which reads the closet (L4), the fit (L5, from L3's body profile) and context (L7: weather, calendar, products), then sends a decision card back through L8 to the glass (NFR-01, NFR-02).
- **Wardrobe intake:** phone → HTTPS → L4 → data store (REQ-04, REQ-05).

Body data, images and user IDs never leave the house; only L7 calls the internet, through a per-endpoint parameter allowlist (NFR-06).

## 3. Interfaces and data formats

Full field-level definitions are in D0 §4 (I1–I17), D1 §5 (API contract) and D2 part 2 (revisions and I18–I28). This section is the consolidated contract.

### 3.1 Common formats

**Bus envelope** (every message on `busd`; messages > 1 MB are rejected with `TOO_LARGE`):

```json
{ "schema": "fit_report/1", "msg_id": "uuid", "corr_id": "uuid|null",
  "sender": "l5_tryon", "ts": 1794182400000000000, "body": { } }
```

**Error shape** (HTTP and bus alike):

```json
{ "error": { "code": "VALIDATION_FAILED", "message": "photo is under 400 px",
             "fields": { "photo": "min 400x400" } } }
```

**Conventions.** IDs are UUID text; lengths in cm; times RFC 3339 UTC over HTTP and int64 ns on the bus; prices decimal strings + ISO 4217 code. HTTP is versioned in the path (`/api/v1`) and bus schemas by name (`fit_report/1`); a breaking change gets a new version (D1 §5).

**Example payload — DecisionView (L6 → L8, I17):**

```json
{ "schema": "decision_view/1", "view_id": "uuid", "view": "outfit_of_day",
  "reasons": ["Class presentation, 8 °C and rain: wool coat, waterproof boots"],
  "garment_ids": ["uuid", "uuid", "uuid", "uuid"], "verdict": null, "budget_left": null }
```

### 3.2 Component boundaries

| Boundary (ID) | Inputs → outputs | Format | Protocol | Error behaviour |
| --- | --- | --- | --- | --- |
| Kinect → L1 (I1) | RGB 640×480 + 11-bit depth, 30 fps | Raw frames | USB 2.0 isochronous | No frame pair for 2 s → health DOWN, reopen every 5 s; L8 shows "Camera status unknown". |
| L8 → L1 (I27) | `{session_id, consent_id}` → `{state, device_open}` | JSON | Bus request, 3 s | `NO_CONSENT` keeps Kinect closed; timeout → L8 state Unknown (REQ-08). |
| L1 → L2 (I7) | `frame_bundle/2 {seq, ts, slot 0–3, generation}` | Header + shared memory | Bus pub/sub, newest 2 | Generation changed during read → frame discarded; > 100 ms old → skipped. |
| L2 → L3 (I8) | `body_measurements/2` (cm + confidence + 20 rest joints) | JSON | Pub/sub `body.measured` | Published only if confidence ≥ 0.7; L3 re-checks ranges and drops bad data. |
| L3 → L5 (I9) | `body_model/1 {profile_id, version, rest_joints, proportions}` | JSON | Pub/sub `body.model` | Missing → L5 keeps previous version. |
| L2 → L5 (I10) | `LivePose {seq, ts, joints[20], mask_ref}` | MessagePack | Pub/sub 30 Hz, newest only | No person > 0.5 s → garments hidden; joint conf < 0.5 → hold last position. |
| L4 → L5 (I11) | `wardrobe_get/1 {garment_id}` → `garment_asset/1` | JSON | Bus request, 500 ms | `NOT_FOUND`, `INCOMPLETE` → garment reported unavailable. |
| L6 ↔ L5 (I12) | `tryon_request/1` (1–4 garments) → `fit_report/1` | JSON | Bus request, 1.5 s | Timeout → card shows "fit pending"; `PROFILE_LOW_CONFIDENCE` → re-measure; `RENDER_BUSY`. |
| L4 → L6 (I13) | `ClosetIndex` for the unlocked user | JSON | Bus query + `wardrobe.changed` | L4 silent → cached index ≤ 24 h, flagged possibly out of date. |
| L6 ↔ L7 (I14a–d) | `ctx.calendar_day`, `ctx.products`, `ctx.images`, `ctx.weather {lat, lon rounded 0.1°}` | JSON | Bus request, 3 s (weather deadline 3.5 s in A4) | Provider down → cached data with `stale=true`; none → `PROVIDER_UNAVAILABLE`, L6 degrades (REQ-02). |
| L7 ↔ providers (I3) | Allowlisted query params → provider JSON | JSON | HTTPS REST, OAuth 2.0 where needed | 429/5xx/timeout → retry 1, 2, 4 s; 401 → refresh once then `NEEDS_RELINK`. |
| L6 ↔ L2 (I15) | `vision.analyze {image_refs 1–6}` → `DetectedItems` | JSON | Bus request, 5 s | `MODEL_UNAVAILABLE`, per-image `IMAGE_UNREADABLE`. |
| L7 → L4 (I16) | `CatalogItem {sku, shop, price, size_chart, image_ref}` | JSON | Pub/sub `catalog.items` | Missing size chart → stored *incomplete*; repeated sku → update in place. |
| L6 ↔ L8 (I17) | `DecisionView` ↔ `UserAction {view_id, action, source}` | JSON | Pub/sub `decision.view` / `ui.action` | Old view_id → `STALE_VIEW`, current view resent. |
| L2 → L6 (I19) | `intent.gesture {intent next/back/select, conf}` | JSON | Pub/sub, ≤ 1/s | conf < 0.8 dropped. |
| Mirror → L8 (I5) | touch, wake word, `voice_command {text ≤ 40, confidence}` — no camera data | JSON | WebSocket | Bad token → close 4401; second Mirror → 4409; confidence < 0.6 ignored. |
| L8 → Mirror (I6, I18) | `ui_state/2 {seq, screen, cards ≤ 4, banner, toast}`; `mirror.control {cmd, cmd_id}` | ES5 bundle + JSON | WebSocket; JS bridge | Socket drop → reconnect every 2 s, full state resent; no control ack in 1 s → retry once, log. |
| L5 → Mirror (I4) | H.264 Main 1280×720 30 fps ≤ 4 Mbit/s | MPEG-TS | HTTP progressive stream | Disconnect → 2 s buffer, reconnect; send buffer > 500 ms → 2 Mbit/s. |
| L8 → Auth (I28) | `auth.unlock {user_id, pin}` → `{session_id, expires_at}` | JSON | Bus request | `WRONG_PIN` (attempts left), `LOCKED` 5 min, `NO_PIN_SET`. |
| Any → Notifications (I20) | `notify.create {user_id, kind, title ≤ 60, body ≤ 200, dedupe_key, ttl_h}` | JSON | Bus request | `BAD_INPUT` (never truncated), `UNKNOWN_USER`. |
| All → busd (I21, I23) | `ops.health {component, state, detail, metrics}` every 5 s; `config.changed` | JSON | Pub/sub | Silent 15 s → component DOWN. |
| L6 → L2, L2 → L8 (I24, I25) | `measure.start/cancel`; `measure.progress {state, hint, progress, reason}` | JSON | Bus request; pub/sub | `BUSY`, `NO_PERSON`; failure reasons `TIMEOUT`, `PERSON_LOST`, `MULTIPLE_PEOPLE`, `LOW_CONFIDENCE`, `OUT_OF_RANGE`. |
| Components → data store | Repository functions per owning component | SQLite rows; files under `files/<garment_id>/` | In-process | Locked > 2 s → `STORAGE_UNAVAILABLE`/503; < 1 GB free → read-only, DEGRADED. |

### 3.3 HTTP endpoints (phone, served by the brain PC over HTTPS on the home LAN)

All endpoints except `POST /pair` require `Authorization: Bearer <device token>`; a missing or revoked token returns 401 `UNAUTHORIZED` (NFR-07). `user_id` always comes from the token or session, never the request (REQ-09).

| Method & path | Owner | Request | Success | Errors |
| --- | --- | --- | --- | --- |
| `POST /api/v1/garments` | L4 | multipart: photo (JPEG/PNG, ≥ 400², ≤ 8 MB), category, optional size_label, fit_type, stretch_pct 0–40, formality 1–5, brand | 201 Garment | 400 `VALIDATION_FAILED`, 409 `DUPLICATE_PHOTO`, 413, 415, 503 |
| `GET /api/v1/garments` | L4 | category, status, limit 1–100, cursor | 200 `{items, next_cursor}` | 400 `BAD_QUERY`, 403 (other owner) |
| `GET /api/v1/garments/{id}` | L4 | — | 200 Garment + sizes, listings, anchors; ETag | 404 `NOT_FOUND` |
| `PATCH /api/v1/garments/{id}` | L4 | JSON fields; `If-Match` required | 200 Garment (clears FitResult rows on size change) | 400, 404, 412 `VERSION_CONFLICT` |
| `DELETE /api/v1/garments/{id}` | L4 | — | 204 (status → archived, files kept 30 days) | 404 |
| `GET /api/v1/decisions` | L6 | kind, limit 1–50, cursor | 200 `{items, next_cursor}` | 400 |
| `POST /api/v1/spend` | L6 | amount > 0, currency, listing_id?, spent_on? | 201 `{spend_id, budget_left}` | 400, 404 `LISTING_NOT_FOUND` |
| `PUT /api/v1/preferences` | L6 | StylePreference fields | 200 | 400 |
| `POST /api/v1/providers/{p}/link`, `GET …/callback`, `DELETE …/{p}` | L7 | provider; OAuth code + state | 201 `{auth_url}`, 302, 204 | 400 `UNKNOWN_PROVIDER`, 400 `BAD_STATE`, 502 |
| `POST /api/v1/pair` | Auth | code (6 digits), device_name | 201 `{device_id, token (once), user_id}` | 404 `CODE_UNKNOWN`, 410 `CODE_EXPIRED`, 429 |
| `GET / DELETE /api/v1/devices[/{id}]` | Auth | — | 200 list / 204 | 404, 409 `CANNOT_REVOKE_SELF` |
| `PUT /api/v1/profile/pin` | Auth | pin 4–6 digits, current_pin | 204 | 400, 403 `WRONG_CURRENT_PIN` |
| `GET /api/v1/notifications`, `POST …/{id}/read` | Notifications | unread, limit, cursor | 200 / 204 | 400, 404 |
| `GET /api/v1/health` | Logging/health | — | 200 `{overall, components}` | 401 |

### 3.4 Database schema (SQLite 3, WAL, `foreign_keys=ON`, `busy_timeout=2000`)

Full ER diagrams: [D1 Fig 1](Design_Diagrams/D1_data_model.svg) and [Fig D2-4](Design_Diagrams/D2_fig4_data_model.svg). Each table has exactly one writing component. Core tables (abridged DDL):

```sql
CREATE TABLE garment (
  garment_id TEXT PRIMARY KEY, owner_user_id TEXT NULL REFERENCES user(user_id),
  source TEXT CHECK (source IN ('closet','catalog')),
  category TEXT CHECK (category IN ('top','bottom','dress','outer','shoes')),
  status TEXT CHECK (status IN ('active','incomplete','archived')),
  fit_type TEXT, stretch_pct REAL, formality INTEGER CHECK (formality BETWEEN 1 AND 5),
  warmth INTEGER CHECK (warmth BETWEEN 1 AND 3), water_resistant INTEGER,
  colors TEXT /* JSON list, ≤ 5 */, photo_hash TEXT UNIQUE, created_at TEXT);
CREATE INDEX ix_garment_owner ON garment(owner_user_id, status, category);
CREATE TABLE garment_size (size_id TEXT PRIMARY KEY, garment_id TEXT REFERENCES garment,
  size_label TEXT, chest_cm REAL, waist_cm REAL, hips_cm REAL, length_cm REAL,
  shoulder_cm REAL, is_owned INTEGER, UNIQUE (garment_id, size_label));
CREATE TABLE body_profile (profile_id TEXT PRIMARY KEY, user_id TEXT REFERENCES user,
  height_cm REAL, chest_cm REAL, waist_cm REAL, hips_cm REAL, shoulder_cm REAL,
  inseam_cm REAL, confidence REAL, is_current INTEGER, captured_at TEXT);
CREATE UNIQUE INDEX ux_profile_current ON body_profile(user_id) WHERE is_current = 1;
CREATE TABLE fit_result (profile_id TEXT, size_id TEXT, algo_version INTEGER,
  overall TEXT, score REAL, zones TEXT, UNIQUE (profile_id, size_id, algo_version));
CREATE TABLE consent_event (event_id TEXT PRIMARY KEY, session_id TEXT,
  action TEXT CHECK (action IN ('allow','decline','revoke','timeout')), ts TEXT);
  -- no user link, no image (REQ-06, NFR-05)
CREATE TABLE profile_lock (user_id TEXT PRIMARY KEY, pin_hash TEXT /* argon2id */,
  failed_attempts INTEGER, locked_until TEXT);
CREATE TABLE device (device_id TEXT PRIMARY KEY, user_id TEXT, kind TEXT, name TEXT,
  token_hash TEXT /* argon2id */, revoked_at TEXT, last_seen_at TEXT);
```

Other tables, as in D1/D2: user, garment_asset, listing, outfit, outfit_item, wear_event, body_model, decision, style_preference, spend_entry, provider_account (tokens encrypted with a key in `secrets.env`), category_rule, cache_entry, notification.

### 3.5 Maintainer CLI (REQ-11, REQ-12)

| Command | Output | Exit codes |
| --- | --- | --- |
| `scmctl status` | One line per component: name, ok/degraded/down, since, detail | 0; 2 = busd unreachable ("health unknown") |
| `scmctl config check <path>` | Validation errors by key | 0 valid; 1 invalid |
| `scmctl config rollback [--to N]` | Restored version, services restarted | 0; 1 `NO_KNOWN_GOOD` / `INVALID_VERSION` (nothing changed); 3 `RESTART_FAILED` |

## 4. Technology stack

| Layer | Choice | Justification (ID) |
| --- | --- | --- |
| Compute host | Ubuntu 24.04 LTS desktop, NVIDIA GPU (team-owned) | Local processing (CON-03); no purchase within the $200 budget (CON-01); GPU for NFR-03. |
| Display client | Gen 1 Mirror shell app: WebView 44 + Media3 player | Reuses owned hardware (CON-01); thin client because of CON-08. |
| Sensor | Kinect 360 via libfreenect (Apache-2.0/GPL-2.0) | Depth gives sizes in cm (REQ-13); ≈ $35 used (CON-01); USB 2.0 (CON-09). |
| Language / API | Python 3.12, FastAPI + Uvicorn, Pydantic v2 | One language for all layers; schema validation for REQ-04 errors; serves phone and Mirror from one process. |
| Message bus | ZeroMQ (pyzmq) with JSON; MessagePack for pose | Microsecond, brokerless local messaging; newest-only queues for NFR-03. (Redis vs ZeroMQ: OQ-1.) |
| Database | SQLite 3 in WAL mode, SQLAlchemy 2 + Alembic | Uniqueness rules enforce REQ-04 (photo hash) and REQ-05 (ETag); no server to run; nightly `.backup` for NFR-11. |
| Pose / perception | MediaPipe Pose (Apache-2.0); OWLv2 for item detection | Maintained, fits 60 ms pose budget (NFR-03); runs offline (CON-03). |
| Imaging | OpenCV, Pillow, ImageHash (pHash), rembg/U²-Net | Duplicate detection for REQ-04; on-device cutout (CON-03); 2 s recognition budget (CON-05). |
| Fit and decisions | NumPy (A1), plain Python (A4, A5, A6) | Explainable rules produce the reasons REQ-01 and REQ-16 display; A1 < 1.5 s (REQ-14). |
| Rendering | ModernGL (OpenGL 3.3) 2-D skinned warp | ≈ 2 ms per frame on GPU, inside A2's 30 ms (REQ-15, NFR-03). |
| Video | FFmpeg via PyAV, `h264_nvenc` (libx264 fallback) | < 5 ms encode for NFR-03; Mirror decodes H.264 in hardware (CON-08). |
| Glass UI | Plain HTML/CSS/ES5, no framework | WebView 44 has no ES6/WebGL (CON-08); large-type cards for NFR-09. |
| Phone UI | Mobile web page (no native app) | No app store, no push off the network (Won't list; NFR-06). |
| Weather | Open-Meteo (no key, free non-commercial) | Free (CON-01); coordinates rounded 0.1° (NFR-06); 15 min cache (NFR-04). |
| Auth / crypto | argon2-cffi, Python `secrets`, HTTPBearer | Hashed PINs and tokens (NFR-07); lockout (REQ-09). |
| Operations | systemd, journald (500 MB / 14 days), `scmctl` | Auto-restart (NFR-10); status and rollback (REQ-11, REQ-12). |
| Tests | pytest | Automated cases for the Week 10 plan. |

## 5. Known constraints

| ID | Constraint (Requirements §8) | What it rules out | What it forces |
| --- | --- | --- | --- |
| CON-01 | $200 hardware, reuse one Mirror, no paid cloud | New smart mirror; paid cloud GPU or APIs; Jetson Orin Nano purchase | Team-owned brain PC; used Kinect (≈ $35); free providers (Open-Meteo, Wikimedia, local catalogue). |
| CON-02 | One Mirror: recovery image first; parts replaceable within 1 week | Irreversible changes without a backup; custom or single-source parts | Clip-over bracket with no drilling (D0 D7); off-the-shelf Kinect and cables. |
| CON-03 | All image processing local; no photo/body data to the cloud | Cloud vision APIs, cloud try-on, cloud storage, push services | On-device models (MediaPipe, rembg, OWLv2); L7 allowlist; in-app notifications only. |
| CON-04 | Own Linux image, ports closed except local interface | Exposing the API to the internet; stock vendor accounts | Ubuntu brain PC with firewall; phone API on home LAN only; default accounts removed. |
| CON-05 | ≤ 2 s on-device recognition per outfit | Heavy models that miss the budget | Cutout at upload time (≈ 1 s), not per frame; design review if exceeded. |
| CON-06 | No circumvention of Mirror access controls (DMCA §1201) | Rooting or bypassing the Mirror's locks | Either an unmodified install path for the shell app or board replacement (open: OQ-5). |
| CON-07 | IRB approval before non-team testing | Usability trials with outside users before approval | NFR-08 trials on team members only until approved (OQ-8). |
| CON-08 | Mirror: Android 6, WebView 44, ES5, no WebGL | 3-D rendering or perception on the Mirror; modern JS frameworks | All processing on brain PC; H.264 video to the glass (D0 D3); ES5 UI. |
| CON-09 | Kinect 360: USB 2.0, 12 V, depth 0.8–4 m | Mounting the Kinect on the Mirror's own board; measuring outside range | USB to brain PC; `OUT_OF_RANGE` hint "Stand 1.5–3 m from the mirror". |

## 6. Traceability matrix

Design components: D0 = layers and interfaces I1–I17; D1 = data model, A1, A2, API contract; D2 = revisions, I18–I28, A3–A7, glue, figures D2-1…D2-6, edge cases EC-*. Test case IDs are **proposed** IDs for the Week 10 test plan.

| Req ID | Description | Design Component (D0/D1/D2) | Status | Test Case |
| ------ | ----------- | --------------------------- | ------ | --------- |
| REQ-01 | Outfit from owned active items with occasion + weather reason | D0 L6, I13, I17; D2 A4, I14d, Fig D2-6 | Designed | TC-01 |
| REQ-02 | "Weather unavailable" and occasion-only outfit when weather stale/failed | D2 A4 step 3, I14d `stale`, EC-L6-X, Fig D2-6 | Designed | TC-02 |
| REQ-03 | "No complete outfit available" naming missing category | D2 A4 step 1, EC-L6-I, Fig D2-6 | Designed | TC-03 |
| REQ-04 | Add garment from phone photo; 409 on duplicate | D0 I2; D1 POST /garments, Garment.photo_hash; EC-L4-B, EC-L4-I | Designed | TC-04 |
| REQ-05 | Edit (ETag/412) and remove garment, excluded next time | D1 PATCH/DELETE /garments; EC-L4-T | Designed | TC-05 |
| REQ-06 | Kinect closed by default; per-session consent; status always shown | D2 L1 consent gate, I27, ConsentEvent, Fig D2-5 | Designed | TC-06 |
| REQ-07 | Decline / 15 s timeout / revoke closes Kinect within 1 s | D2 Fig D2-5, I27 capture.disable, EC-L8-B | Designed | TC-07 |
| REQ-08 | Unverifiable state blocks image functions, "Camera status unknown" | D2 capture.status, EC-L1-X, EC-L8-X, Fig D2-5 | Designed | TC-08 |
| REQ-09 | Per-user isolation, 403, 5-wrong-PIN lockout | D2 Auth isolation rule, I28, ProfileLock, EC-AUTH-B/I | Designed | TC-09 |
| REQ-10 | 6-digit pairing code (120 s, 5 tries); list/revoke devices | D2 Auth I22, /devices, Device, EC-AUTH-T | Designed | TC-10 |
| REQ-11 | `scmctl status`; silent component down within 15 s | D2 Logging/health I21, scmctl status, EC-LOG-T | Designed | TC-11 |
| REQ-12 | One-command rollback to known-good configuration | D2 Configuration, config_history, EC-CFG-I/X | Designed | TC-12 |
| REQ-13 | T-pose measurement, confidence ≥ 0.7, ±2 cm | D0 L2, I8; D2 A3, Fig D2-2, L3 | In progress (accuracy spike, OQ-6) | TC-13 |
| REQ-14 | Per-zone fit and recommended size within 1.5 s | D1 A1, I12 fit_report/1, FitResult | Designed | TC-14 |
| REQ-15 | Live overlay of ≤ 4 garments following pose | D1 A2; D0 Flow A, I4, I10 | Designed | TC-15 |
| REQ-16 | Buy-or-skip verdict with ≤ 3 reasons | D2 A5, Fig D2-3, SpendEntry | Designed | TC-16 |
| REQ-17 | Occasion from first calendar event, default casual | D2 A6, I14a, CategoryRule | Designed | TC-17 |
| REQ-18 | In-app notifications with dedupe | D2 Notifications I20, I26, Notification | Designed | TC-18 |
| REQ-19 | Look from a photo (Won't this release) | D2 A7, I14c, I15 (stretch scope, R9) | Designed | N/A (Won't) |
| NFR-01 | Outfit card ≤ 5 s p95 | D2 A4 cost, 3.5 s weather deadline (R10), Fig D2-6 | Designed | TC-20 |
| NFR-02 | Verdict ≤ 2 s p95 | D0 Flow B; D2 I12 1.5 s timeout, Fig D2-3 | Designed | TC-21 |
| NFR-03 | Motion-to-glass ≤ 250 ms p95 | D0 Flow A budget, I7 newest-only; D1 A2; EC-L2-T, EC-L5-X | Designed | TC-22 |
| NFR-04 | Weather ≤ 60 min old; normally ≤ 15 min | D2 L7 cache TTL, I14d observed_at, EC-L7-B | Designed | TC-23 |
| NFR-05 | Zero image/video files when declined or after revoke | D2 L1 shared-memory ring, L2 no persistence, log privacy rule, EC-LOG-I | Designed | TC-24 |
| NFR-06 | No body data off the home network; location 0.1° | D0 D4 (single L7); D2 L7 privacy allowlist, I14d | Designed | TC-25 |
| NFR-07 | Token on every request; argon2id hashes | D1 HTTPBearer; D2 Auth, Device, ProfileLock | Designed | TC-26 |
| NFR-08 | Touch-only and voice-only outfit task ≤ 30 s, 4 of 5 | D2 L8 Fig D2-1, I5 voice list | Planned (protocol not written; CON-07) | TC-27 |
| NFR-09 | ≥ 28 px text, 4.5:1 contrast, touch + voice for all actions | D0 §6 accessibility; D2 L8 UI text config | Planned (style values not set) | TC-28 |
| NFR-10 | 2-hour run; auto-restart ≤ 10 s; capture resumes ≤ 10 s | D2 systemd restarts, EC-BUS-X, EC-L1-T/X | Designed | TC-29 |
| NFR-11 | Nightly backup, 7 copies, restore ≤ 15 min | D2 Data store nightly backup, EC-DS-X | Designed | TC-30 |
| CON-01 | $200 budget, reuse Mirror, no paid cloud | D0 D1 (brain PC), D2 (Kinect); D1 §6 hosting | Designed | TC-31 (inspection: parts list) |
| CON-02 | Recovery image before irreversible change | ORPHANED — no D0–D2 element covers making or storing a Mirror recovery image. D0 D7 (no-drill bracket) covers only the mount. Needs a maintenance procedure; owner Rehman Khalid. | Planned | TC-32 |
| CON-03 | Local image processing only | D0 D1, D4; D1 rembg offline; D2 L7 allowlist | Designed | TC-25 |
| CON-04 | Ports closed except local interface | D2 Auth (default accounts), HTTPS on LAN; Ethics §2 | Designed | TC-33 |
| CON-05 | ≤ 2 s recognition per outfit | D1 rembg ≈ 1 s at upload; D2 I15 0.6 s per image | Designed | TC-34 |
| CON-06 | No DMCA §1201 circumvention | ORPHANED — D0–D2 assume the Mirror's own board runs the shell app; whether installing it bypasses an access control is unresolved (OQ-5). | In progress | TC-35 (inspection) |
| CON-07 | IRB before non-team testing | ORPHANED — a process constraint with no design component; IRB submission is not yet in the Week 8 task list (OQ-8). | Planned | N/A (process) |
| CON-08 | Android 6 / WebView 44 limits | D0 D1, D3; D2 I6 ES5 bundle, I4 H.264 | Designed | TC-36 |
| CON-09 | Kinect USB 2.0, 12 V, 0.8–4 m | D0 I1, D7; D2 EC-L1-B, A3 OUT_OF_RANGE | Designed | TC-37 |

## 7. Advisor review record

> **To be completed by the team after the meeting.** No advisor review of these two documents has taken place yet; nothing below is filled in on the team's behalf. Send both drafts and this matrix to Dr. Bhide at least three days before the deadline.

| Field | Value |
| --- | --- |
| Date of review | _[YYYY-MM-DD]_ |
| Attendees | _[names]_ |
| Format | _[in person / Zoom / Teams]_ |
| Versions reviewed | Requirements_Document.md v0.9, Technical_Specification.md v0.9 |

**What was discussed.** _[Summary, including the traceability matrix, the Must/Should split, ORPHANED rows CON-02, CON-06, CON-07, and open questions OQ-1 to OQ-10.]_

| # | Advisor comment | Response (Accepted / Modified / Declined + reason) | Change made (doc, section, ID) | Owner |
| --- | --- | --- | --- | --- |
| AR-1 | | | | |
| AR-2 | | | | |
| AR-3 | | | | |

**Resulting changes.** _[List; add a v1.0 row to both change logs.]_
