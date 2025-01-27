#!/bin/bash

if [ "$SCRIPT_ALLOWED" != "true" ]; then
    echo -e " \033[38;5;69m[\033[38;5;88mX\033[38;5;69m]\033[38;5;88m This script must be sourced from the main script 'tuxmanager.sh' .\033[0m"
    exit 1
fi

# UTILS: Source utility scripts for additional functionality
source Utils/styling.sh 
source Utils/progress.sh
source Utils/validate.sh

# FLAGS
is_ftp_installed=0 # Track FTP installation status
is_connection=0 # Track internet connection status

# Function to check if FTP is installed
is_installed() {
    is_ftp_installed=$(yum list installed | grep -q vsftpd && echo 1 || echo 0)
}

# Function to check internet connection
check_connection() {
    is_connection=$(ping -q -w 1 -c 1 8.8.8.8 > /dev/null && echo 1 || echo 0)
}

# Function to show the title banner
show_title() {
    clear
    show_banner $FTPCOLOR $MAIN_COLOR "FTP Service Installation"
}

# Function to manage package installation, update, or removal
manage_pkg() {
    local action=$1
    local message=$2
    local command=$3

    show_title
    echo ""

    check_connection
    if [ $is_connection -eq 0 ]; then
        show_message "X" "No internet connection. Cannot proceed.\n" $RED $MAIN_COLOR
        return
    fi

    show_message "!" "$message" $YELLOW $MAIN_COLOR
    sleep 1
    progress_bar 10 $YELLOW $MAIN_COLOR &
    eval "$command" > /dev/null 2>&1
    wait
    show_message "-" "Completed Successfully." $GREEN $MAIN_COLOR
    wait_for_continue $MAIN_COLOR $FTPCOLOR    
    show_title
    show_menu
}

# Function to install the FTP package
install_pkg() {
    if [ $is_ftp_installed -eq 1 ]; then
        show_message "!" "FTP Service Is Already Installed.\n" $YELLOW $MAIN_COLOR
    else
        manage_pkg "install" "Downloading FTP Package (vsftpd)..." "yum install -y vsftpd"
    fi
}

# Function to remove the FTP package
remove_pkg() {
    if [ $is_ftp_installed -eq 1 ]; then
        show_title
        echo ""
        show_message "!?" "The FTP Service Package (vsftpd) Will Be REMOVED!!" $RED $MAIN_COLOR
        if prompt_confirmation "Is It Okay?" ; then
            manage_pkg "remove" "Removing FTP Service Package..." "yum remove -y vsftpd"
        else
            show_message "!" "Removal canceled." $YELLOW $MAIN_COLOR
            wait_for_continue $MAIN_COLOR $FTPCOLOR   
            show_title
            show_menu
        fi
    else
        show_message "X" "FTP Service Is Not Installed, Cannot Remove.\n" $RED $MAIN_COLOR
    fi
}

# Function to update the FTP package
update_pkg() {
    if [ $is_ftp_installed -eq 1 ]; then
        local is_update_needed=$(yum check-update vsftpd | grep -q 'vsftpd' && echo 1 || echo 0)
        if [ $is_update_needed -eq 1 ]; then
            manage_pkg "update" "Updating FTP Service Package (vsftpd)..." "yum update -y vsftpd"
        else
            show_message "!" "FTP Service Is Already Up To Date..\n" $YELLOW $MAIN_COLOR
        fi
    else
        show_message "X" "FTP Service Is Not Installed, Cannot Update.\n" $RED $MAIN_COLOR
    fi
}

# Function to display the main menu options
show_menu() {
    echo ""
    echo -e " ${MAIN_COLOR}[${FTPCOLOR}1${MAIN_COLOR}]${NOCOLOR} Install FTP"
    echo -e " ${MAIN_COLOR}[${FTPCOLOR}2${MAIN_COLOR}]${NOCOLOR} Remove FTP"
    echo -e " ${MAIN_COLOR}[${FTPCOLOR}3${MAIN_COLOR}]${NOCOLOR} Update FTP"
    echo ""
    echo -e " ${MAIN_COLOR}[${FTPCOLOR}4${MAIN_COLOR}]${NOCOLOR} Exit FTP Installation"
    echo ""
}

# Function to handle user input and navigate the menu
menu() {
    show_title  # Display the title
    show_menu  # Display the menu options
    while true; do
        echo -ne " ${MAIN_COLOR}Enter An Option ${FTPCOLOR}\$${MAIN_COLOR}>:${NOCOLOR} "
        read -r op  # Read user input
        case $op in
            1)
                is_installed  # Check if FTP is installed
                install_pkg  # Install the FTP package
                ;;
            2)
                is_installed  # Check if FTP is installed
                remove_pkg  # Remove the FTP package
                ;;
            3)
                is_installed  # Check if FTP is installed
                update_pkg  # Update the FTP package
                ;;
            4)
                break  # Exit the menu loop
                ;;
            *)
                show_message "X" "Invalid option!" $RED $MAIN_COLOR  # Handle invalid input
                ;;
        esac
    done
    clear 
}

# Main function to start the script
main() {
    menu  # Start the menu function
}

main  # Call the main function
