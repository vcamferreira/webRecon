#!/bin/bash

NAME="ReconPages"
ENVIRONMENT_ENABLE="Y"
USER_AGENT="Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.130 Safari/537.36"
ROBOTS_ENABLE="off"

function installPackages() {
    printf "[+] Install requirements packages...\n\n"
    sudo \
    apt install \
    wafw00f

    sleep 2 && clear
}

function buildEnvironment() {
    # printf "The $NAME needs to create a Environment. Do you agree? [Y/n]:  "
    # read "ENVIRONMENT_ENABLE"
    if [[ "$ENVIRONMENT_ENABLE" == "Y" || "$ENVIRONMENT_ENABLE" == "y" ]]
    then
        ENVIRONMENT=$(mktemp -t $NAME.XXXXX -d --suffix=-$(date +%s)) #--dry-run 
        printf "[+] Create $ENVIRONMENT\n\n"
    else
        exit 1
    fi
}

function removeEnvironment() {
    if [ -d $ENVIRONMENT ]
    then
        printf "[+] $ENVIRONMENT exist! Removing...\n\n"
        rm -rf "$ENVIRONMENT"
    else
        printf "[!] $ENVIRONMENT don't exist!\n\n"
        exit 1
    fi    
}

function clonePage() {
    reconFirewall
    printf "\n\n[+] Clonando alvo $TARGET\n"
    wget -q -m --random-wait -r -p -k -e robots="$ROBOTS_ENABLE" --user-agent \"$USER_AGENT\" "$TARGET" -P "$ENVIRONMENT"
    reconPage
}

function reconPage() {
    for PAGE in $(ls -1 $ENVIRONMENT)
    do
        printf "Starting Pages Recon"
        mkdir -p "$PWD/$PAGE"
        grep -Eoir '<a [^>]+>' "$ENVIRONMENT/$PAGE" | grep -Eo 'href="[^\"]+"' | grep -Eo '(http|https)://[^"]+' | sort -u > "$PWD/$PAGE/report.txt"
    done
}

function reconFirewall() {
    WAF="$(wafw00f $TARGET | grep -e "\[*\]")"

    printf "$WAF\n"
}

function wordlistTargets() {
    if [ -f $WORDLIST_TARGETS ]
    then
        # printf "[+] Successful to load wordlist targets!\n"
        for TARGET in $(cat $WORDLIST_TARGETS)
        do
            printf "\t[+] $TARGET\n"
            clonePage
        done
    else
        printf "[!] Try again! Wordlist doens't exist.\n"
        exit 1
    fi
}

function randomUserAgentes() {
    USER_AGENT=$(sort -R user-agents.txt | head -n 1)
}

function helpWebRecon() {
    printf "Usage: $0 -t example.com -u \"Mozilla\"\n"
    printf "       $0 -w wordlist.txt --random-user-agent user-agents.txt\n\n"
    
    printf "\t[-t | --target]\t\t  \n"

    printf "\t[-u | --user-agent]\t\t  \n"

    printf "\t[-U | --random-user-agent]\t\t  \n"

    printf "\t[-w | --wordlist]\t\t  \n"
}

function main (){
    installPackages
    buildEnvironment
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
    removeEnvironment
}

main "$@"