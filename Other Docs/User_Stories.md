# Assignment 4 - User Stories and Use Cases

**Project:** Smart Mirror Personal Stylist  
**Course:** Senior Design  
**Team members:** Rehman Khalid, Jace Schubert, Clare Hooper, Arya Garg  
**Faculty advisor:** Hrishikesh Bhide  
**Repository location:** `/User_Stories.md`  
**Week:** 04

## 1. Stakeholder Map

| Category | Stakeholder | Need / concern |
| --- | --- | --- |
| Primary | Person choosing clothes before work, class, or an event | Receive wearable outfit suggestions based on owned clothing, occasion, and weather. |
| Primary | Wardrobe owner | Keep an accurate inventory of available clothing without excessive manual work. |
| Secondary | Team member maintaining the mirror prototype | Diagnose failures and restore a functioning demonstration without losing configuration. |
| Secondary | Faculty advisor or expo evaluator | See a reproducible demonstration and understand the basis of recommendations. |
| Hidden | Person who may appear in the camera's view, including a visitor | Know when imaging is active and avoid having their image retained without consent. |
| Hidden | Person sharing the mirror with the wardrobe owner | Prevent their wardrobe and preferences from being mixed with someone else's. |

**Elicitation plan (not yet completed):** Use (1) short interviews with at least one wardrobe user, one maintainer/evaluator, and one camera bystander or shared-space user; and (2) observation of a real outfit-selection and wardrobe-entry workflow. Ask each person what they do today, where mistakes occur, and what happens when the system fails. Record dated notes in `docs/elicitation/` or the design notebook. The stories below are provisional requirements derived from the project concept and team contract; they should be revised after stakeholder input rather than presented as validated interview findings.

## 2. User Stories

### US-01 - Weather- and occasion-aware outfit recommendations (Primary)
**As a** person getting dressed for a scheduled activity,  
**I want to** receive outfit suggestions using clothing I own, the occasion, and current weather conditions,  
**so that** I can choose an appropriate outfit without searching through my entire wardrobe.

### US-02 - Maintain a usable wardrobe inventory (Primary)
**As a** wardrobe owner,  
**I want to** add, correct, and remove clothing items in my personal inventory,  
**so that** recommendations reflect the clothes I actually have available.

### US-03 - Recover from prototype failures (Secondary)
**As a** team member responsible for maintaining the mirror,  
**I want to** identify a failed recommendation service and restore the last working configuration,  
**so that** the mirror can be returned to a demonstrable state after a malfunction.

### US-04 - Control camera-based data collection (Hidden)
**As a** person who may be in front of the mirror,  
**I want to** know whether the camera is active and be able to decline image capture,  
**so that** my image is not collected without my permission.

### US-05 - Separate wardrobes for shared use (Hidden)
**As a** person sharing a mirror with someone else,  
**I want to** access only my own wardrobe and preferences,  
**so that** recommendations do not reveal or mix another person's clothing information.

## 3. Use Cases

### UC-01 - Recommend an outfit
**Expands:** US-01  
**Primary actor:** Person selecting an outfit  
**Secondary actors:** Weather data provider; wardrobe inventory service; recommendation engine

**Preconditions (testable):**
1. The mirror is powered on and the recommendation application is available.
2. The active wardrobe contains at least three clothing items, including a top and a bottom, each marked available.
3. The actor has specified an occasion and a location, and the system has a weather report timestamped within the last 60 minutes.

**Main success flow:**
1. **Actor:** Requests an outfit for an occasion (for example, a class presentation).
2. **System:** Retrieves the active wardrobe's available clothing and confirms the occasion.
3. **Actor:** Confirms the location and requests recommendations.
4. **System:** Retrieves the current weather conditions and evaluates available clothing against the occasion and weather.
5. **Actor:** Requests the suggested outfit details.
6. **System:** Presents at least one complete outfit with item names and a short explanation referring to the occasion and weather.

**Alternate flow A1 - No suitable complete outfit:**  
At step 4, if the available items cannot form a complete outfit, the system states that no complete outfit is available, identifies the missing clothing category, and does not invent items.

