#!/bin/sh
set -e
set -o pipefail
set -x

apk update
apk add gettext


# Waiting for wordpress's database
resp_code="000"
while [ -n "$(mysql --host="mysql" --password="${WORDPRESS_DB_PASSWORD}" --execute="")" ] \
	|| [ $resp_code -lt "200" ] || [ $resp_code -ge "400" ]; do

	echo >&2 "Waiting for db and webserver..."
	sleep 2
	resp_code="$(curl --write-out %{http_code} --silent --output /dev/null ${WP_URL})"
done


# Install wordpress
wp core install \
	--url=${WP_URL} \
	--title=${WP_TITLE} \
	--admin_user=${WP_USERNAME} \
	--admin_password=${WP_PASSWORD} \
	--admin_email=${WP_EMAIL} \
	--skip-email --allow-root

# Install and activate woocommerce
wp plugin install woocommerce --version=${WOOCOMMERCE_VER:-7.5.1} --allow-root
wp plugin activate woocommerce --allow-root

# Install and activate theme
wp theme install storefront --version=${STOREFRONT_VER:-4.2.0} --allow-root
wp theme activate storefront --allow-root

# Install importer
wp plugin install wordpress-importer --allow-root
wp plugin activate wordpress-importer --allow-root

wp site empty --yes --allow-root

# Copy data

mkdir -p /var/www/html/wp-content/uploads/2018/04/
mkdir -p /var/www/html/wp-content/plugins/
cp -r /opt/wordpress/images/. /var/www/html/wp-content/uploads/2018/04/
cp -r /opt/wordpress/cron_job/. /var/www/html/wp-content/plugins/

# Substitute env variables in templates and import data
envsubst < "/opt/wordpress/import_templates/media_template.xml" > "/opt/media.xml"
envsubst < "/opt/wordpress/import_templates/products_template.xml" > "/opt/products.xml"
envsubst < "/opt/wordpress/import_templates/pages_template.xml" > "/opt/pages.xml"
wp import /opt/media.xml --authors=create --allow-root
wp import /opt/products.xml --authors=create --allow-root
wp import /opt/pages.xml --authors=create --allow-root

# Set homepage
wp option update show_on_front page --allow-root
wp option update page_on_front $(wp post list --pagename=welcome --field=ID --allow-root) --allow-root

# Add cron job
wp plugin activate arewethereyet --allow-root
wp cron event schedule arewethereyet_hook now hourly --allow-root
