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
echo "Updating configs..."
files="server.properties permissions.json whitelist.json"
for f in $files; do
    if [ ! -f "${BEDROCK_DATA}/${f}" ]; then
        echo "  copying '${f}'"
        cp -f "${BEDROCK_INSTALL}/${f}" "${BEDROCK_DATA}/${f}"
    else
        echo "  keeping '${f}'"
    fi
done

# These are factory files and clobber the directory on every installation an
# upgrade. Just copy them clobbering the destination.
echo "Updating bedrock packaged files..."
files="behavior_packs definitions resource_packs structures"
for f in $files; do
    echo "  copying '${f}'"
    cp -rf "${BEDROCK_INSTALL}/${f}" "${BEDROCK_DATA}/${f}"
done

# These are the executables and libraries. These are linked to save on disk space
# utilization.
echo "Linking executables and libraries..."
files="bedrock_server bedrock_server_realms.debug libCrypto.so"
for f in $files; do
    echo "  linking '${f}'"
    if [ -f "${BEDROCK_DATA}/${f}" ] || [ -L "${BEDROCK_DATA}/${f}" ]; then
        rm -f "${BEDROCK_DATA}/${f}"
    fi
    ln -sf "${BEDROCK_INSTALL}/${f}" "${BEDROCK_DATA}/${f}"
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
# SERVER_NAME                     server-name                     Dedicated Server Any string
# MAX_PLAYERS                     max-players                     10               INT 
# SERVER_PORT                     server-port                     19132            INT
# LEVEL_NAME                      level-name                      level            Any string
# LEVEL_SEED                      level-seed                      empty            Any string  
# ONLINE_MODE                     online-mode                     true             true, false
# WHITE_LIST                      white-list                      false            true, false
# ALLOW_CHEATS                    allow-cheats                    false            true, false
# VIEW_DISTANCE                   view-distance                   32               INT
# PLAYER_IDLE_TIMEOUT             player-idle-timeout             30               INT
# MAX_THREADS                     max-threads                     8                INT
# TICK_DISTANCE                   tick-distance                   4                INT [4-12]
# DEFAULT_PLAYER_PERMISSION_LEVEL default-player-permission-level member           visitor, member, operator
# TEXTUREPACK_REQUIRED            texturepack-required            false            true, false

function properties-replace {
    local key="$1"
    local val="$2"
    local res
    local file="${BEDROCK_DATA}/server.properties"

    # Search for key
    if grep -q "^${key}=" "${file}"; then

        # Get current value
        res=$(sed -n "s/^${key}=//p" ${file})

        # Replace if new value differs
        if [ "n${res}" != "n${val}" ]; then
            echo "  replacing '${key}=${res}' with '${key}=${val}'"
            sed -i -e "/^${key}=/ s/=.*/=${val}/" "${file}"
        else
            echo "  keeping '${key}=${res}'"
        fi
    else
        echo "  adding '${key}=${val}'"
        echo "${key}=${val}" >> "${file}"
    fi
}

function trim-var {
    local val=$1

    val=${val##*( )}
    val=${val%%*( )}

    echo $val
}

echo "Updating 'server.properties'..."

# GAMEMODE
if [ ! -z ${GAMEMODE+x} ]; then # only proceed if var is set
    case $(trim-var "${GAMEMODE}") in
        survival|0)
            properties-replace gamemode survival
            ;;
        creative|1)
            properties-replace gamemode creative
            ;;
        adventure|2)
            properties-replace gamemode adventure
            ;;
        *)
            echo "Error: '${GAMEMODE}' is NOT valid for 'gamemode' property!"
    esac
fi

# DIFFICULTY
if [ ! -z ${DIFFICULTY+x} ]; then # only proceed if var is set
    case $(trim-var "${DIFFICULTY}") in
        peaceful|0)
            properties-replace difficulty peaceful
            ;;
        easy|1)
            properties-replace difficulty easy
            ;;
        normal|2)
            properties-replace difficulty normal
            ;;
        hard|3)
            properties-replace difficulty hard
            ;;
        *)
            echo "Error: '${DIFFICULTY}' is NOT valid for 'difficulty' property!"
    esac
fi

# LEVEL_TYPE
if [ ! -z ${LEVEL_TYPE+x} ]; then # only proceed if var is set
    case $(trim-var "${LEVEL_TYPE}") in
        FLAT)
            properties-replace level-type FLAT
            ;;
        LEGACY)
            properties-replace level-type LEGACY
            ;;
        DEFAULT)
            properties-replace level-type DEFAULT
            ;;
        *)
            echo "Error: '${LEVEL_TYPE}' is NOT valid for 'level-type' property!"
    esac
fi

# SERVER_NAME
if [ ! -z ${SERVER_NAME+x} ]; then # only proceed if var is set
    SERVER_NAME=$(trim-var "${SERVER_NAME}")
    if [ -n "${SERVER_NAME}" ]; then
        properties-replace server-name "${SERVER_NAME}"
    else
        echo "Error: Empty value not allowed for 'server-name' property!"
    fi
fi

# MAX_PLAYERS
if [ ! -z ${MAX_PLAYERS+x} ]; then # only proceed if var is set
    if [ -z "${MAX_PLAYERS//[0-9]}" ] && [ -n "${MAX_PLAYERS}" ] ; then # test to ensure it is an INT
        properties-replace max-players ${MAX_PLAYERS}
    else
        echo "Error: '${MAX_PLAYERS}' is NOT valid integer for 'level-type' property!"
    fi
fi

