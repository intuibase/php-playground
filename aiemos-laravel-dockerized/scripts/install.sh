#!/bin/bash


if [ ! -f .installed ]; then
    pwd
    echo "Aiemos not installed. Installing"

#    dpkg -i /shared/elastic-otel-php_0.1.0_amd64.deb

    while ! mysqladmin ping -h mysql --silent; do
        echo "Waiting 1s for mysql startup..."
        sleep 1
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
