#!/usr/bin/env bash
# Builds the release archive and prints the release notes to stdout.
#
# Called by bazel-contrib/.github/.github/workflows/release_ruleset.yaml, which
# requires this exact path and reads the release notes from stdout.
set -o errexit -o nounset -o pipefail

TAG="$1"
VERSION="${TAG#v}"
REPO_NAME="bazel_rules_opensbi"
ARCHIVE="${REPO_NAME}-${TAG}.zip"

# These exclusions reproduce the ones thedoctor0/zip-release used before this
# script replaced it, so the archive keeps the same file list. `local/` is the
# scratch directory the integration module's README suggests for an overlaid
# OpenSBI checkout.
#
# `--symlinks` stops `zip` following a symlink and storing what it points at.
# `zip` walks the tree before it applies `-x`, so an exclusion does not stop
# the walk, and with bazel's convenience symlinks present the walk descends the
# whole output base. `*bazel-*` rather than `bazel-*`, because the latter only
# matches the top level and `integration` is its own workspace.
#
# `release_notes.txt` must be excluded too. The reusable workflow runs this
# script as `release_prep.sh TAG > release_notes.txt`, so the shell creates
# that file in the working directory before the script starts.
zip --quiet --symlinks --recurse-paths "${ARCHIVE}" . \
  -x '*.git*' '/*node_modules/*' '.editorconfig' '*bazel-*' \
     'local/*' '*/local/*' 'release_notes.txt' "${ARCHIVE}"

cat <<NOTES
## Using Bzlmod

\`\`\`starlark
bazel_dep(name = "rules_opensbi", version = "${VERSION}")
\`\`\`
NOTES
