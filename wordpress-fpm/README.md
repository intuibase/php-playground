# Description:

This docker compose script starts nginx, php-fpm with WordPress, MySQL, and WordPress CLI, which automatically configures everything (plugins, themes, cron jobs, and sample data).\
Default port is 8080, but it can be modified along with other variables (*see docker-compose.yml* for details).

# Dependencies

- docker-compose 1.19.0+
# Description

This project starts the following services with Docker Compose:

- `nginx`
- `php-fpm` with WordPress
- `mysql`
- `wpcli` (automatic WordPress setup: plugins, themes, cron jobs, and sample data)

The default application port is `8080`. You can change it, along with other variables, in `docker-compose.yml`.

# Requirements

- Docker `1.12.0+`
- Docker Compose `1.19.0+`

# OpenTelemetry Configuration

1. Copy the OpenTelemetry PHP Distro installation package (or EDOT PHP package in `.deb` format) to the `shared/` directory.
2. Export OpenTelemetry variables from your host to the `.env` file:

```bash
env | grep '^OTEL_' > .env
```

3. If needed, add extra variables to `.env`, for example:

```env
OTEL_PHP_INFERRED_SPANS_ENABLED=true
OTEL_PHP_TRANSACTION_URL_GROUPS=/index.php/product/*,/index.php/cart/*,/index.php/checkout/*
```

# Run

Set the host address where WordPress will be available:

```bash
export WP_URL="http://$(ip route get 1.1.1.1 | awk '/src/ {print $7; exit}')"
```

Then start the stack:

```bash
docker compose up
```
