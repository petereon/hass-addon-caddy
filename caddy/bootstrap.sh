#!/usr/bin/env bashio
set -e

build_arch=$1
xcaddy_version=$2

xcaddy_base_url="https://github.com/caddyserver/xcaddy/releases/download"
repo_owner="petereon"
repo_name="hass-addon-caddy"

# Extract version from config.yaml
if [ -f "/config.yaml" ]; then
	addon_version=$(grep 'version:' /config.yaml | awk '{print $2}' | tr -d '"')
	bashio::log.info "Add-on version: $addon_version"
else
	bashio::log.warning "config.yaml not found, cannot determine add-on version for pre-built binary download."
	addon_version=""
fi

# Try to download pre-built binary
if [ -n "$addon_version" ]; then
	binary_url="https://github.com/${repo_owner}/${repo_name}/releases/download/v${addon_version}/caddy-${build_arch}"
	bashio::log.info "Attempting to download pre-built binary from: $binary_url"

	if curl -L -f -o /usr/bin/caddy "$binary_url"; then
		bashio::log.info "Successfully downloaded pre-built binary."
		chmod +x /usr/bin/caddy
		bashio::log.info "Caddy version: $(caddy version)"
		bashio::log.info "Caddy modules: $(caddy list-modules)"

		# Cleanup build tools since we didn't need them
		apk del go git
		rm -rf /root/go /root/.cache
		exit 0
	else
		bashio::log.info "Pre-built binary not found or download failed. Falling back to source build."
	fi
fi

function select_arch() {
	case $build_arch in
	"aarch64") echo "arm64" ;;
	"amd64") echo "amd64" ;;
	"armhf") echo "armv6" ;;
	"armv7") echo "armv7" ;;
	"i386") echo "386" ;; # Assuming 386 support exists
	*)
		bashio::log.error "Unsupported architecture: $build_arch"
		exit 1
		;;
	esac
}

arch=$(select_arch)
bashio::log.info "Detected architecture: $arch"

# Install xcaddy
bashio::log.info "Installing xcaddy v$xcaddy_version..."
curl -L "${xcaddy_base_url}/v${xcaddy_version}/xcaddy_${xcaddy_version}_linux_${arch}.tar.gz" -o xcaddy.tar.gz
tar xvf xcaddy.tar.gz xcaddy
mv xcaddy /usr/bin/xcaddy
rm xcaddy.tar.gz

# Verify Go version
bashio::log.info "Go version: $(go version)"

# Build Caddy with Layer 4
bashio::log.info "Building Caddy with Layer 4 module..."
# xcaddy requires git to be configured sometimes, or just works.
xcaddy build --with github.com/mholt/caddy-l4

# Install Caddy
mv caddy /usr/bin/caddy
bashio::log.info "Caddy version: $(caddy version)"
bashio::log.info "Caddy modules: $(caddy list-modules)"

# Cleanup to reduce image size
apk del go git
rm -rf /root/go
rm -rf /root/.cache
