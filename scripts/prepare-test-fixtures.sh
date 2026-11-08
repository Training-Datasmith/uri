#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_FILES_ROOT="$(dirname "$REPO_ROOT")/test_files"
TEMPLATE_FIXTURES_ROOT="$(cd "${REPO_ROOT}/UriTemplate/../.." && pwd)/vendor/uri-templates/uritemplate-test"
COMMITTED_TEST_FILES="${REPO_ROOT}/test_files"
COMMITTED_TEMPLATE_FIXTURES="${REPO_ROOT}/test_fixtures/uritemplate-test"

# Pinned fixture bytes (thephpleague/uri-src test_files @ master snapshot used in harness).
declare -A TEST_FILE_SHA256=(
  [hello-world.txt]=6fab8500b136ecf4cd70293b87c34dd03d3d1ef62b8c4312082fc18a93e129b1
  [red-nose.gif]=c3530bd10d57059c5eab1f4af836c66fd8ba406966e5e5840482aaaf0eb54b89
  [john-doe.vcf]=b8ab589a04447f1ef5118a4b7430654d8c3c19be8b789ac6460ad9e9f06d3c62
)

# uri-templates/uritemplate-test @ 4171dac22aa67fc710b3f6df308a50bd08552986
declare -A TEMPLATE_FIXTURE_SHA256=(
  [spec-examples.json]=9148100604d25beb4fcc56b9d3a3ed6a0067d5f042bd472918030aff808f77be
  [negative-tests.json]=7f4bd7def905c492b40fae92b6a51665489539dd773db464022a52eb37907e81
  [extended-tests.json]=547c6d6669132a62ea002791cbefed43251c7fe2ad82f8725d930d401e5acd23
)

ensure_dir() {
  local dir="$1"
  mkdir -p "${dir}" || {
    echo "Unable to create directory: ${dir}" >&2
    exit 1
  }
}

verify_sha256() {
  local file="$1"
  local expected="$2"
  local actual
  actual="$(sha256sum "${file}" | awk '{print $1}')"
  if [[ "${actual}" != "${expected}" ]]; then
    echo "Checksum mismatch for ${file}" >&2
    echo "  expected: ${expected}" >&2
    echo "  actual:   ${actual}" >&2
    exit 1
  fi
}

install_test_files() {
  if [[ ! -d "${COMMITTED_TEST_FILES}" ]]; then
    echo "Missing committed test files at ${COMMITTED_TEST_FILES}" >&2
    exit 1
  fi

  ensure_dir "${TEST_FILES_ROOT}"

  local name
  for name in "${!TEST_FILE_SHA256[@]}"; do
    local src="${COMMITTED_TEST_FILES}/${name}"
    if [[ ! -f "${src}" ]]; then
      echo "Missing committed file: ${src}" >&2
      exit 1
    fi
    verify_sha256 "${src}" "${TEST_FILE_SHA256[$name]}"
    cp -a "${src}" "${TEST_FILES_ROOT}/${name}"
  done
}

install_template_fixtures() {
  if [[ ! -d "${COMMITTED_TEMPLATE_FIXTURES}" ]]; then
    echo "Missing committed URI template fixtures at ${COMMITTED_TEMPLATE_FIXTURES}" >&2
    exit 1
  fi

  ensure_dir "${TEMPLATE_FIXTURES_ROOT}"

  local name
  for name in "${!TEMPLATE_FIXTURE_SHA256[@]}"; do
    local src="${COMMITTED_TEMPLATE_FIXTURES}/${name}"
    if [[ ! -f "${src}" ]]; then
      echo "Missing committed file: ${src}" >&2
      exit 1
    fi
    verify_sha256 "${src}" "${TEMPLATE_FIXTURE_SHA256[$name]}"
    cp -a "${src}" "${TEMPLATE_FIXTURES_ROOT}/${name}"
  done
}

install_test_files
install_template_fixtures

test -s "${TEST_FILES_ROOT}/hello-world.txt"
test -s "${TEST_FILES_ROOT}/red-nose.gif"
test -s "${TEMPLATE_FIXTURES_ROOT}/spec-examples.json"
test -s "${TEMPLATE_FIXTURES_ROOT}/negative-tests.json"
test -s "${TEMPLATE_FIXTURES_ROOT}/extended-tests.json"

echo "Fixtures ready:"
echo "  test_files=${TEST_FILES_ROOT}"
echo "  uritemplate=${TEMPLATE_FIXTURES_ROOT}"
