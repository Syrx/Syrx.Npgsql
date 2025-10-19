# Syrx.Commanders.Databases.Connectors.Npgsql

Core PostgreSQL database connector for the Syrx framework.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Architecture](#architecture)
- [Key Components](#key-components)
- [Connection Management](#connection-management)
- [Configuration](#configuration)
- [PostgreSQL-Specific Features](#postgresql-specific-features)
- [Error Handling](#error-handling)
- [Performance Considerations](#performance-considerations)
- [Testing](#testing)
- [Related Packages](#related-packages)
- [Requirements](#requirements)
- [License](#license)
- [Credits](#credits)

## Overview

`Syrx.Commanders.Databases.Connectors.Npgsql` provides the foundational PostgreSQL database connectivity layer for the Syrx framework. This package implements the `IDatabaseConnector` interface specifically for PostgreSQL databases using Npgsql as the underlying provider.

## Features

- **Native PostgreSQL Support**: Direct integration with Npgsql provider
- **Connection Pool Management**: Efficient PostgreSQL connection pooling
- **Transaction Support**: Full transaction lifecycle management
- **Async Operations**: Complete async/await pattern support
- **Error Handling**: PostgreSQL-specific error handling and recovery
- **Parameter Binding**: Safe parameter binding with PostgreSQL types
- **Performance Optimized**: Leverages Npgsql's performance characteristics

## Installation

> **Note**: This package is typically installed automatically as a dependency of `Syrx.Npgsql` or `Syrx.Npgsql.Extensions`.

```bash
dotnet add package Syrx.Commanders.Databases.Connectors.Npgsql
```

**Package Manager**
```bash
Install-Package Syrx.Commanders.Databases.Connectors.Npgsql
```

**PackageReference**
```xml
<PackageReference Include="Syrx.Commanders.Databases.Connectors.Npgsql" Version="3.0.0" />
```

## Core Components

### NpgsqlDatabaseConnector

The main connector implementation that inherits from `DatabaseConnector`:

```csharp
public class NpgsqlDatabaseConnector : DatabaseConnector
{
    public NpgsqlDatabaseConnector() 
        : base(() => NpgsqlFactory.Instance)
    {
    }

    public override DbProviderFactory Factory => NpgsqlFactory.Instance;
}
```

### Key Characteristics

- **Provider Factory**: Uses `NpgsqlFactory.Instance` for connection creation
- **Thread-Safe**: Designed for concurrent access across multiple threads
- **Connection Lifecycle**: Automatic connection opening/closing and disposal
- **Transaction Management**: Supports both explicit and implicit transactions

## PostgreSQL-Specific Features

### Data Type Support

The connector provides native support for PostgreSQL data types:

```csharp
// PostgreSQL native types
public class PostgreSqlEntity
{
    public Guid Id { get; set; }              // UUID
    public string[] Tags { get; set; }        // Text array
    public IPAddress ClientIp { get; set; }   // INET
    public JsonDocument Data { get; set; }    // JSON/JSONB
    public DateTime CreatedAt { get; set; }   // TIMESTAMP
    public TimeSpan Duration { get; set; }    // INTERVAL
    public decimal Amount { get; set; }       // NUMERIC
    public byte[] FileData { get; set; }      // BYTEA
}
```

### Parameter Handling

PostgreSQL-specific parameter binding:

```csharp
// Array parameters
var tags = new[] { "tech", "programming", "database" };
var result = await commander.QueryAsync<Post>(new { tags });

// JSON parameters  
var metadata = JsonDocument.Parse(@"{ ""category"": ""technology"", ""priority"": 1 }");
var result = await commander.ExecuteAsync(new { metadata });

// Network address parameters
var clientIp = IPAddress.Parse("192.168.1.100");
var result = await commander.QueryAsync<LogEntry>(new { clientIp });
```

### Connection String Support

Supports all Npgsql connection string parameters:

```csharp
// Basic connection
"Host=localhost;Database=myapp;Username=app;Password=secret"

// With pooling configuration
"Host=localhost;Database=myapp;Username=app;Password=secret;MinPoolSize=10;MaxPoolSize=200"

// With SSL
"Host=secure.postgres.com;Database=myapp;Username=app;Password=secret;SslMode=Require"

// With timeouts
"Host=localhost;Database=myapp;Username=app;Password=secret;Timeout=30;CommandTimeout=60"
```

## Usage Examples

### Through Dependency Injection

```csharp
// Automatic registration via extensions
services.UseSyrx(builder => builder
    .UseNpgsql(npgsql => npgsql
        .AddConnectionString("Default", connectionString)
        .AddCommand(/* configuration */)));

// Manual registration (advanced scenarios)
services.AddTransient<IDatabaseConnector, NpgsqlDatabaseConnector>();
```

## Connection Management

### Connection Pooling

The connector leverages Npgsql's connection pooling:

```csharp
// Pool configuration via connection string
var connectionString = 
    "Host=localhost;Database=myapp;Username=app;Password=secret;" +
    "MinPoolSize=10;" +          // Minimum connections to keep open
    "MaxPoolSize=200;" +         // Maximum total connections
    "ConnectionLifeTime=300;" +  // Connection lifetime in seconds
    "Pooling=true";              // Enable pooling (default: true)
```

### Connection Lifecycle

```csharp
// Connection lifecycle is automatically managed
public async Task<T> QueryAsync<T>(
    string connectionString,
    CommandSetting commandSetting,
    object parameters = null,
    CancellationToken cancellationToken = default)
{
    // 1. Get connection from pool
    using var connection = Factory.CreateConnection();
    connection.ConnectionString = connectionString;
    
    // 2. Open connection
    await connection.OpenAsync(cancellationToken);
    
    // 3. Execute command
    var result = await connection.QueryAsync<T>(
        commandSetting.CommandText, 
        parameters);
    
    // 4. Connection automatically returned to pool on disposal
    return result;
}
```

## Transaction Support

### Automatic Transaction Management

```csharp
public async Task<bool> ExecuteAsync(
    string connectionString,
    CommandSetting commandSetting,
    object parameters = null,
    CancellationToken cancellationToken = default)
{
    using var connection = Factory.CreateConnection();
    connection.ConnectionString = connectionString;
    await connection.OpenAsync(cancellationToken);
    
    using var transaction = await connection.BeginTransactionAsync(cancellationToken);
    try
    {
        var result = await connection.ExecuteAsync(
            commandSetting.CommandText,
            parameters,
            transaction);
            
        await transaction.CommitAsync(cancellationToken);
        return result > 0;
    }
    catch
    {
        await transaction.RollbackAsync(cancellationToken);
        throw;
    }
}
```

### Transaction Isolation Levels

```csharp
// PostgreSQL supports standard isolation levels
using var transaction = await connection.BeginTransactionAsync(
    IsolationLevel.ReadCommitted,  // Default
    cancellationToken);

// PostgreSQL-specific: Serializable isolation
using var transaction = await connection.BeginTransactionAsync(
    IsolationLevel.Serializable,
    cancellationToken);
```

## Error Handling

### PostgreSQL-Specific Exceptions

```csharp
public async Task<T> QueryWithErrorHandlingAsync<T>(/* parameters */)
{
    try
    {
        return await connector.QueryAsync<T>(/* parameters */);
    }
    catch (PostgresException ex)
    {
        // PostgreSQL-specific error handling
        switch (ex.SqlState)
        {
            case "23505": // unique_violation
                throw new DuplicateKeyException("Record already exists", ex);
            case "23503": // foreign_key_violation  
                throw new ReferenceConstraintException("Referenced record not found", ex);
            case "23514": // check_violation
                throw new CheckConstraintException("Check constraint violated", ex);
            case "42P01": // undefined_table
                throw new TableNotFoundException("Table does not exist", ex);
            case "42703": // undefined_column
                throw new ColumnNotFoundException("Column does not exist", ex);
            default:
                throw; // Re-throw unknown PostgreSQL errors
        }
    }
    catch (NpgsqlException ex)
    {
        // Connection-level errors
        if (ex.IsTransient)
        {
            // Implement retry logic for transient errors
            throw new TransientDatabaseException("Transient error occurred", ex);
        }
        throw new DatabaseConnectionException("Database connection failed", ex);
    }
}
```

## Performance Considerations

### Connection Pool Optimization

```csharp
// Optimize for high-throughput scenarios
var highThroughputConnectionString = 
    "Host=localhost;Database=myapp;Username=app;Password=secret;" +
    "MinPoolSize=20;" +          // Keep more connections warm
    "MaxPoolSize=100;" +         // Limit total connections
    "ConnectionLifeTime=600;" +  // Longer connection lifetime
    "Multiplexing=true";         // Enable connection multiplexing

// Optimize for low-latency scenarios  
var lowLatencyConnectionString =
    "Host=localhost;Database=myapp;Username=app;Password=secret;" +
    "MinPoolSize=5;" +           // Fewer idle connections
    "MaxPoolSize=50;" +          // Lower maximum
    "ConnectionLifeTime=300;" +  // Shorter lifetime
    "NoDelay=true";              // Disable Nagle algorithm
```

### Prepared Statements

The connector automatically benefits from Npgsql's prepared statement caching:

```csharp
// Repeated executions of the same SQL will be automatically prepared
var sql = "SELECT * FROM users WHERE department_id = @departmentId";

// First execution: statement prepared and cached
var users1 = await connector.QueryAsync<User>(connectionString, new { departmentId = 1 });

// Subsequent executions: use prepared statement
var users2 = await connector.QueryAsync<User>(connectionString, new { departmentId = 2 });
```

## Integration Testing

### Test Setup

```csharp
[TestFixture]
public class NpgsqlConnectorTests
{
    private NpgsqlDatabaseConnector _connector;
    private string _testConnectionString;

    [SetUp]
    public void Setup()
    {
        _connector = new NpgsqlDatabaseConnector();
        _testConnectionString = "Host=localhost;Database=test_db;Username=test;Password=test";
    }

    [Test]
    public async Task Should_Connect_To_PostgreSQL()
    {
        // Arrange
        var commandSetting = new CommandSetting
        {
            ConnectionAlias = "test",
            CommandText = "SELECT version()"
        };

        // Act
        var result = await _connector.QueryAsync<string>(_testConnectionString, commandSetting);

        // Assert
        Assert.IsNotNull(result);
        Assert.IsTrue(result.First().Contains("PostgreSQL"));
    }
}
```

### Docker Test Environment

```yaml
# docker-compose.test.yml
version: '3.8'
services:
  postgres-test:
    image: postgres:16
    environment:
      POSTGRES_DB: test_db
      POSTGRES_USER: test
      POSTGRES_PASSWORD: test
    ports:
      - "5432:5432"
    command: postgres -c log_statement=all
```

## Monitoring and Diagnostics

### Connection Pool Monitoring

```csharp
// Enable detailed logging
var connectionString = 
    "Host=localhost;Database=myapp;Username=app;Password=secret;" +
    "LogParameters=true;" +      // Log parameter values
    "LogLevel=Debug";            // Detailed logging

// Monitor pool statistics (requires custom implementation)
public class ConnectionPoolMonitor
{
    public void LogPoolStatistics()
    {
        // Access pool statistics via Npgsql's metrics
        // Implement custom monitoring logic
    }
}
```

### Performance Metrics

```csharp
public class PostgreSqlMetrics
{
    private readonly IMetrics _metrics;

    public async Task<T> QueryWithMetricsAsync<T>(/* parameters */)
    {
        using var activity = _metrics.StartActivity("postgresql.query");
        var stopwatch = Stopwatch.StartNew();
        
        try
        {
            var result = await _connector.QueryAsync<T>(/* parameters */);
            _metrics.Counter("postgresql.queries.success").Increment();
            return result;
        }
        catch (Exception ex)
        {
            _metrics.Counter("postgresql.queries.error").Increment();
            _metrics.Histogram("postgresql.errors").Record(1, new[] { 
                new KeyValuePair<string, object>("error_type", ex.GetType().Name) 
            });
            throw;
        }
        finally
        {
            _metrics.Histogram("postgresql.query.duration")
                .Record(stopwatch.ElapsedMilliseconds);
        }
    }
}
```

## Security Considerations

### Connection Security

```csharp
// SSL/TLS configuration
var secureConnectionString = 
    "Host=secure.postgres.com;Database=myapp;Username=app;Password=secret;" +
    "SslMode=Require;" +                    // Require SSL
    "TrustServerCertificate=false;" +       // Validate server certificate
    "ClientCertificate=client.crt;" +       // Client certificate path
    "ClientCertificateKey=client.key;" +    // Client key path
    "RootCertificate=ca.crt";               // CA certificate path
```

### Parameter Security

```csharp
// The connector automatically handles parameter sanitization
public async Task<User> GetUserByEmailAsync(string email)
{
    // Safe from SQL injection - parameters are properly escaped
    var sql = "SELECT * FROM users WHERE email = @email";
    var user = await _connector.QueryAsync<User>(connectionString, new { email });
    return user.FirstOrDefault();
}

// ❌ Never do this - SQL injection vulnerability
// var sql = $"SELECT * FROM users WHERE email = '{email}'";
```

## Related Packages

- **[Syrx.Npgsql](https://www.nuget.org/packages/Syrx.Npgsql/)**: High-level PostgreSQL provider
- **[Syrx.Npgsql.Extensions](https://www.nuget.org/packages/Syrx.Npgsql.Extensions/)**: Dependency injection extensions
- **[Syrx.Commanders.Databases.Connectors](https://www.nuget.org/packages/Syrx.Commanders.Databases.Connectors/)**: Base connector interfaces
- **[Npgsql](https://www.nuget.org/packages/Npgsql/)**: The underlying PostgreSQL provider

## Requirements

- **.NET 8.0** or later
- **PostgreSQL 12** or later (recommended)
- **Npgsql 8.0** or later

## License

This project is licensed under the [MIT License](https://github.com/Syrx/Syrx/blob/main/LICENSE).

## Credits

- Built on top of [Npgsql](https://github.com/npgsql/npgsql) - the .NET PostgreSQL provider
- Integrates with [Dapper](https://github.com/DapperLib/Dapper) for high-performance data access
- Follows PostgreSQL best practices and conventions
