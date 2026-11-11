# Work Breakdown Structure (WBS) — Smart Closet Mirror

**Project:** Smart Closet Mirror (Senior Design Project II)  
**Team:** Bull riders (Rehman Khalid, Arya Garg, Jace Schubert, Clare Hooper)  

```
1.0 Project Infrastructure & Sensor Ingestion (Sprint 1)
   1.1 T01: Develop L1 Capture Kinect acquisition daemon & shm ring buffer [Rehman]
   1.2 T02: Develop Planes Message Bus & Data Store (Redis/SQLite) [Rehman]
   1.3 T03: Develop L1 Capture privacy consent gate & camera status beacon [Rehman]
   1.4 T11: Develop L4 Wardrobe REST ingestion service & image store [Jace]
   1.5 T14: Develop Glue Authentication 6-digit phone-pairing handshake [Jace]

2.0 Perception & Normalization Pipeline (Sprint 2)
   2.1 T06: Develop L2 Perception body joint detection & T-pose extraction [Arya]
   2.2 T07: Develop L3 Body avatar generation & rigged glTF mesh pipeline [Arya]
   2.3 T12: Develop L7 Connectors calendar & weather normalization adapter [Jace]
   2.4 T13: Develop L7 Connectors product catalog search & image fetcher [Jace]

3.0 Decision & Virtual Try-On Engine (Sprint 3 & 4)
   3.1 T08: Develop L5 Try-on fit evaluation engine (garment tension mapping) [Arya]
   3.2 T09: Develop L5 Try-on live garment overlay & 2D pose-driven warp video [Arya]
   3.3 T16: Develop L6 Decision outfit recommendation scoring engine [Clare]
   3.4 T17: Develop L6 Decision buy/skip scoring algorithm & wardrobe gap analyzer [Clare]
   3.5 T19: Develop Glue Notifications toast broadcast & presence wakeup [Clare]

4.0 Presentation & Thin-Client Integration (Sprint 4 & 5)
   4.1 T18: Develop L8 Presentation WebView UI deck & decision cards [Clare]
   4.2 T04: Develop Planes Logging & Health watchdog heartbeat service [Rehman]

5.0 Verification, Hardening & Acceptance (Sprint 6 & 7)
   5.1 T05: Validate L1 Capture & Planes sustained 30 fps throughput [Rehman]
   5.2 T10: Validate L2 Perception & L5 Try-on 250 ms motion-to-glass latency [Arya]
   5.3 T15: Test L4 Wardrobe & L7 Connectors offline resilience & fallback [Jace]
   5.4 T20: Validate L6 Decision & L8 Presentation end-to-end decision flow [Clare]
```
