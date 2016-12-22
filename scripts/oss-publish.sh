#!/bin/bash

# set -x
set -e

THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION="$(node -p 'require("./package.json").version')"

# When running in CircleCI, verify that the release branch matches the package
# version, and download apm.

if [[ ! -z "$CI" ]]; then
  echo "Building branch:"
  echo "$CIRCLE_BRANCH"
  if [[ "$CIRCLE_BRANCH" != "release-nuclide-v${VERSION}" ]]; then
    echo "Expected build branch to be \"release-nuclide-v${VERSION}\"."
    exit 1
  fi

  # Excerpts from https://github.com/atom/ci/blob/5587d0e/build-package.sh
  echo "Downloading latest Atom release..."
  ATOM_CHANNEL="${ATOM_CHANNEL:=stable}"

  if [ "${CIRCLECI}" = "true" ]; then
    curl -s -L "https://atom.io/download/deb?channel=${ATOM_CHANNEL}" \
      -H 'Accept: application/octet-stream' \
      -o "atom-amd64.deb"
    sudo dpkg --install atom-amd64.deb || true
    sudo apt-get update
    sudo apt-get -f install
    export ATOM_SCRIPT_PATH="atom"
    export APM_SCRIPT_PATH="apm"
    export NPM_SCRIPT_PATH="/usr/share/atom/resources/app/apm/node_modules/.bin/npm"
  else
    echo "Unknown CI environment, exiting!"
    exit 1
  fi
fi

echo "Using Atom version:"
atom -v
echo "Using APM version:"
apm -v

# "$THIS_DIR/scripts/release-generate-proxies.js" --save
# "$THIS_DIR/scripts/release-transpile.js" --overwrite
# "$THIS_DIR/scripts/prepare-apm-release.js"

# Force a detached HEAD
git checkout $(git rev-parse HEAD)

git ls-files --ignored --exclude-standard -z | xargs -0 git rm --cached
git add -A && git commit -F- <<EOF
Release ${VERSION}

This commit is the built version of Nuclide suitable for apm and npm.
EOF

git tag "${VERSION}"
git push origin "${VERSION}"

npm publish

apm publish --tag "${VERSION}"
