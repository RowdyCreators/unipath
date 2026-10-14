# Agent instructions

Follow `CONTRIBUTING.md` for the development and review workflow.

## Technology stack

- Frontend: plain HTML, CSS, and JavaScript.
- Frontend tooling: Vite, with npm as the package manager.
- Backend: Python with Flask.
- Database: PostgreSQL, hosted as the application's single source of truth.
- College-search and scholarship logic: Python modules called by Flask,
  independent of HTTP handling and database access.

Use this stack for the MVP.

## Agent skills

### Issue tracker

Track issues and specs in GitHub Issues for `RowdyCreators/unipath`.
Before issue operations, read `docs/agents/issue-tracker.md`.

### Triage labels

Use the five default triage labels.
Before triaging or applying triage labels, read `docs/agents/triage-labels.md`.

### Domain docs

Use a single-context layout: root `GLOSSARY.md` and `docs/adr/`.
Before exploring the codebase, read `docs/agents/domain.md`.
