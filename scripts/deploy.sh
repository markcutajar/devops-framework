#!/bin/bash

# Export the versions to pull the correct image
. ./scripts/export-versions.sh

# AWK LOGIC HERE: https://www.baeldung.com/linux/join-multiple-lines
# In the awk section. However changed to NR==0 as we want d also at the start
SERVICES=$(find services -type f -name "*docker-compose.yml" | awk -v d=" -f " '{s=(NR==0?s:s d)$0}END{print s}')  

docker compose -f docker-compose.yml ${SERVICES} pull
docker compose -f docker-compose.yml ${SERVICES} up -d --remove-orphans --build
docker compose exec api python manage.py migrate
docker compose exec chat alembic upgrade head
docker image prune -a -f
