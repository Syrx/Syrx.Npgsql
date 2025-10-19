# Syrx PostgreSQL Docker Integration Tests

This directory contains Docker infrastructure for running Syrx PostgreSQL integration tests using a containerized PostgreSQL database.

## Overview

The Docker setup provides a consistent, isolated PostgreSQL environment for integration testing that mirrors the approach used in Syrx.SqlServer. This replaces the previous TestContainers.Net approach with a more explicit docker-compose configuration.

## Files Structure

```
Docker/
├── docker-compose.yml          # Docker Compose configuration
├── Dockerfile                  # PostgreSQL container definition
├── init-scripts/              # Database initialization scripts
│   ├── 01-setup-database.sql   # Database and extension setup
│   ├── 02-create-tables.sql    # Test table creation
│   ├── 03-create-procedures.sql # Stored procedures/functions
│   └── 04-seed-data.sql        # Test data seeding
└── README.md                   # This file
```

## Prerequisites

- Docker Desktop or Docker Engine installed
- Docker Compose available
- PowerShell (for Windows users)

## Starting the Test Database

### Using Docker Compose

```bash
# Navigate to the Docker directory
cd tests/integration/Syrx.Npgsql.Tests.Integration/Docker

# Start the PostgreSQL container
docker-compose up -d

# Check container status
docker-compose ps

# View logs
docker-compose logs postgres
```

### Using PowerShell (Windows)

```powershell
# Navigate to the Docker directory
Set-Location "tests\integration\Syrx.Npgsql.Tests.Integration\Docker"

# Start the container
docker-compose up -d
```

## Connection Details

The PostgreSQL container is configured with the following connection details:

- **Host**: localhost
- **Port**: 5432
- **Database**: syrx
- **Username**: syrx_user
- **Password**: YourStrong!Passw0rd
- **Connection String**: `Host=localhost;Port=5432;Database=syrx;Username=syrx_user;Password=YourStrong!Passw0rd;Include Error Detail=true;`

## Database Schema

The initialization scripts create the following tables:

### Tables
- `poco` - Main test table with id (SERIAL), name (VARCHAR), value (NUMERIC), modified (TIMESTAMP)
- `identity_test` - Identity testing table with same structure
- `bulk_insert` - Bulk operations table with same structure  
- `distributed_transaction` - Distributed transaction testing table with same structure

### Stored Procedures/Functions
- `usp_create_table(text)` - Dynamic table creation procedure
- `usp_identity_tester(varchar, numeric)` - Identity value testing function
- `usp_bulk_insert(text)` - Bulk data insertion procedure
- `usp_bulk_insert_and_return(text)` - Bulk insert with return values
- `usp_clear_table(text)` - Table truncation procedure

## Running Integration Tests

Once the PostgreSQL container is running, you can execute the integration tests:

```bash
# Run all integration tests
dotnet test

# Run specific test classes (Docker variants)
dotnet test --filter "ClassName~NpgsqlDocker"

# Run with verbose output
dotnet test --verbosity normal
```

## Health Checks

The container includes health checks that verify PostgreSQL is ready to accept connections:

```bash
# Check container health
docker-compose ps

# Manual health check
docker exec syrx-postgres-tests pg_isready -U syrx_user -d syrx
```

## Troubleshooting

### Container Won't Start
1. Check if port 5432 is already in use: `netstat -an | findstr 5432`
2. Ensure Docker Desktop is running
3. Check Docker logs: `docker-compose logs postgres`

### Connection Issues
1. Verify container is healthy: `docker-compose ps`
2. Test connection manually: `docker exec -it syrx-postgres-tests psql -U syrx_user -d syrx`
3. Check firewall settings if connecting from external machine

### Database Issues
1. Check initialization logs: `docker-compose logs postgres`
2. Connect to database and verify schema: `docker exec -it syrx-postgres-tests psql -U syrx_user -d syrx -c "\dt"`
3. Verify test data: `docker exec -it syrx-postgres-tests psql -U syrx_user -d syrx -c "SELECT COUNT(*) FROM poco;"`

## Stopping the Test Database

```bash
# Stop and remove containers
docker-compose down

# Stop, remove containers, and delete volumes (fresh start)
docker-compose down -v

# Remove all associated images (complete cleanup)
docker-compose down -v --rmi all
```

## Migration from TestContainers

This Docker setup replaces the previous TestContainers.Net approach:

### Before (TestContainers)
- Used `Testcontainers.PostgreSql` NuGet package
- Container managed programmatically in `NpgsqlFixture`
- Required TestContainers runtime dependency

### After (Docker Compose)
- Uses explicit docker-compose.yml configuration
- Container managed externally via Docker Compose
- No runtime dependencies on TestContainers packages
- Consistent with Syrx.SqlServer approach

### Test Classes

The migration provides both old and new test classes:

- **Original**: `NpgsqlQuery`, `NpgsqlExecute`, etc. (uses TestContainers)
- **New**: `NpgsqlDockerQuery`, `NpgsqlDockerExecute`, etc. (uses Docker Compose)

## Performance Considerations

- Container uses persistent volumes to maintain data between restarts
- Alpine Linux base image for smaller footprint
- Health checks ensure database readiness before tests run
- Connection pooling handled by Npgsql driver

## Security Notes

- Default password should be changed for production-like environments
- Container runs on localhost only by default
- Database user has limited privileges within the container context

## Compatibility

This setup is compatible with:
- PostgreSQL 16 (Alpine Linux)
- .NET 8.0+
- Docker Engine 20.10+
- Docker Compose 2.0+
- Windows, macOS, and Linux development environments
