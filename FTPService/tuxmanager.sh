#!/bin/bash

export SCRIPT_ALLOWED=true

source Utils/styling.sh
source Utils/progress.sh
source Utils/byebye_track.sh

# FLAGS
is_vsftpd=0 # Check FTP install


# Function to display spinner while a command runs
spinner_install() {
    local msg="$1"
    spin[0]="-"
    spin[1]="\\"
    spin[2]="|"
    spin[3]="/"
  
    echo -n "${msg} ${spin[0]}"
    while true; do
        for i in "${spin[@]}"; do
        echo -ne "\b\b\b[$i]"
        sleep 0.1
        done
    done
}

check_services_install() {
    # Start the spinner in the background
    stty -echo
    stty igncr
    spinner_install "$(show_message "!" "Checking Packages...  " $YELLOW $MAIN_COLOR)" &
    spinner_pid=$!

    # Check for installed packages
    is_vsftpd=$(yum list installed | grep -q vsftpd && echo 1 || echo 0)

    # Stop the spinner
    kill $spinner_pid 
    sleep 1
    clear

    show_menu
    echo -ne "\r$(show_message "!" "Done..." $GREEN $MAIN_COLOR)"
    stty echo
    stty -igncr
    echo -ne "\r"
}

check_and_continue() {
    local service_name=$1
    local is_installed=$2
    local script_path=$3
    local menu_function=$4

    if [ $is_installed -eq 0 ]; then
        echo ""
        show_message "X" "The $service_name Service Package Is Not Installed" $RED $MAIN_COLOR
        show_message "!" "Install The Package Before Continuing" $RED $MAIN_COLOR
        echo ""
    else
        bash $script_path
        clear
        $menu_function  
    fi
}

display_not_installed_message() {
    local service=$1
    local flag=$2
    if [ $flag -eq 0 ]; then
        echo -ne "\t\t${NOCOLOR}[${RED}${service} is not installed${NOCOLOR}]"
    fi
}

show_title() {
    show_banner "${TUXCOLOR}" "${MAIN_COLOR}"
}

show_menu() {
    show_title
    echo -ne "\n ${MAIN_COLOR}[${TUXCOLOR}1${MAIN_COLOR}]${NOCOLOR} Install FTP Service\t\t${MAIN_COLOR}[${TUXCOLOR}5${MAIN_COLOR}]${NOCOLOR} Quit"
    echo -ne "\n ${MAIN_COLOR}[${TUXCOLOR}2${MAIN_COLOR}]${NOCOLOR} Configure FTP Service"
    echo -ne "\n ${MAIN_COLOR}[${TUXCOLOR}3${MAIN_COLOR}]${NOCOLOR} Manage DHCP Service"
    display_not_installed_message "FTP" $is_vsftpd
    echo -ne "\n ${MAIN_COLOR}[${TUXCOLOR}4${MAIN_COLOR}]${NOCOLOR} FTP Service Status"
    echo ""
    echo ""
}

show_info() {
    show_title
    echo -e "${YELLOW}"
    echo -e '  / ` /  /_`__ /_` _  /   _/_ . _  _   _'
    echo -ne ' /_; /_,._/   ._/ /_// /_//  / /_// /_\ ' 
    echo -e "${MAIN_COLOR} <\\"
    echo -e "${MAIN_COLOR} <_______________________________________[]${YELLOW}#######${MAIN_COLOR}]"
    echo -e '                                         </'
    echo -e " ${MAIN_COLOR}AUTHORS:"    
    echo -e " ${MAIN_COLOR}@ Gael Landa ${NOCOLOR}\t\thttps://github.com/GsusLnd"
    echo -e " ${MAIN_COLOR}@ Leonardo Aceves ${NOCOLOR}\thttps://github.com/L30AM"
    echo -e " ${MAIN_COLOR}@ Sergio Méndez ${NOCOLOR}\thttps://github.com/sergiomndz15"
    echo -e " ${MAIN_COLOR}@ Alexandra Gonzáles ${NOCOLOR}\thttps://github.com/AlexMangle"
    echo -e "\n${MAIN_COLOR}----------------------------------------------------------------------------------${NOCOLOR}"
    echo -ne " ${MAIN_COLOR}Press [${TUXCOLOR}ANY KEY${MAIN_COLOR}] to continue..."
    read -r -n 1 -s
    clear
}

show_bye_message() {
    clear
    show_title
    echo -e "\t\t    ${MAIN_COLOR}                                        ${NOCOLOR}"
    echo -e "\t\t    ${MAIN_COLOR}     Thank you for using our service!    ${NOCOLOR}"
    echo -e "\t\t    ${MAIN_COLOR}      We hope to see you again soon!     ${NOCOLOR}"
    echo -e "\t\t    ${MAIN_COLOR}                                        ${NOCOLOR}"
    echo -e "\t\t    ${MAIN_COLOR}             ${TUXCOLOR}(o<${MAIN_COLOR}                       ${NOCOLOR}"
    echo -e "\t\t    ${MAIN_COLOR}             ${TUXCOLOR}//\\  Goodbye!${MAIN_COLOR}             ${NOCOLOR}"
    echo -e "\t\t    ${MAIN_COLOR}             ${TUXCOLOR}V_/_${MAIN_COLOR}                      ${NOCOLOR}"
    echo -e "\t\t    ${MAIN_COLOR}                                        ${NOCOLOR}"
    spinner 3 "\t\t\t\t        "
    sleep 3
    clear
}

# MENU: MAIN
main_menu() {
	clear
    show_banner "${TUXCOLOR}" "${MAIN_COLOR}" "WELCOME!!!"
    check_services_install 
    while true; do
        echo -ne " ${MAIN_COLOR}Enter An Option ${TUXCOLOR}\$${MAIN_COLOR}>: ${NOCOLOR}"
        read -r op
        if [ -z "$op" ]; then
            echo "" > /dev/null
        else
            case $op in 
                1)
                    clear
                    bash Scripts/install_ftp.sh
                    show_menu
                    check_services_install
                    ;;
                2)
                    clear
                    bash Scripts/configure_ftp.sh
                    clear
                    show_menu
                    ;;
                3)
                    clear
                    bash Scripts/manage_ftp.sh
                    clear
                    show_menu
                    ;;
                4)
                    clear
                    bash Scripts/status_ftp.sh
                    clear
                    show_menu
                    ;;
                5) 
                    show_bye_message
                    break
                    ;;
                *)
                    show_message "X" "Invalid Option!" $RED $MAIN_COLOR
                    ;;
            esac
        fi
    done
}

main() 
{
    if [ $UID != 0 ]; then
        show_message "X" "TuxManager must be run as ROOT." $RED
        exit 1
    fi

    main_menu
}

main