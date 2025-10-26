# Examples

This file includes short, copy-pasteable examples for common scenarios.

## Dependency Injection registration

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

## Repository usage

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
}
```

## JSON and Arrays

```csharp
// Querying JSON
.UseCommandText("SELECT id, data::jsonb as data, tags FROM products WHERE data->>\'type\' = @type")

// Passing array parameter
var tags = new[] { "admin", "editor" };
var results = await _commander.QueryAsync<Product>(new { tags });
```

## Bulk COPY example

```csharp
.ForMethod("BulkInsert", command => command
    .UseConnectionAlias("Default")
    .UseCommandText("COPY users (name, email) FROM STDIN (FORMAT CSV)")
    .SetCommandTimeout(300))
```
