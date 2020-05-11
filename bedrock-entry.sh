#!/bin/bash

# This script relies on a few environment variables to create the runtime
# environment for our Minecraft Bedrock Server:
#
# BEDROCK_DATA      - The world data                - Default: /bedrock-data
# BEDROCK_INSTALL   - The extracted zip archive     - Default: /bedrock-install
#
# At version 1.14.60.5 the server zip archive contained the following files and
# directories:
#
# bedrock_server               behavior_packs  permissions.json   server.properties
# bedrock_server_how_to.html   definitions     release-notes.txt  structures
# bedrock_server_realms.debug  libCrypto.so    resource_packs     whitelist.json
#

# These are our configuration files, and defaults will be installed unless file
# exists in BEDROCK_DATA.
files="server.properties permissions.json whitelist.json"
for f in $files; do
    if [ ! -f ${BEDROCK_DATA}/${f} ]; then
        echo "Copying default config... ${f}"
        cp -f ${BEDROCK_INSTALL}/${f} ${BEDROCK_DATA}/${f}
    else
        echo "Keeping config... ${f}"
    fi
done

# These are factory files and clobber the directory on every installation an
# upgrade. Just copy them clobbering the destination.
files="behavior_packs definitions resource_packs structures"
for f in $files; do
    echo "Copying files/directories... ${f}"
    cp -rf ${BEDROCK_INSTALL}/${f} ${BEDROCK_DATA}/${f}
done

# These are the executables and libraries. These are linked to save on disk space
# utilization.
files="bedrock_server bedrock_server_realms.debug libCrypto.so"
for f in $files; do
    echo "Linking executables/libraries... ${f}"
    if [ -f ${BEDROCK_DATA}/${f} ] || [ -L ${BEDROCK_DATA}/${f} ]; then
        rm -f ${BEDROCK_DATA}/${f}
    fi
    ln -sf ${BEDROCK_INSTALL}/${f} ${BEDROCK_DATA}/${f}
done

# The following environment variables are supported and mapped to their
# server.properties values as indicated.
# See https://minecraft.gamepedia.com/Server.properties#Bedrock_Edition_3
# 
# Environment variable            server.properties               Default          Allowed values
# --------------------            -----------------               -------          --------------
# GAMEMODE                        gamemode                        survival         survival (0), creative (1), adventure (2)
# DIFFICULTY                      difficulty                      easy             peaceful (0), easy (1), normal (2), hard (3)
# LEVEL_TYPE                      level-type                      DEFAULT          FLAT, LEGACY, DEFAULT 
# SERVER_NAME                     server-name                     Dedicated Server AAny string
# MAX_PLAYERS                     max-players                     10               INT 
# SERVER_PORT                     server-port                     19132            INT
# LEVEL_NAME                      level-name                      level            Any string
# LEVEL_SEED                      level-seed                      empty            Any string  
# ONLINE_MODE                     online-mode                     true             true, false
# WHITE_LIST                      white-list                      false            true, false
# ALLOW_CHEATS                    allow-cheats                    false            true, false
# VIEW_DISTANCE                   view-distance                   10               INT
# PLAYER_IDLE_TIMEOUT             player-idle-timeout             30               INT
# MAX_THREADS                     max-threads                     8                INT
# TICK_DISTANCE                   tick-distance                   4                INT [4-12]
# DEFAULT_PLAYER_PERMISSION_LEVEL default-player-permission-level member           visitor, member, operator
# TEXTUREPACK_REQUIRED            texturepack-required            false            true, false


