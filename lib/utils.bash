#!/usr/bin/env bash

set -euo pipefail

GH_REPO="https://github.com/floci-io/floci-cli"
TOOL_NAME="floci"
TOOL_TEST="floci version"

fail() {
	echo -e "asdf-$TOOL_NAME: $*" >&2
	exit 1
}

curl_opts=(-fsSL)

if [ -n "${GITHUB_API_TOKEN:-}" ]; then
	curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

sort_versions() {
	sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
		LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_github_tags() {
	git ls-remote --tags --refs "$GH_REPO" |
		grep -o 'refs/tags/.*' | cut -d/ -f3- |
		sed 's/^v//'
}

list_all_versions() {
	# floci-cli tags its releases as plain semver (no leading "v"), one GitHub
	# Release per tag. The very first tag (0.1.0) predates binary publishing and
	# has no release assets; asdf will surface a clear download failure if a
	# user tries to install it rather than silently listing it as broken here.
	list_github_tags
}

# Map `uname -s` to the platform slug used in floci-cli release asset names.
get_platform() {
	local kernel
	kernel="$(uname -s)"
	case "$kernel" in
	Darwin) echo "darwin" ;;
	Linux) echo "linux" ;;
	*)
		fail "Unsupported platform '$kernel'. floci-cli publishes native binaries for macOS and Linux only (asdf itself does not run on native Windows; use WSL to install this plugin there)."
		;;
	esac
}

# Map `uname -m` to the arch slug used in floci-cli release asset names.
get_arch() {
	local machine
	machine="$(uname -m)"
	case "$machine" in
	x86_64 | amd64) echo "amd64" ;;
	arm64 | aarch64) echo "arm64" ;;
	*)
		fail "Unsupported architecture '$machine'."
		;;
	esac
}

# The asset name for a given version on the current platform/arch, e.g.
# "floci-darwin-arm64". This is also the binary's own filename once installed.
asset_name() {
	echo "$TOOL_NAME-$(get_platform)-$(get_arch)"
}

sha256_of() {
	local file="$1"
	if command -v sha256sum >/dev/null 2>&1; then
		sha256sum "$file" | awk '{print $1}'
	elif command -v shasum >/dev/null 2>&1; then
		shasum -a 256 "$file" | awk '{print $1}'
	else
		fail "Neither sha256sum nor shasum is available to verify the download."
	fi
}

# floci-cli's sha256sums.txt lines look like:
#   <sha256>  ./floci-darwin-arm64/floci-darwin-arm64
# Match by basename so the checksum lookup doesn't depend on the leading path.
verify_checksum() {
	local file="$1" sums_file="$2" asset="$3"
	local expected actual

	expected="$(awk -v f="$asset" '{n=split($2,parts,"/"); if (parts[n]==f) print $1}' "$sums_file" | head -n1)"
	[ -n "$expected" ] || fail "No checksum entry for '$asset' found in sha256sums.txt"

	actual="$(sha256_of "$file")"
	[ "$expected" = "$actual" ] || fail "Checksum mismatch for $asset (expected $expected, got $actual)"
}

# Downloads the platform-appropriate binary and its checksum, verifies it,
# and leaves a single verified, executable file at "$download_path/$TOOL_NAME".
# Nothing is left in $download_path on any failure path.
download_release() {
	local version download_path asset url sums_url binary_file sums_file
	version="$1"
	download_path="$2"

	asset="$(asset_name "$version")"
	url="$GH_REPO/releases/download/$version/$asset"
	sums_url="$GH_REPO/releases/download/$version/sha256sums.txt"

	binary_file="$download_path/$asset"
	sums_file="$download_path/sha256sums.txt"

	echo "* Downloading $TOOL_NAME $version ($asset)..."
	curl "${curl_opts[@]}" -o "$binary_file" "$url" ||
		fail "Could not download $url -- does release $version publish a '$asset' asset?"

	echo "* Downloading sha256sums.txt..."
	curl "${curl_opts[@]}" -o "$sums_file" "$sums_url" ||
		fail "Could not download $sums_url"

	echo "* Verifying checksum..."
	verify_checksum "$binary_file" "$sums_file" "$asset"

	mv "$binary_file" "$download_path/$TOOL_NAME"
	rm -f "$sums_file"
	chmod +x "$download_path/$TOOL_NAME"
}

install_version() {
	local install_type version install_path bin_path
	install_type="$1"
	version="$2"
	install_path="$3"

	if [ "$install_type" != "version" ]; then
		fail "asdf-$TOOL_NAME supports release installs only"
	fi

	(
		bin_path="$install_path/bin"
		mkdir -p "$bin_path"
		cp "$ASDF_DOWNLOAD_PATH/$TOOL_NAME" "$bin_path/$TOOL_NAME"
		chmod +x "$bin_path/$TOOL_NAME"

		test -x "$bin_path/$TOOL_NAME" || fail "Expected $bin_path/$TOOL_NAME to be executable."

		local test_argv
		read -r -a test_argv <<<"$TOOL_TEST"
		test_argv[0]="$bin_path/$TOOL_NAME"
		"${test_argv[@]}" >/dev/null 2>&1 ||
			fail "'$TOOL_TEST' did not run successfully after install."

		echo "$TOOL_NAME $version installation was successful!"
	) || (
		rm -rf "$install_path"
		fail "An error occurred while installing $TOOL_NAME $version."
	)
}
