# Project Annapurna

### BUPA Kitchen Management & Estimation System

Project Annapurna is a backend-first kitchen management and estimation system designed to solve real-world operational challenges faced by large community kitchens. It focuses on correctness, data integrity, and long-term maintainability rather than UI complexity.

The system enables accurate expense tracking, structured recipe management, and data-driven estimation of ingredient quantities and costs for large gatherings.

---

## Why This Project Exists

Community kitchens often rely on spreadsheets and manual processes to:

- Track expenses across volunteers
- Estimate ingredient quantities for events
- Reconcile historical financial data
- Plan future events efficiently

These approaches break down as scale increases.

**Project Annapurna** replaces ad-hoc workflows with a structured, auditable, and extensible backend system while keeping the frontend intentionally simple.

---

## Core Design Principles

- Backend owns the truth
- Explicit data modeling
- Predictable behavior
- Incremental complexity
- Boring technology, thoughtful design

---

## Architecture Overview

```
Client (React PWA)
        |
        | REST / JSON
        v
Go Backend API
        |
        | SQL / Transactions
        v
PostgreSQL
```

---

## Domain Model (High Level)

### Core Entities

* **Users** - admins, volunteers, viewers
* **Events** - individual kitchen events
* **Ingredients** - standardized raw materials
* **Menu Items** - dishes prepared
* **Recipes** - ingredient quantities per 100 pax
* **Expenses** - financial ledger entries

The schema supports:

* Historical tracking
* Accurate cost computation
* Predictive estimation

## Technology Stack

### Backend

- Go (Golang)
- Gin / Chi
- SQLX / GORM
- Excelize
- shopspring/decimal

### Frontend

- React (Vite)
- Zustand
- TanStack Query
- Shadcn UI

### Database

- PostgreSQL

### Infrastructure

- Docker & Docker Compose

---

## Backend Architecture

```
/cmd/api
  main.go

/internal
  /models        → Database models
  /handlers      → HTTP controllers
  /services      → Business logic
  /repository    → Data access layer

/pkg
  /utils         → Excel parsing, helpers
```

---

## Key Features

- Event & expense tracking
- Excel-based legacy data import
- Deterministic estimation engine
- Role-based access control
- Financially safe decimal math

---

## Estimation Logic (Simplified)

```
scaleFactor := float64(pax) / 100

for each recipe:
  totalQty[ingredient] += recipe.qtyPer100 * scaleFactor

estimatedCost = totalQty * ingredient.avgPrice
```

---

## Frontend Responsibilities

The frontend is intentionally thin.

It:

* Displays server-computed data
* Handles user input and navigation
* Provides sorting, filtering, and dashboards
* Avoids duplicating business rules

### Key Screens

* Events dashboard
* Event details (menu, expenses)
* Estimator tool
* Admin Excel import panel

---

## Security & Data Integrity

* JWT-based authentication
* Role-based access control
* Input validation on all write operations
* Decimal-based financial calculations
* Strict database constraints
* No business logic in the frontend

---

## Phased Implementation

### Phase 1 - Core Foundation

* Backend setup (Go + PostgreSQL)
* Users, Events, Expenses APIs
* Minimal frontend for expense entry

**Outcome:**

Replace manual expense tracking for upcoming events.

---

### Phase 2 - Data Migration

* Excel import service
* Ingredient normalization
* Historical data seeding

**Outcome:**

Clean, structured data foundation.

---

### Phase 3 - Intelligence Layer

* Recipe management
* Estimation service
* Calculator UI

**Outcome:**

Data-driven planning instead of guesswork.

---

## What This Project Demonstrates

- Backend system design
- Clean architecture
- Data correctness
- Real-world problem solving

---

## Author

Built by Pranay Patel
