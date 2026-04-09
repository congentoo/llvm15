#!/bin/bash
# regen-md5-cache.sh — refresh metadata/md5-cache/ in a Gentoo overlay
#
# Regenerates the tracked metadata/md5-cache tree via egencache using a
# user-writable relocated dep cache, so it works without being in the
# portage group and without touching /var/cache/edb/dep.
#
# Usage: regen-md5-cache.sh [OVERLAY_DIR]
#
# If OVERLAY_DIR is omitted, uses the current working directory. Must be
# an overlay root (contains metadata/layout.conf). Auto-detects repo name
# from profiles/repo_name, and the main gentoo tree location from portage.
#
# Source of truth: etc-portage/scripts/regen-md5-cache.sh.
# Copies live per-overlay at .ci/regen-md5-cache.sh (kept in sync).

set -euo pipefail

overlay_dir="${1:-$PWD}"
overlay_dir="$(cd "$overlay_dir" && pwd)"
[[ $# -gt 0 ]] && shift

if [[ ! -f "$overlay_dir/metadata/layout.conf" ]]; then
	echo "error: $overlay_dir is not an overlay root (no metadata/layout.conf)" >&2
	exit 1
fi

if [[ ! -f "$overlay_dir/profiles/repo_name" ]]; then
	echo "error: $overlay_dir has no profiles/repo_name" >&2
	exit 1
fi

repo_name="$(cat "$overlay_dir/profiles/repo_name")"

# Discover the main gentoo tree location from installed portage config.
# Fallback to /var/db/repos/gentoo which is the Gentoo default.
gentoo_location="$(portageq get_repo_path / gentoo 2>/dev/null || echo /var/db/repos/gentoo)"

if [[ ! -d "$gentoo_location" ]]; then
	echo "error: gentoo tree not found at $gentoo_location" >&2
	exit 1
fi

# User-writable dep cache relocated out of /var/cache/edb/dep.
depcache_dir="${PORTAGE_DEPCACHEDIR:-${XDG_CACHE_HOME:-$HOME/.cache}/egencache-depcache}"
mkdir -p "$depcache_dir"

repos_conf="$(mktemp --suffix=.repos.conf)"
trap 'rm -f "$repos_conf"' EXIT

cat > "$repos_conf" <<EOF
[DEFAULT]
main-repo = gentoo

[gentoo]
location = $gentoo_location
auto-sync = no

[$repo_name]
location = $overlay_dir
masters = gentoo
auto-sync = no
EOF

echo "regen-md5-cache: repo=$repo_name dir=$overlay_dir gentoo=$gentoo_location" >&2

egencache \
	--repositories-configuration="$(cat "$repos_conf")" \
	--repo="$repo_name" \
	--update \
	--cache-dir="$depcache_dir" \
	--jobs="${JOBS:-4}" \
	"$@"
