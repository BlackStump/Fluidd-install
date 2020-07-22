#!/bin/bash
# This script installs Moonraker for Klipper on an debian image
#


# Step 1: install dependant gits
clone_gits()
{
    report_status "cloning gits..."
    cd ~/
    git clone https://github.com/BlackStump/moonraker.git
}

# Step 2: change to blackstump klipper
install_kbranch()
{
    report_status "Installing Moonraker Remote_API Branch..."
    cd ~/klipper
    git remote add blackstump https://github.com/BlackStump/klipper.git
    git fetch blackstump
    git checkout blackstump/ms-ar
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


# Run installation steps defined above
verify_ready
clone_gits
install_kbranch


