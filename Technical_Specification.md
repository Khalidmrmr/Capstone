# Technical Specification Document — Smart Closet Mirror

**Document Version:** 1.0  
**Status:** Approved Baseline  
**Traces To:** Requirements Document v1.0  
**Course:** Senior Design (CS 5001 / CS 5002)  
**Team:** Bull riders  
**Members:** Rehman Khalid, Arya Garg, Jace Schubert, Clare Hooper  
**Faculty Advisor:** Hrishikesh Bhide  
**Repository Location:** `/Technical_Specification.md`  

---

## 1. Version and Change Log

| Version | Date | Description of Change | Author |
| :--- | :--- | :--- | :--- |
| **1.0** | 2026-10-28 | Initial creation of technical architecture, interfaces, and traceability matrix. | Jace Schubert |

## 2. Architecture Summary

The **Smart Closet Mirror** architecture employs a distributed, client-server edge deployment that separates high-throughput sensor perception from lightweight presentation. This decomposition resolves the tension between demanding computer vision pipelines and the severe computational limitations of the legacy Android mirror hardware.

```
+-----------------------------------------------------------------------------------+
|                              UBUNTU BRAIN PC (EDGE HOST)                          |
|                                                                                   |
|  +--------------+   I7 (shm)   +----------------+   I8 (bus)   +---------------+  |
|  |  L1 Capture  | -----------> |  L2 Perception | -----------> |    L3 Body    |  |
|  +--------------+              +----------------+              +---------------+  |
|         ^                             |                                |          |
|         | I1 (USB 2.0)                | I10 (pose)                     | I9       |
|         v                             v                                v          |
|  [Kinect 360]                  +----------------+   I12 (bus)  +---------------+  |
|                                |   L5 Try-on    | <----------> |  L6 Decision  |  |
|                                +----------------+              +---------------+  |
|                                       |                                ^          |
|                                       | I4 (H.264 / Wi-Fi)             | I13, I14 |
|                                       v                                v          |
|  +-------------------------------------------------------------+ +-------------+  |
|  |                  SHARED PLANES (REDIS / SQLITE)             | | L4 Wardrobe |  |
|  |   Message Bus (pub/sub), Data Store, Watchdog & Logging     | | L7 Connect  |  |
|  +-------------------------------------------------------------+ +-------------+  |
|                                       |                                ^          |
+---------------------------------------|--------------------------------|----------+
                                        | I6 (WSS)                       | I2, I3   |
                                        v                                v          |
                      +-----------------------------------+    [Phone & Web APIs]   |
                      |   GEN 1 MIRROR (ANDROID 6 THIN)   |                         |
                      |  L8 Presentation: WebView 44 UI   |                         |
                      |  Media3 Video Player (H.264 HW)   |                         |
                      +-----------------------------------+                         |
```

### 2.1 Major Subsystems and Decomposition
1. **L1 Capture (Owner: Rehman Khalid):** Interfaces directly with the Kinect 360 over USB 2.0 (I1). Enforces the privacy consent gate (I27), synchronizes raw 30 fps depth and color streams, and publishes ring-buffered `FrameBundle` pointers into shared memory (`shm`).
2. **L2 Perception (Owner: Arya Garg):** Reads raw frames via `shm` (I7), detects 20 skeletal joints, estimates body circumferences from calibrated depth data, and extracts user gesture intents.
3. **L3 Body (Owner: Arya Garg):** Transforms discrete body measurements into a normalized, rigged anthropometric `BodyModel` (I9).
4. **L4 Wardrobe (Owner: Jace Schubert):** Maintains the personal clothing inventory, processes garment asset uploads via local HTTPS multipart endpoints (I2), and enforces user profile isolation.
5. **L5 Try-on (Owner: Arya Garg):** Computes garment fit tension maps (A1) and renders real-time 2-D pose-driven garment warps (A2), encoding H.264 video streams over local HTTP (I4).
6. **L6 Decision (Owner: Clare Hooper):** Orchestrates styling logic (A4) and buy-or-skip gap evaluations (A5), combining closet inventory with weather and calendar context into UI `DecisionCards`.
7. **L7 Connectors (Owner: Jace Schubert):** Normalizes outside-world data from Open-Meteo (weather) and Google Calendar (events), providing resilient local caching and credential management (I3, I14a–d).
8. **L8 Presentation (Owner: Clare Hooper):** Executes on the Gen 1 Mirror's Android 6 WebView 44 thin client, rendering card decks, managing presence sleep/wake cycles, and driving the consent beacon.
9. **Shared Planes & Glue (Owners: Rehman Khalid & Jace Schubert):** Delivers inter-layer Redis pub/sub messaging, persistent SQLite storage, crash-restart health monitoring, and 6-digit phone pairing authentication.

