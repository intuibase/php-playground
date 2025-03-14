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

if [ ! -f .agent_apache_installed ]; then
  if [[ -n "${INSTALL_OPENTELEMETRY_APACHE}" ]]; then
    tar -xvf "${INSTALL_OPENTELEMETRY_APACHE}" -C /opt
    cd /opt/opentelemetry-webserver-sdk
    ./install.sh
    cd -
    cp /agent/configs/opentelemetry_module.conf /etc/apache2/conf-enabled/
    touch .agent_apache_installed
  fi
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


if [ ! -f .installed ]; then
    pwd
    echo "Aimeos not installed. Installing"

    sleep 10 # mysql init & restart

    while ! mysqladmin ping -h mysql --silent; do
        echo "Waiting 2s for mysql startup..."
        sleep 2
    done

    composer create-project aimeos/aimeos myshop

    cd myshop

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
