#!/bin/bash

if [ "$SCRIPT_ALLOWED" != "true" ]; then
    echo -e " \033[38;5;69m[\033[38;5;88mX\033[38;5;69m]\033[38;5;88m This script must be sourced from the main script 'tuxmanager.sh' .\033[0m"
    exit 1
fi

# Source utility scripts for additional functionality
source Utils/styling.sh
source Utils/progress.sh
source Utils/validate.sh

# Initialize the HTTP service status flag
is_started=0

# Function to show the title banner
show_title() {
    clear
    show_banner $HTTPCOLOR $MAIN_COLOR "HTTP Service Management"
}

# Function to check if the HTTP service is active
is_http_started(){
    is_started=$(systemctl is-active httpd | grep -Po "^active" | grep -q ac && echo 1 || echo 0)
}

check_http_status() {
    echo ""
    spinner 3 "$(show_message "!" "Checking HTTP status...   " $YELLOW $MAIN_COLOR)"
    show_message "!" "Done...\n" $GREEN
    sleep 3
    clear
    show_title
    is_http_started
}

# Function to display detailed error logs if HTTP service fails
show_error_details() {
    # Fetch the HTTP error log
    error_log=$(journalctl -xeu httpd.service | tac)
    # Find the start of the relevant error details
    error_start=$(echo "$error_log" | grep -n "Starting The Apache HTTP Server" | head -n 1 | cut -d: -f1)
    # Get the log line containing the error
    log_line=$(echo "$error_log" | grep "Starting The Apache HTTP Server" | head -n 1)

    # Extract details from the error log line
    IFS=' ' read -r mont day time _ pid_part _ <<< "$log_line"

    # Trim the log to relevant error details
    if [ -n "$error_start" ]; then
        error_log=$(echo "$error_log" | head -n +$((error_start-1)) | tac)
    fi
    pid="$(echo "$pid_part" | grep -oP 'httpd\[\K[0-9]+(?=\])')"

    clear
    show_title
    echo ""
    show_message "X" "Failed to manage HTTP. Check details below." $RED $MAIN_COLOR

    echo ""
    echo -e " ${MAIN_COLOR}Date: ${NOCOLOR}$day $mont, $time"
    echo -e " ${MAIN_COLOR}PID: ${NOCOLOR}${pid}"
    echo -e " ${MAIN_COLOR}Details: ${NOCOLOR}\n"

    # Display the trimmed error log
    while IFS= read -r line; do
        out_line=$(echo "$line" | grep -oP '\]\s*\K.*')
        if [[ "$out_line" =~ [[:alnum:]] ]]; then
            echo -e " ${NOCOLOR}$out_line"
        fi
    done <<< "$error_log"

    echo "" 
    # Provide recommendations to the user
    show_message "!" "Recommendation: Check the Apache configuration files." $BLUE $MAIN_COLOR
    show_message "!" "Recommendation: Check the server logs for more details." $BLUE $MAIN_COLOR
    show_message "!" "Recommendation: Ensure all necessary modules are enabled." $BLUE $MAIN_COLOR
}

# Function to validate and start the HTTP service
validate_start(){
    clear
    show_title
    check_http_status
    if [ $is_started -eq 1 ]; then
        echo ""
        show_message "!" "HTTP is already running." $YELLOW $MAIN_COLOR
        wait_for_continue $MAIN_COLOR $HTTPCOLOR
    else
        if prompt_confirmation "Are you sure you want to start the HTTP service?"; then
            echo ""
            show_message "!" "Starting HTTP service..." $YELLOW $MAIN_COLOR
            systemctl start httpd > /dev/null 2>&1
            progress_bar 5 $YELLOW $MAIN_COLOR
            is_http_started
            sleep 2
            if [ $is_started -eq 1 ]; then
                show_message "-" "HTTP service started successfully." $GREEN $MAIN_COLOR
                systemctl enable dhcpd > /dev/null 2>&1
            else
                show_message "X" "Failed to start HTTP." $RED $MAIN_COLOR
                sleep 1
                show_error_details 
            fi
            wait_for_continue $MAIN_COLOR $HTTPCOLOR
        else
            show_message "!" "HTTP service start aborted." $YELLOW $MAIN_COLOR
            sleep 3
        fi
    fi
}

