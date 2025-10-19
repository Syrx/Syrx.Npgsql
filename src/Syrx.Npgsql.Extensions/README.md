# Syrx.Npgsql.Extensions

Dependency injection extensions for Syrx PostgreSQL integration.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Configuration Examples](#configuration-examples)
- [Advanced Configuration](#advanced-configuration)
- [PostgreSQL-Specific Features](#postgresql-specific-features)
- [Service Lifetimes](#service-lifetimes)
- [Multiple Database Support](#multiple-database-support)
- [Environment-Specific Settings](#environment-specific-settings)
- [Performance Optimization](#performance-optimization)
- [Error Handling](#error-handling)
- [Testing Integration](#testing-integration)
- [Migration Scenarios](#migration-scenarios)
- [Related Packages](#related-packages)
- [Requirements](#requirements)
- [License](#license)
- [Credits](#credits)

## Overview

`Syrx.Npgsql.Extensions` provides seamless dependency injection integration for PostgreSQL data access in the Syrx framework. This package simplifies the registration and configuration of PostgreSQL-specific services in .NET applications using Microsoft's dependency injection container.

## Features

- **Easy Registration**: Simple service registration with `UseSyrx()` extension
- **Fluent Configuration**: Builder pattern for clean configuration syntax
- **Service Lifetime Management**: Configurable service lifetimes
- **PostgreSQL Optimization**: PostgreSQL-specific configuration options
- **Multiple Connections**: Support for multiple named connections
- **Environment Configuration**: Easy switching between development/production settings

## Installation

```bash
dotnet add package Syrx.Npgsql.Extensions
```

**Package Manager**
```bash
Install-Package Syrx.Npgsql.Extensions
```

**PackageReference**
```xml
<PackageReference Include="Syrx.Npgsql.Extensions" Version="3.0.0" />
```

## Quick Start

### Basic Setup

```csharp
using Syrx.Npgsql.Extensions;

public class Startup
{
    public void ConfigureServices(IServiceCollection services)
    {
        services.UseSyrx(builder => builder
            .UseNpgsql(npgsql => npgsql
                .AddConnectionString("Default", Configuration.GetConnectionString("PostgreSQL"))
                .AddCommand(types => types
                    .ForType<UserRepository>(methods => methods
                        .ForMethod(nameof(UserRepository.GetAllAsync), command => command
                            .UseConnectionAlias("Default")
                            .UseCommandText("SELECT id, name, email FROM users"))))));
    }
}
```

### With Repository Registration

```csharp
public void ConfigureServices(IServiceCollection services)
{
    // Register Syrx with PostgreSQL
    services.UseSyrx(builder => builder
        .UseNpgsql(npgsql => npgsql
            .AddConnectionString("Default", connectionString)
            .AddCommand(/* command configuration */)));

    // Register your repositories
    services.AddScoped<IUserRepository, UserRepository>();
    services.AddScoped<IOrderRepository, OrderRepository>();
}
```

## Configuration Options

### Connection String Management

```csharp
services.UseSyrx(builder => builder
    .UseNpgsql(npgsql => npgsql
        // Multiple connection strings
        .AddConnectionString("Primary", "Host=prod-primary;Database=app;Username=app;Password=secret")
        .AddConnectionString("ReadReplica", "Host=prod-replica;Database=app;Username=reader;Password=secret")
        .AddConnectionString("Analytics", "Host=analytics;Database=warehouse;Username=analyst;Password=secret")
        
        .AddCommand(types => types
            .ForType<UserRepository>(methods => methods
                .ForMethod("GetUsers", command => command
                    .UseConnectionAlias("ReadReplica"))      // Read from replica
                .ForMethod("CreateUser", command => command
                    .UseConnectionAlias("Primary")))         // Write to primary
            .ForType<ReportRepository>(methods => methods
                .ForMethod("GenerateReport", command => command
                    .UseConnectionAlias("Analytics"))))));   // Use analytics DB
```

### Service Lifetime Configuration

```csharp
services.UseSyrx(builder => builder
    .UseNpgsql(
        npgsql => npgsql.AddConnectionString("Default", connectionString),
        ServiceLifetime.Scoped));  // Configure service lifetime
```

### Environment-Specific Configuration

```csharp
public void ConfigureServices(IServiceCollection services)
{
    var connectionString = Environment.IsDevelopment() 
        ? Configuration.GetConnectionString("Development")
        : Configuration.GetConnectionString("Production");

    services.UseSyrx(builder => builder
        .UseNpgsql(npgsql => npgsql
            .AddConnectionString("Default", connectionString)
            .AddCommand(LoadCommandConfiguration())));
}

private Action<ITypeSettingsBuilder> LoadCommandConfiguration()
{
    if (Environment.IsDevelopment())
    {
        // Development-specific commands with detailed logging
        return types => types
            .ForType<UserRepository>(methods => methods
                .ForMethod("GetUsers", command => command
                    .UseConnectionAlias("Default")
                    .UseCommandText("SELECT id, name, email, created_at FROM users ORDER BY created_at DESC")
                    .SetCommandTimeout(30)));
    }
    else
    {
        // Production-optimized commands
        return types => types
            .ForType<UserRepository>(methods => methods
                .ForMethod("GetUsers", command => command
                    .UseConnectionAlias("Default")
                    .UseCommandText("SELECT id, name, email FROM users")
                    .SetCommandTimeout(15)));
    }
}
```

## Advanced Configuration

### PostgreSQL-Specific Features

```csharp
services.UseSyrx(builder => builder
    .UseNpgsql(npgsql => npgsql
        .AddConnectionString("Default", 
            "Host=localhost;Database=myapp;Username=app;Password=secret;" +
            "MinPoolSize=10;MaxPoolSize=200;" +                     // Connection pooling
            "ConnectionLifeTime=300;" +                             // Pool management
            "Timeout=30;CommandTimeout=60;" +                       // Timeouts
            "Pooling=true;KeepAlive=30")                           // Connection keep-alive
        
        .AddCommand(types => types
            .ForType<ProductRepository>(methods => methods
                // PostgreSQL JSON support
                .ForMethod("GetProductsWithAttributes", command => command
                    .UseConnectionAlias("Default")
                    .UseCommandText(@"
                        SELECT 
                            id, 
                            name, 
                            attributes::jsonb as attributes,
                            tags 
                        FROM products 
                        WHERE attributes ? @searchKey"))
                
                // PostgreSQL array support
                .ForMethod("GetProductsByTags", command => command
                    .UseConnectionAlias("Default")
                    .UseCommandText("SELECT * FROM products WHERE tags && @tags"))
                
                // PostgreSQL full-text search
                .ForMethod("SearchProducts", command => command
                    .UseConnectionAlias("Default")
                    .UseCommandText(@"
                        SELECT * FROM products 
                        WHERE search_vector @@ plainto_tsquery(@searchText)
                        ORDER BY ts_rank(search_vector, plainto_tsquery(@searchText)) DESC"))))));
```

### SSL and Security Configuration

```csharp
services.UseSyrx(builder => builder
    .UseNpgsql(npgsql => npgsql
        .AddConnectionString("Secure", 
            "Host=secure.postgres.com;Database=myapp;Username=app;Password=secret;" +
            "SslMode=Require;" +                                    // Require SSL
            "TrustServerCertificate=false;" +                       // Validate certificates
            "ClientCertificate=/path/to/client.crt;" +              // Client certificate
            "ClientCertificateKey=/path/to/client.key;" +           // Client key
            "RootCertificate=/path/to/ca.crt")                      // CA certificate
        
        .AddCommand(/* secure command configuration */)));
```

### Performance Optimization

```csharp
services.UseSyrx(builder => builder
    .UseNpgsql(npgsql => npgsql
        // High-performance connection for OLTP
        .AddConnectionString("OLTP", 
            "Host=oltp.postgres.com;Database=app;Username=app;Password=secret;" +
            "MinPoolSize=20;MaxPoolSize=100;" +
            "ConnectionLifeTime=600;" +
            "Timeout=5;CommandTimeout=30")
        
        // Analytics connection for long-running queries
        .AddConnectionString("Analytics", 
            "Host=analytics.postgres.com;Database=warehouse;Username=analyst;Password=secret;" +
            "MinPoolSize=5;MaxPoolSize=20;" +
            "ConnectionLifeTime=1800;" +
            "Timeout=60;CommandTimeout=300")
        
        .AddCommand(types => types
            .ForType<UserRepository>(methods => methods
                .ForMethod("GetUser", command => command
                    .UseConnectionAlias("OLTP")
                    .SetCommandTimeout(10)))
            .ForType<ReportRepository>(methods => methods
                .ForMethod("GenerateComplexReport", command => command
                    .UseConnectionAlias("Analytics")
                    .SetCommandTimeout(600))))));
```

## Configuration from Files

### JSON Configuration

```csharp
// appsettings.json
{
  "ConnectionStrings": {
    "PostgreSQL": "Host=localhost;Database=myapp;Username=app;Password=secret"
  },
  "Syrx": {
    "Commands": {
      "UserRepository": {
        "GetAllUsers": {
          "ConnectionAlias": "Default",
          "CommandText": "SELECT id, name, email FROM users"
        }
      }
    }
  }
}

// Startup.cs
services.UseSyrx(builder => builder
    .UseNpgsql(npgsql => npgsql
        .AddConnectionString("Default", Configuration.GetConnectionString("PostgreSQL"))
        .FromConfiguration(Configuration.GetSection("Syrx"))));
```

### Configuration Builder Pattern

```csharp
public static class PostgreSqlConfiguration
{
    public static void ConfigurePostgreSQL(this NpgsqlBuilder npgsql, IConfiguration configuration)
    {
        npgsql
            .AddConnectionString("Primary", configuration.GetConnectionString("Primary"))
            .AddConnectionString("ReadReplica", configuration.GetConnectionString("ReadReplica"))
            .AddCommand(types => types
                .ConfigureUserRepository()
                .ConfigureOrderRepository()
                .ConfigureReportRepository());
    }
    
    private static ITypeSettingsBuilder ConfigureUserRepository(this ITypeSettingsBuilder types)
    {
        return types.ForType<UserRepository>(methods => methods
            .ForMethod("GetActiveUsers", command => command
                .UseConnectionAlias("ReadReplica")
                .UseCommandText("SELECT * FROM users WHERE is_active = true"))
            .ForMethod("CreateUser", command => command
                .UseConnectionAlias("Primary")
                .UseCommandText("INSERT INTO users (name, email) VALUES (@Name, @Email) RETURNING id")));
    }
}

// Usage
services.UseSyrx(builder => builder
    .UseNpgsql(npgsql => npgsql.ConfigurePostgreSQL(Configuration)));
```

## Integration Examples

### ASP.NET Core Web API

```csharp
public class Startup
{
    public void ConfigureServices(IServiceCollection services)
    {
        services.UseSyrx(builder => builder
            .UseNpgsql(npgsql => npgsql
                .AddConnectionString("Default", Configuration.GetConnectionString("PostgreSQL"))
                .AddCommand(/* configuration */)));

        services.AddControllers();
        services.AddScoped<IUserService, UserService>();
    }
}

[ApiController]
[Route("api/[controller]")]
public class UsersController : ControllerBase
{
    private readonly IUserService _userService;

    public UsersController(IUserService userService)
    {
        _userService = userService;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<User>>> GetUsers()
    {
        var users = await _userService.GetAllUsersAsync();
        return Ok(users);
    }
}
```

### Background Services

```csharp
services.UseSyrx(builder => builder
    .UseNpgsql(npgsql => npgsql
        .AddConnectionString("Background", connectionString)
        .AddCommand(types => types
            .ForType<EmailService>(methods => methods
                .ForMethod("GetPendingEmails", command => command
                    .UseConnectionAlias("Background")
                    .UseCommandText("SELECT * FROM email_queue WHERE status = 'pending'")))),
    ServiceLifetime.Singleton));

services.AddHostedService<EmailProcessorService>();

public class EmailProcessorService : BackgroundService
{
    private readonly ICommander<EmailService> _commander;

    public EmailProcessorService(ICommander<EmailService> commander)
    {
        _commander = commander;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            var pendingEmails = await _commander.QueryAsync<Email>();
            // Process emails...
            await Task.Delay(TimeSpan.FromMinutes(1), stoppingToken);
        }
    }
}
```

### Testing Integration

```csharp
public class IntegrationTestBase
{
    protected ServiceProvider ServiceProvider { get; private set; }

    [SetUp]
    public void Setup()
    {
        var services = new ServiceCollection();
        
        services.UseSyrx(builder => builder
            .UseNpgsql(npgsql => npgsql
                .AddConnectionString("Test", GetTestConnectionString())
                .AddCommand(LoadTestConfiguration())));

        ServiceProvider = services.BuildServiceProvider();
    }

    private string GetTestConnectionString()
    {
        return "Host=localhost;Database=test_db;Username=test;Password=test";
    }
}

[Test]
public async Task Should_Create_And_Retrieve_User()
{
    // Arrange
    var repository = ServiceProvider.GetService<UserRepository>();
    var user = new User { Name = "Test User", Email = "test@example.com" };

    // Act
    await repository.CreateUserAsync(user);
    var retrievedUser = await repository.GetUserByEmailAsync(user.Email);

    // Assert
    Assert.IsNotNull(retrievedUser);
    Assert.AreEqual(user.Name, retrievedUser.Name);
}
```

## Service Lifetime Considerations

| Lifetime | Use Case | PostgreSQL Considerations |
|----------|----------|---------------------------|
| **Transient** | Default, stateless operations | New connection per operation, good for varied workloads |
| **Scoped** | Web requests, unit of work | Connection per request, ideal for web apps |
| **Singleton** | Background services, high throughput | Shared connection pool, careful with long-running operations |

## Troubleshooting

### Common Configuration Issues

```csharp
// ❌ Missing connection alias
.ForMethod("GetUsers", command => command
    .UseCommandText("SELECT * FROM users"))  // Missing .UseConnectionAlias()

// ✅ Correct configuration
.ForMethod("GetUsers", command => command
    .UseConnectionAlias("Default")
    .UseCommandText("SELECT * FROM users"))

// ❌ Connection string not registered
services.UseSyrx(builder => builder
    .UseNpgsql(npgsql => npgsql
        .AddCommand(/* commands */)));  // Missing .AddConnectionString()

// ✅ Correct registration
services.UseSyrx(builder => builder
    .UseNpgsql(npgsql => npgsql
        .AddConnectionString("Default", connectionString)
        .AddCommand(/* commands */)));
```

### Performance Troubleshooting

```csharp
// Monitor connection pool usage
.AddConnectionString("Monitored", 
    "Host=localhost;Database=myapp;Username=app;Password=secret;" +
    "MinPoolSize=10;MaxPoolSize=100;" +
    "ConnectionLifeTime=300;" +
    "LogParameters=true;LogLevel=Debug")  // Enable detailed logging
```

## Related Packages

- **[Syrx.Npgsql](https://www.nuget.org/packages/Syrx.Npgsql/)**: Core PostgreSQL provider
- **[Syrx.Commanders.Databases.Connectors.Npgsql](https://www.nuget.org/packages/Syrx.Commanders.Databases.Connectors.Npgsql/)**: PostgreSQL connector implementation
- **[Syrx](https://www.nuget.org/packages/Syrx/)**: Core Syrx framework
- **[Syrx.Extensions](https://www.nuget.org/packages/Syrx.Extensions/)**: Core dependency injection extensions

## License

This project is licensed under the [MIT License](https://github.com/Syrx/Syrx/blob/main/LICENSE).

## Credits

- Built on top of [Microsoft.Extensions.DependencyInjection](https://github.com/dotnet/extensions)
- PostgreSQL connectivity via [Npgsql](https://github.com/npgsql/npgsql)
- High-performance data access with [Dapper](https://github.com/DapperLib/Dapper)
