# Requirements Document — Smart Closet Mirror

**Team:** Bull Riders — Rehman Khalid, Jace Schubert, Clare Hooper, Arya Garg  
**Course:** Senior Design (CS 5001), University of Cincinnati  
**Faculty advisor:** Dr. Hrishikesh Bhide  
**Document:** `/Requirements_Document.md` · Companion: [`Technical_Specification.md`](Technical_Specification.md)  
**Current version:** 0.9 (draft for advisor review) · 2026-11-17

---

## 1. Version and change log

| Version | Date | Change | Author |
| --- | --- | --- | --- |
| 0.9 | 2026-11-17 | First consolidated draft. Requirements assembled from `User_Stories.md` (Week 4), D0 (Week 5), D1 (Week 6), D2 and peer review (Week 7), `Constraints_Essay.md` (Week 3), the Ethics Statement and the Week 8 plan. D2's interim IDs (US-xx as requirements, NF-01–NF-04) replaced by stable REQ/NFR/CON IDs; mapping in §6.2. | Clare Hooper (drafted with AI assistance, see §10) |
| 1.0 | _[after advisor review]_ | _[Record changes agreed at the advisor review; see Technical Specification §7.]_ | _[name]_ |

**ID rules.** REQ-##, NFR-## and CON-## IDs are permanent. A dropped requirement keeps its ID, is marked **Withdrawn** in its table, and gets a change-log row explaining why. IDs are never renumbered or reused. These IDs are the columns the Week 10 test plan verifies.

## 2. Purpose and scope

**Purpose.** This document states *what* the Smart Closet Mirror must do and for whom. The *how* is in the [Technical Specification](Technical_Specification.md). It consolidates material the team has produced since Week 4; it introduces no new design.

**Product.** The Smart Closet Mirror turns a secondhand Gen 1 Mirror into a closet assistant. A Kinect 360 on the Mirror measures the user; a Ubuntu "brain" PC in the home holds the user's wardrobe, shows garments on the user's body as live video on the glass, recommends what to wear today from owned clothing, occasion and weather, and says whether a shop item is worth buying.

**In scope for this release (Spring 2027 Expo build):** outfit recommendation (weather- and occasion-aware); wardrobe inventory from a paired phone; camera consent; per-person profiles on a shared mirror; maintainer health and configuration rollback; body measurement, fit check and live try-on; buy-or-skip verdict.

**Out of scope:** see the Won't list in §7 (MoSCoW summary). The release is a single-household prototype, not a product for sale.

## 3. Stakeholders and user goals (from Week 4)

| Category | Stakeholder | User goal | Story |
| --- | --- | --- | --- |
| Primary | Person getting dressed for an activity | Receive wearable outfit suggestions from clothes they own, the occasion and current weather. | US-01 |
| Primary | Wardrobe owner | Add, correct and remove clothing items so recommendations reflect what they actually have. | US-02 |
| Secondary | Team member maintaining the prototype | Identify a failed service and restore the last working configuration. | US-03 |
| Secondary | Faculty advisor / Expo evaluator | See a reproducible demonstration and understand why a recommendation was made. | Goal statement |
| Hidden | Person in front of the mirror, including a visitor | Know whether the camera is active and be able to decline capture. | US-04 |
| Hidden | Person sharing the mirror | Access only their own wardrobe and preferences. | US-05 |

The product goal statement (D0 §1) adds three goals no Week 4 story names: *measure the user*, *show clothes on their body*, and *say whether a new piece is worth buying*. D2 gap G9 decided to keep them; they are cited below as source "Goal".

## 4. Glossary

Each term and role is defined once here and used with this meaning in both documents.

