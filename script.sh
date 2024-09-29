#!/bin/ash
# shellcheck shell=dash

# Check if Minecraft version exists
VER_EXISTS=$(curl -s https://api.purpurmc.org/v2/purpur | jq -r --arg VERSION "$MINECRAFT_VERSION" '.versions[] | contains($VERSION)' | grep true)
LATEST_VERSION=$(curl -s https://api.purpurmc.org/v2/purpur | jq -r '.versions' | jq -r '.[-1]')

if [ "${VER_EXISTS}" = "true" ]; then
    printf "Version is valid. Using version %s\n" "${MINECRAFT_VERSION}"
else
    printf "Using the latest Purpur version\n"
    MINECRAFT_VERSION=${LATEST_VERSION}
fi

# Check if build exists
BUILD_EXISTS=$(curl -s https://api.purpurmc.org/v2/purpur/"${MINECRAFT_VERSION}" | jq -r --arg BUILD "${BUILD_NUMBER}" '.builds.all | tostring | contains($BUILD)' | grep true)
LATEST_BUILD=$(curl -s https://api.purpurmc.org/v2/purpur/"${MINECRAFT_VERSION}" | jq -r '.builds.latest')

if [ "${BUILD_EXISTS}" = "true" ]; then
    printf "Build is valid for version %s. Using build %s\n" "${MINECRAFT_VERSION}" "${BUILD_NUMBER}"
else
    printf "Using the latest Purpur build for version %s\n" "${MINECRAFT_VERSION}"
    BUILD_NUMBER=${LATEST_BUILD}
fi

DOWNLOAD_URL=https://api.purpurmc.org/v2/purpur/${MINECRAFT_VERSION}/${BUILD_NUMBER}/download

cd /mnt/server || exit
printf "Downloading Purpur version %s build %s\n" "${MINECRAFT_VERSION}" "${BUILD_NUMBER}"

# Backup the existing server jar if it exists
if [ -f "server.jar" ]; then
    mv server.jar server.jar.old
fi

# Download the server jar
curl -o server.jar "${DOWNLOAD_URL}"

printf "Downloading optimized configuration files\n"

# Create the config directory if it doesn't exist
if [ ! -d "config" ]; then
    mkdir -p config
fi

# Download the new configuration files
curl -o server.properties https://cybernova.hr/server.properties
curl -o spigot.yml https://cybernova.hr/spigot.yml
curl -o purpur.yml https://cybernova.hr/purpur.yml
curl -o pufferfish.yml https://cybernova.hr/pufferfish.yml
curl -o eula.txt https://cybernova.hr/eula.txt
curl -o bukkit.yml https://cybernova.hr/bukkit.yml

# Create the config directory and download additional configuration files
mkdir -p config

curl -o config/paper-global.yml https://cybernova.hr/paper-global.yml
curl -o config/paper-world-defaults.yml https://cybernova.hr/paper-world-defaults.yml

printf "All configuration files downloaded successfully.\n"
