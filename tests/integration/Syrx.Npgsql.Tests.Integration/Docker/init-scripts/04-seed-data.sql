-- Seed test data for Syrx PostgreSQL integration tests

-- Clear existing data
TRUNCATE TABLE public.poco RESTART IDENTITY CASCADE;
TRUNCATE TABLE public.identity_test RESTART IDENTITY CASCADE;
TRUNCATE TABLE public.bulk_insert RESTART IDENTITY CASCADE;
TRUNCATE TABLE public.distributed_transaction RESTART IDENTITY CASCADE;

-- Insert test data into poco table (enough records for multi-mapping tests)
INSERT INTO public.poco (name, value, modified) VALUES
    ('Test Record 1', 100.50, CURRENT_TIMESTAMP - INTERVAL '1 day'),
    ('Test Record 2', 200.75, CURRENT_TIMESTAMP - INTERVAL '2 hours'),
    ('Test Record 3', 300.25, CURRENT_TIMESTAMP - INTERVAL '30 minutes'),
    ('Test Record 4', 400.00, CURRENT_TIMESTAMP - INTERVAL '15 minutes'),
    ('Test Record 5', 500.99, CURRENT_TIMESTAMP - INTERVAL '5 minutes'),
    ('Test Record 6', 600.33, CURRENT_TIMESTAMP - INTERVAL '3 minutes'),
    ('Test Record 7', 700.66, CURRENT_TIMESTAMP - INTERVAL '2 minutes'),
    ('Test Record 8', 800.88, CURRENT_TIMESTAMP - INTERVAL '1 minute'),
    ('Test Record 9', 900.11, CURRENT_TIMESTAMP - INTERVAL '30 seconds'),
    ('Test Record 10', 1000.00, CURRENT_TIMESTAMP - INTERVAL '10 seconds'),
    ('Test Record 11', 1100.22, CURRENT_TIMESTAMP - INTERVAL '5 seconds'),
    ('Test Record 12', 1200.44, CURRENT_TIMESTAMP - INTERVAL '3 seconds'),
    ('Test Record 13', 1300.55, CURRENT_TIMESTAMP - INTERVAL '2 seconds'),
    ('Test Record 14', 1400.77, CURRENT_TIMESTAMP - INTERVAL '1 second'),
    ('Test Record 15', 1500.88, CURRENT_TIMESTAMP),
    ('Test Record 16', 1600.99, CURRENT_TIMESTAMP),
    ('Test Record 17', 1700.11, CURRENT_TIMESTAMP),
    ('Test Record 18', 1800.22, CURRENT_TIMESTAMP),
    ('Test Record 19', 1900.33, CURRENT_TIMESTAMP),
    ('Test Record 20', 2000.44, CURRENT_TIMESTAMP);

-- Verify data was inserted
DO $$
DECLARE
    record_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO record_count FROM public.poco;
    RAISE NOTICE 'Inserted % test records into poco table.', record_count;
END
$$;

-- Insert a few test records for identity testing
INSERT INTO public.identity_test (name, value, modified) VALUES
    ('Identity Test 1', 50.25, CURRENT_TIMESTAMP),
    ('Identity Test 2', 75.50, CURRENT_TIMESTAMP);

-- Verify the database is ready
DO $$
BEGIN
    RAISE NOTICE 'Database seeding completed successfully.';
    RAISE NOTICE 'Syrx PostgreSQL test database is ready for integration tests.';
END
$$;