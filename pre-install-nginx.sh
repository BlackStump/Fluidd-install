#!/bin/bash
# This script installs Mainsail for Klipper on an debian image
#

PYTHONDIR="${HOME}/klippy-env"
SYSTEMDDIR="/etc/systemd/system"
KLIPPER_USER=$USER
KLIPPER_GROUP=$KLIPPER_USER
KWC="https://github.com/BlackStump/mainsail/files/4570245/mainsail-alpha-0.0.9a.zip"

# Step 1: Install system packages
install_packages()
{
    # Packages for wget
    PKGLIST="${PKGLIST} wget"
    # Packages for gzip
    PKGLIST="${PKGLIST} gzip"
    # Packages for tar
    PKGLIST="${PKGLIST} tar"
    # Packages for unzip
    PKGLIST="${PKGLIST} unzip"
    # Packages for nginx
    PKGLIST="${PKGLIST} nginx"

    # Update system package info
    report_status "Running apt-get update..."
    sudo apt-get update

    # Install desired packages
    report_status "Installing packages..."
    sudo apt-get install --yes ${PKGLIST}
}

# Step 2: stop klipper
stop_klipper()
{
    report_status "stopping klipper..."
    sudo systemctl stop klipper
}

# Step 3: Install tornado script
install_script()
{
# install 3 parts
    report_status "Installing tornado script..."
    virtualenv ${PYTHONDIR}
    ${PYTHONDIR}/bin/pip install tornado==5.1.1
}
# Step 4: clone mainsail git
install_script1()
{
    report_status "installing mainsail "
    FILE=~/mainsail
    if [ -d "$FILE" ]; then
        echo "$FILE exist"
    else
        echo "$FILE does not exist"
        mkdir ~/mainsail ~/sdcard
        cd ~/mainsail
        wget -q -O mainsail.zip ${KWC} && unzip mainsail.zip && rm mainsail.zip
        cd ~/
     fi
}


# Step 5 add mainsail to printer.cfg
add_mainsail()
{
    report_status "adding mainsail to printer.cfg..."
    FILE="/home/debian/printer.cfg"
    LINE="###~###"
    grep -xqFs -- "$LINE" "$FILE" || echo "$LINE" >> "$FILE"
    LINE1="[virtual_sdcard]"
    grep -xqFs -- "$LINE1" "$FILE" || echo "$LINE1" >> "$FILE"
    LINE2="path: /home/debian/sdcard"
    grep -xqFs -- "$LINE2" "$FILE" || echo "$LINE2" >> "$FILE"
    LINE3="###~~###"
    grep -xqFs -- "$LINE3" "$FILE" || echo "$LINE3" >> "$FILE"
    LINE4="[remote_api]"
    grep -xqFs -- "$LINE4" "$FILE" || echo "$LINE4" >> "$FILE"
    LINE5="trusted_clients:"
    grep -xqFs -- "$LINE5" "$FILE" || echo "$LINE5" >> "$FILE"
    LINE6="    192.168.2.0/24"
    grep -xqFs -- "$LINE6" "$FILE" || echo "$LINE6" >> "$FILE"
    LINE7="    127.0.0.0/24"
    grep -xqFs -- "$LINE7" "$FILE" || echo "$LINE7" >> "$FILE"
    LINE8="enable_cors: True"
    grep -xqFs -- "$LINE8" "$FILE" || echo "$LINE8" >> "$FILE"
}

# Step 10: start klipper
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
install_packages
install_script
install_script1
add_mainsail
start_klipper
