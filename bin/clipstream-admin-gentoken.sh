#!/bin/bash


### Important initialization
DATADIR=/var/www/clipstream
SECRETDIR=/var/www/clipstream/secret
WEBDIR=/var/www/clipstream/www

mkdir -p $WEBDIR $SECRETDIR

### Generate mastertoken if not yet present
if [[ ! -e $SECRETDIR/mastertoken ]]; then
    dd if=/dev/urandom of=/dev/stdout bs=32 count=1 2>/dev/null | sha256sum | cut -c1-50 > $SECRETDIR/mastertoken 2>/dev/null
    chmod 664 $SECRETDIR/mastertoken
fi
MASTER_TOKEN="$(cat $SECRETDIR/mastertoken)"

### Set default hostname if not yet specified
if [[ ! -e $SECRETDIR/urlprefixlist ]]; then
    MAINIPADDR="$(ip route | head -n1 | grep -o -E 'src [0-9\.]+' | cut -d' ' -f2)"
    echo -e "# One prefix per line\nhttp://$MAINIPADDR:9277" > $SECRETDIR/urlprefixlist
fi
URL_PREFIX_LIST="$(grep -v '#' $SECRETDIR/urlprefixlist)"



# - Get INPUT_USERNAME from the input.
# - Calculate sha256('ClipstreamIsAFreeSoftware' + MASTER_TOKEN) as MASTER_HASH.
# - Generate a piece of random entropy and calculate its SHA-256 hash and get the first 16 hex digits as ENTROPY_RANDOM.
# - Calculate sha256(MASTER_HASH + INPUT_USERNAME + ENTROPY_RANDOM) and get the first 8 hex digits as AUTHCODE.
# - Return ENTROPY_RANDOM + AUTHCODE as TOKEN_DIGITS (24-digit hex lowercase).
INPUT_USERNAME="$1"

MASTER_HASH="$(echo "ClipstreamIsAFreeSoftware$MASTER_TOKEN" | sha256sum | cut -d' ' -f1)"
ENTROPY_RANDOM="$(dd if=/dev/urandom of=/dev/stdout bs=4096 count=1 2>/dev/null | sha256sum | cut -c1-16)"
AUTHCODE="$(echo "${MASTER_HASH}${INPUT_USERNAME}${ENTROPY_RANDOM}" | sha256sum | cut -c1-8)"
TOKEN_DIGITS="${ENTROPY_RANDOM}${AUTHCODE}"
printf "${INPUT_USERNAME}-${TOKEN_DIGITS}"
