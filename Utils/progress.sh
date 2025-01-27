#!/bin/bash

no_color='\033[0m'

# Function to display a progress bar
progress_bar() {
    local duration=$1  # Total duration 
    local steps=10  # Number of steps 
    local interval=$((duration / steps))  # Time interval between steps

    local color=$2  # Color for the progress bar
    local main_color=$3

    for ((i = 0; i <= steps; i++)); do
        echo -ne "${main_color} ["  # Start 
        for ((j = 0; j < i; j++)); do echo -ne "${color}###"; done  # Filled portion
        for ((j = i; j < steps; j++)); do echo -ne "${no_color}..."; done  # Unfilled portion
        echo -ne "${main_color}] ${color}$((i * 10))${main_color}%\r"  # Display percentage
        sleep $interval  # Wait for the interval duration
    done
    echo -e "${no_color}"  # Reset color and move to a new line
}

#!/bin/bash

spinner() {
  	local duration="$1"
  	local msg="$2"

 	spin[0]="-"
  	spin[1]="\\"
  	spin[2]="|"
  	spin[3]="/"

 	echo -ne "${msg} ${spin[0]}"
  	local start_time=$(date +%s)
  	while (( $(date +%s) - start_time < duration )); do
  	  	for i in "${spin[@]}"; do
  	    	echo -ne "\b\b\b[$i]"
  	    	sleep 0.1
  	  	done
  	done
  	echo -ne "\r" # Clean up after spinner finishes
  	echo -e "${msg}      "
}

test_progress_bar() {
    progress_bar 10
}

test_spinner() {
    spinner 5 "SPINNER  "
}

# test_progress_bar
# test_spinner

unset -f test_progress_bar  
unset -f test_spinner