### 2.2 Deployment and Data Flow
* **Deployment Model:** All computation (L1–L7 and Shared Planes) executes locally on the Ubuntu Brain PC connected to the local home Wi-Fi network. The physical Gen 1 Mirror runs an embedded Android shell executing WebView 44 (HTML5/ES5 UI) and a hardware-accelerated Media3 video surface. Smartphone clients communicate exclusively with the Brain PC over local LAN HTTPS.
* **Flow A (Sensory-to-Glass Pipeline — REQ-07, NFR-01):** Kinect 360 &rarr; L1 Capture &rarr; `shm` (I7) &rarr; L2 Perception &rarr; L5 Try-on &rarr; H.264 Stream (I4) &rarr; Mirror Media3 Player. Strict timing budget: &le; 250 ms end-to-end.
* **Flow B (User Recommendation & Decision Loop — REQ-01, NFR-02):** User Tap / Wake (I5) &rarr; L8 Presentation &rarr; L6 Decision &rarr; L4/L7 Queries (I13, I14) &rarr; Decision Cards &rarr; L8 WebView (I6). Strict timing budget: &le; 5.0 s.
* *Architecture Diagram Reference:* See `Design_Diagrams/D0_High_Level_Design.pdf` (Figures 1 and 2) and `Design_Diagrams/D2_Detailed_Design.pdf` (Figures D2-1 through D2-6).

---

## 3. Component Interfaces, Data Formats, and Protocols

### 3.1 Inter-Subsystem Interface Specifications

