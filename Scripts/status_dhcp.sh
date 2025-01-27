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
    show_banner $DHCPCOLOR $MAIN_COLOR "DHCP Service Status"
}

# Function to check the status of the DHCP service
check_status() {
    show_title
    echo ""
    spinner 3 "$(show_message "!" "Checking DHCP service status...   " $YELLOW $MAIN_COLOR)"
    echo ""

    # Get the status of the DHCP service
    DHCPDSTATUS=$(systemctl status dhcpd)

    # Extract the relevant information from the status
    STATUS=$(systemctl is-active dhcpd)
    PID=$(echo "$DHCPDSTATUS" | grep -Po "PID: \K[\d]*")
    MEMORY=$(echo "$DHCPDSTATUS" | grep -Po "Memory: \K[\dA-Z.]*")
    CPU=$(echo "$DHCPDSTATUS" | grep -Po "CPU: \K[\da-z.]*")

    # Display the extracted information
    if [[ "$STATUS" == "active" ]]; then
        echo -e "${MAIN_COLOR} Status: ${GREEN}$STATUS"
    else
        echo -e "${MAIN_COLOR} Status: ${RED}$STATUS"
    fi
    echo -e " ${MAIN_COLOR}PID: ${NOCOLOR}$PID"
    echo -e " ${MAIN_COLOR}Memory: ${NOCOLOR}$MEMORY"
    echo -e " ${MAIN_COLOR}CPU: ${NOCOLOR}$CPU"
    wait_for_continue $MAIN_COLOR $DHCPCOLOR
}
    
# Function to show DHCP leases log
show_logs() {
    show_title
    echo ""
    spinner 3 "$(show_message "!" "Showing DHCP leases log...   " $YELLOW $MAIN_COLOR)"
    echo 
    # Extract and sort unique hostnames, IP addresses, and MAC addresses from the DHCP leases file
    HOSTNAMES=$(grep -Po "client-hostname \K[\d:a-zA-Z^\"]*" /var/lib/dhcpd/dhcpd.leases | sed 's/"//g' | sort | uniq)
    ADDRESSES=$(grep -Po "lease \K[\d.]*" /var/lib/dhcpd/dhcpd.leases | sort | uniq)
    MACS=$(grep -Po "ethernet \K[\d:a-fA-F]*" /var/lib/dhcpd/dhcpd.leases | sort | uniq)

    # Display the log in a formatted table
    echo -e "${MAIN_COLOR}  --------------------------------------------------${NOCOLOR}"
    printf "${MAIN_COLOR} │ ${WHITE}%-10s${MAIN_COLOR} │ ${WHITE}%-15s${MAIN_COLOR} │ ${WHITE}%-17s${MAIN_COLOR} │${NOCOLOR}\n" "HOSTNAME" "ADDRESS" "MAC"
    echo -e "${MAIN_COLOR}  --------------------------------------------------${NOCOLOR}"
    
    # Loop through each entry and display it in the table
    for i in $(seq 1 $(echo "$HOSTNAMES" | wc -l)); do
        HOSTNAME=$(echo "$HOSTNAMES" | sed -n "${i}p")
        ADDRESS=$(echo "$ADDRESSES" | sed -n "${i}p")
        MAC=$(echo "$MACS" | sed -n "${i}p")
        printf "${MAIN_COLOR} │ ${WHITE}%-10s${MAIN_COLOR} │ ${WHITE}%-15s${MAIN_COLOR} │ ${WHITE}%-17s${MAIN_COLOR} │${NOCOLOR}\n" "$HOSTNAME" "$ADDRESS" "$MAC"
        echo -e "${MAIN_COLOR}  --------------------------------------------------${NOCOLOR}"
    done

    wait_for_continue $MAIN_COLOR $DHCPCOLOR
}

#Function to navigate through options
main_menu() {
    while [ true ]; do
        show_title #Display the title
        echo ""
        #Display menu options
        echo -e " ${MAIN_COLOR}[${DHCPCOLOR}1${MAIN_COLOR}]${NOCOLOR} Check DHCP Service Status"
        echo -e " ${MAIN_COLOR}[${DHCPCOLOR}2${MAIN_COLOR}]${NOCOLOR} Show DHCP Leases Logs"
        echo ""
        echo -e " ${MAIN_COLOR}[${DHCPCOLOR}3${MAIN_COLOR}]${NOCOLOR} Exit DHCP Monitoring"
        echo ""
        echo -ne " ${MAIN_COLOR}Enter an option ${DHCPCOLOR}\$${MAIN_COLOR}>:${NOCOLOR} "
        read -r op # Read user input
        case $op in
            1) check_status ;; #Display dhcp service status
            2) show_logs ;; #Show DHCP logs
            3) break ;; # Exit the menu loop
            *) show_message "X" "Invalid option." $RED $MAIN_COLOR;; # Handle invalid input
        esac
    done
}

main_menu # Start the main menu