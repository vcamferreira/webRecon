#!/bin/bash

source $PWD/webRecon.cfg
source $PWD/src/functions.sh
source $PWD/src/colors.sh

function main (){
    while [ ! -z "$1" ]; do
    case "$1" in
            "-h"|"--help")
                shift
                helpWebRecon
                ;;

            "-t"|"--target")
                shift
                TARGET="$1"
                clonePage
                ;;

            "-u"|"--user-agent")
                shift
                USER_AGENT="$1"
                printf "$USER_AGENT"
                ;;

            "-U"|"--random-user-agent")
                shift
                USER_AGENT=$1
                randomUserAgentes
                ;;
            
            "-w"|"--wordlist")
                shift
                WORDLIST_TARGETS=$1
                wordlistTargets
                ;;

            *)
                shift
                printf "Usage: $0 --help"
                exit 1
        esac
    shift
    done
}

main "$@"