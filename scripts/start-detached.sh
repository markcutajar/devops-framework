# AWK LOGIC HERE: https://www.baeldung.com/linux/join-multiple-lines
# In the awk section. However changed to NR==0 as we want d also at the start
SERVICES=$(find services -type f -name "*docker-compose.yml" | awk -v d=" -f " '{s=(NR==0?s:s d)$0}END{print s}')  

# AWK LOGIC HERE: https://www.baeldung.com/linux/join-multiple-lines
# In the awk section. However changed to NR==0 as we want d also at the start
COMMON=$(find common -type f -name "*docker-compose.yml" | awk -v d=" -f " '{s=(NR==0?s:s d)$0}END{print s}')  

docker compose ${COMMON} ${SERVICES} up -d --build
