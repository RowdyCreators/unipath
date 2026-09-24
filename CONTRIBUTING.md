# Contributing to unipath

## Workflow

We use trunk-based development. `main` is always releasable.

1. Branch off `main`. Name it `feat/short-description`, `fix/issue-123`,
   `chore/...`, `docs/...` or `refactor/...`.
2. Keep the branch short-lived: hours or days.
3. Push and open a pull request. Draft PRs are welcome and encouraged early.
4. CI must be green and you need one approval from a code owner.
5. Squash merge. The branch is deleted automatically.

Never push directly to `main`. The ruleset will reject it, including for admins.

## Commit and PR titles

We follow [Conventional Commits](https://www.conventionalcommits.org/).
Because we squash merge, **the PR title becomes the commit message**, so it is
the title that matters most:

```
feat(billing): add proration for mid-cycle upgrades
fix: handle empty response from the pricing API
chore(deps): bump actions/checkout to v4
```

Breaking changes get a `!` before the colon and a `BREAKING CHANGE:` footer.

## Review expectations

- Authors: keep PRs under ~400 changed lines where you can. Describe the *why*
  in the description, not just the *what*. Respond to every comment.
- Reviewers: aim for a first pass within one working day. Distinguish blocking
  comments from suggestions, prefix non-blocking ones with `nit:`.
- Resolve all conversations before merging.

## Local checks

Run the same checks CI runs before you push.

```bash
# TODO: lint command
# TODO: test command
```