| Term | Definition |
| --- | --- |
| **Smart Closet Mirror** | The whole system: Mirror, Kinect, brain PC and phone page. (The Week 4 title "Smart Mirror Personal Stylist" is retired, PR-03.) |
| **Gen 1 Mirror** | The secondhand Android 6 smart mirror reused as the display. It runs a thin shell app with WebView 44 and a Media3 video player. |
| **Glass** | The Mirror's display surface, where cards and try-on video appear. |
| **Brain PC** | The team-owned Ubuntu 24.04 desktop with an NVIDIA GPU that runs every layer. |
| **Kinect** | The Kinect 360 colour + depth sensor clipped to the top of the Mirror. |
| **Layer (L1–L8)** | One of the eight components on the brain PC: L1 Capture, L2 Perception, L3 Body, L4 Wardrobe, L5 Try-on, L6 Decision, L7 Connectors, L8 Presentation. |
| **Planes** | Shared infrastructure used by all layers: data store, message bus, logging and health. |
| **Glue component** | Authentication, Notifications, Configuration, or Logging and health. |
| **Session** | The period from waking the glass until it goes to sleep. Consent and profile unlock last one session. |
| **Camera consent** | The explicit "Allow" given on the glass for one session before the Kinect may open. |
| **Garment** | One clothing item record. A *closet garment* is owned by a user; a *shop garment* has no owner and comes from a Listing. |
| **Wardrobe (closet)** | The set of a user's closet garments with status *active*. |
| **Listing** | One shop's offer (price, currency, URL) for a shop garment. |
| **Size chart** | Body measurements (cm) a garment size is made for. |
| **Ease** | Garment measurement minus body measurement for one zone (chest, waist, hips, shoulder, length), in cm. |
| **Fit report** | Per-zone *tight / good / loose / unknown* result plus a recommended size (algorithm A1). |
| **Body profile** | One saved set of a user's measurements in cm with a confidence 0–1. |
| **T-pose** | Standing facing the Kinect with arms out; used to measure the body (algorithm A3). |
| **Outfit** | A top + bottom (or a dress) + shoes, with optional outerwear. |
| **Occasion** | One of *business, casual, formal, sport*, chosen by the user or derived from a calendar event. |
| **Decision card** | A card on the glass showing an outfit, a buy-or-skip verdict or a look, with up to 3 reasons. |
| **Buy-or-skip verdict** | L6's recommendation on a shop garment, with reasons (algorithm A5). |
| **Stale** | External data older than its freshness limit (weather: 60 min). |
| **Motion-to-glass latency** | Time from the user moving to that movement appearing in try-on video on the glass. |
| **Known-good configuration** | A saved configuration version under which every component reported *ok* for 10 minutes. |
| **scmctl** | The maintainer's command-line tool (status, config check, config rollback). |
| **Device token** | Bearer credential a paired phone or the Mirror sends with each request. |
| **Profile PIN** | 4–6 digit code that unlocks one user's profile on the glass. |
| **Role: User / wardrobe owner** | A household member with a profile and wardrobe (≤ 4 per household). |
| **Role: Person at the glass** | Whoever stands in front of the Mirror, profile or not. |
| **Role: Bystander** | Anyone in the Kinect's view who has not given camera consent. |
| **Role: Maintainer** | A team member operating and repairing the prototype. |
| **Role: Evaluator** | The faculty advisor or an Expo judge. |
| **Role: Provider** | An outside data service (Open-Meteo weather, calendar, Wikimedia Commons images, local product catalogue). |

## 5. Functional requirements

Verification: **T** = test, **D** = demonstration, **I** = inspection, **A** = analysis. Story "Goal" = D0 goal statement (D2 G9).

