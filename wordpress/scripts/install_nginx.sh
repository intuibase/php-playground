#!/bin/bash

source /agent/environment


if [ ! -f /.agent_nginx_installed ]; then

  if [[ -n "${INSTALL_OPENTELEMETRY_NGINX}" ]]; then
    	echo "Installing NGINX OpenTelemetry"

    tar -xvf "${INSTALL_OPENTELEMETRY_NGINX}" -C /opt
    cd /opt/opentelemetry-webserver-sdk
    ./install.sh
    cd -


    CURRENT_CONFIG=$(cat /etc/nginx/nginx.conf)

	echo "load_module /opt/opentelemetry-webserver-sdk/WebServerModule/Nginx/${INSTALL_OPENTELEMETRY_NGINX_VERSION}/ngx_http_opentelemetry_module.so;" > /etc/nginx/nginx.conf
	echo "${CURRENT_CONFIG}" >>/etc/nginx/nginx.conf

#	echo "load_module /opt/opentelemetry-webserver-sdk/WebServerModule/Nginx/${INSTALL_OPENTELEMETRY_NGINX_VERSION}/ngx_http_opentelemetry_module.so;\n$(cat /etc/nginx/nginx.conf)" > /etc/nginx/nginx.conf

    envsubst </agent/configs/opentelemetry_module.conf >/etc/nginx/conf.d/opentelemetry_module.conf

    touch /.agent_nginx_installed

  fi
fi

if [ -f /.agent_nginx_installed ]; then
	echo "NGINX OpenTelemetry module installed"

	export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/opt/opentelemetry-webserver-sdk/sdk_lib/lib"
fi

nginx -g "daemon off;"

