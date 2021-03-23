#!/bin/bash
# This script installs Moonraker for Klipper on an debian image
#

PYTHONDIR="${HOME}/klippy-env"
SYSTEMDDIR="/etc/systemd/system"
KLIPPER_USER=$USER
KLIPPER_GROUP=$KLIPPER_USER

# Step 1: Check for Klipper Service
check_klipper()
{
    if [ "$(systemctl list-units --full -all -t service --no-legend | grep -F "klipper.service")" ]; then
        echo "Klipper service found!"
    else
        echo "Klipper service not found, please install Klipper first"
    fi

}

# Step 1: Install startup script
install_script()
{
# Create systemd service file
    KLIPPER_LOG=/tmp/klippy.log
    report_status "Installing system start script..."
    sudo /bin/sh -c "cat > $SYSTEMDDIR/klipper.service" << EOF
#Systemd service file for klipper
[Unit]
Description=Starts klipper on startup
After=network.target

[Install]
WantedBy=multi-user.target

[Service]
Type=simple
User=$KLIPPER_USER
RemainAfterExit=yes
ExecStart=${PYTHONDIR}/bin/python ${HOME}/klipper/klippy/klippy.py ${HOME}/klipper_config/printer.cfg -l ${KLIPPER_LOG} -a /tmp/klippy_uds
Restart=always
RestartSec=5
EOF
# Use systemctl to enable the klipper systemd service script
    sudo systemctl enable klipper.service
}

# Step 2: Install linux mcu startup script
install_script1()
{
# Create systemd service file
    PIDFILE=/var/run/klipper_mcu.pid
    report_status "Installing linux mcu system start script1..."
    sudo /bin/sh -c "cat > $SYSTEMDDIR/klipper_host_mcu.service" << EOF
#Systemd service file for klipper-linux-host-mcu
[Unit]
Description=klipper linux host
Requires=klipper.service
After=klipper.service
BindsTo=klipper.service

[Service]
Type=simple
User=$KLIPPER_USER
ExecStart=/usr/local/bin/klipper_mcu
Restart=always
RestartSec=5

[Install]
WantedBy=klipper.service
EOF
# Use systemctl to enable the klipper systemd service script
    sudo systemctl enable klipper_host_mcu.service
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
set -e

# Find SRCDIR from the pathname of this script
SRCDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. && pwd )"

# Run installation steps defined above
verify_ready
install_script
install_script1
