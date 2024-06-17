# Devops Boiler

Template repository with server devops functionality

Things the devops project should solve:
* Creating NGINX web server
* Creating and renewing certs
* Having instructions to send logs to logtail or other services
* Pulling all the services together and starting them up on a box


### File setup

1. Clone repository
2. Create blocks and service definitions in services referencing the appropriate .env files
3. For deployable services make sure to have the image version reference an environment variable. Example: `markcutajar/my-new-application:${MY_NEW_APP_VERSION}`
4. For each of the deployable services, create a version file in `/versions` with the name of the environment variable above. Example: `/versions/MY_NEW_APP_VERSION`
5. If the server is development in the versions file put in `latest` that way the image will always reference the latest pushed image.
6. If the server is production, this variable will have the version number to deploy and the file will be modified by CICD.
7. Run the script `scripts/init-server.sh` to install docker
8. Add the domains in a file called `DOMAINS` and these should be new line delimited. Make sure there is no blank new line at the end. Make sure the top domain in the file is the expected one when referencing in the nginx 433 clauses.
9. Add the email in a file called `EMAIL`. Make sure there is no blank line at the end.
10. Run `scripts/init-certs.sh` to initialize certifications.
11. Copy services/blocks into services/blocks-backup
12. Edit all blocks in services/blocks, remove the 433 block
13. Run `scripts/deploy.sh` to run deploys.
14. Delete services/blocks and copy back services/blocks-backup into blocks.

## Helpful notes
* Make sure docker is logged in
* Make sure you add circleci key as authorized key
* Make sure docker network is not clashing with any internal network
* Make sure you do not have empty line in the domains file
