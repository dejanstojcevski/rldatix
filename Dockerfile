# Use the official Microsoft .NET SDK image to build the application
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build-env
WORKDIR /app

# Copy the CSPROJ file and restore any dependencies (via NUGET)
COPY src/*.csproj ./
RUN dotnet restore

# Copy the project files and build the release
COPY src/. ./
RUN dotnet publish -c Release -o out

# Generate the runtime image
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build-env /app/out .

# Expose port to listen to
EXPOSE 8080
ENTRYPOINT ["dotnet", "TodoApi.dll"]
