#!/bin/bash
set -e
### Configuration
SSH_USER=me
SSH_HOST=myhost
DOCUMENT_ROOT=/path/to/htdocs
BASE_URL="https://server.name"
OPEN_URL=true
COPY_URL_TO_CLIPBOARD=true
NOTIFY=true
### Checking requirements
command -v import >/dev/null 2>&1 || {
    echo "ImageMagick is missing, quitting." >&2; exit 1;
}
command -v scp > /dev/null 2>&1 || {
    echo "openssh-client missing, quitting." >&2; exit 1;
}
### Main
FILE=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 4 | head -n 1).png
import /tmp/$FILE
{
    scp -o 'PreferredAuthentications=publickey' \
        /tmp/$FILE "$SSH_USER@$SSH_HOST:$DOCUMENT_ROOT" > /dev/null 2>&1;
} || {
    echo "Public key authentication failed, quitting."
    echo "Screenshot saved:"
    echo /tmp/$FILE
    exit 1
}
URL="$BASE_URL/$FILE"
if [ "$OPEN_URL" = true ]; then
    {
        xdg-open "$URL" > /dev/null 2>&1
    } || {
        echo "Unable to open browser. Screenshot uploaded to:"
        echo "$URL"
    }
fi
if [ "$COPY_URL_TO_CLIPBOARD" = true ]; then
    {
        echo "$URL" | xclip -sel clip > /dev/null 2>&1
        COPIED=true
    } || {
        COPIED=false
        echo "Unable to save to clipboard. Screenshot uploaded to:"
        echo "$URL"
    }
fi
if [ "$NOTIFY" = true ]; then
    [[ "$COPIED" = true ]] && STR="not" || STR=""
    NOTIFICATION="URL ${STR} copied"
    {
        notify-send "$NOTIFICATION"
    } || {
        echo "Unable to spawn notification."
        echo "$NOTIFICATION"
        echo "$URL"
    }
fi
rm /tmp/$FILE

