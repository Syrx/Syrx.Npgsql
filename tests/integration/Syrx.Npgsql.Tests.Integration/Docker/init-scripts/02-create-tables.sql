-- Create tables for Syrx PostgreSQL integration tests

-- Create the main poco table used in most tests
CREATE TABLE IF NOT EXISTS public.poco (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    value NUMERIC(18, 2),
    modified TIMESTAMP
);

-- Create identity_test table for identity testing
CREATE TABLE IF NOT EXISTS public.identity_test (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    value NUMERIC(18, 2),
    modified TIMESTAMP
);

-- Create bulk_insert table for bulk operations
CREATE TABLE IF NOT EXISTS public.bulk_insert (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    value NUMERIC(18, 2),
    modified TIMESTAMP
);

-- Create distributed_transaction table for distributed transaction tests
CREATE TABLE IF NOT EXISTS public.distributed_transaction (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    value NUMERIC(18, 2),
    modified TIMESTAMP
);

-- Create an index for better performance
CREATE INDEX IF NOT EXISTS idx_poco_name ON public.poco(name);
CREATE INDEX IF NOT EXISTS idx_identity_test_name ON public.identity_test(name);
CREATE INDEX IF NOT EXISTS idx_bulk_insert_name ON public.bulk_insert(name);
CREATE INDEX IF NOT EXISTS idx_distributed_transaction_name ON public.distributed_transaction(name);

DO $$
BEGIN
    RAISE NOTICE 'All test tables created successfully.';
END
$$;