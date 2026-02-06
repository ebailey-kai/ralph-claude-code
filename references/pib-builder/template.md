# Product Intent Brief (PIB)

> **Authority note:** This document is the highest-authority statement of product intent. Silence does not imply permission to infer.

---

## 1. Problem and user

- **Primary user(s):**
- **Context / current workflow:**
- **Pain points (ranked):**
- **Why now (trigger or forcing function):**

---

## 2. Outcome

- **Desired outcome (plain language):**
- **What changes for the user:**
- **Success looks like (observable to a user):**
- **Primary success signal (metric or binary condition):**

> **Failure boundary:** If this outcome is not met, is the product considered a failure? (Yes / No)

---

## 3. In-scope capabilities (v1)

List capabilities as **user-facing behaviors**, not features or implementation details.

For each capability, include:
- **What the user can do**
- **What the system must guarantee**

- [ ] Capability 1
- [ ] Capability 2
- [ ] Capability 3

---

## 4. Explicit non-goals (v1)

List behaviors or outcomes the system must *not* attempt, even if they seem adjacent or valuable.

- Non-goal 1
- Non-goal 2
- Non-goal 3

---

## 5. Primary user journeys

Provide 1–3 step-by-step flows that exercise the in-scope capabilities.

### Journey A: <name>
1.
2.
3.

### Journey B: <name>
1.
2.
3.

---

## 6. Quality bar

All items must be **user-visible or user-perceivable**.

- **Must-not-fail behaviors:**
- **Acceptable trade-offs (v1):**
- **Performance / latency expectations (as perceived by a user):**
- **Correctness expectations (what must always be true):**

---

## 7. Constraints

- **Privacy / data constraints:**
- **Compliance constraints (if any):**
- **Budget posture:**
- **Timeline posture:**
- **Operating environment constraints (if relevant):**

### Assumptions (explicit)

List only assumptions that materially affect user-visible behavior, scope, or success.

- Assumption 1 (clearly labeled)
- Assumption 2

---

## 8. Acceptance tests (Given / When / Then)

Rules:
- Distinct behaviors only
- Falsifiable by observation
- Must not restate capabilities verbatim

1. **Given** … **When** … **Then** …
2. **Given** … **When** … **Then** …
3. …

---

## 9. Deferred implementation questions

Capture *how* questions without answering them. These are intentionally out of scope for this PIB.

- Deferred item 1
- Deferred item 2

---

## 10. Open questions (must be resolved before Phase 1)

Only include true **intent blockers** that change user-visible behavior, scope, or success criteria.

- Open question 1
- Open question 2

---

## 11. Intent clarity self-check (author confirmation)

Before considering this PIB complete, confirm:

- [ ] No section relies on inferred tone, philosophy, or preferences
- [ ] Every capability is covered by at least one acceptance test
- [ ] No non-goal is contradicted elsewhere in the document
- [ ] All assumptions are explicit and challengeable

