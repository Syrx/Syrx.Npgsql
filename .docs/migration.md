# Migration Notes

This document highlights common migration concerns when moving from other providers or earlier versions.

## From ADO.NET

- Replace raw NpgsqlConnection usage with `ICommander<T>` calls and declare commands in CommanderSettings.
- Parameter binding is preserved; prefer anonymous objects for parameter values.

## From Entity Framework

- Move read/query logic to commander queries and map DTOs instead of EF entities where appropriate.
- Transactions: use the same transaction boundaries but call into the connector APIs when necessary.

## Version compatibility

- Ensure Npgsql major version compatibility; update connection strings and configuration flags when upgrading Npgsql.
- When upgrading .NET runtime, verify the csproj PackageReadmeFile and README locations remain consistent for NuGet packaging.

## Breaking changes to watch

- Changes to CommanderSettings or the builder API may require updates to extension registration calls.
- Changes to the DatabaseConnector base may affect custom connector implementations.
