# Security policy

## Reporting a vulnerability

Do **not** open a public issue for security problems.

Use [private vulnerability reporting](https://github.com/{{ORG}}/{{REPO}}/security/advisories/new)
to report the issue. You should get an acknowledgement within two business days
and an assessment within five.

Please include: what you found, how to reproduce it, and what an attacker could
do with it.

## Mitigations 

- Secret scanning with push protection is enabled on this repository.
- Dependabot alerts and updates are enabled.
- Every change reaches `main` through a reviewed pull request.
- Only the latest release on `main` receives security fixes.
