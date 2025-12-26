## ADR-002: Database Choice – PostgreSQL

**Status:** Accepted

**Date:** 2025-12-26

### Context

The system must:

* Track expenses accurately
* Preserve historical records
* Support auditing and reconciliation
* Perform aggregate calculations reliably

### Decision

Use **PostgreSQL** as the primary database.

### Rationale

* Strong relational guarantees
* Transactional safety
* Precise numeric types for financial data
* Schema constraints enforce correctness at the data layer

### Consequences

**Positive**

* High data integrity
* Clear and enforceable domain rules
* Strong querying capabilities

**Negative**

* Requires upfront schema design
* Less flexible for rapid schema changes
