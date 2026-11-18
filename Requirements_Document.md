# Requirements Document — Smart Closet Mirror

**Document Version:** 1.0  
**Status:** Approved Baseline  
**Course:** Senior Design (CS 5001 / CS 5002)  
**Team:** Bull riders  
**Members:** Rehman Khalid, Arya Garg, Jace Schubert, Clare Hooper  
**Faculty Advisor:** Hrishikesh Bhide  
**Repository Location:** `/Requirements_Document.md`  

---

## 1. Version and Change Log

| Version | Date | Description of Change | Author |
| :--- | :--- | :--- | :--- |
| **1.0** | 2026-10-28 | Initial creation and baseline specification of system requirements. | Jace Schubert |

## 2. Purpose and Scope

### 2.1 Purpose
This document establishes the formal functional and non-functional requirements for the **Smart Closet Mirror** (Smart Mirror Personal Stylist). It defines what the system shall do, the measurable operational constraints it must satisfy, and the boundaries of its functionality for the CS 5001/CS 5002 academic year. These requirements serve as the direct contract for implementation verification and provide the validation criteria for the Week 10 Test Plan.

### 2.2 Scope
The Smart Closet Mirror is an edge-computed interactive dressing assistant. It repurposes a Gen 1 interactive smart mirror hardware enclosure (display, microphone, chassis) connected to an off-mirror Ubuntu "brain" PC and an optical depth sensor (Xbox Kinect 360). The system provides context-aware outfit recommendations based on locally inventoried garments, schedule events, and real-time weather, evaluates garment fit, and displays recommendations through a dark-themed user interface on the mirror glass.

**In Scope:**
* Local management of personal clothing inventory via authenticated home-network smartphone client.
* Integration with external weather (Open-Meteo) and Google Calendar APIs via normalized local connectors.
* Real-time body dimension extraction from optical depth sensing and live 2-D pose-driven garment try-on streaming.
* Recommendation engine scoring daily looks and rendering verdict cards ("Wear", "Buy", "Skip").
* Hardware-level and software-enforced camera consent gating and multi-user profile PIN isolation.

**Out of Scope:**
* Cloud-hosted computer vision inference or off-premises storage of body imagery.
* Automated physical clothing handling, motorized retrieval, or garment laundering.
* E-commerce payment processing or in-mirror automated purchase execution.

---

## 3. Stakeholders and User Goals

Derived directly from the stakeholder analysis conducted in Week 4 (`/User_Stories.md`):

| Stakeholder Category | Role / Persona | Core Goals & Concerns | Source Story |
| :--- | :--- | :--- | :--- |
| **Primary** | **Wardrobe Owner / Daily Dresser** | Receives timely, weather- and occasion-appropriate outfit recommendations from owned clothing without manual closet searching; easily inventories garments using a smartphone camera. | US-01, US-02 |
| **Secondary** | **System Maintainer (Team Member)** | Diagnoses service crashes, views live component health, and restores known-good system configurations without losing user wardrobe data. | US-03 |
| **Secondary** | **Advisor & Expo Evaluator** | Witnesses a reliable, deterministic, and privacy-preserving demonstration that visually justifies why specific garments were recommended. | All Stories |
| **Hidden** | **Room Bystander / Visitor** | Faces the mirror in a shared bedroom or dressing area; requires visual proof that the optical sensor is powered down unless active consent has been granted. | US-04 |
| **Hidden** | **Shared Household Member** | Shares the physical mirror with another resident; requires strict data isolation so that personal wardrobe items, photos, and sizing remain confidential. | US-05 |

---

## 4. Glossary

* **Brain PC:** The dedicated Ubuntu 22.04 LTS x86-64 host machine executing all sensor capture, computer vision, recommendation, and local database services.
* **Consent Beacon:** An omnipresent visual indicator rendered on the mirror glass indicating whether optical capture is active ("Camera On") or powered down ("Camera Off").
* **Decision Card:** A structured UI widget rendered on the mirror display summarizing an outfit recommendation, weather rationale, fit evaluation, or buy/skip verdict.
* **FrameBundle:** A synchronized shared-memory data structure containing aligned 640x480 RGB (uint8) and registered depth (uint16 mm) frames from the Kinect 360.
* **Gen 1 Mirror:** A repurposed first-generation Lululemon/Studio Mirror featuring an embedded portrait LCD, one-way reflective glass, directional speakers, and an Android 6.0 motherboard running Chromium/WebView 44.
* **Kinect 360:** An off-the-shelf Microsoft Xbox 360 optical sensor incorporating a 640x480 RGB camera and an infrared structured-light depth projector/sensor.
* **Media3 Player:** The native Android video playback component running inside the mirror shell app, decoding progressive H.264 MPEG-TS video over home Wi-Fi.
* **MoSCoW:** A requirement prioritization framework categorizing items into Must have, Should have, Could have, and Won't have.
* **Shuffled Keypad:** An on-screen numeric keypad whose key positions randomize on each display presentation to prevent PIN shoulder-surfing from smudges or line-of-sight observation.
* **T-Pose:** A standardized user body pose (standing upright with arms extended horizontally) used by perception models to calibrate body height, chest, waist, and inseam dimensions.

