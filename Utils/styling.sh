#!/bin/bash

# Exporting color codes for use in scripts
# The colors are defined using ANSI escape sequences

# Main color for banners and headers
export MAIN_COLOR='\033[38;5;69m'

# Color for Tux ASCII art
export TUXCOLOR='\033[38;5;3m'

# Color for HTTP service messages
export HTTPCOLOR='\033[38;5;134m'

# Color for DHCP service messages
export DHCPCOLOR='\033[38;5;204m'

# Additional colors for various purposes
export LIGHTBLUE='\033[38;5;67m'
export BLUE='\033[38;5;92m'
export RED='\033[38;5;88m'
export GREEN='\033[38;5;78m'
export YELLOW='\033[38;5;220m'
export WHITE='\033[38;5;158m'

# Reset color to default
export NOCOLOR='\033[0m'

# Function to display a banner with customizable colors and an extra message
readonly GITHUB_URL="https://github.com/GLS-Solutions/TuxManager"
readonly VERSION="1.0"
readonly NOCOLOR='\033[0m'

show_banner() {
    local color="$1"      # Secondary color for the Tux ASCII art
    local main_color="$2" # Main color for the banner text
    local extra_msg="$3"  # Extra message to display

    echo -e -n "${main_color}"
    echo -e '________                ______  ___                                '               
    echo -e '___  __/____  ______  _____   |/  /______ ________ ______ ________ ______ ________'
    echo -e -n '__  /   _  / / /__  |/_/__  /|_/ / _  __ `/__  __ \_  __ `/__  __ `/_  _ \__  ___/ ' ; echo -e "${color}(o<${main_color}"
    echo -e -n '_  /    / /_/ / __>  <  _  /  / /  / /_/ / _  / / // /_/ / _  /_/ / /  __/_  /     ' ; echo -e "${color}//\\ ${main_color}"
    echo -e -n '/_/     \__,_/  /_/|_|  /_/  /_/   \__,_/  /_/ /_/ \__,_/  _\__, /  \___/ /_/      ' ; echo -e "${color}V_/_${main_color}"
    echo -e '                                                           /____/ '
    echo -e "${color}${extra_msg}${NOCOLOR}"
    echo -e "${main_color}----------------------------------------------------------------------------------${NOCOLOR}"
    echo -e -n "${main_color}GitHub: ${color}${GITHUB_URL}${NOCOLOR}"
    echo -e "\t\t\t      ${main_color}Version: ${color}${VERSION}${NOCOLOR}"
    echo -e "${main_color}----------------------------------------------------------------------------------${NOCOLOR}"
}

# Function to display a formatted message with a specific indicator and color
show_message() {
    local c="$1"       # Indicator symbol (e.g., !, -, X)
    local message="$2" # The message to display
    local color="$3"   # The color for the indicator and message
    local main_color="$4"   # The color for the indicator and message

    # Display the message with formatting and color
    echo -ne "${main_color}"
    echo -e " ${main_color}[${color}${c}${main_color}]${color} ${message}${NOCOLOR}"
}

# Function to display a input to wait for some key to be pressed
wait_for_continue() {
  local main_color="$1"
  local color="$2"

  echo -e "\n${main_color}----------------------------------------------------------------------------------${NOCOLOR}"
  echo -ne " ${main_color}Press [${color}ANY KEY${main_color}] to continue..."
  read -r -n 1 -s
}

# Test function to demonstrate the banner display
test_banner() {
    show_banner "Welcome!!!" $MAIN_COLOR $TUXCOLOR
}

test_message() {
	show_message "!" "Message!!!" $GREEN $MAIN_COLOR 
}

# Uncomment the lines below to test functions
# test_banner
# test_message

# Unset the test function to clean up the namespace
unset -f test_banner
unset -f test_message


