#!/bin/bash

### Important initialization
DATADIR=/var/www/clipstream
SECRETDIR=/var/www/clipstream/secret
WEBDIR=/var/www/clipstream/www

mkdir -p $WEBDIR $SECRETDIR


#
# Authenticate first!
#


# - Get INPUT_USERNAME from the input.
# - Calculate sha256('ClipstreamIsAFreeSoftware' + MASTER_TOKEN) as MASTER_HASH.
# - Generate a piece of random entropy and calculate its SHA-256 hash and get the first 16 hex digits as ENTROPY_RANDOM.
# - Calculate sha256(MASTER_HASH + INPUT_USERNAME + ENTROPY_RANDOM) and get the first 8 hex digits as AUTHCODE.
# - Return ENTROPY_RANDOM + AUTHCODE as TOKEN_DIGITS (24-digit hex lowercase).

MASTER_TOKEN="$(cat /var/www/clipstream/secret/mastertoken)"
MASTER_HASH="$(echo "ClipstreamIsAFreeSoftware$MASTER_TOKEN" | sha256sum | cut -d' ' -f1)"
INPUT_USER_TOKEN="$(echo "$url" | sed 's|/api/functions/saveclip?token=||')"
INPUT_USERNAME="$(echo "$INPUT_USER_TOKEN" | cut -d- -f1)"
TOKEN_DIGITS="$(echo "$INPUT_USER_TOKEN" | cut -d- -f2)"
ENTROPY_RANDOM="$(echo "$TOKEN_DIGITS" | cut -c1-16)"
AUTHCODE="$(echo "${MASTER_HASH}${INPUT_USERNAME}${ENTROPY_RANDOM}" | sha256sum | cut -c1-8)"
INPUT_AUTHCODE="$(echo "$TOKEN_DIGITS" | cut -c17-)"

READONLY_TOKEN="$INPUT_USERNAME-$ENTROPY_RANDOM"

if [[ "$AUTHCODE" != "$INPUT_AUTHCODE" ]]; then
    echo "[ERROR] Authentication failed. Invalid token."
    exit 0
fi

touch $SECRETDIR/revokedtokens
if [[ "$(grep "$INPUT_USER_TOKEN" $SECRETDIR/revokedtokens)" != "" ]]; then
    echo "[ERROR] Authentication failed. Token has been revoked."
    exit 0
fi





# Some variables...
URL_PREFIX_LIST="$(grep -v '#' $SECRETDIR/urlprefixlist)"



### Save the clip content
CLIP_FN="$(date +%Y%m%d.%s).txt"
USERDIR=/$WEBDIR/clips/$READONLY_TOKEN
mkdir -p $USERDIR/db
CLIP_PATH=/$USERDIR/db/$CLIP_FN
echo "$reqBodyData" > $CLIP_PATH
echo "$CLIP_FN" >> $USERDIR/clipslist

### Clear old clips
tail -n2000 $USERDIR/clipslist > $USERDIR/clipslist.new
mv $USERDIR/clipslist.new $USERDIR/clipslist
for realfn in $(ls $USERDIR/db); do
    if [[ "$(grep "$realfn" $USERDIR/clipslist)" == "" ]]; then
        rm "$realfn"
    fi
done


### Return the viewer URL
for pref in $URL_PREFIX_LIST; do
    echo "  > Stream: $pref/www/view.html?token=$READONLY_TOKEN"
done
