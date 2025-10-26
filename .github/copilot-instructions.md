Copilot / Agent instructions for Syrx.Npgsql

Purpose

This file provides guidance to future automated agents and contributors working on the `Syrx.Npgsql` repository. Follow these guidelines to preserve architecture, style, documentation, and packaging conventions.

1. Architecture and intent
- The repository provides a PostgreSQL connector and DI extensions for the Syrx framework. The connector should delegate to `NpgsqlFactory.Instance` and inherit common behaviour from `DatabaseConnector`.
- Keep the connector implementation thin; place database-agnostic behaviour in the `DatabaseConnector` base class.

2. Coding style
- Prefer concise, clear XML documentation comments on all public types and members.
- Use expression-bodied or primary-constructor-style types when it improves clarity (project uses modern C# patterns).
- Keep internal helper methods documented but not publicly visible in API references.

3. Documentation
- Each project that is packaged must include a `README.md` at the project root. If the csproj uses `<PackageReadmeFile>readme.md</PackageReadmeFile>`, ensure the referenced file path exists and is included in the package.
- Keep the `.docs/` folder as the canonical, consolidated technical documentation (overview, architecture, API reference, examples, migration notes).
- When updating README files, keep content consistent with `.docs/*` and cross-link to the appropriate `.docs` pages.
- Follow the existing README style in `.submodules` for tone, structure and headings.

4. Tests and CI
- Run `dotnet build` and unit tests locally after changes. Fix warnings related to missing XML documentation to improve package API docs.
- Avoid changing public APIs unless necessary; if changes are required, update README and `.docs` accordingly.

5. Packaging
- Keep `PackageTags`, `Description`, and `PackageReadmeFile` accurate in the csproj for NuGet packaging.
- If adding new package-level documentation, include a succinct `README.md` that is appropriate for NuGet consumers (short usage, install snippet, minimal example).

6. Commits and PRs
- Small, focused commits are preferred. Include documentation changes in the same PR as code changes when they affect public behavior.
- For API changes, include a migration note in `.docs/migration.md`.

7. When uncertain
- Prefer conservative changes: add documentation and helpers rather than change behaviour.
- If a requested change impacts other submodules, open an issue and request guidance from repository owners.

Thank you for keeping the project consistent and well-documented.
