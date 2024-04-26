1. Added new configuration for application itself - appsettings.json
This file ensures that application is listening on port 8080 in IPv4 inside the container and not on IPv6.
Also, this file ensures that app is listening on every IPv4 address possible (0.0.0.0).

2. Configured Dockerfile
For test purposes, build local docker image with "sudo docker build -t mydotnetapp:latest ." and run it with "sudo docker run mydotnetapp -p 10.0.2.15:8080:8080" just to test the functionality.


