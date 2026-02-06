# Product Intent Brief (PIB) — Interview Flow (Revised)

This interview flow is a **guided intent-extraction process**, not a script. Its purpose is to elicit enough information to produce a **complete, unambiguous PIB** that can drive autonomous specification and implementation without further product-level clarification.

Do not expand the scope of questioning beyond what is necessary to establish intent, scope, success, and constraints.

---

## Step 0 — Elevator pitch

Ask:

- “In one sentence, what do you want this to do for a user?”

Actions:

- Write the draft outcome immediately into the PIB canvas
- Do not refine or optimize wording yet

---

## Step 1 — User and pain

Ask:

- “Who is the primary user?”
- “What are they doing today?”
- “What’s the most painful or frustrating part of that workflow?”

Actions:

- Capture only the dominant pain points
- Avoid secondary or speculative users unless explicitly mentioned

---

## Step 2 — Outcome and success

Ask:

- “What does a great outcome look like for this user?”
- “How would you know it’s working?”
- “If you had to brag, what’s the #1 signal that proves success?”

If no metric exists:

- Translate the outcome into a **binary, observable condition**

### Failure-boundary checkpoint (required)

Ask:

- “If the system did everything else perfectly but failed to deliver this outcome, would you consider the product a failure?”

Actions:

- Record the answer explicitly
- Use it to sharpen acceptance tests and quality bars later

---

## Step 3 — Capabilities and non-goals

Ask:

- “List 3–7 must-have capabilities for v1.”
- “List 3 things we explicitly will not do in v1.”

Guidance:

- Capabilities must be phrased as **user-visible behaviors**
- Non-goals must be enforceable (not vague aspirations)

### Non-inference guardrail (silent rule)

If a capability implicitly assumes:

- UX tone (e.g. simple, playful, minimal)
- User sophistication (e.g. power user vs guided)
- Product philosophy (opinionated vs flexible)

Then:

- Ask **one** clarification question if it materially affects behavior, or
- Record the dimension as **unspecified** and proceed

Do not silently infer preferences.

---

## Step 4 — Primary user journeys

Ask:

- “Walk me through the happy path in 5–8 steps.”

Actions:

- Condense into 1–3 journeys
- Focus on behavior, not screens or implementation

---

## Step 5 — Quality bar and constraints

Ask:

- “What absolutely cannot go wrong?”
- “What’s okay to be imperfect in v1?”
- “Are there any privacy, data handling, or compliance constraints?”
- “Do you have strong budget or timeline constraints?”

Actions:

- Translate answers into user-perceivable quality statements
- Apply default assumptions only when the user is silent

---

## Step 6 — Acceptance tests

Actions:

- Translate capabilities and quality bars into **Given / When / Then** tests
- Each test must describe a distinct, observable behavior

If the user struggles:

- Propose draft tests
- Ask the user to correct or reject them

Do not restate capabilities verbatim.

---

## Step 7 — PIB validation

Present the completed PIB and ask only:

- “Is anything missing or misrepresented?”
- “Are the non-goals accurate?”
- “Do the acceptance tests reflect what you mean?”

Rules:

- Do not reopen implementation discussion
- Do not introduce new capabilities unless correcting an omission

---

## Completion signal

The interview is complete when:

- All PIB sections are filled or marked N/A with rationale
- No unresolved ambiguities affect user-visible behavior, scope, success, or constraints
- Any remaining uncertainty is captured explicitly as an assumption or open question

