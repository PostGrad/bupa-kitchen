-- Project Annapurna - Database Schema
-- Phase 1: Core Foundation (Users, Events, Expenses)
-- 
-- ADR-002: PostgreSQL for strong relational guarantees,
-- transactional safety, and precise numeric types for financial data

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- ENUM TYPES
-- ============================================

-- User roles as per README: admins, volunteers, viewers
CREATE TYPE user_role AS ENUM ('admin', 'volunteer', 'viewer');

-- Event status for tracking lifecycle
CREATE TYPE event_status AS ENUM ('planned', 'in_progress', 'completed', 'cancelled');

-- Expense category for classification
CREATE TYPE expense_category AS ENUM (
    'ingredients',
    'equipment', 
    'transport',
    'utilities',
    'labor',
    'miscellaneous'
);

-- ============================================
-- USERS TABLE
-- ============================================
-- Core entity: Manages authentication and authorization
-- Roles: admin (full access), volunteer (entry), viewer (read-only)

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    role user_role NOT NULL DEFAULT 'viewer',
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Index for email lookups during authentication
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);

-- ============================================
-- EVENTS TABLE
-- ============================================
-- Core entity: Represents kitchen events/gatherings
-- Tracks event details, expected attendance, and status

CREATE TABLE events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    event_date DATE NOT NULL,
    location VARCHAR(255),
    expected_pax INTEGER NOT NULL CHECK (expected_pax > 0),
    actual_pax INTEGER CHECK (actual_pax >= 0),
    status event_status NOT NULL DEFAULT 'planned',
    notes TEXT,
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Index for date-based queries
CREATE INDEX idx_events_date ON events(event_date);
CREATE INDEX idx_events_status ON events(status);
CREATE INDEX idx_events_created_by ON events(created_by);

-- ============================================
-- EXPENSES TABLE
-- ============================================
-- Core entity: Financial ledger for tracking all expenses
-- Uses NUMERIC for precise decimal calculations (ADR-002)

CREATE TABLE expenses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    description VARCHAR(500) NOT NULL,
    category expense_category NOT NULL,
    amount NUMERIC(12, 2) NOT NULL CHECK (amount >= 0),
    quantity NUMERIC(10, 3) CHECK (quantity > 0),
    unit VARCHAR(50),
    vendor VARCHAR(255),
    receipt_number VARCHAR(100),
    expense_date DATE NOT NULL,
    paid_by UUID REFERENCES users(id),
    notes TEXT,
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Indexes for common queries
CREATE INDEX idx_expenses_event ON expenses(event_id);
CREATE INDEX idx_expenses_category ON expenses(category);
CREATE INDEX idx_expenses_date ON expenses(expense_date);
CREATE INDEX idx_expenses_paid_by ON expenses(paid_by);

-- ============================================
-- TRIGGER: Auto-update updated_at
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_events_updated_at
    BEFORE UPDATE ON events
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_expenses_updated_at
    BEFORE UPDATE ON expenses
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- VIEWS FOR COMMON QUERIES
-- ============================================

-- Event summary with total expenses
CREATE VIEW event_expense_summary AS
SELECT 
    e.id,
    e.name,
    e.event_date,
    e.expected_pax,
    e.actual_pax,
    e.status,
    COUNT(ex.id) AS expense_count,
    COALESCE(SUM(ex.amount), 0) AS total_expenses,
    CASE 
        WHEN e.actual_pax > 0 THEN ROUND(COALESCE(SUM(ex.amount), 0) / e.actual_pax, 2)
        WHEN e.expected_pax > 0 THEN ROUND(COALESCE(SUM(ex.amount), 0) / e.expected_pax, 2)
        ELSE 0
    END AS cost_per_person
FROM events e
LEFT JOIN expenses ex ON e.id = ex.event_id
GROUP BY e.id, e.name, e.event_date, e.expected_pax, e.actual_pax, e.status;

-- ============================================
-- SEED DATA (Development Only)
-- ============================================

-- Create a default admin user (password: admin123)
-- In production, this should be done through proper onboarding
INSERT INTO users (email, password_hash, full_name, role) 
VALUES (
    'admin@annapurna.local',
    '$2a$10$rKN5zGbNYdNK2q5FjKpQ5.qnqxNB5FUGlJ3bQ0x2N0qQG5jQ3Q3Q2', -- bcrypt hash placeholder
    'System Admin',
    'admin'
) ON CONFLICT (email) DO NOTHING;

