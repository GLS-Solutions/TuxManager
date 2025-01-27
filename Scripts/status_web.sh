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
    show_banner $HTTPCOLOR $MAIN_COLOR "WEB Service Status"
}

# Function to check the status of the HTTP service
check_status() {
    show_title
    echo ""
    spinner 3 "$(show_message "!" "Checking HTTP service status...   " $YELLOW $MAIN_COLOR)"
    echo ""

    # Get the status of the HTTP service
    HTTPDSTATUS=$(systemctl status httpd)

    # Extract the relevant information from the status
    STATUS=$(systemctl is-active httpd)
    PID=$(echo "$HTTPDSTATUS" | grep -Po "PID: \K[\d]*")
    MEMORY=$(echo "$HTTPDSTATUS" | grep -Po "Memory: \K[\dA-Z.]*")
    CPU=$(echo "$HTTPDSTATUS" | grep -Po "CPU: \K[\da-z.]*")

    # Display the extracted information
    if [[ "$STATUS" == "active" ]]; then
        echo -e "${MAIN_COLOR} Status: ${GREEN}$STATUS"
    else
        echo -e "${MAIN_COLOR} Status: ${RED}$STATUS"
    fi
    echo -e " ${MAIN_COLOR}PID: ${NOCOLOR}$PID"
    echo -e " ${MAIN_COLOR}Memory: ${NOCOLOR}$MEMORY"
    echo -e " ${MAIN_COLOR}CPU: ${NOCOLOR}$CPU"
    echo ""
    wait_for_continue $MAIN_COLOR $HTTPCOLOR
}

# Function to show HTTP access logs
show_logs() {
    show_title
    echo ""
    spinner 3 "$(show_message "!" "Showing HTTP access logs...   " $YELLOW $MAIN_COLOR)"
    echo

    # Extract the last 20 lines from the access log
    log_lines=$(tail -n 20 /var/log/httpd/access_log | tac)

    # echo -e "${MAIN_COLOR}  ----------------------------------------------------------------${NOCOLOR}"
    printf "${MAIN_COLOR} │ ${WHITE}%-15s${MAIN_COLOR} │ ${WHITE}%-20s${MAIN_COLOR} │ ${WHITE}%-7s${MAIN_COLOR} │ ${WHITE}%-30s${MAIN_COLOR}${NOCOLOR}\n" "ADDRESS" "DATE" "METHOD" "URL"
    # echo -e "${MAIN_COLOR}  ----------------------------------------------------------------${NOCOLOR}"
    echo ""

    # Loop through each log line and extract relevant details using regex
    while IFS= read -r line; do
        address=$(echo "$line" | cut -d' ' -f1)  # Extract the IP address
        date=$(echo "$line" | cut -d' ' -f4 | sed 's/\[//g')  # Extract the date and time
        method=$(echo "$line" | cut -d' ' -f6 | sed 's/"//g')  # Extract the HTTP method
        url=$(echo "$line" | cut -d' ' -f11)  # Extract the URL

        # Print the extracted details in a formatted table
        printf "${MAIN_COLOR} │ ${WHITE}%-15s${MAIN_COLOR} │ ${WHITE}%-20s${MAIN_COLOR} │ ${WHITE}%-7s${MAIN_COLOR} │ ${WHITE}%-30s${MAIN_COLOR} ${NOCOLOR}\n" "$address" "$date" "$method" "$url"
        # echo -e "${MAIN_COLOR}  ----------------------------------------------------------------${NOCOLOR}"
    done <<< "$log_lines"

    wait_for_continue $MAIN_COLOR $HTTPCOLOR
}

# Function to navigate through options
main_menu() {
    while true; do
        show_title
        echo ""
        # Display menu options
        echo -e " ${MAIN_COLOR}[${HTTPCOLOR}1${MAIN_COLOR}]${NOCOLOR} Check HTTP Service Status"
        echo -e " ${MAIN_COLOR}[${HTTPCOLOR}2${MAIN_COLOR}]${NOCOLOR} Show HTTP Access Logs"
        echo ""
        echo -e " ${MAIN_COLOR}[${HTTPCOLOR}3${MAIN_COLOR}]${NOCOLOR} Exit HTTP Monitoring"
        echo ""
        echo -ne " ${MAIN_COLOR}Enter an option ${HTTPCOLOR}\$${MAIN_COLOR}>:${NOCOLOR} "
        read -r op # Read user input
        case $op in
            1) check_status ;; # Display HTTP service status
            2) show_logs ;; # Show HTTP logs
            3) break ;; # Exit the menu loop
            *) show_message "X" "Invalid option." $RED $MAIN_COLOR;; # Handle invalid input
        esac
    done
}

main_menu # Start the main menu