| ID | Requirement | MoSCoW | Source | Verification |
| --- | --- | --- | --- | --- |
| REQ-01 | The system shall, when an unlocked user requests an outfit and fresh weather is available, display at least one outfit consisting only of that user's *active* garments (a top and a bottom, or a dress, plus shoes) with a reason of ≤ 80 characters naming the occasion and a retrieved weather condition. | Must | US-01 (C-01.1) | T |
| REQ-02 | The system shall, when the weather provider fails or the latest reading is more than 60 minutes old, display the text "Weather unavailable", not label the outfit weather-appropriate, and offer an occasion-only outfit. | Must | US-01 (C-01.2) | T |
| REQ-03 | The system shall, when the wardrobe cannot form a complete outfit, display "No complete outfit available" and name each missing category, recommending zero items absent from the inventory. | Must | US-01 (C-01.3) | T |
| REQ-04 | The system shall accept a garment photo (JPEG or PNG, ≥ 400 × 400 px, ≤ 8 MB) with a category from a paired phone and create a garment record, returning 409 with the existing garment ID when the photo's perceptual hash is within distance 6 of a stored photo. | Must | US-02 | T |
| REQ-05 | The system shall let the owner correct a garment's attributes and remove a garment; a removed garment shall be excluded from the very next recommendation, and a conflicting concurrent edit shall be rejected (HTTP 412) rather than overwrite. | Must | US-02 | T |
| REQ-06 | The system shall keep the Kinect closed by default and open it only after explicit "Allow" on the glass for the current session, and shall always show "Camera on" or "Camera off" while awake. | Must | US-04 (UC-02) | T, D |
| REQ-07 | The system shall, when consent is declined, not answered within 15 s, or revoked, keep or return the Kinect to closed within 1 s and initiate no further capture. | Must | US-04 (C-02.1, C-02.3) | T |
| REQ-08 | The system shall, when camera state cannot be verified within 2 s, block every image-dependent function and display "Camera status unknown", never "Camera off". | Must | US-04 (C-02.2) | T |
| REQ-09 | The system shall show only the unlocked user's garments, cards and notifications; any request for another user's data shall return 403 FORBIDDEN, and 5 consecutive wrong PINs shall lock that profile for 5 minutes. | Must | US-05 | T |
| REQ-10 | The system shall pair a phone with a 6-digit code that expires after 120 s and allows at most 5 attempts, and shall let a user list and revoke their paired devices. | Should | US-02, US-05 | T |
| REQ-11 | The system shall provide a maintainer status command that lists every component as ok / degraded / down and marks a silent component down within 15 s. | Should | US-03 | T |
| REQ-12 | The system shall restore the latest known-good configuration (or a named version) with one command, validate it before applying, and restart affected services, changing nothing if validation fails. | Should | US-03 | T |
| REQ-13 | The system shall measure height, chest, waist, hips, shoulder and inseam from a T-pose and save a body profile only when confidence ≥ 0.7, each value within ±2 cm of a tape measure on all four team members. | Should | Goal | T |
| REQ-14 | The system shall label each zone of each garment size tight / good / loose / unknown against the user's current body profile and recommend one size, returning the fit report within 1.5 s. | Should | Goal | T |
| REQ-15 | The system shall overlay up to 4 selected garments on the live mirrored camera image, following the user's pose, while camera consent is active. | Should | Goal | D |
| REQ-16 | The system shall give a *buy* or *skip* verdict on a shop garment with up to 3 reasons drawn from fit, remaining monthly budget and closet duplicates/gaps. | Could | Goal | T |
| REQ-17 | The system shall derive the occasion from the user's first calendar event of the day when the user does not choose one, defaulting to *casual* when no rule matches. | Could | US-01 | T |
| REQ-18 | The system shall show in-app notifications (glass toast and phone page) for outfit-ready, provider re-link needed, measurement due (30 days) and system notices, merging duplicates with the same key. | Could | US-01, US-03 | T |
| REQ-19 | The system shall build a look from photos of a public figure, matching detected pieces to the closet or shop items. | Won't (this release) | Goal (A7, PR-02) | — |

## 6. Non-functional requirements

