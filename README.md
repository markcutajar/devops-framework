# Devops Boiler

Template repository with server devops functionality

Things the devops project should solve:
* Creating NGINX web server
* Creating and renewing certs
* Having instructions to send logs to logtail or other services
* Creating a common network that other services can use
* Pulling all the services together and starting them up on a box


### File setup

All composes will be flattened. There is no need for external volumes and networks

**1. Volumes**
Add to `common/volumes.docker-compose.yml`.

**2. Server blocks**
Add `name.conf` to `services/blocks`. Make sure there is only one default block. Example given in the examples folder.

**3. Services**
Add services compose files to `services/definitions`. Make sure names are unique across services as these will be flattened and run together. You can access other services using the service name as these will be on the same bridge network. There is no need to specify the external network as they will be run using same docker compose command.

Make sure the images are prehosted as this service cannot build images for these external services.

### Services setup
**1. Run certbot**

Update the `scripts/init-certs.sh` with the correct domains and email and then run the script. This will fetch / renew the certs for these domains.

**2. Start the services**
Run the `scripts/start.sh` command from top level to start the different services.

Run the `scripts/start-detached.sh` command from top level to start the different services in detached mode.