| Interface ID | Boundary | Direction | Protocol / Transport | Data Format / Payload Schema | Error Behavior & Handling |
| :--- | :--- | :---: | :--- | :--- | :--- |
| **I1** | Kinect 360 &rarr; L1 | In | USB 2.0 Isochronous | Raw RGB uint8[480][640][3] + 11-bit depth uint16[480][640] at 30 fps | USB disconnect or stall &gt; 2 s triggers L1 down state; auto-reconnect every 5 s (NFR-06). |
| **I2** | Phone &rarr; L4 | In | HTTPS POST | `multipart/form-data` (JPEG photo &le; 8 MB + JSON garment metadata) | 400 Bad Request on invalid category/schema; 409 Conflict on duplicate image hash. |
| **I3** | L7 &harr; Web APIs | Duplex | HTTPS REST / OAuth2 | JSON payloads (Open-Meteo weather readings, Google Calendar v3 events) | Stale cache returned on 429/5xx (REQ-03, NFR-07); token refreshed automatically on 401. |
| **I4** | L5 &rarr; Media3 | Out | HTTP Progressive | H.264 Main Profile in MPEG-TS, 720p (or 480p fallback), 30 fps, &le; 4 Mbps | Buffer underrun causes player reconnect with backoff; L5 throttles bitrate if buffer &gt; 500 ms. |
| **I5** | Mirror &rarr; L8 | In | WebSocket | JSON: `{touch: {x, y, ts}, wake_word: {ts}, voice_cmd: {text, conf}}` | Closed on token mismatch (4401); voice commands with confidence &lt; 0.6 are discarded. |
| **I6** | L8 &rarr; WebView | Out | WebSocket (WSS) | JSON: `ui_state/2{seq, screen: enum, cards: Card[], banner, toast}` | Reconnects every 2 s on socket drop; full state resent idempotently by sequence number. |
| **I7** | L1 &rarr; L2 | Out | Shared Memory (`shm`) | Binary header + ring-buffer slots (0–3) with 64-bit atomic generation counter | Consumer discards frame if generation counter increments during read (NFR-03). |
| **I8** | L2 &rarr; L3 | Out | Redis pub/sub | JSON: `body_measurements/2{user_id, height, chest, waist, hips, rest_joints[20]}` | Measurements published only if confidence &ge; 0.70; otherwise prompts user re-pose. |
| **I9** | L3 &rarr; L5 | Out | Redis pub/sub | JSON: `body_model/1{user_id, profile_id, rest_joints[20], proportions{torso, arm, leg}}` | If model unavailable, L5 falls back to generic bounding-box 2D overlay mode. |
| **I10** | L2 &rarr; L5 | Out | Redis pub/sub | MessagePack binary: `live_pose{seq, ts, joints[20], mask_ref: 640x480 bitmask}` | If person lost &gt; 0.5 s, garments hidden; joints with conf &lt; 0.5 held at last good position. |
| **I11** | L4 &harr; L5 | Duplex | Redis Request/Reply | Request: `garment_id: UUID`; Reply: `GarmentAsset{size_chart, texture_ref, mesh_ref}` | 500 ms timeout; missing assets reported as "Try-on unavailable" in decision view. |
| **I12** | L6 &harr; L5 | Duplex | Redis Request/Reply | Request: `TryOnRequest{user_id, garment_ids[]}`; Reply: `FitReport{overall, issues[]}` | 1.5 s timeout; if timed out, L6 displays recommendation card labeled "Fit pending". |
| **I13** | L4 &rarr; L6 | Out | Redis Query & Events | JSON: `ClosetIndex{items: [{garment_id, category, warmth, water_res, formality}]}` | Stale cached index used if L4 unreachable; flags recommendation as "Offline inventory". |
| **I14a** | L6 &harr; L7 | Duplex | Redis Request/Reply | Request: `user_id, date`; Reply: `ContextEvents{events: [{start, end, title, category}]}` | If calendar unlinked or down, L6 defaults event category to "Casual". |
| **I14d** | L6 &harr; L7 | Duplex | Redis Request/Reply | Request: `lat, lon`; Reply: `WeatherBundle{temp_c, condition: enum, precip_prob, stale}` | Stale cache older than 60 min returns `stale=true`; L6 triggers "Weather unavailable" (REQ-03). |
| **I18** | L8 &rarr; Mirror | Out | Android JS Bridge | JSON: `{cmd: enum{wake, sleep, brightness}, value: int, cmd_id: UUID}` | Mirror shell acknowledges command; unacknowledged commands retried once after 1.0 s. |
| **I21** | Layers &rarr; Ops | Out | Redis pub/sub | JSON: `ops_health{component, state: enum{ok, degraded, down}, detail, fps, p95_ms}` | Watchdog restarts crashed layer process after 3 consecutive missed heartbeats (REQ-06). |
| **I27** | L8 &harr; L1 | Duplex | Redis Request/Reply | Request: `capture.enable{session_id, consent_id}`; Reply: `{state, device_open: bool}` | Rejects with `NO_CONSENT` if consent token invalid or revoked; defaults to camera off (REQ-07/08). |
| **I28** | L8 &harr; Auth | Duplex | Redis Request/Reply | Request: `auth.unlock{user_id, pin}`; Reply: `{session_id, user_id, expires_at}` | Rejects with `WRONG_PIN` (decrements remaining attempts); locks out after 5 failures (NFR-04). |

---

### 3.2 HTTP REST Endpoints

All HTTP endpoints are exposed by the Brain PC on the home LAN over HTTPS with Bearer token authorization:

