# Syrx.Commanders.Databases.Connectors.Npgsql.Extensions

Dependency injection extensions for Syrx PostgreSQL database connectors.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Key Extensions](#key-extensions)
- [Usage](#usage)
- [Service Registration Details](#service-registration-details)
- [Service Lifetimes](#service-lifetimes)
- [Configuration Examples](#configuration-examples)
- [PostgreSQL-Specific Configuration](#postgresql-specific-configuration)
- [Integration with Other Extensions](#integration-with-other-extensions)
- [Error Handling](#error-handling)
- [Performance Optimization](#performance-optimization)
- [Testing Support](#testing-support)
- [Related Packages](#related-packages)
- [Requirements](#requirements)
- [License](#license)
- [Credits](#credits)

## Overview

`Syrx.Commanders.Databases.Connectors.Npgsql.Extensions` provides dependency injection and service registration extensions specifically for PostgreSQL database connectors in the Syrx framework. This package enables easy registration of PostgreSQL connectors with DI containers.

## Features

- **Service Registration**: Automatic registration of PostgreSQL connector services
- **Lifecycle Management**: Configurable service lifetimes for connectors
- **DI Integration**: Seamless integration with Microsoft.Extensions.DependencyInjection
- **Builder Pattern**: Fluent configuration APIs
- **Extensibility**: Support for custom connector configurations

## Installation

> **Note**: This package is typically installed automatically as a dependency of `Syrx.Npgsql.Extensions`.

```bash
dotnet add package Syrx.Commanders.Databases.Connectors.Npgsql.Extensions
```

**Package Manager**
```bash
Install-Package Syrx.Commanders.Databases.Connectors.Npgsql.Extensions
```

**PackageReference**
```xml
<PackageReference Include="Syrx.Commanders.Databases.Connectors.Npgsql.Extensions" Version="3.0.0" />
```

## Key Extensions

### ServiceCollectionExtensions

Provides extension methods for `IServiceCollection`:

```csharp
public static class ServiceCollectionExtensions
{
    internal static IServiceCollection AddNpgsql(
        this IServiceCollection services, 
        ServiceLifetime lifetime = ServiceLifetime.Transient)
    {
        return services.TryAddToServiceCollection(
            typeof(IDatabaseConnector),
            typeof(NpgsqlDatabaseConnector),
            lifetime);
    }
}
```

### NpgsqlConnectorExtensions

Provides builder pattern extensions:

```csharp
public static class NpgsqlConnectorExtensions
{
    public static SyrxBuilder UseNpgsql(
        this SyrxBuilder builder,
        Action<CommanderSettingsBuilder> factory,
        ServiceLifetime lifetime = ServiceLifetime.Transient)
    {
        // Extension implementation
    }
}
```

## Usage

### Basic Registration

```csharp
using Syrx.Commanders.Databases.Connectors.Npgsql.Extensions;

public void ConfigureServices(IServiceCollection services)
{
    services.UseSyrx(builder => builder
        .UseNpgsql(npgsql => npgsql
            .AddConnectionString("Default", connectionString)
            .AddCommand(/* command configuration */)));
}
```

### Custom Lifetime

```csharp
services.UseSyrx(builder => builder
    .UseNpgsql(
        npgsql => npgsql.AddConnectionString(/* config */),
        ServiceLifetime.Scoped));
```

### Advanced Configuration

```csharp
services.UseSyrx(builder => builder
    .UseNpgsql(npgsql => npgsql
        .AddConnectionString("Primary", "Host=localhost;Database=mydb;Username=admin;Password=adminpass")
        .AddConnectionString("ReadOnly", "Host=readonly;Database=mydb;Username=reader;Password=readpass")
        .AddCommand(types => types
            .ForType<UserRepository>(methods => methods
                .ForMethod("GetUsers", command => command
                    .UseConnectionAlias("ReadOnly")
                    .UseCommandText("SELECT * FROM users")))),
        ServiceLifetime.Singleton));
```

## Service Registration Details

The extensions automatically register:

1. **ICommanderSettings**: The configuration settings instance
2. **IDatabaseCommandReader**: For reading command configurations  
3. **IDatabaseConnector**: The PostgreSQL-specific connector
4. **DatabaseCommander<T>**: The generic database commander

## Service Lifetimes

| Lifetime | Use Case | Description |
|----------|----------|-------------|
| `Transient` | Default | New instance per injection |
| `Scoped` | Web Apps | Instance per request/scope |
| `Singleton` | Performance | Single instance for application |

### Lifetime Recommendations

- **Transient**: Default for most scenarios, minimal overhead
- **Scoped**: Web applications where you want request-scoped connections
- **Singleton**: High-performance scenarios with careful connection management

## Registration Process

When calling `.UseNpgsql()`, the following happens:

1. **Settings Registration**: CommanderSettings configured as transient
2. **Reader Registration**: DatabaseCommandReader registered
3. **Connector Registration**: NpgsqlDatabaseConnector registered
4. **Commander Registration**: DatabaseCommander<T> registered

## Integration with Other Extensions

Works seamlessly with other Syrx extension packages:

```csharp
services.UseSyrx(builder => builder
    .UseNpgsql(/* PostgreSQL config */)
    .UseSqlServer(/* SQL Server config */)    // If needed
    .UseMySql(/* MySQL config */));           // If needed
```

## PostgreSQL-Specific Configuration

### Connection Pool Management
```csharp
services.UseSyrx(builder => builder
    .UseNpgsql(npgsql => npgsql
        .AddConnectionString("Pooled", 
            "Host=localhost;Database=mydb;Username=user;Password=pass;" +
            "MinPoolSize=10;MaxPoolSize=200;ConnectionLifeTime=300;")
        .AddCommand(/* commands */)));
```

### Master/Replica Configuration
```csharp
services.UseSyrx(builder => builder
    .UseNpgsql(npgsql => npgsql
        .AddConnectionString("Primary", primaryConnectionString)
        .AddConnectionString("Replica", replicaConnectionString)
        .AddCommand(types => types
            .ForType<UserRepository>(methods => methods
                .ForMethod("GetUsers", command => command
                    .UseConnectionAlias("Replica"))      // Read operations
                .ForMethod("CreateUser", command => command
                    .UseConnectionAlias("Primary"))))));  // Write operations
```

### SSL Configuration
```csharp
services.UseSyrx(builder => builder
    .UseNpgsql(npgsql => npgsql
        .AddConnectionString("Secure", 
            "Host=prod.postgres.com;Database=mydb;Username=user;Password=pass;" +
            "SslMode=Require;TrustServerCertificate=false;" +
            "ClientCertificate=client.crt;ClientCertificateKey=client.key;")
        .AddCommand(/* commands */)));
```

### JSON and Array Support
```csharp
services.UseSyrx(builder => builder
    .UseNpgsql(npgsql => npgsql
        .AddConnectionString("Default", connectionString)
        .AddCommand(types => types
            .ForType<ProductRepository>(methods => methods
                // JSON/JSONB support
                .ForMethod("GetProductsByAttributes", command => command
                    .UseConnectionAlias("Default")
                    .UseCommandText(@"
                        SELECT id, name, attributes::jsonb 
                        FROM products 
                        WHERE attributes ? @searchKey"))
                
                // Array support
                .ForMethod("GetProductsByTags", command => command
                    .UseConnectionAlias("Default")
                    .UseCommandText("SELECT * FROM products WHERE tags && @tags"))))));
```

## Error Handling

The extensions provide proper error handling for:
- Invalid configuration scenarios
- Missing dependencies
- Circular dependency issues
- Service registration conflicts
- PostgreSQL-specific connection errors

## Testing Support

The extensions support testing scenarios:

```csharp
// Test service collection
var services = new ServiceCollection();
services.UseSyrx(builder => builder
    .UseNpgsql(npgsql => npgsql
        .AddConnectionString("Test", testConnectionString)
        .AddCommand(/* test commands */)));

var provider = services.BuildServiceProvider();
var connector = provider.GetService<IDatabaseConnector>();
```

## Performance Optimizations

### Connection String Optimization
```csharp
services.UseSyrx(builder => builder
    .UseNpgsql(npgsql => npgsql
        .AddConnectionString("Optimized", 
            "Host=localhost;Database=mydb;Username=user;Password=pass;" +
            "MinPoolSize=5;MaxPoolSize=100;" +
            "ConnectionLifeTime=300;ConnectionTimeout=30;" +
            "CommandTimeout=60;Pooling=true;KeepAlive=30;")
        .AddCommand(/* commands */)));
```

### Bulk Operation Configuration
```csharp
.ForMethod("BulkInsert", command => command
    .UseConnectionAlias("BulkWrite")
    .UseCommandText("COPY users (name, email) FROM STDIN (FORMAT CSV)")
    .SetCommandTimeout(300))  // Longer timeout for bulk operations
```

### High-Performance OLTP
```csharp
services.UseSyrx(builder => builder
    .UseNpgsql(npgsql => npgsql
        .AddConnectionString("OLTP", 
            "Host=oltp.postgres.com;Database=app;Username=app;Password=secret;" +
            "MinPoolSize=20;MaxPoolSize=100;" +
            "ConnectionLifeTime=600;" +
            "Timeout=5;CommandTimeout=30;" +
            "Multiplexing=true;")  // Enable connection multiplexing
        .AddCommand(/* OLTP commands */)));
```

### Analytics Workload
```csharp
services.UseSyrx(builder => builder
    .UseNpgsql(npgsql => npgsql
        .AddConnectionString("Analytics", 
            "Host=analytics.postgres.com;Database=warehouse;Username=analyst;Password=secret;" +
            "MinPoolSize=5;MaxPoolSize=20;" +
            "ConnectionLifeTime=1800;" +
            "Timeout=60;CommandTimeout=300;")  // Long timeouts for complex queries
        .AddCommand(/* analytics commands */)));
```

## PostgreSQL Advanced Features

### Full-Text Search Configuration
```csharp
.ForMethod("SearchDocuments", command => command
    .UseConnectionAlias("Default")
    .UseCommandText(@"
        SELECT *, ts_rank(search_vector, plainto_tsquery(@searchText)) as rank
        FROM documents 
        WHERE search_vector @@ plainto_tsquery(@searchText)
        ORDER BY rank DESC"))
```

### Window Functions and CTEs
```csharp
.ForMethod("GetUserStatistics", command => command
    .UseConnectionAlias("Analytics")
    .UseCommandText(@"
        WITH user_stats AS (
            SELECT 
                user_id,
                COUNT(*) as order_count,
                SUM(total) as total_spent,
                RANK() OVER (ORDER BY SUM(total) DESC) as spending_rank
            FROM orders 
            GROUP BY user_id
        )
        SELECT 
            u.id, u.name, u.email,
            COALESCE(us.order_count, 0) as order_count,
            COALESCE(us.total_spent, 0) as total_spent,
            COALESCE(us.spending_rank, 999999) as spending_rank
        FROM users u
        LEFT JOIN user_stats us ON u.id = us.user_id"))
```

### Temporal Tables and Versioning
```csharp
.ForMethod("GetUserHistory", command => command
    .UseConnectionAlias("Default")
    .UseCommandText(@"
        SELECT 
            id, name, email, 
            valid_from, valid_to,
            LEAD(valid_from) OVER (PARTITION BY id ORDER BY valid_from) as next_version
        FROM user_history 
        WHERE id = @userId
        ORDER BY valid_from DESC"))
```

## Configuration from Environment

### Environment-Specific Setup

```csharp
public static class PostgreSqlEnvironmentExtensions
{
    public static SyrxBuilder ConfigurePostgreSqlForEnvironment(
        this SyrxBuilder builder, 
        IConfiguration configuration)
    {
        var environment = configuration["ENVIRONMENT"] ?? "Development";
        
        return environment switch
        {
            "Development" => builder.UseNpgsql(npgsql => npgsql.ConfigureDevelopment(configuration)),
            "Staging" => builder.UseNpgsql(npgsql => npgsql.ConfigureStaging(configuration)),
            "Production" => builder.UseNpgsql(npgsql => npgsql.ConfigureProduction(configuration)),
            _ => throw new InvalidOperationException($"Unknown environment: {environment}")
        };
    }
    
    private static NpgsqlBuilder ConfigureDevelopment(this NpgsqlBuilder npgsql, IConfiguration config)
    {
        return npgsql
            .AddConnectionString("Default", config.GetConnectionString("Development"))
            .AddCommand(/* development-specific commands with detailed logging */);
    }
    
    private static NpgsqlBuilder ConfigureProduction(this NpgsqlBuilder npgsql, IConfiguration config)
    {
        return npgsql
            .AddConnectionString("Primary", config.GetConnectionString("ProductionPrimary"))
            .AddConnectionString("ReadReplica", config.GetConnectionString("ProductionReplica"))
            .AddCommand(/* production-optimized commands */);
    }
}

// Usage
services.UseSyrx(builder => builder.ConfigurePostgreSqlForEnvironment(Configuration));
```

### Docker Integration

```csharp
public static class DockerPostgreSqlExtensions
{
    public static SyrxBuilder UseDockerPostgreSql(this SyrxBuilder builder)
    {
        var connectionString = Environment.GetEnvironmentVariable("POSTGRES_CONNECTION") ??
            "Host=postgres;Database=app;Username=postgres;Password=postgres";
            
        return builder.UseNpgsql(npgsql => npgsql
            .AddConnectionString("Docker", connectionString)
            .AddCommand(/* container-optimized commands */));
    }
}

// docker-compose.yml
services:
  postgres:
    image: postgres:16
    environment:
      POSTGRES_DB: app
      POSTGRES_USER: postgres  
      POSTGRES_PASSWORD: postgres
    volumes:
      - postgres_data:/var/lib/postgresql/data
```

## Health Checks Integration

```csharp
services.UseSyrx(builder => builder
    .UseNpgsql(npgsql => npgsql
        .AddConnectionString("Default", connectionString)
        .AddCommand(/* commands */)));

// Add health checks
services.AddHealthChecks()
    .AddNpgSql(connectionString, name: "postgresql");

// Custom health check using Syrx
services.AddHealthChecks()
    .AddTypeActivatedCheck<SyrxPostgreSqlHealthCheck>(
        "syrx-postgresql", 
        args: new object[] { "Default" });

public class SyrxPostgreSqlHealthCheck : IHealthCheck
{
    private readonly ICommander<SyrxPostgreSqlHealthCheck> _commander;
    private readonly string _connectionAlias;

    public SyrxPostgreSqlHealthCheck(ICommander<SyrxPostgreSqlHealthCheck> commander, string connectionAlias)
    {
        _commander = commander;
        _connectionAlias = connectionAlias;
    }

    public async Task<HealthCheckResult> CheckHealthAsync(HealthCheckContext context, CancellationToken cancellationToken = default)
    {
        try
        {
            var result = await _commander.QueryAsync<int>("SELECT 1");
            return HealthCheckResult.Healthy("PostgreSQL is responding");
        }
        catch (Exception ex)
        {
            return HealthCheckResult.Unhealthy("PostgreSQL is not responding", ex);
        }
    }
}
```

## Related Packages

- **[Syrx.Npgsql.Extensions](https://www.nuget.org/packages/Syrx.Npgsql.Extensions/)**: High-level PostgreSQL extensions
- **[Syrx.Commanders.Databases.Connectors.Npgsql](https://www.nuget.org/packages/Syrx.Commanders.Databases.Connectors.Npgsql/)**: Core PostgreSQL connector
- **[Syrx.Commanders.Databases.Extensions](https://www.nuget.org/packages/Syrx.Commanders.Databases.Extensions/)**: Base database extensions

## License

This project is licensed under the [MIT License](https://github.com/Syrx/Syrx/blob/main/LICENSE).

## Credits

- Built on top of [Microsoft.Extensions.DependencyInjection](https://github.com/dotnet/extensions)
- PostgreSQL support provided by [Npgsql](https://github.com/npgsql/npgsql)
- Follows [Dapper](https://github.com/DapperLib/Dapper) performance patterns