**Exception flow E1 - Weather data unavailable:**  
At step 4, if the weather service fails or returns data older than 60 minutes, the system labels the weather as unavailable, does not claim a weather-appropriate recommendation, and offers an occasion-only suggestion based on owned clothing.

**Postcondition:** The actor sees a recommendation or a clear explanation of why a complete or weather-aware recommendation cannot be produced. No wardrobe item is modified by this use case.

### UC-02 - Decline camera capture
**Expands:** US-04  
**Primary actor:** Person in front of the mirror  
**Secondary actor:** Camera/capture service

**Preconditions (testable):**
1. The mirror application is running and the camera service is connected.
2. Image capture is disabled until explicit consent is given.
3. The application can report the current camera state.

**Main success flow:**
1. **Actor:** Checks whether camera capture is active.
2. **System:** Shows the current camera state and requests explicit consent before capture.
3. **Actor:** Declines consent.
4. **System:** Leaves image capture disabled and confirms that no image was captured or saved during this interaction.

**Alternate flow A1 - Consent granted:**  
At step 3, if the actor explicitly consents, the system enables capture for the current session and visibly indicates that capture is active; the actor can revoke consent to stop future capture.

**Exception flow E1 - Camera state cannot be verified:**  
At step 2, if the camera service fails to report its state, the application blocks image-dependent functions and displays that camera status is unknown; it does not assert that capture is off.

**Postcondition:** Capture remains disabled after refusal, or image-dependent functions remain blocked if the state cannot be verified.

## 4. Given / When / Then Acceptance Criteria

### UC-01 - Recommend an outfit

**C-01.1 - Main success flow**  
**Given** the active wardrobe has an available top, bottom, and shoes, an occasion is selected, and weather data is no more than 60 minutes old,  
**When** the actor requests an outfit recommendation,  
**Then** the system displays at least one outfit containing an available top, bottom, and shoes, plus a reason mentioning both the selected occasion and a retrieved weather condition.

**C-01.2 - Exception: weather unavailable**  
**Given** the weather service fails or the latest weather record is more than 60 minutes old,  
**When** the actor requests an outfit recommendation,  
**Then** the system displays the text "Weather unavailable", does not label the outfit as weather-appropriate, and offers an occasion-only recommendation or states that no complete outfit is available.

**C-01.3 - Alternate: incomplete wardrobe**  
**Given** the active wardrobe contains no available bottoms,  
**When** the actor requests a complete outfit,  
**Then** the system displays "No complete outfit available" and identifies "bottom" as a missing category without recommending an item absent from the inventory.

### UC-02 - Decline camera capture

**C-02.1 - Main success flow**  
**Given** camera capture is initially disabled and no consent has been granted,  
**When** the actor declines the camera consent request,  
**Then** the camera service remains in the disabled state and the application writes zero new image or video files during the interaction.

**C-02.2 - Exception: camera state unknown**  
**Given** the camera service does not return a verifiable state,  
**When** the actor opens an image-dependent function,  
**Then** the function is blocked and the application displays "Camera status unknown" rather than reporting that capture is off.

**C-02.3 - Alternate: consent revoked**  
**Given** the actor explicitly enabled camera capture for the current session,  
**When** the actor revokes consent,  
**Then** the application stops initiating new captures and indicates that capture is disabled; no additional image or video files are created after revocation.

## 5. Traceability Summary

| Story | Stakeholder category | Use case | Acceptance criteria |
| --- | --- | --- | --- |
| US-01 | Primary | UC-01 | C-01.1, C-01.2, C-01.3 |
| US-02 | Primary | Planned for later design | To be defined |
| US-03 | Secondary | Planned for later design | To be defined |
| US-04 | Hidden | UC-02 | C-02.1, C-02.2, C-02.3 |
| US-05 | Hidden | Planned for later design | To be defined |

**Design and test note:** The timing threshold, minimum outfit components, and exact messages are initial measurable targets proposed for this draft. Confirm them with stakeholders before treating them as final requirements in Weeks 5-9.
