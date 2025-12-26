## ADR-003: Backend-First Architecture

**Status:** Accepted

**Date:** 2025-12-26

### Context

Multiple clients may interact with the system over time, and correctness must be preserved regardless of client behavior.

### Decision

All business logic, validation, and calculations reside in the backend.

### Rationale

* Single source of truth
* Prevents logic duplication
* Ensures consistent behavior across clients

### Consequences

**Positive**

* Predictable and auditable behavior
* Frontend remains simple

**Negative**

* Backend complexity increases
* Some UI interactions require API round-trips
