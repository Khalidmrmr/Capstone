# Peer Design Review Notes — Smart Closet Mirror (D2)

**Team bullriders:** Arya Garg, Clare Hooper, Rehman Khalid, Jace Schubert
**Review date:** Week 7
**Reviewer:** Austin Heiss

Rubric criteria: **completeness**, **feasibility**, **clarity**, **risk**.
Priorities: **must-fix**, **worth considering**, **out of scope for now**.
Must-fix items are applied to D2 before submission and marked in D2 part 5 (Design rationale).

## Action items

| ID | Criterion | Issue | Raised by | Action | Owner | Priority | Due |
|----|-----------|-------|-----------|--------|-------|----------|-----|
| PR-01 | Completeness | The four glue components had only proposed owners, and L8 had no lead, so no one was accountable for the screen every layer feeds. | Austin Heiss | Confirm the glue owners and name Clare Hooper as L8 lead (D2 part 2). | Clare Hooper | Must-fix (done) | Week 7 |
| PR-02 | Risk | A7 (look from a photo) has no user story and depends on two providers not yet chosen, so it could take time away from the stories. | Austin Heiss | Move A7 to stretch scope and choose the image and product sources (G1, G9, R9). | Clare Hooper, Jace Schubert | Must-fix (done) | Week 7 |
| PR-03 | Clarity | The user stories and D0–D2 use two different project titles. | Austin Heiss | Use "Smart Closet Mirror" everywhere (G8); User_Stories takes it in its next revision. | Arya Garg | Must-fix (done in D2) | Week 8 |
| PR-04 | Feasibility | L7's retries on the weather call (1 + 2 + 4 s) can push the outfit card past its 5 s budget. | Austin Heiss | Add a 3.5 s deadline on I14d in A4, then fall back to an occasion-only outfit (NF-03, R10). | Clare Hooper | Must-fix (done) | Week 7 |
| PR-05 | Risk | A PIN typed on a shared glass can be watched by someone nearby. | Austin Heiss | Keep the shuffled keypad; evaluate unlocking from the paired phone once the core works (G2, R6). | Jace Schubert | Worth considering | Week 10 |
| PR-06 | Risk | A3's ±2 cm accuracy is untested, and the fit check and buy-or-skip verdict rest on it. | Austin Heiss | Tape-measure test on all four team members in the Week 8 hardware spike; tune the calibration factors (G3). | Arya Garg | Worth considering | Week 9 |
| PR-07 | Feasibility | Phone notifications only appear while the page is open. | Austin Heiss | Web push sends data off the home network; keep in-app notifications (G4). | Clare Hooper | Out of scope for now | Not scheduled |

## Summary

**Criterion that drew the most feedback:** Risk (PR-02, PR-05, PR-06). The review focused on the parts that rest on things we have not yet tested or chosen: measurement accuracy, outside providers, and PIN entry on a shared screen.

**Issues we raised while reviewing other teams:** none for this round. Austin Heiss reviewed our design one way, and we did not review another team's design.
