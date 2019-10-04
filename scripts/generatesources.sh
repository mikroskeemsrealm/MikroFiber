#!/usr/bin/env bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "${SOURCE}" ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR="$(cd -P "$(dirname "${SOURCE}")" && pwd)"
    SOURCE="$(readlink "${SOURCE}")"
    [[ "${SOURCE}" != /* ]] && SOURCE="${DIR}/${SOURCE}" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
. "$(dirname "${SOURCE}")/init.sh"

basedir
paperVer="$(cat current-paper)"

minecraftversion="$(grep minecraftVersion "${basedir}/Paper/work/BuildData/info.json" | cut -d '"' -f 4)"
decompile="Paper/work/Minecraft/${minecraftversion}/spigot"

mkdir -p mc-dev/src/net/minecraft/server

cd mc-dev
if [ ! -d ".git" ]; then
	git init
fi

find src/net/minecraft/server -name "*.java" -delete
find "${basedir}/${decompile}/net/minecraft/server" -name "*.java" -exec cp '{}' src/net/minecraft/server/ ';'

base="${basedir}/Paper/Paper-Server/src/main/java/net/minecraft/server"
cd "${basedir}/mc-dev/src/net/minecraft/server/"
find "${base}" -mindepth 1 -maxdepth 1 -type f -delete
cd "${basedir}/mc-dev"
git add . -A
git commit . -m "mc-dev"
git tag -a "${paperVer}" -m "${paperVer}" 2>/dev/null
pushRepo . "${MCDEV_REPO}" "${paperVer}"