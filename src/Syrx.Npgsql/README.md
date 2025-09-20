# Syrx.Npgsql

PostgreSQL data access provider for the Syrx framework.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
  - [1. Configure Services](#1-configure-services)
  - [2. Create Repository](#2-create-repository)
  - [3. Configure Commands](#3-configure-commands)
- [PostgreSQL-Specific Features](#postgresql-specific-features)
  - [JSON Support](#json-support)
  - [Array Support](#array-support)
  - [Advanced PostgreSQL Types](#advanced-postgresql-types)
- [Configuration Patterns](#configuration-patterns)
  - [Basic Configuration](#basic-configuration)
  - [Multiple Databases](#multiple-databases)
  - [Connection Pool Optimization](#connection-pool-optimization)
  - [SSL Configuration](#ssl-configuration)
- [Advanced Usage](#advanced-usage)
  - [Bulk Operations](#bulk-operations)
  - [Complex Queries with CTEs](#complex-queries-with-ctes)
  - [Window Functions](#window-functions)
- [Error Handling](#error-handling)
- [Performance Tips](#performance-tips)
  - [Connection Management](#connection-management)
  - [Query Optimization](#query-optimization)
  - [Data Types](#data-types)
- [Testing](#testing)
- [Migration from Other Providers](#migration-from-other-providers)
  - [From Entity Framework](#from-entity-framework)
  - [From Raw ADO.NET](#from-raw-adonet)
- [Related Packages](#related-packages)
- [Requirements](#requirements)
- [License](#license)
- [Credits](#credits)

## Overview

`Syrx.Npgsql` provides PostgreSQL database connectivity for the Syrx data access framework. Built on top of Npgsql (the .NET PostgreSQL provider), this package offers seamless integration with PostgreSQL databases while maintaining Syrx's core principles of control, performance, and flexibility.

## Features

- **PostgreSQL Integration**: Native support for PostgreSQL databases via Npgsql
- **High Performance**: Leverages Npgsql's optimized connection handling and Dapper's speed
- **JSON Support**: Built-in support for PostgreSQL JSON and JSONB data types
- **Array Support**: Native PostgreSQL array type handling
- **Advanced Types**: Support for PostgreSQL-specific types (UUID, INET, etc.)
- **Connection Pooling**: Efficient connection pool management
- **Transaction Support**: Full transaction control with rollback capabilities
- **Async/Await**: Complete async operation support
- **Multi-mapping**: Complex object composition from query results

## Installation

```bash
dotnet add package Syrx.Npgsql
```

**Package Manager**
```bash
Install-Package Syrx.Npgsql
```

**PackageReference**
```xml
<PackageReference Include="Syrx.Npgsql" Version="2.4.5" />
```

## Quick Start

### 1. Configure Services

```csharp
using Syrx.Npgsql.Extensions;

public void ConfigureServices(IServiceCollection services)
{
    services.UseSyrx(builder => builder
        .UseNpgsql(npgsql => npgsql
            .AddConnectionString("Default", "Host=localhost;Database=mydb;Username=postgres;Password=admin")
            .AddCommand(types => types
                .ForType<UserRepository>(methods => methods
                    .ForMethod(nameof(UserRepository.GetAllUsersAsync), command => command
                        .UseConnectionAlias("Default")
                        .UseCommandText("SELECT id, name, email, created_at FROM users"))))));
}
```

### 2. Create Repository

```csharp
public class UserRepository
{
    private readonly ICommander<UserRepository> _commander;

    public UserRepository(ICommander<UserRepository> commander)
    {
        _commander = commander;
    }

    public async Task<IEnumerable<User>> GetAllUsersAsync()
        => await _commander.QueryAsync<User>();

    public async Task<User> GetUserByIdAsync(int id)
        => await _commander.QueryAsync<User>(new { id }).SingleOrDefaultAsync();

    public async Task<bool> CreateUserAsync(User user)
        => await _commander.ExecuteAsync(user) > 0;
}
```

### 3. Configure Commands

```csharp
services.UseSyrx(builder => builder
    .UseNpgsql(npgsql => npgsql
        .AddConnectionString("Default", connectionString)
        .AddCommand(types => types
            .ForType<UserRepository>(methods => methods
                .ForMethod(nameof(UserRepository.GetUserByIdAsync), command => command
                    .UseConnectionAlias("Default")
                    .UseCommandText("SELECT id, name, email, created_at FROM users WHERE id = @id"))
                .ForMethod(nameof(UserRepository.CreateUserAsync), command => command
                    .UseConnectionAlias("Default")
                    .UseCommandText("INSERT INTO users (name, email) VALUES (@Name, @Email)"))))));
```

## PostgreSQL-Specific Features

### JSON Support

PostgreSQL's JSON capabilities are fully supported:

```csharp
public class ProductRepository
{
    private readonly ICommander<ProductRepository> _commander;

    public ProductRepository(ICommander<ProductRepository> commander)
    {
        _commander = commander;
    }

    // Query JSON data
    public async Task<IEnumerable<Product>> GetProductsWithAttributesAsync()
        => await _commander.QueryAsync<Product>();

    // Store JSON data
    public async Task<bool> SaveProductAsync(Product product)
        => await _commander.ExecuteAsync(product) > 0;
}

public class Product
{
    public int Id { get; set; }
    public string Name { get; set; }
    public JsonDocument Attributes { get; set; }  // PostgreSQL JSON
    public string[] Tags { get; set; }            // PostgreSQL Array
}
```

Configure JSON commands:
```csharp
.ForMethod(nameof(ProductRepository.GetProductsWithAttributesAsync), command => command
    .UseConnectionAlias("Default")
    .UseCommandText("SELECT id, name, attributes::json, tags FROM products"))
.ForMethod(nameof(ProductRepository.SaveProductAsync), command => command
    .UseConnectionAlias("Default")
    .UseCommandText("INSERT INTO products (name, attributes, tags) VALUES (@Name, @Attributes::jsonb, @Tags)"))
```

### Array Support

PostgreSQL arrays are natively supported:

```csharp
public async Task<IEnumerable<User>> GetUsersByRolesAsync(string[] roles)
    => await _commander.QueryAsync<User>(new { roles });

// Command configuration
.UseCommandText("SELECT id, name, email FROM users WHERE roles && @roles")
```

### Advanced PostgreSQL Types

```csharp
public class NetworkLog
{
    public Guid Id { get; set; }              // PostgreSQL UUID
    public IPAddress ClientIp { get; set; }   // PostgreSQL INET
    public DateTime Timestamp { get; set; }   // PostgreSQL TIMESTAMP
    public TimeSpan Duration { get; set; }    // PostgreSQL INTERVAL
}

// Query with PostgreSQL-specific types
.UseCommandText(@"
    SELECT 
        id::uuid, 
        client_ip::inet, 
        timestamp, 
        duration::interval 
    FROM network_logs 
    WHERE timestamp > @since")
```

## Configuration Patterns

### Basic Configuration

```csharp
services.UseSyrx(builder => builder
    .UseNpgsql(npgsql => npgsql
        .AddConnectionString("Default", "Host=localhost;Database=myapp;Username=app;Password=secret")));
```

### Multiple Databases

```csharp
services.UseSyrx(builder => builder
    .UseNpgsql(npgsql => npgsql
        .AddConnectionString("Primary", "Host=prod-primary;Database=myapp;Username=app;Password=secret")
        .AddConnectionString("ReadReplica", "Host=prod-replica;Database=myapp;Username=reader;Password=secret")
        .AddCommand(types => types
            .ForType<ReportRepository>(methods => methods
                .ForMethod("GetReportData", command => command
                    .UseConnectionAlias("ReadReplica")))  // Use read replica for reports
            .ForType<UserRepository>(methods => methods
                .ForMethod("CreateUser", command => command
                    .UseConnectionAlias("Primary"))))));  // Use primary for writes
```

### Connection Pool Optimization

```csharp
services.UseSyrx(builder => builder
    .UseNpgsql(npgsql => npgsql
        .AddConnectionString("Optimized", 
            "Host=localhost;Database=myapp;Username=app;Password=secret;" +
            "MinPoolSize=10;MaxPoolSize=200;ConnectionLifeTime=300;" +
            "Timeout=30;CommandTimeout=60;")));
```

### SSL Configuration

```csharp
services.UseSyrx(builder => builder
    .UseNpgsql(npgsql => npgsql
        .AddConnectionString("Secure", 
            "Host=secure.postgres.com;Database=myapp;Username=app;Password=secret;" +
            "SslMode=Require;TrustServerCertificate=false;" +
            "ClientCertificate=client.crt;ClientCertificateKey=client.key;")));
```

## Advanced Usage

### Bulk Operations

```csharp
public async Task<bool> BulkInsertUsersAsync(IEnumerable<User> users)
{
    // Use PostgreSQL COPY for large datasets
    return await _commander.ExecuteAsync(users) > 0;
}

// Configuration for bulk operations
.ForMethod(nameof(UserRepository.BulkInsertUsersAsync), command => command
    .UseConnectionAlias("Default")
    .UseCommandText("COPY users (name, email) FROM STDIN (FORMAT CSV)")
    .SetCommandTimeout(300))
```

### Complex Queries with CTEs

```csharp
public async Task<IEnumerable<UserStatistics>> GetUserStatisticsAsync()
    => await _commander.QueryAsync<UserStatistics>();

// PostgreSQL CTE support
.UseCommandText(@"
    WITH user_stats AS (
        SELECT 
            user_id,
            COUNT(*) as order_count,
            SUM(total) as total_spent
        FROM orders 
        GROUP BY user_id
    )
    SELECT 
        u.id,
        u.name,
        u.email,
        COALESCE(us.order_count, 0) as order_count,
        COALESCE(us.total_spent, 0) as total_spent
    FROM users u
    LEFT JOIN user_stats us ON u.id = us.user_id")
```

### Window Functions

```csharp
public async Task<IEnumerable<SalesRanking>> GetSalesRankingAsync()
    => await _commander.QueryAsync<SalesRanking>();

.UseCommandText(@"
    SELECT 
        salesperson_id,
        name,
        total_sales,
        RANK() OVER (ORDER BY total_sales DESC) as ranking,
        LAG(total_sales) OVER (ORDER BY total_sales DESC) as previous_sales
    FROM salesperson_totals")
```

## Error Handling

PostgreSQL-specific error handling:

```csharp
public async Task<User> CreateUserAsync(User user)
{
    try
    {
        var success = await _commander.ExecuteAsync(user) > 0;
        return success ? user : null;
    }
    catch (PostgresException ex) when (ex.SqlState == "23505") // Unique violation
    {
        throw new DuplicateUserException($"User with email {user.Email} already exists", ex);
    }
    catch (PostgresException ex) when (ex.SqlState == "23503") // Foreign key violation
    {
        throw new InvalidReferenceException("Referenced record does not exist", ex);
    }
}
```

## Performance Tips

### Connection Management
- Use connection pooling for better performance
- Configure appropriate pool sizes based on load
- Set reasonable connection lifetimes

### Query Optimization
- Use prepared statements for repeated queries
- Leverage PostgreSQL's query planner with EXPLAIN
- Use appropriate indexes for your query patterns

### Data Types
- Use PostgreSQL-native types when possible
- Leverage JSONB for flexible document storage
- Use arrays instead of separate junction tables when appropriate

## Testing

Example test configuration:

```csharp
[Test]
public async Task Should_Retrieve_Users_From_PostgreSQL()
{
    // Arrange
    var services = new ServiceCollection();
    services.UseSyrx(builder => builder
        .UseNpgsql(npgsql => npgsql
            .AddConnectionString("Test", "Host=localhost;Database=testdb;Username=test;Password=test")
            .AddCommand(types => types
                .ForType<UserRepository>(methods => methods
                    .ForMethod(nameof(UserRepository.GetAllUsersAsync), command => command
                        .UseConnectionAlias("Test")
                        .UseCommandText("SELECT id, name, email FROM users"))))));

    var provider = services.BuildServiceProvider();
    var repository = provider.GetService<UserRepository>();

    // Act
    var users = await repository.GetAllUsersAsync();

    // Assert
    Assert.IsNotNull(users);
}
```

## Migration from Other Providers

### From Entity Framework

```csharp
// Entity Framework
var users = await context.Users
    .Where(u => u.IsActive)
    .OrderBy(u => u.Name)
    .ToListAsync();

// Syrx equivalent
public async Task<IEnumerable<User>> GetActiveUsersAsync()
    => await _commander.QueryAsync<User>();

.UseCommandText("SELECT * FROM users WHERE is_active = true ORDER BY name")
```

### From Raw ADO.NET

```csharp
// Raw ADO.NET
using var connection = new NpgsqlConnection(connectionString);
await connection.OpenAsync();
using var command = new NpgsqlCommand("SELECT * FROM users WHERE id = @id", connection);
command.Parameters.AddWithValue("@id", userId);
using var reader = await command.ExecuteReaderAsync();
// Manual mapping...

// Syrx equivalent
public async Task<User> GetUserByIdAsync(int id)
    => await _commander.QueryAsync<User>(new { id }).SingleOrDefaultAsync();
```

## Related Packages

- **[Syrx.Npgsql.Extensions](https://www.nuget.org/packages/Syrx.Npgsql.Extensions/)**: Dependency injection extensions
- **[Syrx.Commanders.Databases.Connectors.Npgsql](https://www.nuget.org/packages/Syrx.Commanders.Databases.Connectors.Npgsql/)**: Core PostgreSQL connector
- **[Syrx](https://www.nuget.org/packages/Syrx/)**: Core Syrx framework
- **[Syrx.Commanders.Databases](https://www.nuget.org/packages/Syrx.Commanders.Databases/)**: Database command framework

## Requirements

- **.NET 8.0** or later
- **PostgreSQL 12** or later (recommended)
- **Npgsql 8.0** or later

## License

This project is licensed under the [MIT License](https://github.com/Syrx/Syrx/blob/main/LICENSE).

## Credits

- Built on top of [Npgsql](https://github.com/npgsql/npgsql) - the .NET PostgreSQL provider
- Uses [Dapper](https://github.com/DapperLib/Dapper) for object mapping
- Inspired by PostgreSQL's powerful feature set