-- Create stored procedures/functions for Syrx PostgreSQL integration tests

-- Drop existing procedures if they exist
DROP PROCEDURE IF EXISTS usp_create_table(text);
DROP FUNCTION IF EXISTS usp_identity_tester(varchar, numeric);
DROP PROCEDURE IF EXISTS usp_bulk_insert(text);
DROP PROCEDURE IF EXISTS usp_bulk_insert_and_return(text, OUT refcursor);
DROP PROCEDURE IF EXISTS usp_clear_table(text);

-- Create table creation procedure
CREATE OR REPLACE PROCEDURE usp_create_table(_name text)
LANGUAGE plpgsql
AS $$
DECLARE
    _template text;
    _sql text;
BEGIN
    -- Check if the table exists and drop it if it does
    IF EXISTS (SELECT FROM pg_catalog.pg_tables WHERE schemaname = 'public' AND tablename = lower(_name)) THEN
        _template := 'DROP TABLE IF EXISTS public.%I';
        _sql := format(_template, _name);
        EXECUTE _sql;
    END IF;

    -- Create the table if it does not exist
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_tables WHERE schemaname = 'public' AND tablename = lower(_name)) THEN
        _template := 'CREATE TABLE public.%I (id SERIAL PRIMARY KEY, name VARCHAR(50), value NUMERIC(18, 2), modified TIMESTAMP)';
        _sql := format(_template, _name);
        EXECUTE _sql;
    END IF;
END;
$$;

-- Create identity tester function
CREATE OR REPLACE FUNCTION usp_identity_tester(_name VARCHAR(50), _value NUMERIC(18, 2))
RETURNS SETOF bigint AS
$$
DECLARE
    _id bigint;
BEGIN
    INSERT INTO identity_test(name, value, modified)
    VALUES (_name, _value, CURRENT_TIMESTAMP)
    RETURNING id INTO _id;

    RETURN NEXT _id;
END;
$$ LANGUAGE plpgsql;

-- Create bulk insert procedure
CREATE OR REPLACE PROCEDURE usp_bulk_insert(_path text)
LANGUAGE plpgsql
AS $$
DECLARE
    _command text;
BEGIN
    -- Prepare the COPY command
    _command := format('COPY bulk_insert FROM %L WITH (FORMAT csv, DELIMITER '','', NULL '''', HEADER);', _path);

    -- Execute the COPY command
    EXECUTE _command;
END;
$$;

-- Create bulk insert and return procedure
CREATE OR REPLACE PROCEDURE usp_bulk_insert_and_return(_path text, OUT ref refcursor)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Perform the bulk insert using COPY
    EXECUTE format('COPY bulk_insert FROM %L WITH (FORMAT csv, DELIMITER '','', NULL '''', HEADER);', _path);

    -- Open a refcursor to return the result set
    OPEN ref FOR SELECT * FROM bulk_insert;
END;
$$;

-- Create table clearing procedure
CREATE OR REPLACE PROCEDURE usp_clear_table(_name text)
LANGUAGE plpgsql
AS $$
DECLARE
    _template text;
    _sql text;
BEGIN
    -- Prepare the TRUNCATE TABLE statement
    _template := 'TRUNCATE TABLE public.%I';
    _sql := format(_template, _name);

    -- Execute the TRUNCATE TABLE statement
    EXECUTE _sql;
END;
$$;

DO $$
BEGIN
    RAISE NOTICE 'All stored procedures and functions created successfully.';
END
$$;