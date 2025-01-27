#!/bin/bash

if [ "$SCRIPT_ALLOWED" != "true" ]; then
    echo -e " \033[38;5;69m[\033[38;5;88mX\033[38;5;69m]\033[38;5;88m This script must be sourced from the main script 'tuxmanager.sh' .\033[0m"
    exit 1
fi

# UTILS: Source utility scripts for additional functionality
source Utils/styling.sh
source Utils/progress.sh

show_title() {
    clear
    show_banner $FTPCOLOR $MAIN_COLOR "FTP Service Status"
}

# Function to check the status of the FTP service
check_status() {
    show_title
    echo ""
    spinner 3 "$(show_message "!" "Checking FTP service status...   " $YELLOW $MAIN_COLOR)"
    echo ""

    # Get the status of the FTP service
    FTPDSTATUS=$(systemctl status vsftpd)

    # Extract the relevant information from the status
    STATUS=$(systemctl is-active vsftpd)
    PID=$(echo "$FTPDSTATUS" | grep -Po "PID: \K[\d]*")
    MEMORY=$(echo "$FTPDSTATUS" | grep -Po "Memory: \K[\dA-Z.]*")
    CPU=$(echo "$FTPDSTATUS" | grep -Po "CPU: \K[\da-z.]*")

    # Display the extracted information
    if [[ "$STATUS" == "active" ]]; then
        echo -e "${MAIN_COLOR} Status: ${GREEN}$STATUS"
    else
        echo -e "${MAIN_COLOR} Status: ${RED}$STATUS"
    fi
    echo -e " ${MAIN_COLOR}PID: ${NOCOLOR}$PID"
    echo -e " ${MAIN_COLOR}Memory: ${NOCOLOR}$MEMORY"
    echo -e " ${MAIN_COLOR}CPU: ${NOCOLOR}$CPU"
    wait_for_continue $MAIN_COLOR $FTPCOLOR
}
    
# Function to show FTP logs
show_logs() {
    show_title
    echo ""
    spinner 3 "$(show_message "!" "Showing FTP logs...   " $YELLOW $MAIN_COLOR)"
    echo 
    # Extract and display logs from the vsftpd log file
    LOGFILE="/var/log/vsftpd.log"
    if [ -f "$LOGFILE" ]; then
        tail -n 50 "$LOGFILE"
    else
        show_message "X" "No FTP logs found." $RED $MAIN_COLOR
    fi

    wait_for_continue $MAIN_COLOR $FTPCOLOR
}

# Function to navigate through options
main_menu() {
    while [ true ]; do
        show_title # Display the title
        echo ""
        # Display menu options
        echo -e " ${MAIN_COLOR}[${FTPCOLOR}1${MAIN_COLOR}]${NOCOLOR} Check FTP Service Status"
        echo -e " ${MAIN_COLOR}[${FTPCOLOR}2${MAIN_COLOR}]${NOCOLOR} Show FTP Logs"
        echo ""
        echo -e " ${MAIN_COLOR}[${FTPCOLOR}3${MAIN_COLOR}]${NOCOLOR} Exit FTP Monitoring"
        echo ""
        echo -ne " ${MAIN_COLOR}Enter an option ${FTPCOLOR}\$${MAIN_COLOR}>:${NOCOLOR} "
        read -r op # Read user input
        case $op in
            1) check_status ;; # Display FTP service status
            2) show_logs ;; # Show FTP logs
            3) break ;; # Exit the menu loop
            *) show_message "X" "Invalid option." $RED $MAIN_COLOR;; # Handle invalid input
        esac
    done
}

main_menu # Start the main menu
