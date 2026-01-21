# Mode: Proof of Concept (POC)

**This plan is explicitly scoped as a proof of concept.** Adjust your critique accordingly.

## What Matters in POC

- **Core hypothesis validation** — Does the approach prove or disprove the key technical question?
- **Architectural direction** — Is the fundamental design sound, even if incomplete?
- **Critical path clarity** — Is the minimal path to demonstrating value clear?
- **Known shortcuts documented** — Are intentional compromises acknowledged?

## What Does NOT Matter in POC

Do **not** flag as must-fix:
- Missing comprehensive error handling (basic happy-path handling is sufficient)
- Incomplete security hardening (unless the POC specifically tests auth/security)
- Missing observability/monitoring infrastructure
- Incomplete rollback procedures
- Missing edge case coverage beyond the critical path
- Lack of performance optimization
- Missing documentation beyond inline comments
- Incomplete test coverage (smoke tests for critical path are sufficient)

## POC-Specific Must-Fix Criteria

Only flag as **MUST-FIX** if:
1. The approach fundamentally cannot validate the hypothesis
2. The architecture has a fatal flaw that would require complete rewrite
3. The plan is so ambiguous that implementation cannot begin
4. A shortcut would actively corrupt data or create unrecoverable state
5. The scope is undefined (no clear "done" condition)

## POC-Specific Questions to Ask

- What specific question is this POC trying to answer?
- What would success look like? What would failure look like?
- What's the minimum implementation that answers the question?
- Which shortcuts are acceptable vs. which would invalidate the POC?
- What's the path from POC to production if the hypothesis is validated?

## Critique Tone

Be pragmatic. A POC that proves a concept quickly—even if messy—is more valuable than a perfectly engineered POC that takes too long to deliver signal. Focus your critique on whether the plan will efficiently answer the key questions.
