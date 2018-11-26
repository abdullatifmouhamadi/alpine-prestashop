#!/bin/sh

[ -f /run-pre.sh ] && /run-pre.sh

if [ -d /usr/html ]; then
  echo "[i] /usr/html directory already contains files, making nginx the owner..."
  chown -R nginx:nginx /usr/html
else
  echo "[i] /usr/html directory not found, creating..."
  mkdir -p /usr/html
  chown -R nginx:nginx /usr/html
fi

if [ "$PS_INSTALL_AUTO" = "1" ]; then
  wget "https://github.com/PrestaShop/PrestaShop/releases/download/1.7.4.4/prestashop_1.7.4.4.zip" -O /tmp/prestashop.zip
  unzip -n -q /tmp/prestashop.zip -d /tmp/prestashop/
  rm -rf /tmp/prestashop.zip
  unzip -n -q /tmp/prestashop/prestashop.zip -d /usr/html/
  rm -rf /tmp/prestashop/prestashop.zip
  chown -R nginx:nginx /usr/html/

  if [ $PS_FOLDER_INSTALL != "install" ]; then
		echo "\n* Renaming install folder to $PS_FOLDER_INSTALL ...";
		mv /usr/html/install /usr/html/$PS_FOLDER_INSTALL/
	fi

	if [ $PS_FOLDER_ADMIN != "admin" ]; then
		echo "\n* Renaming admin folder to $PS_FOLDER_ADMIN ...";
		mv /usr/html/admin /usr/html/$PS_FOLDER_ADMIN/
	fi
else
  echo "\n* Pretashop already installed...";
fi

if [ "$PS_INSTALL_GIT" = "1" ]; then
  mkdir -p ~/.ssh
  echo "${SSH_PRIVATE_KEY}" | tr -d '\r' > ~/.ssh/id_rsa
  chmod 600 ~/.ssh/id_rsa
  #clone repo with passwordless auth
  git clone --depth=1 --branch=master ${REPO} /usr/html
  rm -rf /usr/html/.git
else
  echo "\n* Pretashop already installed...";
fi

sed -i "s|admin/|${PS_FOLDER_ADMIN}/|g" /etc/nginx/nginx.conf

chown -R nginx:nginx /usr/html

echo "[i] Starting Prestashop..."

# start php-fpm
mkdir -p /usr/logs/php-fpm
php-fpm7

# start nginx
mkdir -p /usr/logs/nginx
mkdir -p /tmp/nginx
chown nginx /tmp/nginx
nginx