# Function to validate and restart the HTTP service
validate_restart(){
    clear
    show_title
    check_http_status
    if [ $is_started -eq 0 ]; then
        echo ""
        show_message "!" "HTTP service is not running. Would you like to start it instead?" $YELLOW $MAIN_COLOR
        if prompt_confirmation "Start HTTP?"; then
            validate_start
        else
            show_message "!" "HTTP service start aborted." $YELLOW $MAIN_COLOR
            sleep 3
        fi
    else
        if prompt_confirmation "Are you sure you want to restart the HTTP service?"; then
            echo ""
            show_message "!" "Restarting HTTP service..." $YELLOW $MAIN_COLOR
            systemctl restart httpd > /dev/null 2>&1
            progress_bar 5 $YELLOW $MAIN_COLOR
            is_http_started
            sleep 2
            if [ $is_started -eq 1 ]; then
                show_message "-" "HTTP service restarted successfully." $GREEN $MAIN_COLOR
            else
                show_message "X" "Failed to restart HTTP." $RED $MAIN_COLOR
                sleep 1
                show_error_details 
            fi
            wait_for_continue $MAIN_COLOR $HTTPCOLOR
        else
            show_message "!" "HTTP service restart aborted." $YELLOW $MAIN_COLOR
            sleep 3
        fi
    fi
}

# Function to validate and stop the HTTP service
validate_stop(){
    clear
    show_title
    check_http_status
    if [ $is_started -eq 0 ]; then
        echo ""
        show_message "!" "HTTP service is already stopped." $YELLOW $MAIN_COLOR
        wait_for_continue $MAIN_COLOR $HTTPCOLOR
    else
        if prompt_confirmation "Are you sure you want to stop the HTTP service?"; then
            echo ""
            show_message "!" "Stopping HTTP service..." $YELLOW $MAIN_COLOR
            systemctl stop httpd > /dev/null 2>&1
            progress_bar 5 $YELLOW $MAIN_COLOR
            is_http_started
            sleep 2
            if [ $is_started -eq 0 ]; then
                show_message "-" "HTTP service stopped successfully." $GREEN $MAIN_COLOR
                systemctl disable httpd > /dev/null 2>&1
            else
                show_message "X" "Failed to stop HTTP." $RED $MAIN_COLOR
                sleep 1
                show_error_details 
            fi
            wait_for_continue $MAIN_COLOR $HTTPCOLOR
        else
            show_message "!" "HTTP service stop aborted." $YELLOW $MAIN_COLOR
            sleep 3
        fi
    fi
}

# Function to display the HTTP management menu
menu_http_man() {
    show_title $HTTPCOLOR
    echo -ne "\n ${MAIN_COLOR}[${HTTPCOLOR}1${MAIN_COLOR}]${NOCOLOR} Start HTTP service"
    echo -ne "\n ${MAIN_COLOR}[${HTTPCOLOR}2${MAIN_COLOR}]${NOCOLOR} Restart HTTP service"
    echo -ne "\n ${MAIN_COLOR}[${HTTPCOLOR}3${MAIN_COLOR}]${NOCOLOR} Stop HTTP service"
    echo -e "\n ${MAIN_COLOR}[${HTTPCOLOR}4${MAIN_COLOR}]${NOCOLOR} Go Back"
    echo ""
}

# Function to handle the HTTP menu interaction
menu_http() {
    menu_http_man
    while true; do
        echo -ne "${MAIN_COLOR} Enter An Option${HTTPCOLOR}\$${MAIN_COLOR}>:${NOCOLOR} "
        read -r op
        case $op in
            1)
                # HTTP start
                validate_start
                menu_http_man
                ;;
            2)
                # HTTP restart
                validate_restart
                menu_http_man
                ;;
            3)
                # HTTP stop
                validate_stop
                menu_http_man
                ;;
            4)
                # Go back to main menu
                break
                ;;
            *)
                # Invalid option
                show_message "X" "Invalid option." $RED $MAIN_COLOR
                ;;
        esac
    done
}

# Main function to start the script
main() {
    menu_http
}

# Execute the main function
main
