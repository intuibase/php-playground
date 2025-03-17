# Description:

This docker compose script starts nginx, php-fpm w/ wordpress, mysql and wordpress:cli that actually sets up everything
(plugins, themes, cron job and sample data) .\
Default port is 8080, but it can be modified as well as other variables (*check docker-compose.yml* for details)

# Dependencies

- docker-compose 1.19.0+
- docker 1.12.0+

# Usage
```bash
export WP_URL=http://123.45.67.89
docker-compose up
```


## Prepare configuration from template files

Copy `agent/configs/php.ini.template` to `agent/configs/php.ini` and follow instructions below.
Copy `agent/environment.template` to `agent/environment` and follow instructions below.


## Preparing the Environment in the `agent` Directory

The `agent/environment` file contains configuration settings for the environment you want to install. Some options are mutually exclusive, such as installing OpenTelemetry and Elastic Distribution for OpenTelemetry PHP—these options should be enabled with caution.

## Enabling Packages for Installation Using Environment Variables


### Installing EDOT PHP

To install the Elastic Distribution for OpenTelemetry PHP (EDOT PHP), set:

```bash
export AGENT_TO_INSTALL=/agent/installers/elastic-otel-php_0.3.4_amd64.deb
```

This will install the EDOT PHP package. Further configuration, such as the endpoint and authorization headers, must be set using environment variables in this file. You can also control other agent features here:

```bash
export OTEL_EXPORTER_OTLP_HEADERS="authorization=Bearer *****"
export OTEL_EXPORTER_OTLP_ENDPOINT="https://******/"
export OTEL_RESOURCE_ATTRIBUTES=service.name=Wordpress,service.version=1.0,deployment.environment=dev
```

Additional configuration, can be done also in the agent/configs/php.ini file. Its contents will be appended to the original php.ini file in the container.

### Installing Elastic APM Agent for PHP

To install the Elastic APM agent for PHP, set:

```bash
export AGENT_TO_INSTALL=/agent/installers/apm-agent-php_1.15.0_amd64.deb
```

This will install the Elastic APM PHP package. Additional configuration, such as the endpoint, should be done in the `agent/configs/php.ini` file. Its contents will be appended to the original `php.ini` file in the container.


### Installing OpenTelemetry

Setting the following environment variable:

```bash
export INSTALL_OPENTELEMETRY=1
```

This will install the OpenTelemetry auto-instrumentation extension, including auto-instrumentation for PDO and CURL, and enable autoloading for the SDK.
Installing EDOT PHP

### Installing the OpenTelemetry Web Server Apache Module

```bash
export INSTALL_OPENTELEMETRY_APACHE=/agent/installers/opentelemetry-webserver-sdk-x64-linux.tgz
```

This will install the package and copy the configuration file from `agent/configs/opentelemetry_module.conf`. This configuration file will be applied to the Apache server inside the container.

