#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_FILES_ROOT="$(dirname "$REPO_ROOT")/test_files"
TEMPLATE_FIXTURES_ROOT="$(cd "${REPO_ROOT}/UriTemplate/../.." && pwd)/vendor/uri-templates/uritemplate-test"

ensure_dir() {
  local dir="$1"
  if mkdir -p "${dir}" 2>/dev/null; then
    return 0
  fi
  if command -v sudo >/dev/null 2>&1; then
    sudo mkdir -p "${dir}"
    sudo chown -R "$(id -u):$(id -g)" "${dir}"
    return 0
  fi
  echo "Unable to create ${dir}" >&2
  return 1
}

ensure_dir "${TEST_FILES_ROOT}"
ensure_dir "${TEMPLATE_FIXTURES_ROOT%/*}"

if [[ -d "${REPO_ROOT}/test_files" ]]; then
  cp -a "${REPO_ROOT}/test_files/." "${TEST_FILES_ROOT}/"
else
  curl -fsSL -o "${TEST_FILES_ROOT}/hello-world.txt" \
    https://raw.githubusercontent.com/thephpleague/uri-src/master/test_files/hello-world.txt
  curl -fsSL -o "${TEST_FILES_ROOT}/red-nose.gif" \
    https://raw.githubusercontent.com/thephpleague/uri-src/master/test_files/red-nose.gif
  curl -fsSL -o "${TEST_FILES_ROOT}/john-doe.vcf" \
    https://raw.githubusercontent.com/thephpleague/uri-src/master/test_files/john-doe.vcf
fi

for json in spec-examples.json negative-tests.json extended-tests.json; do
  test -s "${TEMPLATE_FIXTURES_ROOT}/${json}" || {
    rm -rf "${TEMPLATE_FIXTURES_ROOT}"
    git clone --depth 1 https://github.com/uri-templates/uritemplate-test.git \
      "${TEMPLATE_FIXTURES_ROOT}"
    break
  }
done

test -s "${TEST_FILES_ROOT}/hello-world.txt"
test -s "${TEST_FILES_ROOT}/red-nose.gif"
test -s "${TEMPLATE_FIXTURES_ROOT}/spec-examples.json"

echo "Fixtures ready:"
echo "  test_files=${TEST_FILES_ROOT}"
echo "  uritemplate=${TEMPLATE_FIXTURES_ROOT}"
