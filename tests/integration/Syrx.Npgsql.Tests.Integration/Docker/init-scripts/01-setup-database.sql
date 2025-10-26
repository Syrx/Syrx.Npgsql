-- Create the Syrx database and user
-- Note: The database 'syrx' is created by the POSTGRES_DB environment variable
-- This script will be run in the syrx database context

-- Ensure the main tables exist
DO $$
BEGIN
    -- Enable plpgsql extension if not already enabled
    CREATE EXTENSION IF NOT EXISTS plpgsql;
    
    RAISE NOTICE 'Syrx PostgreSQL database initialization started.';
END
$$;