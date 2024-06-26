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

5. Added helm template for our application in dir "helm"
This tempate will be used to deploy our docker image from DockerHUB to KIND kubernetes cluster which will be created in the GitHUB Actions runner.
Packeged helm chart will be stored in the dir "helm" and is automatically build in one of the steps in new workflow named "Kubernetes".
Ideally, helm charts are stored in a remote Helm repository (github pages, chartmuseum: https://chartmuseum.com/) but for simplicity, we will store the packeged helm chart in local dir on the github actions runner executor.
Packaging helm charts: "helm package ./"

6. Added second GitHUB Actions workflow with dependency on the previous workflow.
This workflow will provision kubernetes cluster with kind and use this cluster for tests/deploy our sample application with helm.
With this workflow, new KIND k8s cluster is configured and tested.
This cluster will be used to host our mydotnetapp deployment.

NOTE: I tried to install MetalLB addon to KIND k8s cluster but failed to do so. Wanted to configure the kubernetes service of mydotnetapp to be of type LoadBalancer and expose our app to external world (outside of k8s). Since I failed to configure MetalLB addon, we will access our app with "kubectl port-forward" action.

In order our app to be in Ready state, I removed liveness and readiness probes because they are not configured in the application code itself.

7. Connect to our app running inside kubernetes cluster with port-forward command:
kubectl port-forward --address localhost svc/mydotnetapp 8888:80

This commands forwards traffic from localhost:8888 (on localhost - github action runner) to service mydotnetapp:80 (in kubernetes cluster) to container mydotnetapp:8080 (inside the pod)

It can be seen from workflows that connectivity is established (altough response from our app is empty)

8. Configure our dockerized app to be run as AWS Lambda Function
I will use my own private AWS account to deploy mydotnetapp as a Lambda function in my AWS Account.
In order to do that:
- we will need a private ECR repository where our docker image will be stored. i will do this manually (logs in push_docker_image_to_ecr.log)
  this ECR repository must reside in same AWS region as Lambda function itself
- we will use terraform as IaC tool. dir "lambda" will be home dir for terraform operations(terraform init, terraform plan, terraform apply, terrform destroy). it will house terraform configuration (main.tf), terraform state file (terraform.tfstate) and .terraform dir - where providers will be downloaded.
- logs from terrafrom apply are in "terraform_apply.log" file - it creates: IAM policies, Lambda Function, API Gateway trough which our app will be publicly exposed to internet
- logs from terraform destroy are in "terrafaform_destroy.log" file - it destroys complete infrastructure
- outputs from terraform apply operation are information about public API endpoints API Gateway.
