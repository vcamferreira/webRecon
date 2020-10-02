#!/bin/bash

function helpWebRecon() {
    printf "Usage: $0 -t example.com -u \"Mozilla\"\n"
    printf "       $0 -w wordlist.txt --random-user-agent user-agents.txt\n\n"
    
    printf "\t[-t | --target]\t\t  \n"

    printf "\t[-u | --user-agent]\t\t  \n"

    printf "\t[-U | --random-user-agent]\t\t  \n"

    printf "\t[-w | --wordlist]\t\t  \n"
}

function main (){
    while [ ! -z "$1" ]; do
    case "$1" in
            "-h"|"--help")
                shift
                helpWebRecon
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