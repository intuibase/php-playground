#!/bin/bash

source /agent/environment

if [ ! -f memory_limit_applied ]; then
  echo "memory_limit=1G" >>/usr/local/etc/php/php.ini 
  touch memory_limit_applied
fi

if [ "${INSTALL_OPENTELEMETRY}" = "1" ]; then
  if [ ! -f opentelemetry_installed ]; then
    echo "Installing opentelemetry"
    
    pecl install opentelemetry
    echo "extension=opentelemetry.so" >>/usr/local/etc/php/php.ini

    composer require open-telemetry/opentelemetry open-telemetry/opentelemetry-auto-pdo 
    touch opentelemetry_installed
  fi
  export OTEL_PHP_AUTOLOAD_ENABLED=true
fi

if [ ! -f agent_apache_installed ]; then
  if [[ -n "${INSTALL_OPENTELEMETRY_APACHE}" ]]; then
    tar -xvf "${INSTALL_OPENTELEMETRY_APACHE}" -C /opt
    cd /opt/opentelemetry-webserver-sdk
    ./install.sh
    cd -
    cp /agent/configs/opentelemetry_module.conf /etc/apache2/conf-enabled/
    touch agent_apache_installed
  fi
fi

if [ ! -f agent_installed ]; then
  if [[ -n "${AGENT_TO_INSTALL}" ]]; then
      echo "Installing agent from: ${AGENT_TO_INSTALL}"

      if [[ -f "${AGENT_TO_INSTALL}" ]]; then
        dpkg -i "${AGENT_TO_INSTALL}" || apt-get install -f -y "${AGENT_TO_INSTALL}" 
        cat /agent/configs/php.ini >>/usr/local/etc/php/php.ini

        touch agent_installed
      else
        echo "Can't find agent deb package file"
        exit 1
      fi
  fi

else
  echo "Agent installed"
fi

if [ ! -f drupal_installed ]; then
  apt update && apt install -y default-mysql-client

  echo "Waiting for database..."
  sleep 10
  until mysql -h db -u drupal -pdrupal -e "SELECT 1"; do
    sleep 2
  done


  echo "Installing drupal drush..."
  composer require drush/drush

  echo "Installing drupal umami app..."
  drush site-install demo_umami --db-url=mysql://drupal:drupal@db/drupal --account-name=admin --account-pass=admin --site-name="Umami Demo" -y

  echo "Clearing cache cache..."
  drush cache:rebuild

  chown -R www-data:www-data recipes vendor web

  touch drupal_installed

else
    echo "Drupal is already installed. Exiting..."
fi




echo "Drupal is ready on http://localhost:8080"

apache2-foreground

