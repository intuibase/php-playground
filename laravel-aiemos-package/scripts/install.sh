#!/bin/bash

env


if [ ! -f .agent_installed ]; then
  if [[ -n "${AGENT_TO_INSTALL}" ]]; then
      echo "Installing agent from: ${AGENT_TO_INSTALL}"

      if [[ -f "${AGENT_TO_INSTALL}" ]]; then
        dpkg -i "${AGENT_TO_INSTALL}" || apt-get install -f -y "${AGENT_TO_INSTALL}" 

        touch .agent_installed
      else
        echo "Can't find agent deb package file"
        exit 1
      fi
  fi

else
  echo "Agent installed"
fi


if [ ! -f .installed ]; then

   # pecl install protobuf
   # echo "extension=protobuf.so" >>/usr/local/etc/php/php.ini
   # php -m

    pwd
    echo "Aimeos not installed. Installing"

    sleep 10 # mysql init & restart

    while ! mysqladmin ping -h mysql --ssl=0 --silent; do
        echo "Waiting 2s for mysql startup..."
        sleep 2
    done

    composer create-project aimeos/aimeos myshop

    cd myshop

    if [ "${INSTALL_OPENTELEMETRY}" = "1" ]; then
      if [ ! -f .opentelemetry_installed ]; then
        echo "Installing opentelemetry"
        
        pecl install opentelemetry
        echo "extension=opentelemetry.so" >>/usr/local/etc/php/conf.d/docker-php-ext-opentelemetry.ini

        composer require open-telemetry/opentelemetry open-telemetry/opentelemetry-auto-pdo open-telemetry/opentelemetry-auto-laravel open-telemetry/opentelemetry-auto-symfony open-telemetry/opentelemetry-auto-guzzle open-telemetry/opentelemetry-auto-curl
        touch .opentelemetry_installed
      fi
      export OTEL_PHP_AUTOLOAD_ENABLED=true
    fi


    cp .env.example .env
    sed -i "s|DB_HOST=.*|DB_HOST=mysql|" .env
    sed -i "s|DB_DATABASE=.*|DB_DATABASE=$MYSQL_DATABASE|" .env
    sed -i "s|DB_USERNAME=.*|DB_USERNAME=root|" .env
    sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=$MYSQL_ROOT_PASSWORD|" .env

    php artisan key:generate
    php artisan aimeos:setup --option=setup/default/demo:1

    cd -

    chmod -R 755 /var/www/html/ && chown -R www-data:www-data /var/www/html/

    touch .installed
fi

apache2-foreground
