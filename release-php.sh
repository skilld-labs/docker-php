#!/bin/bash

set -euo pipefail

usage() {
  cat <<'EOF'
Resolve and optionally publish versioned PHP image tags.

Usage:
  ./release-php.sh latest <series>
  ./release-php.sh check <series> [image]
  ./release-php.sh publish <series> [image]

Examples:
  ./release-php.sh latest 85
  ./release-php.sh check 84
  ./release-php.sh publish 85

Rules:
  1. Latest stable patch version comes from php/php-src tags.
  2. Installed image PHP version must match that stable tag.
  3. Installed apk package version must match that stable tag.
  4. publish triggers the matching GitHub workflow with -f version=<stable>.
EOF
}

die() {
  echo "Error: $*" >&2
  exit 1
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"
}

normalize_series() {
  case "$1" in
    83|84|85) echo "$1" ;;
    8.3) echo "83" ;;
    8.4) echo "84" ;;
    8.5) echo "85" ;;
    *) die "Unsupported series '$1' (expected 83, 84, 85, 8.3, 8.4, or 8.5)" ;;
  esac
}

series_to_minor() {
  printf '%s.%s\n' "${1%?}" "${1#?}"
}

default_image() {
  printf 'skilldlabs/php:%s\n' "$1"
}

workflow_name() {
  printf 'Build PHP %s\n' "$(series_to_minor "$1")"
}

latest_stable_tag() {
  local series="$1"
  local minor regex

  minor="$(series_to_minor "$series")"
  regex="^php-${minor//./\\.}\\.[0-9]+$"

  curl -fsSL 'https://api.github.com/repos/php/php-src/tags?per_page=100' \
    | jq -r '.[].name' \
    | rg "$regex" \
    | sed 's/^php-//' \
    | sort -V \
    | tail -n 1
}

installed_php_version() {
  local image="$1"

  docker run --rm "$image" php -r 'echo PHP_VERSION, PHP_EOL;'
}

installed_apk_version() {
  local series="$1"
  local image="$2"

  docker run --rm "$image" sh -lc "grep -A1 '^P:php${series}$' /lib/apk/db/installed | sed -n '2s/^V://p'"
}

check_versions() {
  local series="$1"
  local image="$2"
  local stable phpv apkv apkv_base

  stable="$(latest_stable_tag "$series")"
  [ -n "$stable" ] || die "Unable to resolve latest stable php-src tag for $series"

  phpv="$(installed_php_version "$image")"
  [ -n "$phpv" ] || die "Unable to read installed PHP version from $image"

  apkv="$(installed_apk_version "$series" "$image")"
  [ -n "$apkv" ] || die "Unable to read installed apk version for php$series from $image"
  apkv_base="${apkv%-r*}"

  echo "Series: $(series_to_minor "$series")"
  echo "Image: $image"
  echo "php-src tag: $stable"
  echo "Installed PHP: $phpv"
  echo "Installed apk: $apkv"

  [ "$phpv" = "$apkv_base" ] || die "Installed PHP ($phpv) does not match apk package version ($apkv)"
  [ "$phpv" = "$stable" ] || die "Installed PHP ($phpv) does not match latest stable php-src tag ($stable)"

  printf '%s\n' "$stable"
}

publish() {
  local series="$1"
  local image="$2"
  local stable workflow

  stable="$(check_versions "$series" "$image" | tail -n 1)"
  workflow="$(workflow_name "$series")"

  echo "Triggering workflow: $workflow"
  gh workflow run "$workflow" -f version="$stable"
}

main() {
  local action series image

  action="${1:-}"
  [ -n "$action" ] || {
    usage
    exit 1
  }

  case "$action" in
    -h|--help|help)
      usage
      exit 0
      ;;
  esac

  shift
  series="$(normalize_series "${1:-}")"
  image="${2:-$(default_image "$series")}"

  need_cmd curl
  need_cmd jq
  need_cmd rg
  need_cmd sort
  need_cmd sed
  need_cmd docker

  case "$action" in
    latest)
      latest_stable_tag "$series"
      ;;
    check)
      check_versions "$series" "$image"
      ;;
    publish)
      need_cmd gh
      publish "$series" "$image"
      ;;
    *)
      usage
      exit 1
      ;;
  esac
}

main "$@"
