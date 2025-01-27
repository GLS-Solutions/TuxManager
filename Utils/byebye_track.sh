    #!/bin/bash

stty -echoctl # hide ^C
trap 'byebye_execution' SIGINT

byebye_execution() {
	echo -ne "\r"
    show_message "!" "Execution was stopped by the user (^C)!" $RED $MAIN_COLOR
    tput sgr0
    stty echo
    stty -igncr
    exit
}



