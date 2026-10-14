# Issue tracker: GitHub

Issues and specs live in GitHub Issues for `RowdyCreators/unipath`.
Use the `gh` CLI for tracker operations.

Run commands inside this clone, or specify
`--repo RowdyCreators/unipath` explicitly.

## Issue operations

- Create: `gh issue create --title "..." --body-file <file>`
- Read: `gh issue view <number> --comments`
- Read structured metadata:
  `gh issue view <number> --json number,title,body,labels,comments,assignees,state`
- List:
  `gh issue list --state open --json number,title,body,labels,assignees`
- Comment: `gh issue comment <number> --body-file <file>`
- Apply labels: `gh issue edit <number> --add-label "..."`
- Remove labels: `gh issue edit <number> --remove-label "..."`
- Assign: `gh issue edit <number> --add-assignee @me`
- Close: `gh issue close <number> --comment "..."`

Use state and label filters appropriate to the task.
Label mappings are defined in `docs/agents/triage-labels.md`.

When a skill says "publish to the issue tracker," create a GitHub issue.
When it says "fetch the relevant ticket," read the issue and its comments.

## Pull requests as a triage surface

**PRs as a request surface: no.**

GitHub issues and pull requests share a number space.
If a reference is ambiguous, determine whether it identifies an issue
or a pull request before acting.

## Parent issues and dependencies

Use native GitHub sub-issues when available. Otherwise, add
`Part of #<parent>` to the child's body and list the child in the
parent's task list.

Use native GitHub issue dependencies when available. To add a blocker:

```bash
gh api --method POST \
  repos/RowdyCreators/unipath/issues/<child-number>/dependencies/blocked_by \
  -F issue_id=<blocker-database-id>
```

Retrieve the blocker's database ID with:

```bash
gh api repos/RowdyCreators/unipath/issues/<blocker-number> --jq .id
```

The database ID is not the issue number or `node_id`.

If native dependencies are unavailable, put
`Blocked by: #<number>, #<number>` at the top of the child issue.
A ticket is unblocked when all its blockers are closed.

## Wayfinding operations

When using the wayfinder skill:

- Keep the map in one issue labeled `wayfinder:map`.
- Link child tickets using the parent-issue convention above.
- Label children `wayfinder:research`, `wayfinder:prototype`,
  `wayfinder:grilling`, or `wayfinder:task`.
- Select the first open child in map order that has no open blocker
  and no assignee.
- Claim it by assigning the driving developer.
- Resolve it by commenting with the answer, closing the ticket,
  and adding a summary and link to the map's Decisions-so-far section.
