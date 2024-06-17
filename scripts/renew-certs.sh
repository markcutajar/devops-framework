#!/bin/bash

# AWK LOGIC HERE: https://www.baeldung.com/linux/join-multiple-lines
# In the awk section. However changed to NR==0 as we want d also at the start
SERVICES=$(find services -type f -name "*docker-compose.yml" | awk -v d=" -f " '{s=(NR==0?s:s d)$0}END{print s}')
DEFAULTS="-f docker-compose.yml -f setup/certs.docker-compose.yml "

compose_files="$DEFAULTS$SERVICES"

docker compose ${compose_files} run --rm --entrypoint "\
    certbot renew --force-renewal" certbot
echo

echo "### Reloading nginx ..."
docker compose ${compose_files} exec nginx nginx -s reload
