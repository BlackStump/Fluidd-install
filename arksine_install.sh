#!/bin/bash
# This script installs DWC for Klipper on an debian image
#


# Step 1: stop klipper
stop_klipper()
{
    report_status "stopping klipper..."
    sudo systemctl stop klipper
}

# Step 3: create symbolic link nginx
install_script()
{
    report_status "Installing Arksine Remote_API Branch..."
    cd ~/klipper
    git remote add arksine https://github.com/Arksine/klipper.git
    git fetch arksine
    git checkout arksine/dev-moonraker-testing
}

# Step 4: start klipper
start_klipper()
{
    report_status "starting klipper..."
    sudo systemctl start klipper
}

# Helper functions
report_status()
{
    echo -e "\n\n###### $1"
}

verify_ready()
{
    if [ "$EUID" -eq 0 ]; then
        echo "This script must not run as root"
        exit -1
    fi
}

# Force script to exit if an error occurs
#set -e

# Find SRCDIR from the pathname of this script
SRCDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. && pwd )"

# Run installation steps defined above
verify_ready
stop_klipper
install_script
start_klipper
