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
    report_status "Installing symbolic link..."
    FILE=/etc/nginx/sites-available/mainsail
    if [ -e "$FILE" ];
    then
        echo "$FILE exist"
    else
        echo "$FILE does not exist"
        sudo cp /home/debian/mainsail-install/mainsail-debian /etc/nginx/sites-available/mainsail-debian
        sudo ln -s /etc/nginx/sites-available/mainsail-debian /etc/nginx/sites-enabled/
        sudo rm /etc/nginx/sites-enabled/default
        sudo systemctl restart nginx
    fi
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
    if [[ $UID != 0 ]]; then
      echo "Please run this script with sudo:"
      echo "sudo $0 $*"
      exit 1
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