| ID | Category | Requirement | MoSCoW | Source | Verification |
| --- | --- | --- | --- | --- | --- |
| NFR-01 | Performance | The system shall display the outfit card within 5 s of the request at p95 over 20 requests, including when the weather call is slow (weather deadline 3.5 s). | Should | US-01; D2 NF-03, PR-04 | T |
| NFR-02 | Performance | The system shall display a buy-or-skip verdict within 2 s of the request at p95 over 20 requests. | Should | Goal; D2 NF-03 | T |
| NFR-03 | Performance | The system shall show try-on motion on the glass within 250 ms of the movement at p95 over 100 consecutive frames at 30 fps. | Should | Goal; D2 NF-04 | T |
| NFR-04 | Reliability (data quality) | The system shall never use a weather reading older than 60 minutes in a recommendation; under normal operation readings shall be ≤ 15 minutes old. | Must | US-01; D2 NF-01 | T |
| NFR-05 | Security / privacy | The system shall write zero image or video files during a session in which consent is declined, and zero after consent is revoked (file count under the data directory unchanged). | Must | US-04; D2 NF-02 | T |
| NFR-06 | Security / privacy | The system shall send no body image, depth frame, measurement or user ID off the home network; outbound requests carry only allowlisted parameters, with location rounded to 0.1°. | Must | US-04; CON-03 | T (packet capture), I |
| NFR-07 | Security | The system shall require a valid device token on every phone and Mirror request (HTTP 401 otherwise) and store PINs and tokens only as argon2id hashes. | Must | US-05 | T, I |
| NFR-08 | Usability | A first-time user shall get today's outfit from a sleeping mirror using touch only, and again using voice only, within 30 s, unaided, in ≥ 4 of 5 trials per mode. | Should | US-01 | T (timed task) |
| NFR-09 | Usability | Glass text shall be ≥ 28 px with contrast ≥ 4.5:1 (WCAG 2.1 AA), and every action shall be reachable by touch and by voice. | Could | D0 §6 accessibility | I |
| NFR-10 | Reliability | The system shall run a 2-hour continuous demonstration with zero failures needing a manual restart; a crashed process shall be restarted automatically within 10 s, and capture shall resume within 10 s of the Kinect being reconnected. | Should | US-03; M16 | T |
| NFR-11 | Reliability | The system shall back up the database and garment files nightly, keep 7 copies, and support a restore in ≤ 15 minutes. | Could | US-02, US-03 | D |

Must count: 13 of 30 requirements (43 %), within the "about half" guide.

### 6.1 Withdrawn requirements

None in v0.9.

### 6.2 Mapping from D2 interim IDs

| D2 ID | Now |
| --- | --- |
| US-01 | REQ-01, REQ-02, REQ-03, REQ-17 |
| US-02 | REQ-04, REQ-05, REQ-10 |
| US-03 | REQ-11, REQ-12 |
| US-04 | REQ-06, REQ-07, REQ-08 |
| US-05 | REQ-09, REQ-10 |
| NF-01 / NF-02 / NF-03 / NF-04 | NFR-04 / NFR-05 / NFR-01 + NFR-02 / NFR-03 |

## 7. MoSCoW summary

**Must (13):** REQ-01, REQ-02, REQ-03, REQ-04, REQ-05, REQ-06, REQ-07, REQ-08, REQ-09, NFR-04, NFR-05, NFR-06, NFR-07.

**Should (11):** REQ-10, REQ-11, REQ-12, REQ-13, REQ-14, REQ-15, NFR-01, NFR-02, NFR-03, NFR-08, NFR-10.

**Could (5):** REQ-16, REQ-17, REQ-18, NFR-09, NFR-11.

**Won't for this release** (written down so it cannot creep back in):

- REQ-19 Look from a photo of a public figure (A7) — stretch only if every Must and Should passes by Week 11 (PR-02, R9).
- Phone push notifications (web push or app push) — would send data off the home network (G4, PR-07).
- Unlocking a profile from the paired phone — evaluate after core works (PR-05).
- Face recognition or presence-detection wake — needs the camera before consent (R4, R6).
- Purchasing, checkout or any payment handling.
- 3-D cloth simulation or neural (VITON-style) try-on (R2).
- Garments shared between household members; more than 4 users; more than one Mirror per household.
- Cloud processing or cloud storage of any user data.
- Native iOS/Android phone app (phone uses a web page).

## 8. Inherited constraints

From the Week 3 constraints essay unless marked. What each rules out or forces is restated in Technical Specification §5.

| ID | Constraint | Origin |
| --- | --- | --- |
| CON-01 | Hardware spending is limited to $200 of personal funds; the team reuses one secondhand Gen 1 Mirror and pays for no cloud services. | Essay — Economic |
| CON-02 | Because the team owns only one Mirror, every irreversible hardware change requires a recovery image first, and every added part must be off-the-shelf and replaceable within one week. | Essay — Economic |
| CON-03 | All image processing happens on the team's own hardware; no photo or body data is sent to a cloud service. | Essay — Security |
| CON-04 | The system runs its own Linux image with every network port closed except those needed on the local interface. | Essay — Security |
| CON-05 | On-device clothing recognition must take ≤ 2 s per outfit; exceeding it triggers a design review. | Essay — Security/Economic |
| CON-06 | The Mirror's software access controls may not be circumvented (DMCA §1201). | Essay — Legal |
| CON-07 | Testing with anyone outside the team requires UC IRB approval; until approved, only team members are test subjects. | Essay — Legal |
| CON-08 | The Mirror runs Android 6 with WebView 44: ES5 JavaScript only, no WebGL, weak GPU, hardware H.264 decode. | D0 §6 (inherited) |
| CON-09 | The Kinect 360 needs a USB 2.0 host and its own 12 V supply, and returns usable depth only between 0.8 m and 4 m. | D0 §6, EC-L1-B (inherited) |

