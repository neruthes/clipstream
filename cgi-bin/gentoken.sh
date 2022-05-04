#!/bin/bash


### Important initialization
DATADIR=/var/www/clipstream
SECRETDIR=/var/www/clipstream/secret
WEBDIR=/var/www/clipstream/www

mkdir -p $WEBDIR $SECRETDIR

### Generate mastertoken if not yet present
if [[ ! -e $SECRETDIR/mastertoken ]]; then
    dd if=/dev/urandom of=/dev/stdout bs=32 count=1 2>/dev/null | sha256sum | cut -c1-50 > $SECRETDIR/mastertoken
    chmod 664 $SECRETDIR/mastertoken
    echo "[INFO] Created mastertoken: '$(cat $SECRETDIR/mastertoken)'"
    ls -lah $SECRETDIR/mastertoken
fi
SAVED_MASTER_TOKEN="$(cat $SECRETDIR/mastertoken)"




if [[ ! -w $DATADIR ]]; then
    echo "[ERROR] Directory '$DATADIR' cannot be written by '$USER'."
fi

#
# Notes:
#
#   URL param must be sorted as "?token=123456&user=alice"
#

INPUT_MASTER_TOKEN="$(echo "$url" | sed 's|/api/functions/gentoken?||' | cut -d'&' -f1 | sed 's|token=||')"
INPUT_USERNAME="$(echo "$url" | sed 's|/api/functions/gentoken?||' | cut -d'&' -f2 | sed 's|user=||')"

echo "INPUT_MASTER_TOKEN=$INPUT_MASTER_TOKEN"
echo "INPUT_USERNAME=$INPUT_USERNAME"

if [[ "$INPUT_MASTER_TOKEN" != "$SAVED_MASTER_TOKEN" ]]; then
    echo "[ERROR] Authentication failed."
    exit 0
fi
### Authentication is done
clipstream-admin-gentoken "$INPUT_USERNAME"