# SERVER_PORT
if [ ! -z ${SERVER_PORT+x} ]; then # only proceed if var is set
    if [ -z "${SERVER_PORT//[0-9]}" ] && [ -n "${SERVER_PORT}" ] ; then # test to ensure it is an INT
        properties-replace server-port ${SERVER_PORT}
    else
        echo "Error: '${SERVER_PORT}' is NOT valid integer for 'server-port' property!"
    fi
fi

# LEVEL_NAME
if [ ! -z ${LEVEL_NAME+x} ]; then # only proceed if var is set
    LEVEL_NAME=$(trim-var "${LEVEL_NAME}")
    if [ -n "${LEVEL_NAME}" ]; then
        properties-replace level-name "${LEVEL_NAME}"
    else
        echo "Error: Empty value not allowed for 'level-name' property!"
    fi
fi

# LEVEL_SEED
if [ ! -z ${LEVEL_SEED+x} ]; then # only proceed if var is set
    LEVEL_SEED=$(trim-var "${LEVEL_SEED}")
    properties-replace level-seed "${LEVEL_SEED}"
fi

# ONLINE_MODE
if [ ! -z ${ONLINE_MODE+x} ]; then # only proceed if var is set
    case $(trim-var "${ONLINE_MODE}") in
        true)
            properties-replace online-mode true
            ;;
        false)
            properties-replace online-mode false
            ;;
        *)
            echo "Error: '${ONLINE_MODE}' is NOT valid for 'online-mode' property!"
    esac
fi

# WHITE_LIST
if [ ! -z ${WHITE_LIST+x} ]; then # only proceed if var is set
    case $(trim-var "${WHITE_LIST}") in
        true)
            properties-replace white-list true
            ;;
        false)
            properties-replace white-list false
            ;;
        *)
            echo "Error: '${WHITE_LIST}' is NOT valid for 'white-list' property!"
    esac
fi

# ALLOW_CHEATS
if [ ! -z ${ALLOW_CHEATS+x} ]; then # only proceed if var is set
    case $(trim-var "${ALLOW_CHEATS}") in
        true)
            properties-replace allow-cheats true
            ;;
        false)
            properties-replace allow-cheats false
            ;;
        *)
            echo "Error: '${ALLOW_CHEATS}' is NOT valid for 'allow-cheats' property!"
    esac
fi

# VIEW_DISTANCE
if [ ! -z ${VIEW_DISTANCE+x} ]; then # only proceed if var is set
    if [ -z "${VIEW_DISTANCE//[0-9]}" ] && [ -n "${VIEW_DISTANCE}" ] ; then # test to ensure it is an INT
        properties-replace view-distance ${VIEW_DISTANCE}
    else
        echo "Error: '${VIEW_DISTANCE}' is NOT valid integer for 'view-distance' property!"
    fi
fi

# PLAYER_IDLE_TIMEOUT
if [ ! -z ${PLAYER_IDLE_TIMEOUT+x} ]; then # only proceed if var is set
    if [ -z "${PLAYER_IDLE_TIMEOUT//[0-9]}" ] && [ -n "${PLAYER_IDLE_TIMEOUT}" ] ; then # test to ensure it is an INT
        properties-replace player-idle-timeout ${PLAYER_IDLE_TIMEOUT}
    else
        echo "Error: '${PLAYER_IDLE_TIMEOUT}' is NOT valid integer for 'player-idle-timeout' property!"
    fi
fi

# MAX_THREADS
if [ ! -z ${MAX_THREADS+x} ]; then # only proceed if var is set
    if [ -z "${MAX_THREADS//[0-9]}" ] && [ -n "${MAX_THREADS}" ] ; then # test to ensure it is an INT
        properties-replace max-threads ${MAX_THREADS}
    else
        echo "Error: '${MAX_THREADS}' is NOT valid integer for 'max-threads' property!"
    fi
fi

# TICK_DISTANCE
if [ ! -z ${TICK_DISTANCE+x} ]; then # only proceed if var is set
    if [ -z "${TICK_DISTANCE//[0-9]}" ] && [ "${TICK_DISTANCE}" -ge 4 ] && [ "${TICK_DISTANCE}" -le 12 ]; then # test to ensure it is an INT
        properties-replace tick-distance ${TICK_DISTANCE}
    else
        echo "Error: '${TICK_DISTANCE}' is NOT valid integer for 'tick-distance' property!"
    fi
fi

# DEFAULT_PLAYER_PERMISSION_LEVEL
if [ ! -z ${DEFAULT_PLAYER_PERMISSION_LEVEL+x} ]; then # only proceed if var is set
    case $(trim-var "${DEFAULT_PLAYER_PERMISSION_LEVEL}") in
        visitor)
            properties-replace default-player-permission-level visitor
            ;;
        member)
            properties-replace default-player-permission-level member
            ;;
        operator)
            properties-replace default-player-permission-level operator
            ;;
        *)
            echo "Error: '${DEFAULT_PLAYER_PERMISSION_LEVEL}' is NOT valid for 'default-player-permission-level' property!"
    esac
fi

# TEXTUREPACK_REQUIRED
if [ ! -z ${TEXTUREPACK_REQUIRED+x} ]; then # only proceed if var is set
    case $(trim-var "${TEXTUREPACK_REQUIRED}") in
        true)
            properties-replace texturepack-required true
            ;;
        false)
            properties-replace texturepack-required false
            ;;
        *)
            echo "Error: '${TEXTUREPACK_REQUIRED}' is NOT valid for 'texturepack-required' property!"
    esac
fi






