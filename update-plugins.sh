#!/bin/bash
declare -a MYSERVERS MYPLUGINS

# Define your servers here, add as many as you want
MYSERVERS+=("/home/minecraft/servers/demo1.16.1")
MYSERVERS+=("/home/minecraft/servers/demo1.12.2")
MYSERVERS+=("/home/minecraft/servers/demo")

# Define the plugins to be updated here
# You have to spell the name correctly
# CaSe SeNsItIvE, see here:
# https://repo.jeff-media.de/maven2/de/jeff_media
MYPLUGINS+=("ChestSort")
MYPLUGINS+=("AngelChest")
MYPLUGINS+=("LumberJack")
MYPLUGINS+=("Drop2Inventory")
#MYPLUGINS+=("LightPerms")
MYPLUGINS+=("InvUnload")

function get_plugin_https() {
	name="$1"
	serverpath="$2"
	path="https://repo.jeff-media.de/maven2/de/jeff_media/"
	version=$(get_latest_version $name)
	echo Downloading $name $version ...
	wget -q -O "${tmpdir}/${name}.jar" "${path}${name}/${version}/${name}-${version}.jar"
}

function get_latest_version() {
	tmppath=$(mktemp -d)
	name="${1,,}"
	url="https://api.jeff-media.de/${name}/latest-version.txt"
	version=$(curl --silent $url 2>/dev/null | tr -d '\n')
	echo "$version"
}

function banner() {
	echo "===== $* ====="
}

tmpdir=$(mktemp -d)

banner Downloading Plugins...
for plugin in "${MYPLUGINS[@]}"; do
	get_plugin_https $plugin
done

banner Installing Plugins...
for server in "${MYSERVERS[@]}"; do
	echo "Copying plugins to $server/plugins/ ..."
	for plugin in "${MYPLUGINS[@]}"; do
		cp "${tmpdir}/${plugin}.jar" "${server}/plugins/"
	done
done

for plugin in "${MYPLUGINS[@]}"; do
	rm "${tmpdir}/${plugin}.jar"
done
rmdir "${tmpdir}"
