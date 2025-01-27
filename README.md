# TuxManager
**CentOS DHCP and HTTP manager tool**

<p align="center">
<a href="https://github.com/GutsNet"><img title="Author" src="https://img.shields.io/badge/Author-GutsNet-red.svg?style=for-the-badge&logo=github"></a>
<a href="https://github.com/L30AM"><img title="Author" src="https://img.shields.io/badge/Author-L30AM-red.svg?style=for-the-badge&logo=github"></a>
<a href="https://github.com/sergiomndz15"><img title="Author" src="https://img.shields.io/badge/Author-sergiomndz15-red.svg?style=for-the-badge&logo=github"></a>
<a href="https://github.com/AlexMangle"><img title="Author" src="https://img.shields.io/badge/Author-AlexMangle-red.svg?style=for-the-badge&logo=github"></a>
</p>

## Table of Contents

- [Project Structure](#project-structure)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Utilities](#utilities)

## Project Structure

```
TuxManager/
│
├── README.md
├── tuxmanager.sh              # Main script to run TuxManager
├── Scripts/
│   ├── configure_dhcp.sh      # Script to configure DHCP
│   ├── configure_web.sh       # Script to configure HTTP (Web) service
│   ├── install_dhcp.sh        # Script to install DHCP service
│   ├── install_web.sh         # Script to install HTTP (Web) service
│   ├── manage_dhcp.sh         # Script to manage DHCP service (start, stop, restart)
│   ├── manage_web.sh          # Script to manage HTTP (Web) service (start, stop, restart)
│   ├── status_dhcp.sh         # Script to check the status of DHCP service
│   ├── status_web.sh          # Script to check the status of HTTP (Web) service
│
└── Utils/
    ├── byebye_track.sh        # Utility script to clean up tracking data or logs
    ├── progress.sh            # Utility script to show progress bars or spinners
    ├── styling.sh             # Utility script for text styling in terminal
    ├── validate.sh            # Utility script to validate configurations or inputs
```

## Features

- **Automated Installation:** It automates the installation process, ensuring that all necessary dependencies and configurations are properly implemented.
- **Service Management:** Allows actions such as starting, stopping, and restarting the web server configuration.
- **Configuration:** Easily configure DHCP and HTTP services.
- **Status Monitoring:** It reports on whether the server is active, uptime, and possible errors or warnings in the service.
- **Utilities:** Additional utility scripts to enhance the functionality and appearance of TuxManager.

## Requirements

- **Bash Shell:** Ensure your system supports Bash scripting.
- **Permissions:** Root or sudo privileges to install and manage services.
- **Dependencies:** Necessary packages (e.g., `dhcpd`, `httpd`) should be available. Alternatively, for a better experience, install them using the TuxManager installation tools.

## Installation

Clone the repository to your local machine:

```bash
git clone https://github.com/GLSSltns/TuxManager.git
cd TuxManager
```

Ensure the scripts have executable permissions:

```bash
chmod +x Scripts/*.sh Utils/*.sh tuxmanager.sh
```

## Usage

TuxManager's main script can be executed to interact with all available features:
Main script that acts as the entry point for all TuxManager functions. This script provides an interface to interact with all other scripts easily.
> NOT RECOMMENDABLE TO RUN THE SCRIPTS INDIVIDUALLY!

```bash
./tuxmanager.sh
```


## Utilities

- **byebye_track.sh:** Clean up logs or tracking data.
- **progress.sh:** Display progress bars or spinners during operations.
- **styling.sh:** Add text styling to your terminal outputs.
- **validate.sh:** Validate your configurations and inputs for correctness.

