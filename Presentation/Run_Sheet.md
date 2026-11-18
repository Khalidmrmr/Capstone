# Run Sheet — Fall Design Presentation

**Project:** Smart Closet Mirror
**Team:** Bull Riders — Arya Garg, Clare Hooper, Rehman Khalid, Jace Schubert
**Faculty advisor:** Hrishikesh Bhide
**Deck:** `Bullriders_presentation_final.pdf` (source: `Senior design presentation.pptx`)
**Time limit:** 10 minutes presenting + 5 minutes of questions · **Target:** 6:00
**Timekeeper:** Clare

## 1. Speaking roles

| Speaker | Slides | Section | Planned time |
| --- | --- | --- | --- |
| Clare Hooper | 1–4 | Title, team, purpose and goal, abstract | 1:30 + slide 3 |
| Arya Garg | 5–6 | User stories, system block diagram | 1:30 |
| Jace Schubert | 7–8 | Constraints, progress | 1:30 |
| Rehman Khalid | 9–11 | End-of-semester targets, division of work, Expo demo | 1:30 |
| All | 14–22 (backup) | Questions, using the backup slides | up to 5:00 |

## 2. Slide run sheet

Start times are cumulative from the planned seconds in the speaker notes. Slide 3 (Purpose & Goal) was added after the timing table was drafted and has no planned time yet; times after it assume 0 s for it.

| Slide | Title | Speaker | Planned start | Seconds | Hand-off line |
| --- | --- | --- | --- | --- | --- |
| 1 | Smart Closet Mirror | Clare | 0:00 | 25 | — |
| 2 | Our Team | Clare | 0:25 | 20 | — |
| 3 | Purpose & Goal | Clare | 0:45 | [s] | — |
| 4 | Abstract | Clare | 0:45 | 45 | "Arya will take us through the requirements and design." |
| 5 | User Stories | Arya | 1:30 | 40 | — |
| 6 | System Block Diagram | Arya | 2:10 | 50 | "Jace will cover our constraints." |
| 7 | Main Constraints | Jace | 3:00 | 45 | — |
| 8 | Progress | Jace | 3:45 | 45 | "Rehman will cover what's next." |
| 9 | Target By End of Semester | Rehman | 4:30 | 30 | — |
| 10 | Division of Work | Rehman | 5:00 | 25 | — |
| 11 | Expo Demo Plan | Rehman | 5:25 | 35 | "Thank you, we're happy to take questions." |
| — | End of talk | | 6:00 | | |

Slides 12–13 (Speakers and Timing, Recording Plan) are planning slides and are skipped when presenting. Slides 14–22 are backup for questions.

## 3. Anticipated questions

Owners follow the division of work. Answers come from the deck's backup slides and speaker notes.

| # | Question | Owner | Short answer | Backup slide |
| --- | --- | --- | --- | --- |
| Q1 | How do you keep live try-on fast enough to feel like a mirror? | Arya | A 250 ms budget split across capture, body tracking, garment drawing + encode, and Wi-Fi + decode; each stage keeps only the newest frame, garments are warped on the GPU instead of cloth simulation, and resolution drops if frames run slow. Checked at M14. | 18 |
| Q2 | How accurate are the body measurements? | Arya | Front and side T-pose depth gives chest, waist and hip width and thickness, each treated as an ellipse. Target is ±2 cm; not yet tested. | 19 |
| Q3 | Why rule-based instead of machine learning for outfits and buy-or-skip? | Clare | No training data, and every answer has to explain itself with reasons. Rules are fast at household scale. | 19 |
| Q4 | What stops the camera from recording people in a bedroom? | Rehman | Off by default, on only after "Allow" for one session; blocked if its state can't be verified; frames stay in shared memory and are never written to disk. | 17, 20 |
| Q5 | Does any personal data leave the house? | Jace | Only the connectors layer reaches the internet, through an allowlist; weather gets a location rounded to about 10 km. Body data and images stay home. | 20 |
| Q6 | What happens when something fails, e.g. weather is down? | Jace | Every failure has a decided behaviour (retry, degrade, fall back, surface error). Stale weather gives an occasion-only outfit with a label; 56 edge cases are catalogued. | 21 |
| Q7 | Is modifying the mirror legal? | Jace | We replace the main board rather than break the firmware, to stay clear of DMCA anti-circumvention rules. | 7 |
| Q8 | What if the live Expo demo fails? | Rehman | We play a recorded run of the same six steps; with no network, the mirror falls back to cached weather and catalog data. | 11 |
| Q9 | How is the data stored? | Rehman | One SQLite file with 21 tables; every query is scoped to the unlocked user's profile. | 15 |
| Q10 | How did you use AI? | Clare | Layout, styling and wording drafts; requirements, design and plan content are the team's own, and every slide was reviewed by the team. | 22 |

## 4. Rehearsal log

At least one full-group timed rehearsal is required. Record per-section time for each speaker's block.

| # | Date | Attendees | Clare (1–4) | Arya (5–6) | Jace (7–8) | Rehman (9–11) | Total | Notes / changes made |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| R1 | [2026-11-16] | [Clare, Arya, Jace, Rehman] | [1:29] | [2:00] | [1:25] | [1:30] | [2:00] | |
| R2 | [2026-11-17] | [Clare, Arya, Jace, Rehman] | [2:09] | [1:31] | [1:32] | [1:35] | [1:42] | |
