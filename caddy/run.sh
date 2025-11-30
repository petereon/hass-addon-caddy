#!/usr/bin/env bashio

CONFIG_PATH=$(bashio::config 'config_path')
DEFAULT_CONFIG="/etc/caddy/config.json"

if [ ! -f "$CONFIG_PATH" ]; then
	bashio::log.info "Configuration file not found at: $CONFIG_PATH"
	bashio::log.info "Using default configuration: $DEFAULT_CONFIG"
	CONFIG_PATH=$DEFAULT_CONFIG
else
	bashio::log.info "Using configuration file: $CONFIG_PATH"
fi

bashio::log.info "Starting Caddy..."

# Print version and modules for debugging
caddy version
caddy list-modules

# Run Caddy
# We use exec so Caddy takes over PID 1 (or the script process) and receives signals correctly.
# Caddy auto-detects JSON config format, no need for --adapter flag
exec caddy run --config "$CONFIG_PATH"
