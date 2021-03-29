#!/bin/bash
# This script installs Mainsail for Klipper on an debian image
#

PYTHONDIR="${HOME}/klippy-env"
SYSTEMDDIR="/etc/systemd/system"
MOONRAKER_USER=$USER
KLIPPER_USER=$USER
KLIPPER_GROUP=$KLIPPER_USER
KWC="https://github.com/cadriel/fluidd/releases/download/v1.11.2/fluidd.zip"

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

#step 3: clone moonraker script
clone_moon()
{
    report_status "cloning moonraker..."
     FILE=~/moonraker
    if [ -e "$FILE" ];
    then
        echo "$FILE exist"
    else
        echo "$FILE does not exist"
    cd ~/
    git clone https://github.com/Arksine/moonraker.git
    fi
}

#step 3: install moonraker
install_moonraker()
{
  ${SRCDIR}/moonraker/scripts/install-moonraker.sh -f -c /home/pi/klipper_config/moonraker.conf
  cd ~/
}

#step 5: install nginx config
install-nginxcfg()
{
  report_status "Installing symbolic link..."
    FILE=/etc/nginx/sites-available/fluidd
    if [ -e "$FILE" ];
    then
        echo "$FILE exist"
    else
        echo "$FILE does not exist"
        
NGINXDIR="/etc/nginx/sites-available"
NGINXUPS="/etc/nginx/conf.d/"
NGINXVARS="/etc/nginx/conf.d/"
sudo /bin/sh -c "cp ${SRCDIR}/Fluidd-install/fluidd $NGINXDIR/"
sudo /bin/sh -c "cp ${SRCDIR}/Fluidd-install/upstreams.conf $NGINXUPS/"
sudo /bin/sh -c "cp ${SRCDIR}/Fluidd-install/common_vars.conf $NGINXVARS/"

        sudo ln -s /etc/nginx/sites-available/fluidd /etc/nginx/sites-enabled/
        sudo rm /etc/nginx/sites-available/default
        sudo rm /etc/nginx/sites-enabled/default
        sudo systemctl restart nginx
    fi
}

# Step 4: clone fluidd
install_fluidd()
{
    report_status "installing Fluidd "
    FILE=~/fluidd
    if [ -d "$FILE" ]; then
        echo "$FILE exist"
    else
        echo "$FILE does not exist"
        mkdir ~/fluidd ~/gcode_files
        cd ~/fluidd
        wget -q -O fluidd.zip ${KWC} && unzip fluidd.zip && rm fluidd.zip
        cd ~/
     fi
}

#step 5 make klipper_config directory
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

# Step 6 add moonraker.conf
add_moon()
{
  if
  FILE="${SRCDIR}/klipper_config/moonraker.conf"
  LINE="trusted_clients:"
    grep -q -- "$LINE" "$FILE"
      then
        echo "moonraker exist"
  else
      cp ~/Fluidd-install/moonraker.conf ~/klipper_config/moonraker.conf
      fi
}

# step 7 update klipper service
add_klipserv()
{
    report_status "update klipper service....."
    ${SRCDIR}/Fluidd-install/blackstump.sh
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
clone_moon
install_moonraker
install-nginxcfg
install_fluidd
add_klipconf
add_moon
add_klipserv
start_klipper
