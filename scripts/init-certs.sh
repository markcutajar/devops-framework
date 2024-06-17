#!/bin/bash
mapfile -t domains < DOMAINS  # Update domains in file DOMAINS
email=$(<EMAIL)  # Update email in file called EMAIL

# Export the environment veriables for versions
. ./scripts/export-versions.sh

# AWK LOGIC HERE: https://www.baeldung.com/linux/join-multiple-lines
# In the awk section. However changed to NR==0 as we want d also at the start
SERVICES=$(find services -type f -name "*docker-compose.yml" | awk -v d=" -f " '{s=(NR==0?s:s d)$0}END{print s}')
DEFAULTS="-f docker-compose.yml -f setup/certs.docker-compose.yml "

compose_files="$DEFAULTS$SERVICES"
data_path="./certbot"  # Do not update path here setup to use this folder
rsa_key_size=4096
staging=0 # Set to 1 if you're testing your setup to avoid hitting request limits

if [ -d "$data_path" ]; then
  read -p "Existing data found for $domains. Continue and replace existing certificate? (y/N) " decision
  if [ "$decision" != "Y" ] && [ "$decision" != "y" ]; then
    exit
  fi
fi

# Build docker in case it changed
docker compose ${compose_files} build
docker compose ${compose_files} up -d

if [ ! -e "$data_path/conf/options-ssl-nginx.conf" ] || [ ! -e "$data_path/conf/ssl-dhparams.pem" ]; then
  echo "### Downloading recommended TLS parameters ..."
  mkdir -p "$data_path/conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf > "$data_path/conf/options-ssl-nginx.conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > "$data_path/conf/ssl-dhparams.pem"
  echo
fi

echo "### Creating dummy certificate for $domains ..."
path="/etc/letsencrypt/live/$domains"
mkdir -p "$data_path/conf/live/$domains"
docker compose ${compose_files} run --rm --entrypoint "\
  openssl req -x509 -nodes -newkey rsa:$rsa_key_size -days 1\
    -keyout '$path/privkey.pem' \
    -out '$path/fullchain.pem' \
    -subj '/CN=localhost'" certbot
echo


echo "### Starting nginx ..."
docker compose ${compose_files} up --force-recreate -d nginx
echo

echo "### Deleting dummy certificate for $domains ..."
docker compose ${compose_files} run --rm --entrypoint "\
  rm -Rf /etc/letsencrypt/live/$domains && \
  rm -Rf /etc/letsencrypt/archive/$domains && \
  rm -Rf /etc/letsencrypt/renewal/$domains.conf" certbot
echo


echo "### Requesting Let's Encrypt certificate for $domains ..."
# Join $domains to -d args
domain_args=""
for domain in "${domains[@]}"; do
  domain_args="$domain_args -d $domain"
done

# Select appropriate email arg
case "$email" in
  "") email_arg="--register-unsafely-without-email" ;;
  *) email_arg="--email $email" ;;
esac

# Enable staging mode if needed
if [ $staging != "0" ]; then staging_arg="--staging"; fi
if [ $staging == "0" ]; then staging_arg=""; fi

echo "Staging argis: "
echo $staging_arg

docker compose ${compose_files} run --rm --entrypoint "\
  certbot certonly --webroot -w /var/www/certbot \
    $staging_arg \
    $email_arg \
    $domain_args \
    --rsa-key-size $rsa_key_size \
    --agree-tos \
    --force-renewal" certbot
echo

echo "### Reloading nginx ..."
docker compose ${compose_files} exec nginx nginx -s reload