| Endpoint | Method | Input Parameters | Success Response | Error Responses | Description / Traceability |
| :--- | :---: | :--- | :--- | :--- | :--- |
| `/api/v1/garments` | `POST` | `multipart/form-data`: JPEG photo, category, warmth (1–3), water_resistant | `201 Created` `{garment_id: UUID}` | `400 Validation Error`<br>`401 Unauthorized`<br>`409 Duplicate Hash` | Ingests new clothing photo and metadata (REQ-04). |
| `/api/v1/garments` | `GET` | Query: `category`, `available`, `limit`, `cursor` | `200 OK` `{items: [Garment], next_cursor}` | `400 Bad Query`<br>`401 Unauthorized` | Lists personal inventory for authenticated profile (REQ-04, REQ-09). |
| `/api/v1/garments/{id}` | `PATCH` | JSON: `available: bool`, `warmth: int`, `notes: str` | `200 OK` `{garment_id, ...}` | `400 Bad Input`<br>`401`<br>`404 Not Found` | Updates garment availability or metadata (REQ-05). |
| `/api/v1/garments/{id}` | `DELETE` | Path parameter: `id: UUID` | `204 No Content` | `401 Unauthorized`<br>`404 Not Found` | Permanently deletes garment and associated image (REQ-05). |
| `/api/v1/decisions` | `GET` | Query: `kind: enum`, `limit: int`, `cursor: str` | `200 OK` `{items: [Decision], next_cursor}` | `400 Bad Query`<br>`401 Unauthorized` | Retrieves historical outfit recommendations (REQ-01). |
| `/api/v1/pair` | `POST` | JSON: `{code: "123456", device_name: "Phone"}` | `201 Created` `{device_id, token, user_id}` | `404 Code Unknown`<br>`410 Expired`<br>`429 Too Many Attempts` | Pairs new smartphone via 6-digit mirror code (REQ-09). |
| `/api/v1/profile/pin` | `PUT` | JSON: `{pin: "1234", current_pin: "..."}` | `204 No Content` | `400 Bad PIN Format`<br>`401`<br>`403 Wrong Current PIN` | Sets or updates user profile isolation PIN (REQ-09). |
| `/api/v1/health` | `GET` | None | `200 OK` `{status: enum, components: [...]}` | `401 Unauthorized`<br>`503 Degraded` | Reports overall system and layer status (REQ-06). |

---

## 4. Technology Stack & Constraint Justifications

### 4.1 Technology Stack Selection

| Subsystem / Layer | Selected Technology | Technical Justification | Traceability |
| :--- | :--- | :--- | :--- |
| **Brain PC OS** | Ubuntu 22.04 LTS (x86-64) | Stable Linux kernel with robust USB isochronous support (`libusb`), real-time thread scheduling (`SCHED_FIFO`), and open-source toolchain. | CON-01, CON-04, NFR-06 |
| **Optical Capture** | `libfreenect` / C++20 | Lightweight open-source driver directly interfacing with Kinect 360; provides raw USB control and hardware LED power state toggle. | REQ-07, NFR-03, CON-02 |
| **Inter-Process Comm** | POSIX Shared Memory (`shm`) | Provides zero-copy ring-buffer frame transport between L1 and L2, guaranteeing &lt; 5 ms transport latency. | NFR-01, NFR-03 |
| **Message Bus** | Redis 7.0 (Local Unix Socket) | Microsecond-latency in-memory pub/sub broker; supports structured key-value cache and topic isolation without external network ports. | NFR-01, CON-04 |
| **Database Plane** | SQLite 3.37 (WAL Mode) | Serverless, zero-configuration embedded relational database; ACID transactions with write-ahead logging guarantee integrity across crashes. | REQ-04, REQ-06, CON-04 |
| **Computer Vision / Pose** | MediaPipe Pose / OpenCV (Python/C++) | High-accuracy on-device landmark detection running locally on x86 CPU/GPU without cloud dependencies. | REQ-01, NFR-03, CON-03 |
| **Video Encoding** | FFmpeg / libx264 (or NVENC) | Low-latency progressive H.264 stream encoding targeting baseline profile for legacy Android hardware decode. | NFR-01, CON-01 |
| **Mirror Shell UI** | Chromium 44 / HTML5 / Strict ES5 | Custom single-page application transpiled via Babel to strict ES5; zero external web dependencies; CSS flexbox layout. | NFR-05, CON-05 |
| **Mirror Video Player** | Android Media3 (ExoPlayer) | Native hardware-accelerated H.264 MPEG-TS decoding surface on Android 6, minimizing CPU utilization on the mirror board. | NFR-01, CON-05 |
| **CLI & Service Ops** | Python 3.10 / `systemd` / `scmctl` | Standard Linux daemon supervision; automated crash restart, structured logging, and configuration rollback. | REQ-06 |

### 4.2 Restatement of Constraints and Engineering Consequences

