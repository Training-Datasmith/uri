#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

"${REPO_ROOT}/scripts/prepare-test-fixtures.sh"

if ! command -v composer >/dev/null 2>&1; then
  echo "composer is required on PATH" >&2
  exit 1
fi

PHP_BIN="${PHP_BIN:-php8.1}"

if [[ ! -f vendor/autoload.php ]]; then
  "${PHP_BIN}" "$(command -v composer)" install --no-interaction --no-progress --prefer-dist
fi

exec "${PHP_BIN}" vendor/bin/phpunit --configuration phpunit.xml.dist --do-not-cache-result "$@"
