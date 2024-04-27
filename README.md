1. Added new configuration for application itself - src/appsettings.json
This file ensures that application is listening on port 8080 in IPv4 inside the container and not on IPv6.
Also, this file ensures that app is listening on every IPv4 address possible (0.0.0.0).

2. Configured Dockerfile
For test purposes, build local docker image with "sudo docker build -t mydotnetapp:latest ." and run it with "sudo docker run mydotnetapp -p 10.0.2.15:8080:8080" just to test the functionality.
Same Dockefile will be used to build docker image of the app in GitHub Actions.

3. Configuring GitHub actions to build a dockerimage
Configuration file for this workflow is located at .github/workflows/docker-build.yml
This workflow will build the docker image and push it to DockerHub.com in my personal public repository.
Configured secrets in Guthub->Settings->Secrets and Variables->Actions. Added two secrets for login to Dockerhub:
DOCKERHUB_USERNAME: dejanstojcevski
DOCKERHUB_PASSWORD: arspir_11
you can login with these credentials into Dockerhub in order to see build images in repository dejanstojcevski/"mydotnetapp"

Two SemVer tags are added to every docker image in the form: 1.0.<gh_actions_run_number> and "latest"


