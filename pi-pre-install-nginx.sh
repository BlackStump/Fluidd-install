#!/bin/bash
# This script installs Mainsail for Klipper on an debian image
#

PYTHONDIR="${HOME}/klippy-env"
SYSTEMDDIR="/etc/systemd/system"
KLIPPER_USER=$USER
KLIPPER_GROUP=$KLIPPER_USER
KWC="https://github.com/meteyou/mainsail/releases/tag/v0.0.10"

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
  if
  FILE="/home/pi/printer.cfg"
  LINE="trusted_clients:"
    grep -q -- "$LINE" "$FILE"
      then
        echo "remote_ip exist"
  else
      sed -i '/#*# <---------------------- SAVE_CONFIG ---------------------->/i[virtual_sdcard]\npath: /home/debian/sdcard\n' ~/printer.cfg
      sed -i '/#*# <---------------------- SAVE_CONFIG ---------------------->/i[api_server]\ntrusted_clients:\n  192.168.2.0/24\n  127.0.0.0/24\nenable_cors:  True\n' ~/printer.cfg
      sleep 1
      LINE1="#*# <---------------------- SAVE_CONFIG ---------------------->"
      grep -xqFs -- "$LINE1" "$FILE" || sed -i '$a[virtual_sdcard]\npath: /home/debian/sdcard\n[api_server]\ntrusted_clients:\n  192.168.2.0/24\n  127.0.0.0/24\nenable_cors:  True\n' ~/printer.cfg
  fi
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
