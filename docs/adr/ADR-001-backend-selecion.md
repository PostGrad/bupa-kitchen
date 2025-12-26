## ADR-001: Backend Language Selection – Go

**Status:** Accepted

**Date:** 2025-12-26

### Context

Project Annapurna requires a backend system that handles:

* Financial calculations
* Deterministic estimation logic
* Concurrent request handling
* Long-term maintainability

The backend is expected to own all business logic and data validation.

### Decision

We chose **Go (Golang)** as the primary backend language.

### Rationale

* Predictable performance and low runtime overhead
* Strong concurrency model using goroutines
* Explicit error handling encourages disciplined failure paths
* Minimal framework abstractions keep focus on business logic

### Consequences

**Positive**

* High confidence in runtime behavior
* Clear separation of concerns
* Easy to reason about performance and failures

**Negative**

* Slower initial development compared to dynamic languages
* Less built-in convenience than full-stack frameworks
