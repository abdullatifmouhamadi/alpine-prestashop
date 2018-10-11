#!/bin/sh

[ -f /run-pre.sh ] && /run-pre.sh

if [ ! -d /usr/html ] ; then
  mkdir -p /usr/html
  chown -R nginx:nginx /usr/html
else
  chown -R nginx:nginx /usr/html
fi

mkdir -p ~/.ssh
echo "${SSH_PRIVATE_KEY}" | tr -d '\r' > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
#clone repo with passwordless auth
git clone --depth=1 --branch=master ${REPO} /usr/html
rm -rf /usr/html/.git

chown -R nginx:nginx /usr/html

# start php-fpm
mkdir -p /usr/logs/php-fpm
php-fpm7

# start nginx
mkdir -p /usr/logs/nginx
mkdir -p /tmp/nginx
chown nginx /tmp/nginx
nginx
