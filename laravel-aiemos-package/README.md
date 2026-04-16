# Laravel Aimeos + OpenTelemetry Agent

Docker environment for testing an [Aimeos](https://aimeos.org/) shop on Laravel with PHP 8.2 and OpenTelemetry instrumentation.

## Requirements

- Docker + Docker Compose

## Quick Start

1. Copy the agent package (`.deb`) into the `shared/` directory:

   ```bash
   cp opentelemetry-php-distro_0.1.0_amd64.deb shared/
   ```

2. Adjust the `.env` file (see variable descriptions below).

3. Start the environment:

   ```bash
   docker compose up --build
   ```

4. The Aimeos shop will be available at: **http://localhost:8082**

> On the first run the `install.sh` script automatically: installs the agent from `shared/`, creates the Aimeos project via Composer, configures the database, installs the OpenTelemetry PHP extension (if enabled), and starts Apache.

## Environment Variables (`.env`)

| Variable | Default | Description |
|---|---|---|
| `OTEL_LOG_LEVEL` | `debug` | OpenTelemetry SDK log level. Possible values: `none`, `error`, `warn`, `info`, `debug`. |
| `OTEL_PHP_LOG_LEVEL_STDERR` | `debug` | OpenTelemetry PHP extension log level written to stderr. |
| `OTEL_RESOURCE_ATTRIBUTES` | `service.name=LaravelAiemos,...` | OTEL resource attributes (service name, version, environment). |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | `http://192.168.192.37:4318/` | OTLP collector endpoint (e.g. SigNoz, Jaeger). Change to your collector address. |
| `INSTALL_OPENTELEMETRY` | `1` | Whether to install the OpenTelemetry PHP extension and Composer packages. `1` = yes, `0` = no. |
| `AGENT_TO_INSTALL` | `/shared/opentelemetry-php-distro_0.1.0_amd64.deb` | Path (inside the container) to the agent `.deb` package to install. The `shared/` directory is mounted as `/shared` in the container. |
| `OTEL_PHP_AUTOLOAD_ENABLED` | `true` | Enable automatic loading of PHP OpenTelemetry instrumentation. For package-style instrumentation only. |

