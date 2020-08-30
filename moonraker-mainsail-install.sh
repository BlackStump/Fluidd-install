#!/bin/bash
# This script installs Mainsail for Klipper on an debian image
#

PYTHONDIR="${HOME}/klippy-env"
SYSTEMDDIR="/etc/systemd/system"
MOONRAKER_USER=$USER
KLIPPER_USER=$USER
KLIPPER_GROUP=$KLIPPER_USER
KWC="https://github.com/BlackStump/mainsail-install/releases/download/v0.1.14-beta/mainsail-beta-0.01.4.zip"

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

#step 3: run blackstump script
blkstump()
{
  ${SRCDIR}/mainsail-install/blackstump.sh
}

#step 3: install moonraker
install_moonraker()
{
  ${SRCDIR}/moonraker/scripts/install-debianmoonraker.sh
  cd ~/
}

#step 5: install nginx config
install-nginxcfg()
{
  report_status "Installing symbolic link..."
    FILE=/etc/nginx/sites-available/mainsail
    if [ -e "$FILE" ];
    then
        echo "$FILE exist"
    else
        echo "$FILE does not exist"
        
NGINXDIR="/etc/nginx/sites-available"
sudo /bin/sh -c "cp /home/debian/mainsail-install/mainsail $NGINXDIR/" 

        sudo ln -s /etc/nginx/sites-available/mainsail /etc/nginx/sites-enabled/
        sudo rm /etc/nginx/sites-enabled/default
        sudo systemctl restart nginx
    fi
}

# Step 4: clone mainsail git
install_mainsail()
{
    report_status "installing mainsail "
    FILE=~/mainsail
    if [ -d "$FILE" ]; then
        echo "$FILE exist"
    else
        echo "$FILE does not exist"
        mkdir ~/mainsail ~/gcodes
        cd ~/mainsail
        wget -q -O mainsail.zip ${KWC} && unzip mainsail.zip && rm mainsail.zip
        cd ~/
     fi
}


# Step 5 add mainsail to printer.cfg
add_mainsail()
{
  if
  FILE="${SRCDIR}/moonraker.conf"
  LINE="trusted_clients:"
    grep -q -- "$LINE" "$FILE"
      then
        echo "moonraker exist"
  else
      cp ~/mainsail-install/moonraker.conf ~/moonraker.conf
      fi
}

#step 6 make klipper_config directory
# Step 7: start klipper
add_klipconf()
{
    report_status "make klipper_config directory "
    FILE=~/klipper_config
    if [ -d "$FILE" ]; then
        echo "$FILE exist"
    else
        echo "$FILE does not exist"
        mkdir ~/klipper_config
        fi
}        

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
blkstump
install_moonraker
install-nginxcfg
install_mainsail
add_mainsail
add_klipconf
start_klipper
