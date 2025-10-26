# Architecture

This section explains the architecture and how the pieces fit together.

Core concepts:

- CommanderSettings: Declarative configuration containing connection strings and command definitions. Built with a builder API and consumed by DI registration extensions.
- IDatabaseConnector: Abstraction for a database-specific connector. Connectors create provider-specific connections and execute queries/commands.
- DatabaseConnector: Base implementation that orchestrates common behaviours such as opening connections, transaction management and mapping results.
- NpgsqlDatabaseConnector: PostgreSQL-specific connector that plugs Npgsql's DbProviderFactory into the DatabaseConnector base.
- DatabaseCommander<T>: Generic commander used by application code to perform queries and executes using the configured connector and settings.

Dependency registration flow (typical when calling UsePostgres / UseNpgsql):

1. Build CommanderSettings from the provided configuration action.
2. Register the CommanderSettings instance as <code>ICommanderSettings</code>.
3. Register a command reader implementation (IDatabaseCommandReader) to resolve command settings per type/method.
4. Register the database connector implementation (IDatabaseConnector) — e.g. NpgsqlDatabaseConnector.
5. Register DatabaseCommander<T> for consumers.

Notes on lifetimes:

- Lifetime configuration is exposed by the extension helpers. Transient (default), Scoped and Singleton lifetimes are supported. Choose Scoped for web request-based units of work, Singleton for long-running background processes with care.

Error handling:

- PostgreSQL-specific errors are surfaced via <code>PostgresException</code> (Npgsql). The connector and higher-level helpers prefer mapping known SqlState codes to typed exceptions where appropriate (e.g., unique key violation -> DuplicateKeyException).
