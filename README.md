# Home Assistant Add-on: Caddy (xcaddy with Layer 4)

This add-on runs a custom build of [Caddy](https://caddyserver.com/) compiled with [xcaddy](https://github.com/caddyserver/xcaddy) to include the [Layer 4 module](https://github.com/mholt/caddy-l4).

This allows Caddy to handle not just HTTP/HTTPS traffic (like Home Assistant), but also raw TCP/UDP connections for protocols like MQTT, SSH, etc.

## Features

- **Reverse Proxy**: Proxy HTTP/HTTPS traffic to Home Assistant or other services.
- **Layer 4 Support**: Proxy raw TCP streams, enabling TLS termination for MQTT and other services.
- **JSON Configuration**: Full control over Caddy via a JSON configuration file.

## Configuration

The add-on is configured via the `Configuration` tab in Home Assistant.

### Options

| Option | Type | Default | Description |
|---|---|---|---|
| `config_path` | string | `/share/caddy.json` | The absolute path to your Caddy JSON configuration file. |

If the file specified in `config_path` does not exist, the add-on will use a default internal configuration.

## Default Configuration

The default configuration (used if no custom config is found) sets up:

- **Home Assistant**: Listens on port `443` (HTTPS) and proxies to `homeassistant:8123`.
- **MQTT**: Listens on port `8883` (MQTTS), terminates TLS, and proxies to `mosquitto:1883`.

**Note**: The default configuration uses `example.com` as the hostname. You **must** provide your own configuration to use your actual domain and generate valid certificates.

## Custom Configuration

To use your own configuration:

1.  Create a file named `caddy.json` in your Home Assistant `/share` directory (or any other location accessible to add-ons).
2.  Update the `config_path` option in the add-on configuration to point to this file (e.g., `/share/caddy.json`).
3.  Restart the add-on.

### Example `caddy.json`

Here is an example configuration that proxies Home Assistant on port 443 and MQTT on port 8883 with TLS termination:

```json
{
  "admin": {
    "disabled": true
  },
  "apps": {
    "http": {
      "servers": {
        "srv0": {
          "listen": [
            ":443"
          ],
          "routes": [
            {
              "match": [
                {
                  "host": [
                    "your-domain.com"
                  ]
                }
              ],
              "handle": [
                {
                  "handler": "reverse_proxy",
                  "upstreams": [
                    {
                      "dial": "homeassistant:8123"
                    }
                  ]
                }
              ]
            }
          ]
        }
      }
    },
    "layer4": {
      "servers": {
        "mqtt": {
          "listen": [
            ":8883"
          ],
          "routes": [
            {
              "match": [
                {
                  "tls": {
                    "sni": [
                      "mqtt.your-domain.com"
                    ]
                  }
                }
              ],
              "handle": [
                {
                  "handler": "tls"
                },
                {
                  "handler": "proxy",
                  "upstreams": [
                    {
                      "dial": "core-mosquitto:1883"
                    }
                  ]
                }
              ]
            }
          ]
        }
      }
    }
  }
}
```

> [!CAUTION]
> Misconfigured Caddy can expose your Home Assistant instance or other services to the internet without protection. Ensure you understand Caddy's configuration and security implications.
