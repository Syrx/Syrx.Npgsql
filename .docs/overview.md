# Syrx.Npgsql — Overview

Syrx.Npgsql provides PostgreSQL database support for the Syrx framework. It integrates the Npgsql ADO.NET provider with Syrx's database commander and settings system, offering a performant, idiomatic API for command-based data access.

Key goals:

- Provide a dedicated PostgreSQL connector that delegates to Npgsql's provider factory.
- Offer DI-friendly registration through small extension packages.
- Support PostgreSQL-native types (JSON/JSONB, arrays, UUID, INET, INTERVAL, etc.).
- Keep configuration declarative through CommanderSettings used by Syrx builders.

Packages included in this repository:

- `Syrx.Npgsql` — High-level package that aggregates extensions and connector packages for consumers.
- `Syrx.Npgsql.Extensions` — DI extensions and configuration helpers for registering Syrx with PostgreSQL.
- `Syrx.Commanders.Databases.Connectors.Npgsql` — Core connector implementation (NpgsqlDatabaseConnector).
- `Syrx.Commanders.Databases.Connectors.Npgsql.Extensions` — Service registration helpers for the connector.

Supported runtimes and requirements:

- .NET 8.0 or later
- PostgreSQL 12 or later (recommended)
- Npgsql 8.x or later

For quick start instructions and examples see the `examples.md` and each project's README files.
