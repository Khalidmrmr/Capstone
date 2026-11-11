# Table 2: Effort Matrix & Workload Distribution

Division of labor in estimated hours per task and team member using PERT (O + 4M + P) / 6.

| Task ID | Task Statement | Rehman (hrs) | Arya (hrs) | Jace (hrs) | Clare (hrs) | Total Hours | Primary Owner |
| --- | --- | --- | --- | --- | --- | --- | --- |
| T01 | Develop L1 Capture Kinect acquisition daemon & shm buffer | 26 | 4 | 2 | 0 | 32 | Rehman Khalid |
| T02 | Develop Planes Message Bus & Data Store (Redis/SQLite) | 24 | 2 | 4 | 2 | 32 | Rehman Khalid |
| T03 | Develop L1 Capture privacy consent hardware gate | 20 | 0 | 2 | 4 | 26 | Rehman Khalid |
| T04 | Develop Planes Logging & Health watchdog service | 22 | 2 | 2 | 2 | 28 | Rehman Khalid |
| T05 | Validate L1 Capture & Planes 30 fps throughput | 22 | 4 | 2 | 0 | 28 | Rehman Khalid |
| T06 | Develop L2 Perception joint detection & T-pose pipeline | 4 | 26 | 0 | 0 | 30 | Arya Garg |
| T07 | Develop L3 Body avatar rigged mesh generator | 0 | 26 | 0 | 2 | 28 | Arya Garg |
| T08 | Develop L5 Try-on fit evaluation engine | 0 | 24 | 2 | 4 | 30 | Arya Garg |
| T09 | Develop L5 Try-on live garment overlay & 2D warp pipeline | 2 | 28 | 0 | 2 | 32 | Arya Garg |
| T10 | Validate L2/L5 H.264 video stream 250ms latency | 4 | 22 | 0 | 2 | 28 | Arya Garg |
| T11 | Develop L4 Wardrobe REST ingestion & image store | 2 | 0 | 26 | 2 | 30 | Jace Schubert |
| T12 | Develop L7 Connectors calendar/weather adapter | 0 | 0 | 24 | 4 | 28 | Jace Schubert |
| T13 | Develop L7 Connectors catalog search & image fetcher | 0 | 0 | 24 | 4 | 28 | Jace Schubert |
| T14 | Develop Glue: Auth 6-digit phone-pairing handshake | 2 | 0 | 22 | 2 | 26 | Jace Schubert |
| T15 | Test L4/L7 offline resilience & consistency fallback | 2 | 0 | 22 | 2 | 26 | Jace Schubert |
| T16 | Develop L6 Decision outfit recommendation scoring engine | 0 | 2 | 4 | 26 | 32 | Clare Hooper |
| T17 | Develop L6 Decision buy/skip algorithm & gap analyzer | 0 | 2 | 2 | 24 | 28 | Clare Hooper |
| T18 | Develop L8 Presentation WebView UI deck & cards | 0 | 0 | 4 | 28 | 32 | Clare Hooper |
| T19 | Develop Glue: Notifications toast broadcast & presence | 2 | 0 | 2 | 22 | 26 | Clare Hooper |
| T20 | Validate L6/L8 end-to-end decision flow & timeouts | 2 | 2 | 2 | 22 | 28 | Clare Hooper |
| TOTALS | Sum of estimated labor hours | 134 | 144 | 146 | 154 | 578 | Balanced |

### Workload Rebalancing Plan
Total estimated effort is 562 hours across 11.5 implementation weeks (~12 hours/week per student). Member totals (132 to 150 hours) are within a 12% balance margin. If Clare's WebView 44 integration requires extra time, Jace Schubert will take over 10 hours of presentation card template binding (T18), balancing Clare at 140 hours and Jace at 150 hours.
