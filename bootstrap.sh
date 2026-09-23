#!/usr/bin/env bash
#
# bootstrap.sh — one-shot setup for a repo created from the Rowdy Creators
# GitHub template.
#
# and then applies the standard repository settings on GitHub.
#
# Run it once, right after you click "Use this template" and clone the repo:
#
#   ./bootstrap.sh                 # interactive, auto-detects org/repo
#   ./bootstrap.sh --owner acme-corp/platform --org acme-corp --public --yes
#
# Requirements:
#   - git
#   - GitHub CLI (https://cli.github.com), authenticated (`gh auth login`)
#   - admin rights on the repository
#
set -euo pipefail

# --------------------------------------------------------------------------
# Validation
# --------------------------------------------------------------------------

# GitHub repo names: letters, digits, dot, dash, underscore.
REPO_RE='^[A-Za-z0-9._-]+$'
# Either "user" (a user/org) or "foo-org/team" (an org team).
OWNER_RE='^[A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?(/[A-Za-z0-9._-]+)?$'

die() {
  echo "error: $*" >&2
  exit 1
}

validate_owner() {
  [[ "$1" =~ $OWNER_RE ]] ||
    die "'$1' is not a valid GitHub handle. Expected 'username', 'org', or 'org/team'."
}

validate_repo() {
  [[ "$1" =~ $REPO_RE ]] ||
    die "'$1' is not a valid repository name. Use letters, digits, '.', '-' or '_'."
}

# --------------------------------------------------------------------------
# Arguments
# --------------------------------------------------------------------------

OWNER=""      # code owner handle: user, org, or org/team (drives CODEOWNERS)
ORG=""        # org/user that owns the repo (drives URLs)
REPO=""       # repository name
VISIBILITY="" # "--public" or "--private"; empty means leave as-is
ASSUME_YES=0
DO_COMMIT=1

usage() {
  cat <<'EOF'
Usage: ./bootstrap.sh [options]

  --owner HANDLE   GitHub handle used as the default code owner.
                   A user ('octocat'), an org, or an org team ('acme-corp/platform').
                   Defaults to the org.
  --org ORG        GitHub org or user that owns the repo (used to build URLs).
                   Auto-detected from the git remote when possible.
  --repo REPO      Repository name. Auto-detected from the git remote when possible.
  --public         Make the repository public when applying settings.
  --private        Make the repository private when applying settings.
  --no-commit      Do not create a commit after filling in the placeholders.
  --yes            Non-interactive: accept detected values and defaults.
  -h, --help       Show this help.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
  --owner)
    OWNER="${2:-}"
    shift 2
    ;;
  --org)
    ORG="${2:-}"
    shift 2
    ;;
  --repo)
    REPO="${2:-}"
    shift 2
    ;;
  --public)
    VISIBILITY="--public"
    shift
    ;;
  --private)
    VISIBILITY="--private"
    shift
    ;;
  --no-commit)
    DO_COMMIT=0
    shift
    ;;
  --yes | -y)
    ASSUME_YES=1
    shift
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *) die "unknown option '$1' (see --help)" ;;
  esac
done

command -v git >/dev/null || die "git not found on PATH."
command -v gh >/dev/null || die "gh CLI not found (https://cli.github.com)."

# --------------------------------------------------------------------------
# Figure out org / repo / owner
# --------------------------------------------------------------------------

# Try to auto-detect "org/repo" from the repository's GitHub remote.
detected=""
if detected="$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null)"; then
  [[ -z "$ORG" ]] && ORG="${detected%%/*}"
  [[ -z "$REPO" ]] && REPO="${detected##*/}"
fi

prompt() {
  # prompt <varname> <question> <default>
  local __var="$1" question="$2" default="${3:-}" reply
  if [[ "$ASSUME_YES" == 1 ]]; then
    printf -v "$__var" '%s' "$default"
    return
  fi
  if [[ -n "$default" ]]; then
    read -r -p "$question [$default]: " reply
    reply="${reply:-$default}"
  else
    read -r -p "$question: " reply
  fi
  printf -v "$__var" '%s' "$reply"
}

prompt ORG "GitHub org or user that owns the repo" "$ORG"
[[ -n "$ORG" ]] || die "an org/user is required."
validate_owner "$ORG"

prompt REPO "Repository name" "$REPO"
[[ -n "$REPO" ]] || die "a repository name is required."
validate_repo "$REPO"

# Code owner defaults to the org itself.
prompt OWNER "Default code owner (user, org, or org/team)" "${OWNER:-$ORG}"
validate_owner "$OWNER"

OWNER_MENTION="@$OWNER"

echo
echo "  org:         $ORG"
echo "  repo:        $REPO"
echo "  code owner:  $OWNER_MENTION"
echo

if [[ "$ASSUME_YES" != 1 ]]; then
  read -r -p "Proceed with these values? [Y/n] " reply
  [[ -z "$reply" || "$reply" == [Yy]* ]] || die "aborted."
fi

# --------------------------------------------------------------------------
# Fill in the {{...}} placeholders in place
# --------------------------------------------------------------------------
#
# Only files that actually contain the {{ORG}} / {{REPO}} / {{OWNER_MENTION}}
# markers are touched. GitHub Actions' ${{ ... }} expressions are left alone
# because they do not contain those keys.

echo "==> Filling in template placeholders"

self_name="$(basename "$0")"

