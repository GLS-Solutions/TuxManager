#!/bin/bash

# Utility functions for styling and progress display
source Utils/styling.sh
source Utils/progress.sh

readonly FTP_CONFIG="/etc/vsftpd/vsftpd.conf"
CHROOT_LIST_FILE=""

show_title() {
    show_banner "${FTPCOLOR}" "${MAIN_COLOR}" "FTP Service Configuration"
}

show_vsftpd_menu() {
    show_title
    echo -e "\t\t\t\t\t ${FTPCOLOR}CURRENT CONFIG:${NOCOLOR}"
    echo -e " ${MAIN_COLOR}[${FTPCOLOR}1${MAIN_COLOR}]${NOCOLOR} Anonymous Enable \t\t\t [${FTPCOLOR}$(grep -E '^anonymous_enable=' $FTP_CONFIG | cut -d= -f2)${NOCOLOR}]"
    echo -e " ${MAIN_COLOR}[${FTPCOLOR}2${MAIN_COLOR}]${NOCOLOR} FTPD Banner \t\t\t [${FTPCOLOR}$(grep -E '^ftpd_banner=' $FTP_CONFIG | cut -d= -f2-)${NOCOLOR}]"
    echo -e " ${MAIN_COLOR}[${FTPCOLOR}3${MAIN_COLOR}]${NOCOLOR} Chroot Local User \t\t\t [${FTPCOLOR}$(grep -E '^chroot_local_user=' $FTP_CONFIG | cut -d= -f2)${NOCOLOR}]"
    echo -e " ${MAIN_COLOR}[${FTPCOLOR}4${MAIN_COLOR}]${NOCOLOR} Chroot List Enable \t\t [${FTPCOLOR}$(grep -E '^chroot_list_enable=' $FTP_CONFIG | cut -d= -f2)${NOCOLOR}]"
    echo -e " ${MAIN_COLOR}[${FTPCOLOR}5${MAIN_COLOR}]${NOCOLOR} Allow Writeable Chroot \t\t [${FTPCOLOR}$(grep -E '^allow_writeable_chroot=' $FTP_CONFIG | cut -d= -f2)${NOCOLOR}]"
    echo -e " ${MAIN_COLOR}[${FTPCOLOR}6${MAIN_COLOR}]${NOCOLOR} Chroot List File \t\t\t [${FTPCOLOR}$(grep -E '^chroot_list_file=' $FTP_CONFIG | cut -d= -f2)${NOCOLOR}]"
    echo -e " ${MAIN_COLOR}[${FTPCOLOR}7${MAIN_COLOR}]${NOCOLOR} LS Recurse Enable \t\t\t [${FTPCOLOR}$(grep -E '^ls_recurse_enable=' $FTP_CONFIG | cut -d= -f2)${NOCOLOR}]"
    echo -e " ${MAIN_COLOR}[${FTPCOLOR}8${MAIN_COLOR}]${NOCOLOR} Listen \t\t\t\t [${FTPCOLOR}$(grep -E '^listen=' $FTP_CONFIG | cut -d= -f2)${NOCOLOR}]"
    echo -e " ${MAIN_COLOR}[${FTPCOLOR}9${MAIN_COLOR}]${NOCOLOR} Listen IPv6 \t\t\t [${FTPCOLOR}$(grep -E '^listen_ipv6=' $FTP_CONFIG | cut -d= -f2)${NOCOLOR}]"
    echo -e " ${MAIN_COLOR}[${FTPCOLOR}10${MAIN_COLOR}]${NOCOLOR} Use Localtime \t\t\t [${FTPCOLOR}$(grep -E '^use_localtime=' $FTP_CONFIG | cut -d= -f2)${NOCOLOR}]"
    echo -e " ${MAIN_COLOR}[${FTPCOLOR}11${MAIN_COLOR}]${NOCOLOR} Add User to Chroot List"
    echo -e " ${MAIN_COLOR}[${FTPCOLOR}12${MAIN_COLOR}]${NOCOLOR} Remove User from Chroot List"
    echo -e " ${MAIN_COLOR}[${FTPCOLOR}13${MAIN_COLOR}]${NOCOLOR} Go Back"
    echo ""
}

