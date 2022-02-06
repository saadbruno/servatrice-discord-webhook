#!/bin/bash

# Servatrice Discord Webhook. A simple way to push your Cockatrice server updates to Discord.
# MIT License
# Documentation available at: https://github.com/saadbruno/servatrice-discord-webhook
# Usage:
#    WEBHOOK_URL=<discord webhook> SERVERLOG=</path/to/server/logs> FOOTER=<optional footer> LANGUAGE=<optional language> ./servatrice-discord.webook.sh
# Also available via a Docker image, read the github repo for more information

#let's check for required variables
if [ -z "$WEBHOOK_URL" ]; then
    echo ":: WARNING: Missing arguments. USAGE:"
    echo "   WEBHOOK_URL=<discord webhook> SERVERLOG=</path/to/server/logs> FOOTER=<optional footer> LANGUAGE=<optional language> ./servatrice-discord.webook.sh"
    echo ":: If you're using Docker, make sure you've set the WEBHOOK_URL environment variable"
    exit 1
fi

if [ ! -f "$SERVERLOG/servatrice.log" ]; then
    echo ":: WARNING: Couldn't find server log. Make sure $SERVERLOG/servatrice.log exists. USAGE:"
    echo "   WEBHOOK_URL=<discord webhook> SERVERLOG=</path/to/server/logs> FOOTER=<optional footer> LANGUAGE=<optional language> ./servatrice-discord.webook.sh"
    echo ":: If you're using Docker, make sure you mounted your server log to /app/logs with '-v /path/to/server/logs:/app/logs:ro'"
    exit 1
fi

DIR=$(dirname $0)


# Let's default our language to english
if [ -z "$LANGUAGE" ]; then
    LANGUAGE="en-US"
fi

LANGFILE=$DIR/lang/$LANGUAGE.sh
echo "================================================="
echo "Starting webhooks script with the following info:"
echo ":: Language: $LANGUAGE"
echo ":: URL: $WEBHOOK_URL"
echo ":: Footer: $FOOTER"
echo ":: Server logs: $SERVERLOG/servatrice.log"
echo "================================================="

# compact version of the webhook
function webhook_generic() {
    curl -H "Content-Type: application/json" \
        -X POST \
        -d '{
                "username": "Cockatrice",
                "avatar_url" : "https://raw.githubusercontent.com/Cockatrice/cockatrice.github.io/master/images/cockatrice_logo.png",
                "embeds": [{
                    "color": "'"$2"'",
                    "author": {
                        "name": "'"$1"'"
                    },
                    "footer": {
                        "text": "'"$FOOTER"'"
                    }
                }
            ]}' $WEBHOOK_URL
}

function webhook_createroom() {
    curl -H "Content-Type: application/json" \
        -X POST \
        -d '{
                "username": "Cockatrice",
                "avatar_url" : "https://raw.githubusercontent.com/Cockatrice/cockatrice.github.io/master/images/cockatrice_logo.png",
                "embeds": [{
                    "color": "'"$4"'",
                    "thumbnail": {
                        "url": "https://i.imgur.com/RD0qhnx.png"
                    },
                    "fields": [
                        {
                            "name": "'"$NAME"':",
                            "value": "'"$2"'",
                            "inline": false
                        },
                        {
                            "name": "'"$NUMBER_OF_PLAYERS"':",
                            "value": "'"$3"'",
                            "inline": false
                        }
                    ],
                    "author": {
                        "name": "'"$1"'"
                    },
                    "footer": {
                        "text": "'"$FOOTER"'"
                    }
                }
            ]}' $WEBHOOK_URL
}

# actual loop with parsing of the log
tail -n 0 -F $SERVERLOG/servatrice.log | while read LINE; do

    case $LINE in

    # joins and parts
    *loginUser*)
        PLAYER=$(echo "$LINE" | cut -d '"' -f2)
        source $LANGFILE
        echo "$PLAYER joined. Sending webhook..."
        webhook_generic "$JOIN" 6473516
        ;;

    *"removeClient: name"*)
        PLAYER=$(echo "$LINE" | cut -d '"' -f2)
        source $LANGFILE
        echo "$PLAYER left. Sending webhook..."
        webhook_generic "$LEAVE" 9737364
        ;;

    *Command_CreateGame*)
        ROOM=$(echo "$LINE" | cut -d '"' -f2)
        PLAYERS=$(echo "$LINE" | grep -oP '(?<=max_players: )[0-9]+')

        # room names can be empty, so we account for it
        if [ -z "$ROOM" ]
            then
                ROOM="---"
        fi

        source $LANGFILE
        echo "Room $ROOM created. Sending webhook..."
        webhook_createroom "$CREATEROOM" "$ROOM" "$PLAYERS" 10113475
        ;;

    esac
done
