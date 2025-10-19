# API Reference

This reference covers the primary public surface shipped by the repository. It is not exhaustive but focuses on types consumers will interact with.

## NpgsqlDatabaseConnector

Namespace: `Syrx.Commanders.Databases.Connectors.Npgsql`

Summary: PostgreSQL implementation of `IDatabaseConnector`. Uses `NpgsqlFactory.Instance` to create provider-specific connections. Inherits common behaviour from `DatabaseConnector`.

Remarks: The connector is intended to be registered through the provider extensions and not instantiated directly in most applications. Prefer the `UsePostgres`/`UseNpgsql` registration helpers.

## NpgsqlConnectorExtensions

Namespace: `Syrx.Commanders.Databases.Connectors.Npgsql.Extensions`

- `SyrxBuilder UsePostgres(this SyrxBuilder builder, Action<CommanderSettingsBuilder> factory, ServiceLifetime lifetime = ServiceLifetime.Singleton)`
  - Registers CommanderSettings and the PostgreSQL connector services using the provided factory delegate to build connection strings and command settings.
  - Parameters:
    - `builder`: Syrx configuration builder.
    - `factory`: Action to configure CommanderSettings with connection strings and commands.
    - `lifetime`: Service lifetime to register dependent services with.
  - Returns: The same SyrxBuilder for chaining.

## ServiceCollectionExtensions (internal)

- `IServiceCollection AddPostgres(this IServiceCollection services, ServiceLifetime lifetime = ServiceLifetime.Transient)`
  - Registers `NpgsqlDatabaseConnector` as the implementation of `IDatabaseConnector` and wires the dependency for the given lifetime.

## CommanderSettings and Reader

Consumers will primarily interact with the CommanderSettings builder API to declare connection aliases and command text. The command reader resolves the right `CommandSetting` for a given type/method at runtime.


For more detailed API documentation, see the source XML comments and the README files in each project.
