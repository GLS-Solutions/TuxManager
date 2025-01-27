#!/bin/bash

if [ "$SCRIPT_ALLOWED" != "true" ]; then
    echo -e " \033[38;5;69m[\033[38;5;88mX\033[38;5;69m]\033[38;5;88m This script must be sourced from the main script 'tuxmanager.sh' .\033[0m"
    exit 1
fi

# Source utility scripts for additional functionality
source Utils/styling.sh
source Utils/progress.sh
source Utils/validate.sh

# Initialize the FTP service status flag
is_started=0

# Function to show the title banner
show_title() {
    clear
    show_banner $FTPCOLOR $MAIN_COLOR "FTP Service Management"
}

# Function to check if the FTP service is active
is_ftp_started(){
    is_started=$(systemctl is-active vsftpd | grep -Po "^active" | grep -q ac && echo 1 || echo 0)
}

check_ftp_status() {
    echo ""
    spinner 3 "$(show_message "!" "Checking FTP status...   " $YELLOW $MAIN_COLOR)"
    show_message "!" "Done...\n" $GREEN
    sleep 3
    clear
    show_title
    is_ftp_started
}

# Function to display detailed error logs if FTP service fails
show_error_details() {
    # Fetch the FTP error log
    error_log=$(journalctl -xeu vsftpd.service | tac)
    # Find the start of the relevant error details
    error_start=$(echo "$error_log" | grep -n "Starting vsftpd FTP server" | head -n 1 | cut -d: -f1)
    # Get the log line containing the error
    log_line=$(echo "$error_log" | grep "Starting vsftpd FTP server" | head -n 1)

    # Extract details from the error log line
    IFS=' ' read -r mont day time _ pid_part _ <<< "$log_line"

    # Trim the log to relevant error details
    if [ -n "$error_start" ]; then
        error_log=$(echo "$error_log" | head -n +$((error_start-1)) | tac)
    fi
    pid="$(echo "$pid_part" | grep -oP 'vsftpd\[\K[0-9]+(?=\])')"

    clear
    show_title
    echo ""
    show_message "X" "Failed to manage FTP. Check details below." $RED $MAIN_COLOR

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
    show_message "!" "Recommendation: Check the vsftpd configuration files." $BLUE $MAIN_COLOR
    show_message "!" "Recommendation: Check the server logs for more details." $BLUE $MAIN_COLOR
    show_message "!" "Recommendation: Ensure all necessary modules are enabled." $BLUE $MAIN_COLOR
}

# Function to validate and start the FTP service
validate_start(){
    clear
    show_title
    check_ftp_status
    if [ $is_started -eq 1 ]; then
        echo ""
        show_message "!" "FTP is already running." $YELLOW $MAIN_COLOR
        wait_for_continue $MAIN_COLOR $FTPCOLOR
    else
        if prompt_confirmation "Are you sure you want to start the FTP service?"; then
            echo ""
            show_message "!" "Starting FTP service..." $YELLOW $MAIN_COLOR
            systemctl start vsftpd > /dev/null 2>&1
            progress_bar 5 $YELLOW $MAIN_COLOR
            is_ftp_started
            sleep 2
            if [ $is_started -eq 1 ]; then
                show_message "-" "FTP service started successfully." $GREEN $MAIN_COLOR
                systemctl enable vsftpd > /dev/null 2>&1
            else
                show_message "X" "Failed to start FTP." $RED $MAIN_COLOR
                sleep 1
                show_error_details 
            fi
            wait_for_continue $MAIN_COLOR $FTPCOLOR
        else
            show_message "!" "FTP service start aborted." $YELLOW $MAIN_COLOR
            sleep 3
        fi
    fi
}

# Function to validate and restart the FTP service
validate_restart(){
    clear
    show_title
    check_ftp_status
    if [ $is_started -eq 0 ]; then
        echo ""
        show_message "!" "FTP service is not running. Would you like to start it instead?" $YELLOW $MAIN_COLOR
        if prompt_confirmation "Start FTP?"; then
            validate_start
        else
            show_message "!" "FTP service start aborted." $YELLOW $MAIN_COLOR
            sleep 3
        fi
    else
        if prompt_confirmation "Are you sure you want to restart the FTP service?"; then
            echo ""
            show_message "!" "Restarting FTP service..." $YELLOW $MAIN_COLOR
            systemctl restart vsftpd > /dev/null 2>&1
            progress_bar 5 $YELLOW $MAIN_COLOR
            is_ftp_started
            sleep 2
            if [ $is_started -eq 1 ]; then
                show_message "-" "FTP service restarted successfully." $GREEN $MAIN_COLOR
            else
                show_message "X" "Failed to restart FTP." $RED $MAIN_COLOR
                sleep 1
                show_error_details 
            fi
            wait_for_continue $MAIN_COLOR $FTPCOLOR
        else
            show_message "!" "FTP service restart aborted." $YELLOW $MAIN_COLOR
            sleep 3
        fi
    fi
}

# Function to validate and stop the FTP service
validate_stop(){
    clear
    show_title
    check_ftp_status
    if [ $is_started -eq 0 ]; then
        echo ""
        show_message "!" "FTP service is already stopped." $YELLOW $MAIN_COLOR
        wait_for_continue $MAIN_COLOR $FTPCOLOR
    else
        if prompt_confirmation "Are you sure you want to stop the FTP service?"; then
            echo ""
            show_message "!" "Stopping FTP service..." $YELLOW $MAIN_COLOR
            systemctl stop vsftpd > /dev/null 2>&1
            progress_bar 5 $YELLOW $MAIN_COLOR
            is_ftp_started
            sleep 2
            if [ $is_started -eq 0 ]; then
                show_message "-" "FTP service stopped successfully." $GREEN $MAIN_COLOR
                systemctl disable vsftpd > /dev/null 2>&1
            else
                show_message "X" "Failed to stop FTP." $RED $MAIN_COLOR
                sleep 1
                show_error_details 
            fi
            wait_for_continue $MAIN_COLOR $FTPCOLOR
        else
            show_message "!" "FTP service stop aborted." $YELLOW $MAIN_COLOR
            sleep 3
        fi
    fi
}

# Function to display the FTP management menu
menu_ftp_man() {
    show_title $FTPCOLOR
    echo -ne "\n ${MAIN_COLOR}[${FTPCOLOR}1${MAIN_COLOR}]${NOCOLOR} Start FTP service"
    echo -ne "\n ${MAIN_COLOR}[${FTPCOLOR}2${MAIN_COLOR}]${NOCOLOR} Restart FTP service"
    echo -ne "\n ${MAIN_COLOR}[${FTPCOLOR}3${MAIN_COLOR}]${NOCOLOR} Stop FTP service"
    echo -e "\n ${MAIN_COLOR}[${FTPCOLOR}4${MAIN_COLOR}]${NOCOLOR} Go Back"
    echo ""
}

# Function to handle the FTP menu interaction
menu_ftp() {
    menu_ftp_man
    while true; do
        echo -ne "${MAIN_COLOR} Enter An Option${FTPCOLOR}\$${MAIN_COLOR}>:${NOCOLOR} "
        read -r op
        case $op in
            1)
                # FTP start
                validate_start
                menu_ftp_man
                ;;
            2)
                # FTP restart
                validate_restart
                menu_ftp_man
                ;;
            3)
                # FTP stop
                validate_stop
                menu_ftp_man
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
    menu_ftp
}

# Execute the main function
main
