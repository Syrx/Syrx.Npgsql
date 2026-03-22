# Syrx.Npgsql Implementation Plan

Date: 2026-03-22
Branch target: 3.0.0
Scope: Implement remediation items from the security and performance research reports.

## Source Inputs

- Security findings: .docs/research/security/Syrx.Npgsql-security-research-report-20260322.md
- Performance findings: .docs/research/performance/Syrx.Npgsql-performance-research-report-20260322.md

## Plan Goals

1. Eliminate medium-severity security findings in documentation and logging paths.
2. Remove top performance bottlenecks in test infrastructure and CI.
3. Add regression-proof test coverage for key security and performance-sensitive behaviors.
4. Keep build and full test suite green throughout implementation.

## Delivery Principles

1. Implement in small, verifiable batches.
2. Preserve public API behavior unless explicitly required.
3. Prefer fixes with measurable impact and low migration risk.
4. End each phase with build + tests + documentation updates.

## Workstreams

### Workstream A: Security Hardening

A1. Remove hardcoded credential patterns from product documentation.
- Target files:
  - src/Syrx.Npgsql.Extensions/README.md
  - src/Syrx.Commanders.Databases.Connectors.Npgsql/README.md
  - src/Syrx.Npgsql/README.md
  - src/Syrx.Commanders.Databases.Connectors.Npgsql.Extensions/README.md
  - .docs/examples.md
- Changes:
  - Replace literal passwords with placeholders.
  - Add warnings against committing credentials.
  - Add environment-variable based configuration examples.
- Acceptance:
  - No password literals in public docs except explicitly marked test-only examples.

A2. Eliminate sensitive connection string logging in integration fixture.
- Target file:
  - tests/integration/Syrx.Npgsql.Tests.Integration/NpgsqlFixture.cs
- Changes:
  - Stop logging raw connection strings.
  - If needed, log redacted or non-sensitive fields only.
- Acceptance:
  - No log output path includes full credentials.

A3. Add security guidance artifact.
- Target files:
  - SECURITY.md (new)
  - README.md (link to security guidance)
  - .docs/overview.md or .docs/architecture.md (brief security section)
- Changes:
  - Disclosure policy, reporting channel, supported versions.
  - Secure configuration checklist for connection strings and logging.
- Acceptance:
  - SECURITY.md exists and is linked from top-level README.

A4. Add focused security regression tests.
- Target area:
  - tests/unit and tests/integration
- Candidate tests:
  - Ensure docs/config helpers do not emit sensitive data in logs.
  - Validate command usage remains parameterized in supported execution paths.
- Acceptance:
  - New security-oriented tests pass in CI.

### Workstream B: Performance Improvements

B1. Remove sync-over-async fixture startup pattern.
- Target file:
  - tests/integration/Syrx.Npgsql.Tests.Integration/NpgsqlFixture.cs
- Changes:
  - Ensure container start remains fully async in lifecycle methods.
- Acceptance:
  - No .Wait() or .Result in fixture startup path.

B2. Replace N+1 seed insert pattern with batched strategy.
- Target file:
  - tests/integration/Syrx.Npgsql.Tests.Integration/DatabaseBuilder.cs
- Changes:
  - Use batched insert strategy (multi-row insert or equivalent bulk path).
- Acceptance:
  - Seed path no longer issues one command per row.

B3. Reduce fixture startup allocation/logging overhead.
- Target file:
  - tests/integration/Syrx.Npgsql.Tests.Integration/NpgsqlFixture.cs
- Changes:
  - Remove repeated large string construction for banner logs.
  - Gate verbose details behind debug-only or remove.
- Acceptance:
  - Startup logging is concise and low-allocation.

B4. CI workflow optimization.
- Target file:
  - .github/workflows/publish.yml
- Changes:
  - Remove redundant submodule init steps when checkout already handles recursive submodules.
  - Add Docker build caching strategy where applicable.
  - Keep .NET 10 matrix behavior intact.
- Acceptance:
  - Workflow remains valid and runs tests successfully.

B5. Tune Docker readiness settings for integration tests.
- Target file:
  - tests/integration/Syrx.Npgsql.Tests.Integration/Docker/docker-compose.yml
- Changes:
  - Reduce conservative healthcheck timing where safe.
- Acceptance:
  - Integration tests remain stable and startup time improves.

## Execution Order

Phase 1: Security docs and logging baseline.
- Deliver: A1, A2, A3
- Gate:
  - dotnet build Syrx.Npgsql.sln -c Release
  - dotnet test Syrx.Npgsql.sln -c Release --no-build

Phase 2: Performance fixture and seed path.
- Deliver: B1, B2, B3
- Gate:
  - dotnet build Syrx.Npgsql.sln -c Release
  - dotnet test tests/integration/Syrx.Npgsql.Tests.Integration/Syrx.Npgsql.Tests.Integration.csproj -c Release --no-build

Phase 3: CI and Docker pipeline optimization.
- Deliver: B4, B5
- Gate:
  - Workflow lint/validation check
  - Full solution tests locally

Phase 4: Security and performance regression tests.
- Deliver: A4
- Gate:
  - Full unit and integration test pass
  - Documentation links and references validated

## Definition of Done

1. Security report medium findings are resolved or downgraded with explicit rationale.
2. Performance critical/high findings are resolved in code or workflow.
3. SECURITY.md exists and is linked from README.
4. Build passes cleanly in Release.
5. All unit and integration tests pass.
6. Changes are documented in .docs/migration.md if user-visible behavior changed.

## Risk Register and Mitigations

R1. Test flakiness after fixture/healthcheck changes.
- Mitigation: Apply timing changes incrementally; run integration tests multiple times.

R2. Behavior drift from seed strategy changes.
- Mitigation: Keep seeded data shape identical; assert expected row counts and values.

R3. CI workflow regressions.
- Mitigation: Keep workflow edits minimal and validate syntax plus local equivalent steps.

R4. Documentation inconsistency across package READMEs.
- Mitigation: Update all package README files in one batch and cross-check wording.

## Session Handoff Checklist

Use this checklist at the end of each session:

1. Update this file with completed items and next item in progress.
2. Record commands executed and outcomes in commit message or PR notes.
3. Confirm current branch and submodule SHAs.
4. Re-run build/tests for changed scope.
5. Leave explicit next action as one line under Next Step.

## Tracking Board

Status key: Not Started, In Progress, Blocked, Done.

- A1 Documentation credential cleanup: Done
- A2 Sensitive log redaction in fixture: Done
- A3 Security guidance artifacts: Done
- A4 Security regression tests: Done
- B1 Async fixture startup cleanup: Done
- B2 Batched seed inserts: Done
- B3 Startup logging allocation reduction: Done
- B4 CI submodule and Docker optimization: Done
- B5 Docker healthcheck tuning: Done

## Next Step

Record before/after timing metrics for integration startup and prepare commit/PR notes with validation evidence.