* **CON-01 (Budget & Reuse):** Rules out buying commercial smart mirror platforms or high-end depth cameras (Azure Kinect). Forces repurposing the Gen 1 Mirror as a dumb terminal and executing all compute on existing student PC hardware.
* **CON-02 (Hardware Replacement):** Rules out proprietary or delicate custom electronics. Forces standard USB 2.0 cabling, off-the-shelf Kinect 360 sensor hardware, and pre-built recovery disk images.
* **CON-03 (Bedroom Camera Privacy):** Strictly rules out offloading computer vision to AWS/Google cloud APIs. Forces all pose detection and sizing algorithms to execute locally on the Brain PC.
* **CON-04 (Network & Firmware Security):** Rules out opening public ports or trusting Android 6 firmware security. Forces all mirror communication to remain behind local Wi-Fi, using TLS with pre-shared bearer tokens.
* **CON-05 (DMCA §1201 Compliance):** Rules out reverse engineering proprietary Lululemon binary executables. Forces using the mirror display strictly via standard Android WebView and open media players.
* **CON-06 (IRB Human Subjects Ethics):** Rules out external user trials during Senior Design I/II. Forces all testing and calibration to use only the four team members until institutional approval is granted.

---

## 5. Traceability Matrix

This matrix establishes 100% bidirectional traceability between formal requirements/constraints, architectural design components, and planned verification test cases for the Week 10 Test Plan.

| Req ID | Requirement / Constraint Description | Design Component (D0/D1/D2) | Implementation Status | Planned Test Case |
| :--- | :--- | :--- | :---: | :---: |
| **REQ-01** | Outfit recommendation generated in &le; 5.0 s matching weather/events | L6 Decision, L7 Connectors (I13, I14, A4) | Designed | `TC-01` |
| **REQ-02** | Display missing category notification for incomplete wardrobe | L6 Decision (Fig D2-6, UserAction) | Designed | `TC-02` |
| **REQ-03** | Fall back to occasion-only when weather is stale (&gt; 60 min) or down | L7 Connectors, L6 Decision (I14d, A4) | Designed | `TC-03` |
| **REQ-04** | Ingest garment photo and metadata via phone HTTPS REST API | L4 Wardrobe (`POST /api/v1/garments`, I2) | Designed | `TC-04` |
| **REQ-05** | Update inventory status and delete garments via phone API | L4 Wardrobe (`PATCH / DELETE`, D1 Fig 1) | Designed | `TC-05` |
| **REQ-06** | Inspect status and rollback config via CLI (`scmctl`) in &le; 10 s | Planes: Ops, Health, Watchdog (`scmctl`, I21) | Designed | `TC-06` |
| **REQ-07** | Camera powered down by default; visual consent banner displayed | L1 Capture, L8 Presentation (I27, Fig D2-5) | Designed | `TC-07` |
| **REQ-08** | Optical capture terminated and buffers zeroed &le; 500 ms on revocation | L1 Capture, L8 Presentation (I27, `shm`) | Designed | `TC-08` |
| **REQ-09** | Wardrobe profile isolation with randomized glass PIN unlock keypad | Glue: Auth, L8 Presentation (I28, Fig D2-4) | Designed | `TC-09` |
| **REQ-10** | Calculate and render buy/skip verdict cards with &le; 3 rationale items | L6 Decision (I12, A5, Fig D2-3) | Designed | `TC-10` |
| **REQ-11** | Real-time live 2-D pose-driven garment try-on video overlay | L5 Try-on, L2 Perception (A2, I4, I10) | Planned | `TC-11` |
| **NFR-01** | Motion-to-glass latency &le; 250 ms at &ge; 28 fps | L1, L2, L5, Media3 (Flow A, I1, I4, I7) | Designed | `TC-12` |
| **NFR-02** | Decision cards delivered to WebView &le; 5.0 s under normal load | L6 Decision, L8 Presentation (Flow B, I6) | Designed | `TC-13` |
| **NFR-03** | Optical frames processed in volatile `shm`; zero disk/cloud image writes | L1 Capture, L2 Perception (I7, POSIX `shm`) | Designed | `TC-14` |
| **NFR-04** | Enforce 120 s lockout after 5 consecutive failed PIN attempts | Glue: Auth, L8 Presentation (I28, ProfileLock) | Designed | `TC-15` |
| **NFR-05** | UI text contrast &ge; 4.5:1 against black background on WebView 44 | L8 Presentation (CSS2/3 flexbox, Babel ES5) | Designed | `TC-16` |
| **NFR-06** | Detect USB disconnect in &le; 2 s; auto-re-enumeration every 5 s | L1 Capture, Ops Watchdog (I1, I21, `libusb`) | Designed | `TC-17` |
| **NFR-07** | Cache external API bundles (24h TTL) and answer queries with stale flag | L7 Connectors (I3, I14, CacheEntry) | Designed | `TC-18` |
| **CON-01** | Hardware budget capped at $200; reuse secondhand Mirror & student PC | System Deployment Model (PC Host + Mirror Thin) | Designed | `TC-19` |
| **CON-02** | Off-the-shelf replacement parts; recovery disk images maintained | L1 Capture, Physical Kinect 360 Mounting | Designed | `TC-20` |
| **CON-03** | Bedroom camera privacy; zero raw imagery leaves local LAN | L1, L2, Network Topology (Local LAN Only) | Designed | `TC-21` |
| **CON-04** | Android 6 unpatchable firmware; closed external listening ports | Glue: Auth, Brain PC Firewall Rules (`iptables`) | Designed | `TC-22` |
| **CON-05** | DMCA §1201 compliance; display interface uses open web shell only | L8 Presentation, Mirror WebView 44 / Media3 | Designed | `TC-23` |
| **CON-06** | Human subjects compliance; testing restricted to team members | Project Execution Plan (Internal Test Protocol) | Designed | `TC-24` |

