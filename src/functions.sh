function installPackages() {
    printf "$BBlue[?] $NAME needs to install requirements packages. Do you agree? [Y/n]:$Color_Off  "
    read PACKAGES_AGREE
    if [[ "$PACKAGES_AGREE" == "Y" || "$PACKAGES_AGREE" == "y" ]]
    then
    printf "$Green"
        sudo \
        apt install \
        wafw00f
    printf "$Colors_Off"
    else
        printf "$BRed[!] Exit $NAME $Color_Off\n"
        exit 1
    fi

    sleep 2 && clear
}

function buildEnvironment() {
    printf "$BBlue[?] $NAME needs to create a Environment. Do you agree? [Y/n]:$Color_Off  "
    read "ENVIRONMENT_ENABLE"
    if [[ "$ENVIRONMENT_ENABLE" == "Y" || "$ENVIRONMENT_ENABLE" == "y" ]]
    then
        ENVIRONMENT=$(mktemp -t $NAME.XXXXX -d --suffix=-$(date +%s))
        printf "\n$BGreen[+] Create a temporary directory$Color_Off\n\n"
    else
        printf "$BRed[!] Exit $NAME $Color_Off\n"
        exit 1
    fi
}

function removeEnvironment() {
    if [ -d $ENVIRONMENT ]
    then
        printf "\n\n$BGreen[+] $ENVIRONMENT exist! Removing...$Color_Off\n\n"
        rm -rf "$ENVIRONMENT"
    else
        printf "\n[!] $ENVIRONMENT don't exist!\n\n"
        exit 1
    fi    
}

function clonePage() {
    installPackages
    buildEnvironment
    printf "\t$BGreen[+] Cloning target $TARGET$Color_Off\n\n"
    reconFirewall
    wget -q -m --random-wait -r -p -k -e robots="$ROBOTS_ENABLE" --user-agent \"$USER_AGENT\" "$TARGET" -P "$ENVIRONMENT"
    reconPage
}

function reconPage() {
    printf "\t$BGreen[+] Recognizing target $TARGET$Color_Off\n\n"
    for PAGE in $(ls -1 $ENVIRONMENT)
    do
        printf "\t$BGreen[+] $NAME is generating the recognition report. $BRed Waiting...$Color_Off"
        mkdir -p "$PWD/$PAGE"
        grep -Eoir '<a [^>]+>' "$ENVIRONMENT/$PAGE" | grep -Eo 'href="[^\"]+"' | grep -Eo '(http|https)://[^"]+' | sort -u > "$PWD/$PAGE/report.txt"
        printf "$BGreen Finished!$Color_Off"
    done
    removeEnvironment
}

function reconFirewall() {
    WAF="$(wafw00f $TARGET | grep -e "\[*\]")"

    printf "$BYellow$WAF$Color_Off\n\n"
}

function wordlistTargets() {
    if [ -f $WORDLIST_TARGETS ]
    then
        printf "$BGreen[+] Successful to load wordlist targets!$Color_Off\n"
        for TARGET in $(cat $WORDLIST_TARGETS)
        do
            printf "\t$Green[+] $TARGET$Color_Off\n"
            clonePage
        done
    else
        printf "$BRed[!] Try again! Wordlist doens't exist.$Color_Off\n"
        exit 1
    fi
}

function randomUserAgentes() {
    USER_AGENT=$(sort -R user-agents.txt | head -n 1)
}

function helpWebRecon() {
    printf "$Green"
    printf "Usage: $0 -t example.com -u \"Mozilla\"\n"
    printf "       $0 -w wordlist.txt --random-user-agent user-agents.txt\n\n"
    
    printf "\t[-t | --target]\t\t  \n"

    printf "\t[-u | --user-agent]\t\t  \n"

    printf "\t[-U | --random-user-agent]\t\t  \n"

    printf "\t[-w | --wordlist]\t\t  \n"
    printf "$Color_Off"
}