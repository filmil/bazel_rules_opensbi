# Project conventions

## General change rules

* This repository overlays Bazel build files onto **pristine** OpenSBI source;
  it never vendors or patches OpenSBI. The `opensbi` sources are fetched at build
  time. Do not check OpenSBI source into this repo.
* The fixed-config generated files in `overlay/` (`config/generic/autoconf.h`
  and the `*.carray.c` tables) are produced by `local/gen_overlay.py` from a
  reference `make PLATFORM=generic` build. Regenerate them with that script
  rather than editing by hand.
* Ensure tests pass after every change:
  `bazel build //... && bazel run //:update` (docs), then in `integration/`
  `bazel test //...` (needs `dtc` and `qemu-system-riscv64`).
* When generating scripts, create file templates and load them into rules.
* Put temporary files under `local/` (git-ignored).

## Public API documentation

Run `bazel run //:update` to regenerate every committed `.md` from Stardoc, and
`bazel run //:buildifier` to format BUILD/.bzl files. Keep the documentation
table in `README.md` in sync with the generated files.

## Git commit rules

* Use Conventional Commits v1.0.0 for commit messages and PR descriptions.
* Prefer rebase over merge (e.g. `git rebase origin/main`).
* Use `gh` to open pull requests against `origin/main`.
* Avoid interactive editors: use `--no-edit` / `-m`.
* Any commit or pull request created by an automated assistant must end with:

  ```
  This change has been created by an automated coding assistant,
  with human supervision.
  ```

## Bazel basics

* Workspace root is `//` (where `MODULE.bazel` lives).
* Build everything: `bazel build //...`
* The `integration/` directory is a separate Bazel module; `cd integration`
  before running commands there.
