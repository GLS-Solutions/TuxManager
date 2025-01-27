#!/bin/bash

if [ "$SCRIPT_ALLOWED" != "true" ]; then
    echo -e " \033[38;5;69m[\033[38;5;88mX\033[38;5;69m]\033[38;5;88m This script must be sourced from the main script 'tuxmanager.sh' .\033[0m"
    exit 1
fi

# UTILS: Source utility scripts for additional functionality
source Utils/styling.sh
source Utils/progress.sh
source Utils/validate.sh

# Set the root directory for the HTTPD service
readonly HTTPD_ROOT="/var/www/html"

# FLAGS: Flag to track if configuration has changed
config_changed=0

# Function to show the title banner
show_title() {
    show_banner $HTTPCOLOR $MAIN_COLOR "WEB Service Configuration"
}

# Function to create a new directory
create_directory() {
    clear
    show_title
    while [ true ]; do 
        echo -ne "\n Enter the name of the directory to create: "
        read -r dir_name
        if [ -z "$dir_name" ]; then
            show_message "!" "Cancelled..." $YELLOW $MAIN_COLOR
            sleep 3
            break
        else
            if validate_input_regex "$dir_name" '^[a-zA-Z0-9_-]+$'; then
                if [ -d "$HTTPD_ROOT/$dir_name" ]; then
                    show_message "X" "Directory '$dir_name' already exists." $RED $MAIN_COLOR
                else
                    mkdir -p "$HTTPD_ROOT/$dir_name"
                    show_message "+" "Directory '$dir_name' created successfully." $GREEN $MAIN_COLOR
                    wait_for_continue $MAIN_COLOR $HTTPCOLOR
                    config_changed=1
                    clear
                    break
                fi
            else
                show_message "X" "Invalid directory name." $RED $MAIN_COLOR
            fi
        fi
    done
}

# Function to add a new file
add_file() {
    clear
    show_title
    while [ true ]; do 
        echo -ne "\n Enter the directory to add the file in (${HTTPCOLOR}relative to $HTTPD_ROOT, or leave empty for root${NOCOLOR}): "
        read -r dir_name
        local target_dir="$HTTPD_ROOT/$dir_name"
        if [[ -z "$dir_name" || -d "$target_dir" ]]; then
            echo -ne "\n Enter the name of the file to create (${HTTPCOLOR}e.g., index.html, style.css${NOCOLOR}): "
            read -r file_name
            if [ -z "$file_name" ]; then
                show_message "!" "Cancelled..." $YELLOW $MAIN_COLOR
                sleep 3
                break
            elif validate_input_regex "$file_name" '^[a-zA-Z0-9_-]+\.[a-zA-Z0-9]+$'; then
                if [ -f "$target_dir/$file_name" ]; then
                    show_message "X" "File '$file_name' already exists in '$target_dir'." $RED $MAIN_COLOR
                else
                    touch "$target_dir/$file_name"
                    show_message "+" "File '$file_name' created successfully in '$target_dir'." $GREEN $MAIN_COLOR
                    wait_for_continue $MAIN_COLOR $HTTPCOLOR
                    config_changed=1
                    clear
                    break
                fi
            else
                show_message "X" "Invalid file name." $RED $MAIN_COLOR
            fi
        else
            show_message "X" "Directory '$dir_name' does not exist." $RED $MAIN_COLOR
        fi
    done
}

# Function to edit an existing file
edit_file() {
    clear
    show_title
    while [ true ]; do 
        echo -ne "\n Enter the name of the file to edit (${HTTPCOLOR}relative to $HTTPD_ROOT${NOCOLOR}): "
        read -r file_name
        if [ -z "$file_name" ]; then
            show_message "!" "Cancelled..." $YELLOW $MAIN_COLOR
            sleep 3
            break
        fi
        local target_file="$HTTPD_ROOT/$file_name"
        if [[ -f "$target_file" ]]; then
            nano "$target_file"
            show_message "+" "File '$file_name' edited successfully." $GREEN $MAIN_COLOR
            wait_for_continue $MAIN_COLOR $HTTPCOLOR
            config_changed=1
            clear
            break
        else
            show_message "X" "File '$file_name' does not exist." $RED $MAIN_COLOR
        fi
    done
}