---

## 5. Functional Requirements

Functional requirements define the core operational behaviors of the system. Each requirement is stated in mandatory *"The system shall [verb]"* syntax with an objective, testable condition.

| Req ID | Requirement Statement | MoSCoW | Source Story | Verification Method |
| :--- | :--- | :---: | :---: | :--- |
| **REQ-01** | The system shall generate at least one complete outfit recommendation (top, bottom, shoes) matching retrieved calendar event categories and weather conditions within 5.0 seconds of user request. | **Must** | US-01 | Test (automated latency & payload check) |
| **REQ-02** | The system shall display the exact missing clothing category and omit invented garments whenever owned available inventory cannot form a complete outfit. | **Must** | US-01 | Test (simulated partial inventory) |
| **REQ-03** | The system shall label recommendation outputs with "Weather unavailable" and fall back to occasion-only rules whenever external weather data is unavailable or older than 60 minutes. | **Should** | US-01 | Test (simulated network isolation) |
| **REQ-04** | The system shall ingest garment photographs, category tags, warmth ratings (1–3), and water-resistance booleans submitted via local HTTPS REST requests from authenticated smartphones. | **Must** | US-02 | Test (API integration suite) |
| **REQ-05** | The system shall allow users to modify metadata, update availability status, and permanently delete inventoried garments via the local phone interface. | **Should** | US-02 | Inspection (CRUD database verification) |
| **REQ-06** | The system shall provide a command-line interface (`scmctl`) enabling maintainers to inspect subsystem status and roll back configuration to the latest known-good state within 10.0 seconds. | **Must** | US-03 | Demonstration (CLI fault injection test) |
| **REQ-07** | The system shall maintain the Kinect optical sensor in a powered-down, uninitialized state and render an unambiguous "Camera Off" banner until explicit on-screen consent is confirmed by the user. | **Must** | US-04 | Demonstration (hardware beacon & bus inspect) |
| **REQ-08** | The system shall immediately terminate sensor streaming, close the USB device handle, and zero active frame buffers within 500 ms upon user consent revocation or 15-second prompt timeout. | **Must** | US-04 | Test (timeout and revocation event logging) |
| **REQ-09** | The system shall restrict wardrobe inventory, styling history, and measurements to the authenticated profile and display a randomized, shuffled PIN keypad on mirror glass during unlock. | **Must** | US-05 | Inspection & Security Audit |
| **REQ-10** | The system shall calculate and render a "Buy" or "Skip" verdict with at most three itemized rationale statements when evaluating a candidate e-commerce listing against wardrobe gaps. | **Should** | US-01 | Test (listing evaluation test harness) |
| **REQ-11** | The system shall render a real-time live 2-D pose-driven garment try-on video stream overlaid onto the user's reflection when optical capture consent is granted. | **Could** | D1/D2 | Demonstration (visual try-on playback) |

---

## 6. Non-Functional Requirements

Non-functional requirements quantify quality attributes covering performance, security, usability, and reliability. Every requirement incorporates a strict numeric threshold.

| Req ID | Requirement Statement | Category | MoSCoW | Verification Method |
| :--- | :--- | :---: | :---: | :--- |
| **NFR-01** | The system shall maintain an end-to-end motion-to-glass latency not exceeding 250 ms at a sustained minimum frame rate of 28 fps for the live perception and video pipeline. | Performance | **Must** | Test (high-speed camera timestamp delta) |
| **NFR-02** | The system shall render complete recommendation decision cards to the mirror WebView within 5.0 seconds from the receipt of an intent action under normal local network load. | Performance | **Should** | Test (server-to-client telemetry timing) |
| **NFR-03** | The system shall process all RGB and depth video frames strictly within volatile shared memory (`shm`) and write zero raw optical frames to persistent disk or off-premises networks. | Security | **Must** | Inspection (filesystem & packet capture audit) |
| **NFR-04** | The system shall enforce a lockout period of 120 seconds after 5 consecutive failed PIN entry attempts on the mirror glass and reject all wardrobe queries during lockout. | Security | **Should** | Test (automated brute-force test script) |
| **NFR-05** | The system shall render all mirror display typography with a contrast ratio of at least 4.5:1 (WCAG 2.1 AA) against a true-black (`#000000`) background compatible with WebView 44. | Usability | **Must** | Inspection (colorimeter & DOM validation) |
| **NFR-06** | The system shall detect USB optical sensor disconnection within 2.0 seconds, emit an ops alert, and automatically re-attempt USB re-enumeration every 5.0 seconds. | Reliability | **Must** | Test (physical USB disconnect fault injection) |
| **NFR-07** | The system shall cache external calendar and weather bundles with a 24-hour time-to-live and answer queries with `stale = true` when external web services fail or rate-limit requests. | Reliability | **Should** | Test (mock HTTP 429/500 gateway response) |

---

## 7. MoSCoW Prioritization Summary

To ensure an achievable, high-quality Minimum Viable Product (MVP) for Senior Design II implementation without schedule creep, requirements are strictly prioritized:

