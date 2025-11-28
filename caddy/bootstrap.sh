#!/usr/bin/env bashio
build_arch=$1
xcaddy_version=$2

xcaddy_base_url="https://github.com/caddyserver/xcaddy/releases/download"

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
wget "${xcaddy_base_url}/v${xcaddy_version}/xcaddy_${xcaddy_version}_linux_${arch}.tar.gz" -O xcaddy.tar.gz
tar xvf xcaddy.tar.gz xcaddy
mv xcaddy /usr/bin/xcaddy
rm xcaddy.tar.gz

# Build Caddy with Layer 4
bashio::log.info "Building Caddy with Layer 4 module..."
# xcaddy requires git to be configured sometimes, or just works.
xcaddy build --with github.com/mholt/caddy-l4

# Install Caddy
mv caddy /usr/bin/caddy
bashio::log.info "Caddy version: $(caddy version)"
bashio::log.info "Caddy modules: $(caddy list-modules)"

# Cleanup to reduce image size
# apk del go git curl tar # Keep curl/tar if needed for runtime? No, usually not.
# But wait, run.sh might need bashio which depends on some tools?
# bashio is usually built-in or a script.
# Let's keep it safe and only remove build tools.
apk del go git
rm -rf /root/go
rm -rf /root/.cache
