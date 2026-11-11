# Tasklist.md — Smart Closet Mirror (Assignment #5)

**Project:** Smart Closet Mirror (Smart Mirror Personal Stylist)  
**Team:** Bull riders  
**Members:** Rehman Khalid, Arya Garg, Jace Schubert, Clare Hooper  
**Course:** Senior Design (CS 5001 / CS 5002)  

T01. Develop the L1 Capture Kinect frame acquisition daemon with USB error recovery and shared-memory ring buffer (I1, I7). Owner: Rehman Khalid.
T02. Develop the Planes Message Bus and Data Store Redis broker and SQLite schema migrations for state and telemetry. Owner: Rehman Khalid.
T03. Develop the L1 Capture privacy consent hardware gate and camera status beacon integration (I27). Owner: Rehman Khalid.
T04. Develop the Planes Logging and Health watchdog service for layer heartbeats, crash restarts, and drop-rate telemetry. Owner: Rehman Khalid.
T05. Validate the L1 Capture and Planes pipeline for sustained 30 fps throughput under 50 ms capture-to-shm latency. Owner: Rehman Khalid.
T06. Develop the L2 Perception body joint detection and T-pose extraction pipeline using depth and RGB streams (I7, I8). Owner: Arya Garg.
T07. Develop the L3 Body avatar generator translating measurement vectors into rigged 3D avatar meshes (I8, I9). Owner: Arya Garg.
T08. Develop the L5 Try-on fit evaluation engine calculating garment tension and size compatibility (I11, I12). Owner: Arya Garg.
T09. Develop the L5 Try-on live garment overlay and 2D pose-driven warp video pipeline (A2, I10). Owner: Arya Garg.
T10. Validate the L2 Perception and L5 Try-on H.264 video stream encoder against the 250 ms motion-to-glass latency budget (I4). Owner: Arya Garg.
T11. Develop the L4 Wardrobe REST ingestion service and image storage for phone-submitted garment assets (I2). Owner: Jace Schubert.
T12. Develop the L7 Connectors calendar and weather normalization adapter with token refresh and stale-cache fallback (I3, I14). Owner: Jace Schubert.
T13. Develop the L7 Connectors product catalog search and external image fetcher with rate limiting (I3, I14). Owner: Jace Schubert.
T14. Develop the Glue: Authentication 6-digit phone-pairing handshake and session authorization handler. Owner: Jace Schubert.
T15. Test the L4 Wardrobe and L7 Connectors offline resilience and data plane consistency under simulated network failures. Owner: Jace Schubert.
T16. Develop the L6 Decision outfit recommendation scoring engine matching closet items to weather and calendar context (I13, I14). Owner: Clare Hooper.
T17. Develop the L6 Decision buy or skip scoring algorithm and wardrobe gap analyzer (I12, I14). Owner: Clare Hooper.
T18. Develop the L8 Presentation WebView UI deck and decision card rendering engine compatible with WebView 44 (I6, I17). Owner: Clare Hooper.
T19. Develop the Glue: Notifications toast broadcast service and Mirror presence/wake controller (I5, I6). Owner: Clare Hooper.
T20. Validate the L6 Decision and L8 Presentation end-to-end user recommendation flow against gesture and voice action timeouts. Owner: Clare Hooper.