* **Must Have (MVP Core — 64% of Functional, 57% of Non-Functional):**
  * Core outfit recommendation generation (REQ-01, REQ-02).
  * Ingestion of clothing items over local REST API (REQ-04).
  * System fault reporting and configuration rollback (REQ-06).
  * Complete optical privacy consent hardware gate and instant revocation (REQ-07, REQ-08).
  * Profile PIN data isolation with randomized keypad (REQ-09).
  * 250 ms motion-to-glass pipeline latency budget (NFR-01).
  * Absolute on-device volatile frame privacy guarantee (NFR-03).
  * WebView 44 ES5 visual contrast compliance (NFR-05).
  * Automated sensor USB recovery daemon (NFR-06).

* **Should Have (First-Order Enhancements):**
  * Stale weather fallback logic (REQ-03, NFR-07).
  * Wardrobe inventory editing and deletion (REQ-05).
  * E-commerce buy/skip verdict engine (REQ-10).
  * 5.0-second recommendation decision card budget (NFR-02).
  * PIN brute-force attempt lockout (NFR-04).

* **Could Have (Aspirational Polish):**
  * Live 2-D pose-driven garment try-on video warping (REQ-11).

* **Won't Have for this Release (Explicit Out-of-Scope / Anti-Creep Safeguards):**
  1. *Cloud-based vision processing:* Prohibited by privacy constraint CON-03; zero imagery leaves the local host.
  2. *Facial recognition authentication:* Prohibited to prevent biometric surveillance concerns; profile unlock relies exclusively on PIN (REQ-09).
  3. *Continuous room presence surveillance:* Optical camera will never operate in background while mirror is asleep (REQ-07).
  4. *Physical motorized clothing retrieval:* No electromechanical closet hardware will be constructed (CON-01).
  5. *Multi-camera 3D photogrammetric meshing:* High hardware cost and compute overhead rule out multi-camera setups (CON-01).
  6. *In-mirror automated checkout:* Financial transactions are restricted; system provides styling advice only.

---

## 8. Inherited Project Constraints

Inherited from the Week 3 Constraints Essay (`/Constraints_Essay.md`):

| Constraint ID | Category | Governing Constraint Statement | Engineering Impact |
| :--- | :--- | :--- | :--- |
| **CON-01** | Economic / Budget | Hardware budget is strictly capped at $200 in personal team funds; system must reuse one secondhand Gen 1 Mirror and student compute. | Mandates software-only thin client; rules out commercial smart-glass purchases or expensive GPUs. |
| **CON-02** | Economic / Hardware | Team owns only one physical Mirror chassis; added hardware must be standard off-the-shelf parts replaceable within 7 days. | Requires clean recovery disk images before flashing; enforces standard USB 2.0 peripherals (Kinect 360). |
| **CON-03** | Security / Privacy | Mirror camera directly faces private dressing areas; all visual processing must occur strictly on-device on the home LAN. | Rules out cloud vision APIs (Google Vision, AWS Rekognition); forces local model inference on brain PC. |
| **CON-04** | Security / Network | Stock Android 6 firmware on mirror chassis cannot be audited for security patches; external listening ports must be closed. | Enforces strict local LAN isolation; brain PC acts as firewall; only HTTPS/WSS with local bearer tokens allowed. |
| **CON-05** | Legal / DMCA §1201 | Circumvention of proprietary Android DRM access controls on mirror mainboard is restricted under federal copyright statute. | Restricts mirror board usage to generic web browser display (WebView); rules out reverse-engineering proprietary OS binaries. |
| **CON-06** | Legal / Human Subjects | Testing interactive camera systems with external users constitutes human-subjects data collection requiring institutional oversight. | Testing restricted exclusively to team members until UC Institutional Review Board (IRB) review approval. |

---

## 9. Assumptions and Open Questions

| Item ID | Nature | Description | Owner | Target Date | Status / Resolution |
| :--- | :--- | :--- | :--- | :---: | :--- |
| **A-01** | Assumption | The student Ubuntu brain PC possesses sufficient CPU/GPU capability to encode 720p H.264 video at 30 fps using software x264 or NVENC. | Rehman Khalid | 2026-11-20 | Confirmed viable; fallback to 480p at 24 fps benchmarked. |
| **A-02** | Assumption | Open-Meteo API will remain accessible without API keys and without commercial fee structures for non-commercial student capstone usage. | Jace Schubert | 2026-12-01 | Validated; local hourly caching provides full offline fallback. |
| **Q-01** | Open Question | What is the empirical depth accuracy of the Kinect 360 structured light sensor at 1.5–2.5 meters under indoor lighting? | Arya Garg | 2026-12-08 | Planned hardware spike; calibration offset table implemented in L2. |
| **Q-02** | Open Question | Can the stock Gen 1 Mirror WebView 44 reliably maintain a WebSocket connection under continuous 2 Hz state broadcast without memory leaks? | Clare Hooper | 2026-12-11 | Prototype harness running; heartbeats with auto-reconnect handle drops. |

