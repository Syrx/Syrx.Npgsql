# Security Policy

## Supported Versions

Security fixes are provided for the latest major version on the default branch.

| Version | Supported |
| --- | --- |
| 3.x | Yes |
| < 3.0 | No |

## Reporting A Vulnerability

Do not open public issues for suspected security vulnerabilities.

1. Email repository maintainers with the subject: `Security vulnerability report - Syrx.Npgsql`.
2. Include reproduction details, impact, and any proof-of-concept information.
3. Allow maintainers time to triage and coordinate disclosure before publishing details.

If you cannot identify maintainers, open a minimal issue requesting a private reporting channel without disclosing exploit details.

## Security Guidance

- Never commit production credentials or secrets.
- Use environment variables or a secure secret store for connection strings.
- Keep `Include Error Detail=false` and `LogParameters=false` outside local debugging.
- Use least-privilege database accounts for application workloads.