# Function to view the content of an existing file
view_file_content() {
    clear
    show_title
    while [ true ]; do 
        echo -ne "\n Enter the name of the file to view (${HTTPCOLOR}relative to $HTTPD_ROOT${NOCOLOR}): "
        read -r file_name
        if [ -z "$file_name" ]; then
            show_message "!" "Cancelled..." $YELLOW $MAIN_COLOR
            sleep 3
            break
        fi
        local target_file="$HTTPD_ROOT/$file_name"
        if [[ -f "$target_file" ]]; then
            echo -e "\n${YELLOW}Content of '$file_name':${NOCOLOR}"
            cat "$target_file"
            wait_for_continue $MAIN_COLOR $HTTPCOLOR
            break
        else
            show_message "X" "File '$file_name' does not exist." $RED $MAIN_COLOR
        fi
    done
}

# Function to remove an existing file
remove_file() {
    clear
    show_title
    while [ true ]; do 
        echo -ne "\n Enter the name of the file to remove (${HTTPCOLOR}relative to $HTTPD_ROOT${NOCOLOR}): "
        read -r file_name
        if [ -z "$file_name" ]; then
            show_message "!" "Cancelled..." $YELLOW $MAIN_COLOR
            sleep 2
            break
        fi
        local target_file="$HTTPD_ROOT/$file_name"
        if [[ -f "$target_file" ]]; then
            if prompt_confirmation "Are you sure you want to delete '$file_name'?" ; then
                rm -rf "$target_file"
                show_message "-" "File '$file_name' deleted successfully." $GREEN $MAIN_COLOR
                wait_for_continue $MAIN_COLOR $HTTPCOLOR
                config_changed=1
                clear
                break
            else
                show_message "X" "File deletion cancelled." $RED $MAIN_COLOR
                break
            fi
        else
            show_message "X" "File '$file_name' does not exist." $RED $MAIN_COLOR
        fi
    done
}

# Function to remove an existing directory
remove_directory() {
    clear
    show_title
    while [ true ]; do 
        echo -ne "\n Enter the name of the directory to remove (${HTTPCOLOR}relative to $HTTPD_ROOT${NOCOLOR}): "
        read -r dir_name
        if [ -z "$dir_name" ]; then
            show_message "!" "Cancelled..." $YELLOW $MAIN_COLOR
            sleep 2
            break
        fi
        local target_dir="$HTTPD_ROOT/$dir_name"
        if [[ -d "$target_dir" ]]; then
            if prompt_confirmation "Are you sure you want to delete directory '$dir_name' and all its contents?" ; then
                rm -rf "$target_dir"
                show_message "-" "Directory '$dir_name' deleted successfully." $GREEN $MAIN_COLOR
                wait_for_continue $MAIN_COLOR $HTTPCOLOR
                config_changed=1
                clear
                break
            else
                show_message "X" "Directory deletion cancelled." $RED $MAIN_COLOR
                break
            fi
        else
            show_message "X" "Directory '$dir_name' does not exist." $RED $MAIN_COLOR
        fi
    done
}

# Function to upload a file
upload_file() {
    clear
    show_title
    while [ true ]; do 
        echo -ne "\n Enter the path of the file to upload (${HTTPCOLOR}e.g., /path/to/local/file.html${NOCOLOR}): "
        read -r local_file_path
        if [ -z "$local_file_path" ]; then
            show_message "!" "Cancelled..." $YELLOW $MAIN_COLOR
            sleep 3
            break
        elif [[ -f "$local_file_path" ]]; then
            echo -ne "\n Enter the target directory (${HTTPCOLOR}relative to $HTTPD_ROOT, or leave empty for root${NOCOLOR}): "
            read -r dir_name
            local target_dir="$HTTPD_ROOT/$dir_name"
            if [[ -z "$dir_name" || -d "$target_dir" ]]; then
                local target_file_path="$target_dir/$(basename "$local_file_path")"
                if [[ -f "$target_file_path" ]]; then
                    show_message "X" "File '$(basename "$local_file_path")' already exists in '$target_dir'." $RED $MAIN_COLOR
                else
                    cp "$local_file_path" "$target_dir"
                    show_message "+" "File '$(basename "$local_file_path")' uploaded successfully to '$target_dir'." $GREEN $MAIN_COLOR
                    wait_for_continue $MAIN_COLOR $HTTPCOLOR
                    config_changed=1
                    clear
                    break
                fi
            else
                show_message "X" "Directory '$dir_name' does not exist." $RED $MAIN_COLOR
            fi
        else
            show_message "X" "File '$local_file_path' does not exist." $RED $MAIN_COLOR
        fi
    done
}

