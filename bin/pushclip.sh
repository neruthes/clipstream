#!/bin/bash

#
# Copyright (c) 2022 Neruthes.
# This script is a component of the Clipstream software.
# Cilpstream is a free software licensed under GNU GPLv2.
# You may get Clipstream at <https://github.com/neruthes/clipstream>.
#

APPVER="0.1.0-pre1"

CONFDIR="$HOME/.config/clipstream"
mkdir -p "$CONFDIR"


#
# Functions
#
function _failIfNoToken() {
    if [[ ! -e $CONFDIR/servers ]]; then
        echo "[ERROR] You need at least a server at '$CONFDIR/servers'."
        echo "        Consult 'pushclip help' for help."
        exit 1
    fi
}
function _help() {
    echo "pushclip (version $APPVER)

This script is a component of Clipstream <https://github.com/neruthes/clipstream>.
Cilpstream is a free software licensed under GNU GPLv2.

USAGE:

    pushclip help                               Print this help message.
    pushclip ls                                 List Clipstream servers.
    pushclip addserver {SERVER} {TOKEN}         Add a Clipstream server by SERVER and TOKEN.
    pushclip editservers                        Edit servers list.
    pushclip push                               Push stdin to the first Clipstream server.
    pushclip push {USERNAME}                    Push to the fist server where the username is used.
    pushclip pushall                            Push stdin to all Clipstream servers.
"
}
function _ls () {
    cat $CONFDIR/servers | grep -v '#' | sed 's|^http|\nserver: http|g' | sed 's/|/\ntoken:  /g'
}
function _push() {
    echo "[INFO] Pushing from stdin."
    STDIN_CACHE=/tmp/pushclip-stdincache-$RANDOM$RANDOM$RANDOM$RANDOM
    cat /dev/stdin > $STDIN_CACHE
    if [[ -z "$1" ]]; then
        ### Normally first
        SERVERS_TABLE="$(grep -v '#' $CONFDIR/servers)"
    else
        ### Find specific stream
        echo "debug: Pushing to a specific stream"
        SERVERS_TABLE="$(grep -v '#' $CONFDIR/servers | grep -E "\|$1-")"
    fi
    if [[ "$PUSHALL" != y ]]; then
        SERVERS_TABLE="$(echo "$SERVERS_TABLE" | head -n1)"
    fi
    for SERVER_LINE in $SERVERS_TABLE; do
        echo "[INFO] Pushing to server '${SERVER_LINE/|/\' as \'}'."
        _pushToServer "$SERVER_LINE"
        
    done
    rm $STDIN_CACHE
}
function _pushToServer() {
    USER_TOKEN="$(echo "$SERVER_LINE" | cut -d'|' -f2)"
    SERVER_PREFIX="$(echo "$SERVER_LINE" | cut -d'|' -f1)"
    API_ENDPOINT="$(echo "$SERVER_LINE" | cut -d'|' -f1)/api/functions/saveclip?token=$USER_TOKEN"
    echo "--------------------- Begin Server Response ---------------------"
    cat $STDIN_CACHE | curl -X POST --data-binary "@/dev/stdin" "$API_ENDPOINT"
    echo "---------------------- End Server Response ----------------------"
}

#
# Main
#
case $1 in
    ls)
        _ls 
        ;;
    addserver)
        echo "$2|$3" >> $CONFDIR/servers
        sort -u $CONFDIR/servers > $CONFDIR/servers.new
        mv $CONFDIR/servers.new $CONFDIR/servers
        echo "[INFO] Current list of servers:"
        _ls
        ;;
    editservers)
        if [[ -z $EDITOR ]]; then
            EDITOR="nano"
        fi
        $EDITOR $CONFDIR/servers
        ;;
    push)
        _push $2
        ;;
    pushall)
        PUSHALL=y _push
        ;;
    help|*)
        _help
        ;;
esac