# Pure-bash substitution avoids sed escaping headaches with '@' and '/'.
substitute() {
  local file="$1" content
  content="$(cat "$file")"
  content="${content//\{\{REPO\}\}/$REPO}"
  content="${content//\{\{ORG\}\}/$ORG}"
  content="${content//\{\{OWNER_MENTION\}\}/$OWNER_MENTION}"
  printf '%s\n' "$content" >"$file"
}

changed=0
while IFS= read -r -d '' file; do
  [[ "$(basename "$file")" == "$self_name" ]] && continue
  substitute "$file"
  echo "  $file"
  changed=1
done < <(grep -rlZ -e '{{ORG}}' -e '{{REPO}}' -e '{{OWNER_MENTION}}' . --exclude-dir=.git 2>/dev/null || true)

[[ "$changed" == 1 ]] || echo "  (no placeholders found — already bootstrapped?)"

# --------------------------------------------------------------------------
# LICENSE warning (ported from mktemplate.py)
# --------------------------------------------------------------------------

if [[ ! -f LICENSE ]]; then
  cat >&2 <<'EOF'

  ----------------------------------------------------------------
  WARNING: no LICENSE file exists.

  Until you add one, default copyright applies: nobody outside the
  organisation has the right to use, copy, modify or distribute this
  code, contributors have no clear terms to contribute under, and
  GitHub will label the repository as unlicensed.

  Pick one at https://choosealicense.com and save it as LICENSE, or
  use GitHub's 'Add file -> Create new file -> LICENSE' flow, which
  offers a license template picker.
  ----------------------------------------------------------------
EOF
fi

# --------------------------------------------------------------------------
# Apply GitHub repository settings (ported from setup-github.sh)
# --------------------------------------------------------------------------

if ! gh repo view "$ORG/$REPO" >/dev/null 2>&1; then
  echo
  echo "==> $ORG/$REPO does not exist on GitHub yet."
  if [[ "$VISIBILITY" == "" ]]; then
    VISIBILITY="--private"
  fi
  if [[ "$VISIBILITY" == "--public" && ! -f LICENSE ]]; then
    echo "warning: creating a PUBLIC repository with no LICENSE file."
    if [[ "$ASSUME_YES" != 1 ]]; then
      read -r -p "         Continue? [y/N] " reply
      [[ "$reply" == [Yy]* ]] || die "aborted."
    fi
  fi
  echo "==> Creating $ORG/$REPO ($VISIBILITY)"
  gh repo create "$ORG/$REPO" "$VISIBILITY" --source=. --remote=origin --push
else
  echo
  echo "==> $ORG/$REPO already exists, skipping creation"
  if [[ "$VISIBILITY" != "" ]]; then
    echo "==> Setting visibility ($VISIBILITY)"
    gh repo edit "$ORG/$REPO" "--visibility" "${VISIBILITY#--}" --accept-visibility-change-consequences >/dev/null
  fi
fi

echo "==> Merge settings: squash only, auto-delete branches"
gh api -X PATCH "repos/$ORG/$REPO" \
  -F allow_squash_merge=true \
  -F allow_merge_commit=false \
  -F allow_rebase_merge=false \
  -F allow_auto_merge=true \
  -F delete_branch_on_merge=true \
  -F squash_merge_commit_title=PR_TITLE \
  -F squash_merge_commit_message=PR_BODY \
  -F has_wiki=false \
  -F has_projects=false >/dev/null

echo "==> Enabling Dependabot alerts and automated security fixes"
gh api -X PUT "repos/$ORG/$REPO/vulnerability-alerts" >/dev/null
gh api -X PUT "repos/$ORG/$REPO/automated-security-fixes" >/dev/null

echo "==> Enabling secret scanning with push protection"
gh api -X PATCH "repos/$ORG/$REPO" \
  -f 'security_and_analysis[secret_scanning][status]=enabled' \
  -f 'security_and_analysis[secret_scanning_push_protection][status]=enabled' \
  >/dev/null || echo "    (skipped — needs GitHub Advanced Security on private repos)"

echo "==> Applying branch ruleset to the default branch"
gh api -X POST "repos/$ORG/$REPO/rulesets" \
  --input .github/rulesets/main.json >/dev/null ||
  echo "    (a ruleset with this name may already exist — check the repo settings)"

# --------------------------------------------------------------------------
# Commit the filled-in files and remove this bootstrap script
# --------------------------------------------------------------------------

if [[ "$DO_COMMIT" == 1 && "$changed" == 1 ]] && git rev-parse --git-dir >/dev/null 2>&1; then
  echo
  echo "==> Committing the bootstrapped scaffold"
  git rm -q --ignore-unmatch "$self_name" 2>/dev/null || rm -f "$self_name"
  git add -A
  git commit -q -m "chore: bootstrap repository from template" || true
  echo "    committed (and removed $self_name). Push with: git push"
else
  # Even without a commit, drop the now-spent bootstrap script.
  rm -f "$self_name"
fi

# --------------------------------------------------------------------------
# Next steps
# --------------------------------------------------------------------------

cat <<EOF

Done. Remaining manual steps:
  - Add a LICENSE file if you have not already
  - Remove the TODO markers left in the template files
  - Require 2FA at the organisation level
  - Add a second admin so there is no single point of failure
  - Create Environments for deploys and add required reviewers on production
EOF