# Function to list all files and directories
list_files() {
    clear
    show_title
    echo -e "\n ${YELLOW}Listing files in $HTTPD_ROOT:${NOCOLOR}"
    display_tree_structure "$HTTPD_ROOT" " "
    wait_for_continue $MAIN_COLOR $HTTPCOLOR
}

# Function to display the tree structure of files and directories
display_tree_structure() {
    local dir_path=$1 
    local indent="$2"

    for file in "$dir_path"/*; do
        if [[ -d "$file" ]]; then
            echo -e "${indent}${MAIN_COLOR}+-- ${NOCOLOR}$(basename "$file")/"
            display_tree_structure "$file" "$indent    |"
        elif [[ -f "$file" ]]; then
            echo -e "${indent}${GREEN}+-- ${NOCOLOR}$(basename "$file")"
        fi
    done
}

# Function to show the main HTTPD configuration menu
show_httpd_menu() {
    clear
    show_title
    echo -e "\t\t\t\t\t ${HTTPCOLOR}HTTPD CONFIGURATION:${NOCOLOR}"
    echo -e " ${MAIN_COLOR}[${HTTPCOLOR}1${MAIN_COLOR}]${NOCOLOR} List Files"
    echo -e " ${MAIN_COLOR}[${HTTPCOLOR}2${MAIN_COLOR}]${NOCOLOR} Create Directory"
    echo -e " ${MAIN_COLOR}[${HTTPCOLOR}3${MAIN_COLOR}]${NOCOLOR} Remove Directory"
    echo -e " ${MAIN_COLOR}[${HTTPCOLOR}4${MAIN_COLOR}]${NOCOLOR} Add File"
    echo -e " ${MAIN_COLOR}[${HTTPCOLOR}5${MAIN_COLOR}]${NOCOLOR} Upload File"
    echo -e " ${MAIN_COLOR}[${HTTPCOLOR}6${MAIN_COLOR}]${NOCOLOR} Edit File"
    echo -e " ${MAIN_COLOR}[${HTTPCOLOR}7${MAIN_COLOR}]${NOCOLOR} Remove File"
    echo -e " ${MAIN_COLOR}[${HTTPCOLOR}8${MAIN_COLOR}]${NOCOLOR} View File Content"
    echo ""
    echo -e " ${MAIN_COLOR}[${HTTPCOLOR}9${MAIN_COLOR}]${NOCOLOR} Exit WEB Configuration"
    echo ""
}

# Function to handle the main menu loop
httpd_menu() {
    clear
    show_httpd_menu
    while [ true ]; do
        echo -ne " ${MAIN_COLOR}Enter an option ${HTTPCOLOR}\$${MAIN_COLOR}>:${NOCOLOR} "
        read -r op
        if [ -z "$op" ]; then
            echo "" > /dev/null
        else
            case $op in
                1) 
                    list_files
                    show_httpd_menu
                    ;;
                2) 
                    create_directory 
                    show_httpd_menu
                    ;;
                3) 
                    remove_directory 
                    show_httpd_menu
                    ;;
                4) 
                    add_file 
                    show_httpd_menu
                    ;;
                5) 
                    upload_file 
                    show_httpd_menu
                    ;;
                6) 
                    edit_file 
                    show_httpd_menu
                    ;;
                7) 
                    remove_file 
                    show_httpd_menu
                    ;;
                8) 
                    view_file_content 
                    show_httpd_menu
                    ;;
                9) break ;;
                *) show_message "X" "Invalid option." $RED $MAIN_COLOR
                sleep 3 ; echo "" ;;
            esac
        fi
    done
    clear
}

# Start the HTTPD configuration menu
httpd_menu