update_chroot_list_file() {
    CHROOT_LIST_FILE=$(grep -E '^chroot_list_file=' $FTP_CONFIG | cut -d= -f2)
}

handle_vsftpd_option() {
    while true; do
        show_vsftpd_menu
        echo -ne " ${MAIN_COLOR}Enter An Option ${TUXCOLOR}\$${MAIN_COLOR}>: ${NOCOLOR}"
        read -r op
        case $op in
            1)  # Anonymous Enable
                value=$(grep -E '^anonymous_enable=' $FTP_CONFIG | cut -d= -f2)
                if [ "$value" == "YES" ]; then
                    sed -i 's/^anonymous_enable=YES/anonymous_enable=NO/' $FTP_CONFIG
                    show_message "!" "Anonymous Enable has been set to NO." $YELLOW $MAIN_COLOR
                    clear
                else
                    sed -i 's/^anonymous_enable=NO/anonymous_enable=YES/' $FTP_CONFIG
                    show_message "!" "Anonymous Enable has been set to YES." $YELLOW $MAIN_COLOR
                    clear
                fi
                ;;
            2)  # FTPD Banner
                echo "Enter new FTPD Banner:"
                read new_banner
                sed -i "s/^ftpd_banner=.*/ftpd_banner=$new_banner/" $FTP_CONFIG
                show_message "!" "FTPD Banner has been updated." $YELLOW $MAIN_COLOR
                clear
                ;;
            3)  # Chroot Local User
                value=$(grep -E '^chroot_local_user=' $FTP_CONFIG | cut -d= -f2)
                if [ "$value" == "YES" ]; then
                    sed -i 's/^chroot_local_user=YES/chroot_local_user=NO/' $FTP_CONFIG
                    show_message "!" "Chroot Local User has been set to NO." $YELLOW $MAIN_COLOR
                    clear
                else
                    sed -i 's/^chroot_local_user=NO/chroot_local_user=YES/' $FTP_CONFIG
                    show_message "!" "Chroot Local User has been set to YES." $YELLOW $MAIN_COLOR
                    clear
                fi
                ;;
            4)  # Chroot List Enable
                value=$(grep -E '^chroot_list_enable=' $FTP_CONFIG | cut -d= -f2)
                if [ "$value" == "YES" ]; then
                    sed -i 's/^chroot_list_enable=YES/chroot_list_enable=NO/' $FTP_CONFIG
                    show_message "!" "Chroot List Enable has been set to NO." $YELLOW $MAIN_COLOR
                    clear
                else
                    sed -i 's/^chroot_list_enable=NO/chroot_list_enable=YES/' $FTP_CONFIG
                    show_message "!" "Chroot List Enable has been set to YES." $YELLOW $MAIN_COLOR
                    clear
                fi
                ;;
            5)  # Allow Writeable Chroot
                value=$(grep -E '^allow_writeable_chroot=' $FTP_CONFIG | cut -d= -f2)
                if [ "$value" == "YES" ]; then
                    sed -i 's/^allow_writeable_chroot=YES/allow_writeable_chroot=NO/' $FTP_CONFIG
                    show_message "!" "Allow Writeable Chroot has been set to NO." $YELLOW $MAIN_COLOR
                    clear
                else
                    sed -i 's/^allow_writeable_chroot=NO/allow_writeable_chroot=YES/' $FTP_CONFIG
                    show_message "!" "Allow Writeable Chroot has been set to YES." $YELLOW $MAIN_COLOR
                    clear
                fi
                ;;
            6)  # Chroot List File
                echo "Enter new Chroot List File path:"
                read new_chroot_list_file
                sed -i "s|^chroot_list_file=.*|chroot_list_file=$new_chroot_list_file|" $FTP_CONFIG
                update_chroot_list_file
                show_message "!" "Chroot List File path has been updated." $YELLOW $MAIN_COLOR
                clear
                ;;
            7)  # LS Recurse Enable
                value=$(grep -E '^ls_recurse_enable=' $FTP_CONFIG | cut -d= -f2)
                if [ "$value" == "YES" ]; then
                    sed -i 's/^ls_recurse_enable=YES/ls_recurse_enable=NO/' $FTP_CONFIG
                    show_message "!" "LS Recurse Enable has been set to NO." $YELLOW $MAIN_COLOR
                    clear
                else
                    sed -i 's/^ls_recurse_enable=NO/ls_recurse_enable=YES/' $FTP_CONFIG
                    show_message "!" "LS Recurse Enable has been set to YES." $YELLOW $MAIN_COLOR
                    clear
                fi
                ;;
            8)  # Listen
                value=$(grep -E '^listen=' $FTP_CONFIG | cut -d= -f2)
                if [ "$value" == "YES" ]; then
                    sed -i 's/^listen=YES/listen=NO/' $FTP_CONFIG
                    show_message "!" "Listen has been set to NO." $YELLOW $MAIN_COLOR
                    clear
                else
                    sed -i 's/^listen=NO/listen=YES/' $FTP_CONFIG
                    show_message "!" "Listen has been set to YES." $YELLOW $MAIN_COLOR
                    clear
                fi
                ;;
            9)  # Listen IPv6
                value=$(grep -E '^listen_ipv6=' $FTP_CONFIG | cut -d= -f2)
                if [ "$value" == "YES" ]; then
                    sed -i 's/^listen_ipv6=YES/listen_ipv6=NO/' $FTP_CONFIG
                    show_message "!" "Listen IPv6 has been set to NO." $YELLOW $MAIN_COLOR
                    clear
                else
                    sed -i 's/^listen_ipv6=NO/listen_ipv6=YES/' $FTP_CONFIG
                    show_message "!" "Listen IPv6 has been set to YES." $YELLOW $MAIN_COLOR
                    clear
                fi
                ;;
            10)  # Use Localtime
                value=$(grep -E '^use_localtime=' $FTP_CONFIG | cut -d= -f2)
                if [ "$value" == "YES" ]; then
                    sed -i 's/^use_localtime=YES/use_localtime=NO/' $FTP_CONFIG
                    show_message "!" "Use Localtime has been set to NO." $YELLOW $MAIN_COLOR
                    clear
                else
                    sed -i 's/^use_localtime=NO/use_localtime=YES/' $FTP_CONFIG
                    show_message "!" "Use Localtime has been set to YES." $YELLOW $MAIN_COLOR
                    clear
                fi
                ;;
            11)  # Add User to Chroot List
                update_chroot_list_file
                echo "Enter the username to add to the chroot list:"
                read username
                if [[ -n "$CHROOT_LIST_FILE" ]]; then
                    echo "$username" >> "$CHROOT_LIST_FILE"
                    show_message "!" "User $username has been added to the chroot list." $YELLOW $MAIN_COLOR
                    clear
                else
                    show_message "!" "Chroot list file path is not set." $RED $MAIN_COLOR
                    clear
                fi
                ;;
            12)  # Remove User from Chroot List
                update_chroot_list_file
                echo "Enter the username to remove from the chroot list:"
                read username
                if [[ -n "$CHROOT_LIST_FILE" ]]; then
                    sed -i "/^$username$/d" "$CHROOT_LIST_FILE"
                    show_message "!" "User $username has been removed from the chroot list." $YELLOW $MAIN_COLOR
                    clear
                else
                    show_message "!" "Chroot list file path is not set." $RED $MAIN_COLOR
                    clear
                fi
                ;;
            13)  # Go Back
                break
                ;;
            *)  # Invalid option
                show_message "!" "Invalid option." $RED $MAIN_COLOR
                ;;
        esac
    done
}

update_chroot_list_file

# Main menu loop
handle_vsftpd_option
