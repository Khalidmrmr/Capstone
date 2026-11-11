# Table 1: Project Timeline & Dependencies

Implementation horizon: January 11, 2027 – April 01, 2027 (Senior Design II Expo: April 2027).

| Task/Milestone ID | Statement | Owner | Start Date | Completion Date | Dependencies | Buffer Allocation & Risk Visibility |
| --- | --- | --- | --- | --- | --- | --- |
| T01 | Develop the L1 Capture Kinect frame acquisition daemon with USB error recovery and shared-memory ring buffer (I1, I7) | Rehman | 2027-01-11 | 2027-01-22 | None | 2 days (20%) buffer. Addresses Risk R05 (Kinect USB drop recovery). |
| T02 | Develop the Planes Message Bus and Data Store Redis broker and SQLite schema migrations for state and telemetry | Rehman | 2027-01-11 | 2027-01-22 | None | 2 days (20%) buffer. |
| T11 | Develop the L4 Wardrobe REST ingestion service and image storage for phone-submitted garment assets (I2) | Jace | 2027-01-11 | 2027-01-22 | None | 2 days (20%) buffer. |
| T14 | Develop the Glue: Authentication 6-digit phone-pairing handshake and session authorization handler | Jace | 2027-01-11 | 2027-01-22 | None | 2 days (20%) buffer. |
| M10 | MILESTONE: Sensor Ingest & Data Plane Skeleton Operational | Rehman & Jace | 2027-01-22 | 2027-01-22 | T01, T02, T11, T14 | Protected Milestone Checkpoint. |
| T03 | Develop the L1 Capture privacy consent hardware gate and camera status beacon integration (I27) | Rehman | 2027-01-25 | 2027-02-05 | T01, T02 | 2 days (20%) buffer. |
| T06 | Develop the L2 Perception body joint detection and T-pose extraction pipeline using depth and RGB streams (I7, I8) | Arya | 2027-01-25 | 2027-02-05 | T01 | 2 days (20%) buffer. Addresses Risk R06 (Sensor stability). |
| T12 | Develop the L7 Connectors calendar and weather normalization adapter with token refresh and stale-cache fallback (I3, I14) | Jace | 2027-01-25 | 2027-02-05 | T02 | 2 days (20%) buffer. Addresses Risk R03 (API rate limit mitigation). |
| M11 | MILESTONE: Perception & Context Normalization MVP Operational | Arya & Jace | 2027-02-05 | 2027-02-05 | T03, T06, T12 | Protected Milestone Checkpoint. |
| T07 | Develop the L3 Body avatar generator translating measurement vectors into rigged 3D avatar meshes (I8, I9) | Arya | 2027-02-08 | 2027-02-19 | T06 | 2 days (20%) buffer. |
| T13 | Develop the L7 Connectors product catalog search and external image fetcher with rate limiting (I3, I14) | Jace | 2027-02-08 | 2027-02-19 | T12 | 2 days (20%) buffer. |
| T16 | Develop the L6 Decision outfit recommendation scoring engine matching closet items to weather and calendar context (I13, I14) | Clare | 2027-02-08 | 2027-02-19 | T02, T12 | 2 days (20%) buffer. |
| M12 | MILESTONE: Body Avatar & Recommendation Core Operational | Clare & Arya | 2027-02-19 | 2027-02-19 | T07, T13, T16 | Protected Milestone Checkpoint. |
| T08 | Develop the L5 Try-on fit evaluation engine calculating garment tension and size compatibility (I11, I12) | Arya | 2027-02-22 | 2027-03-05 | T07 | 2 days (20%) buffer. |
| T09 | Develop the L5 Try-on live garment overlay and 2D pose-driven warp video pipeline (A2, I10) | Arya | 2027-02-22 | 2027-03-05 | T08 | 2 days (20%) buffer. Addresses Risk R02 (250ms latency margin). |
| T17 | Develop the L6 Decision buy or skip scoring algorithm and wardrobe gap analyzer (I12, I14) | Clare | 2027-02-22 | 2027-03-05 | T16 | 2 days (20%) buffer. |
| T18 | Develop the L8 Presentation WebView UI deck and decision card rendering engine compatible with WebView 44 (I6, I17) | Clare | 2027-02-22 | 2027-03-05 | T16 | 2 days (20%) buffer. Addresses Risk R01 (ES5/WebView 44 polyfills). |
| M13 | MILESTONE: Try-on Stream & Glass Presentation Alpha Verified | Clare & Rehman | 2027-03-05 | 2027-03-05 | T08, T09, T17, T18 | Protected Milestone Checkpoint. |
| T04 | Develop the Planes Logging and Health watchdog service for layer heartbeats, crash restarts, and drop-rate telemetry | Rehman | 2027-03-08 | 2027-03-12 | T02 | 1 day (20%) buffer. |
| T19 | Develop the Glue: Notifications toast broadcast service and Mirror presence/wake controller (I5, I6) | Clare | 2027-03-08 | 2027-03-12 | T02, T18 | 1 day (20%) buffer. |
| RECESS | SPRING BREAK (University Holiday — Scheduled Academic Hiatus) | Team | 2027-03-15 | 2027-03-21 | None | Addresses Risk R04 (Mid-semester workload & burnout). |
| T05 | Validate the L1 Capture and Planes pipeline for sustained 30 fps throughput under 50 ms capture-to-shm latency | Rehman | 2027-03-22 | 2027-03-26 | T01, T03, T04 | 1 day (20%) buffer. |
| T10 | Validate the L2 Perception and L5 Try-on H.264 video stream encoder against the 250 ms motion-to-glass latency budget (I4) | Arya | 2027-03-22 | 2027-03-26 | T09 | 1 day (20%) buffer. Addresses Risk R02. |
| T15 | Test the L4 Wardrobe and L7 Connectors offline resilience and data plane consistency under simulated network failures | Jace | 2027-03-22 | 2027-03-26 | T11, T13 | 1 day (20%) buffer. Addresses Risk R03. |
| T20 | Validate the L6 Decision and L8 Presentation end-to-end user recommendation flow against gesture and voice action timeouts | Clare | 2027-03-22 | 2027-03-26 | T17, T18 | 1 day (20%) buffer. |
| M14 | MILESTONE: Subsystem Integration & 250 ms Latency Gate Passed | Entire Team | 2027-03-26 | 2027-03-26 | T05, T10, T15, T20 | Protected System Gate. |
| M15 | MILESTONE: Final Project Completion & Acceptance Freeze | Advisor & Team | 2027-04-01 | 2027-04-01 | M14 | Formal Code Freeze & Final System Verification. |
| M16 | MILESTONE: Senior Design II Expo Demonstration | Expo Evaluators | 2027-04-15 | 2027-04-15 | M15 | Live Public Presentation & Judging. |
