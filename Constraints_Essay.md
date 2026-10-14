# Project Constraints: Smart Mirror Personal Stylist

**Team:** Clare Hooper, Rehman Khalid, Arya Garg, Jace Schubert

## Economic (Manufacturability)

Economics shapes our design directly, because our hardware budget is $200 in personal funds, while a new Lululemon Mirror retailed from $995 before Lululemon stopped selling it in 2023. Reusing one secondhand Mirror lets us keep its display, camera, and enclosure and spend the rest of the budget on compute, which a from-scratch mirror build would not leave room for. Because the team owns only one Mirror, every irreversible hardware change requires a recovery image first, and every added part must be an off-the-shelf component we can replace within one week.

## Security

Security applies because the Mirror's camera faces into a bedroom or dressing area where users stand partly dressed while choosing outfits. We will therefore process all images on the device, send no photos to cloud services, and store only extracted clothing attributes (category, color, pattern), never full-body images. We cannot audit the stock firmware's update schedule, so our build will run its own Linux image with every network port closed except the local interface. Security and economics conflict most in compute, since on-device clothing recognition needs a board such as a Jetson Orin Nano (about $250) instead of a free cloud vision API. We chose privacy over cost and will fund local inference with a smaller model, and we will revisit this at the design review if recognition takes longer than [2] seconds per outfit.

## Legal (Regulatory)

Legal constraints apply to two parts of the project: modifying the Mirror's software and handling images of real people. Because Section 1201 of the DMCA restricts circumventing access controls We will replace its main board and keep only the display, camera, and frame. Testing with anyone outside the team counts as human-subjects data collection, so we will submit to the UC Institutional Review Board before user testing in February and test only on team members until it approves.
