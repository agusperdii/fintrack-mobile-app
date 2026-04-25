-- =========================
-- EXTENSIONS
-- =========================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =========================
-- ENUMS
-- =========================
CREATE TYPE transaction_source AS ENUM ('manual', 'ocr');

CREATE TYPE nudge_type AS ENUM ('warning', 'positive', 'reminder');

-- =========================
-- USERS
-- =========================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =========================
-- CATEGORIES
-- =========================
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    type TEXT CHECK (type IN ('income', 'expense')) NOT NULL
);

-- =========================
-- TRANSACTIONS
-- =========================
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    category_id INT NOT NULL,
    amount NUMERIC(12,2) NOT NULL CHECK (amount >= 0),
    description TEXT,
    transaction_date DATE NOT NULL,
    source transaction_source DEFAULT 'manual',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_user
        FOREIGN KEY(user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_category
        FOREIGN KEY(category_id)
        REFERENCES categories(id)
);

CREATE INDEX idx_transactions_user_id ON transactions(user_id);
CREATE INDEX idx_transactions_date ON transactions(transaction_date);

-- =========================
-- RECEIPTS (RAW OCR INPUT)
-- =========================
CREATE TABLE receipts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    image_url TEXT NOT NULL,
    raw_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- =========================
-- OCR RESULTS (STRUCTURED)
-- =========================
CREATE TABLE ocr_results (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    receipt_id UUID UNIQUE,
    total_amount NUMERIC(12,2),
    merchant_name TEXT,
    transaction_date DATE,
    is_confirmed BOOLEAN DEFAULT FALSE,

    FOREIGN KEY(receipt_id) REFERENCES receipts(id) ON DELETE CASCADE
);

-- =========================
-- BUDGETS
-- =========================
CREATE TABLE budgets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    category_id INT NOT NULL,
    limit_amount NUMERIC(12,2) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,

    FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY(category_id) REFERENCES categories(id)
);

CREATE INDEX idx_budgets_user_id ON budgets(user_id);

-- =========================
-- NUDGES
-- =========================
CREATE TABLE nudges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    type nudge_type NOT NULL,
    message TEXT NOT NULL,
    is_sent BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_nudges_user_id ON nudges(user_id);

-- =========================
-- OPTIONAL: DEFAULT CATEGORIES
-- =========================
INSERT INTO categories (name, type) VALUES
('Food', 'expense'),
('Transport', 'expense'),
('Shopping', 'expense'),
('Salary', 'income'),
('Investment', 'income');