**Change since Week 3, logged:** the essay said only clothing attributes would be stored. D1/D2 added garment photos and body measurements; the Ethics Statement (2026-11-11) accepts this only behind an explicit per-item user choice. CON-03 is unchanged (nothing leaves the home).

## 9. Assumptions and open questions

### 9.1 Assumptions

| # | Assumption | If false |
| --- | --- | --- |
| AS-1 | One household: ≤ 4 users, ≈ 300 closet garments, ≈ 2,000 cached shop items. | Re-check D1 indexes and A1 timing. |
| AS-2 | The brain PC (Clare Hooper's Ubuntu desktop) has a working NVIDIA GPU and NVENC. | libx264 fallback at 20 fps; NFR-03 at risk. |
| AS-3 | The Mirror, brain PC and phone share one home Wi-Fi network. | Pairing and video streaming fail. |
| AS-4 | Users stand 1.5–3 m from the Kinect and face the mirror during try-on. | A2 fades garments ("face the mirror"). |
| AS-5 | Voice commands are English and come from a fixed list. | NFR-08 voice trials fail. |
| AS-6 | Open-Meteo remains free for non-commercial use without an API key. | Choose another provider behind the L7 adapter. |

### 9.2 Open questions

| # | Question | Owner | Due |
| --- | --- | --- | --- |
| OQ-1 | The Week 8 task list (T02) and timeline say "Redis broker", but D1 §6 chose ZeroMQ and rejected Redis. Which is the plan of record? | Rehman Khalid | 2026-11-24 |
| OQ-2 | T07 says L3 builds "rigged 3D avatar meshes", but D2 replaced the mesh with a BodyModel (I9 revision). Update T07 or the design? | Arya Garg | 2026-11-24 |
| OQ-3 | T19 mentions a "Mirror presence/wake controller", but D2 R4 removed camera presence detection (wake by touch or voice only). Confirm T19's scope. | Clare Hooper | 2026-11-24 |
| OQ-4 | Risk R01 plans a Babel ES5 transpile; D1 §6 says plain ES5 with no build tools. Pick one. | Clare Hooper | 2026-11-24 |
| OQ-5 | CON-06: the essay planned to replace the Mirror's main board; D0–D2 run a shell app on the Mirror's own Android 6 board. Does installing the shell app require bypassing any access control? If yes, the board-replacement plan returns. | Jace Schubert | 2026-12-11 (M09) |
| OQ-6 | REQ-13: is ±2 cm achievable? Tape-measure results from the Week 8 hardware spike (G3, PR-06) are not yet recorded. | Arya Garg | 2027-02-05 (M11) |
| OQ-7 | Kinect depth quality under the Mirror's lighting at 1–3 m (G6). | Rehman Khalid | 2026-12-11 (M09) |
| OQ-8 | When will the IRB protocol be submitted, so NFR-08 trials can include non-team users before the Expo? (CON-07) | Clare Hooper | 2026-12-11 |
| OQ-9 | Stakeholder interviews planned in Week 4 have not happened; thresholds (60 min, 5 s, 30 s) are still team-proposed. | Arya Garg | 2027-01-22 |
| OQ-10 | `Project-Description.md` still describes trading algorithms. Update to the Smart Closet Mirror. | Jace Schubert | 2026-11-24 |

## 10. AI-use note

Consistent with the team's Ethics Statement §5, a generative AI assistant was used to consolidate and format material from the team's earlier documents. Requirement priorities, thresholds and the Won't list come from the team's D0–D2 decisions and must be confirmed by the team at the advisor review.
