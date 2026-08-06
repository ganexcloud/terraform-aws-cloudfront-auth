# Contributing

Contributions that improve this Terraform module are welcome. Please keep each
change focused, documented, and validated before opening a pull request.

## Prerequisites

- The Terraform version declared in `.terraform-version`.
- Docker, used by the `terraform-docs` pre-commit hook.
- Python with `pre-commit` installed. For example: `pipx install pre-commit`.

## Local validation

Before opening a pull request, run:

```shell
tfswitch
pre-commit run --all-files
```

The command formats Terraform, validates the root module, runs TFLint, checks
for credentials, and refreshes generated Terraform documentation in
`README.md`. Do not manually edit content between Terraform Docs markers.

## Pull requests

- Create a branch from the repository default branch and keep the pull request
  focused on one change.
- Describe the behavior being changed and include an example when the module
  interface changes.
- Ensure the GitHub Actions validation workflow passes before requesting review.
- Use a Conventional Commit-compatible pull request title. Allowed types are
  `feat`, `fix`, `docs`, `ci`, `chore`, `style`, and `revert`. The
  subject must start with a lowercase character.

## Releases

Releases are automated by Semantic Release after changes are merged into the
repository default branch. It determines the next semantic version from
Conventional Commits, creates the Git tag and GitHub Release, and updates
`CHANGELOG.md`.

- `fix:` produces a patch release.
- `feat:` produces a minor release.
- A commit with `!` in its type or scope, or a `BREAKING CHANGE:` footer,
  produces a major release.

The Terraform Registry is connected to this repository once by the module
owner. After initial registration, Registry versions are indexed from Semantic
Release Git tags.
