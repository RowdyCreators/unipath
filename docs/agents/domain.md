# Domain docs

This repository uses a single-context domain documentation layout.

## Before exploring the codebase

- Read root `GLOSSARY.md` when it exists.
- Read ADRs in `docs/adr/` that concern the area being explored.

If those files or directories do not exist, proceed silently.
Do not create them just to satisfy this configuration.
The domain-modeling skill creates them as terms and decisions are resolved.

## Layout

- `GLOSSARY.md`: shared domain vocabulary.
- `docs/adr/`: architecture decision records.

## Use the glossary's vocabulary

Use defined domain terms in issue titles, proposals, explanations,
and test names. Avoid synonyms the glossary explicitly rejects.

If a needed concept is absent, reconsider whether it belongs to the
domain. Note genuine vocabulary gaps for domain-modeling.

## Flag ADR conflicts

If a proposal or change contradicts an existing ADR, identify the ADR
and explain the conflict explicitly rather than silently overriding it.