---

## 6. Record of Faculty Advisor Review

### 6.1 Meeting Record
* **Review Date:** November 18, 2026 (30 minutes)
* **Format:** MS Teams Conference
* **Attendees:** Prof. Hrishikesh Bhide (Faculty Advisor), Rehman Khalid, Arya Garg, Jace Schubert, Clare Hooper
* **Artifact Reviewed:** Fall Design Presentation Draft (`Senior design presentation draft.pptx`) & Technical Design Baseline

### 6.2 Feedback Log & Review Summary
The faculty advisor reviewed the system architecture, design specifications, and presentation deck. Prof. Bhide noted that the overall technical structure, layer decomposition (L1–L8), and interface specifications look solid and approved the design without requiring structural redesign. Two specific engineering follow-up directives were established:

| # | Focus / Slides | Advisor Feedback & Directive | Team Response & Decided Action | Status |
| :---: | :--- | :--- | :--- | :---: |
| **F1** | System Design | Overall architecture and presentation deck look good; no structural changes requested. | Accepted. Baseline technical specifications and 8-layer decomposition approved. | Closed |
| **F2** | Lab Hardware Validation | Ensure the system actually functions once lab access is granted; latency targets (250 ms) and demo plans are currently unverified on physical hardware. | Accepted. Hardware bring-up spike (Brain PC, Kinect 360 streaming over `shm`, and Android mirror shell) scheduled immediately upon lab access before freezing end-of-semester targets. | Open (Tracked) |
| **F3** | Schedule Adaptability | Explicitly state in progress and milestone documentation that the schedule and task allocations remain subject to change. | Accepted. Added "Plan subject to change" qualifying annotations to progress, end-of-semester milestone targets, and work distribution matrices. | Closed |

### 6.3 Open Action Items Resulting from Review
* **AI-01 (Hardware Verification Gate):** Conduct end-to-end hardware bring-up and benchmark Kinect 360 isochronous USB throughput and Media3 H.264 video playback on the physical mirror display as soon as lab facility access is provisioned. *(Owner: Team / Rehman & Arya)*
* **AI-02 (Schedule Flexibility Annotation):** Restate in all planning documentation (Tasklist, Milestones, and Gantt timeline) that task sequencing and PERT effort hours are subject to calibration based on lab hardware results. *(Owner: Team / Jace & Clare)*
* **AI-03 (Presentation Recording Protocol):** Conduct audio/video test recording and confirm recording platform, link placement, and submission upload ownership ahead of final presentation delivery. *(Owner: Team)*
