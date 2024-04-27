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

So, consecutive runs of this workflow will generate docker images with incremental semver tags and the tag "latest" will always be attached to latest build docker image.

https://hub.docker.com/repository/docker/dejanstojcevski/mydotnetapp/general

4. Added scanning of source code with SonarCloud in GitHub Actions workflow.
To do this, several prerequsites ar needed:
- open private organization on SonarCloud. my sonarcloud account is connected to github identitiy provider which recuires MFA - so you can not login to my SonarCloud account to see scanned jobs.
- generate API token in SonarCloud
- put this token in GitHub Actions secrets as SONAR_TOKEN secret
- reference this token in workfolw file

Also, simple test is configured in GitHub workflow before building docker file and push it to DockerHub.


