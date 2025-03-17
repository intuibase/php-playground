#!/bin/bash

source /agent/environment

if [ "${INSTALL_OPENTELEMETRY}" = "1" ]; then
  if [ ! -f .opentelemetry_installed ]; then
    echo "Installing opentelemetry"
    
    pecl install opentelemetry
    echo "extension=opentelemetry.so" >>/usr/local/etc/php/php.ini

    composer require open-telemetry/opentelemetry open-telemetry/opentelemetry-auto-pdo 
    touch .opentelemetry_installed
  fi
  export OTEL_PHP_AUTOLOAD_ENABLED=true
fi

if [ ! -f .agent_installed ]; then
  if [[ -n "${AGENT_TO_INSTALL}" ]]; then
      echo "Installing agent from: ${AGENT_TO_INSTALL}"

      if [[ -f "${AGENT_TO_INSTALL}" ]]; then
        dpkg -i "${AGENT_TO_INSTALL}" || apt-get install -f -y "${AGENT_TO_INSTALL}" 
        cat /agent/configs/php.ini >>/usr/local/etc/php/php.ini

        touch .agent_installed
      else
        echo "Can't find agent deb package file"
        exit 1
      fi
  fi

else
  echo "Agent installed"
fi

/usr/local/bin/docker-entrypoint.sh php-fpm
