#!/bin/bash
# This script installs Moonraker on a Debiab machine running the
# Debian distribution.

PYTHONDIR="${HOME}/klippy-env"
SYSTEMDDIR="/etc/systemd/system"
MOONRAKER_USER=$USER

# Step 1:  Verify Klipper has been installed
check_klipper()
{
    if [ "$(systemctl list-units --full -all -t service --no-legend | grep -F "klipper.service")" ]; then
        echo "Klipper service found!"
    else
        echo "Klipper service not found, please install Klipper first"
        exit -1
    fi

    if [ -d ${PYTHONDIR} ]; then
        echo "Klippy virtualenv found!  Installing tornado..."
        ${PYTHONDIR}/bin/pip install tornado
    else
        echo "Klipper Virtual ENV not installed, check your Klipper installation"
        exit -1
    fi
}

# Step 2: Install startup script
install_script()
{
# Create systemd service file
    MOONRAKER_LOG=/tmp/moonraker.log
    report_status "Installing system start script..."
    sudo /bin/sh -c "cat > $SYSTEMDDIR/moonraker.service" << EOF
#Systemd service file for klipper
[Unit]
Description=Starts moonraker on startup
After=network.target

[Install]
WantedBy=multi-user.target

[Service]
Type=simple
User=$MOONRAKER_USER
RemainAfterExit=yes
ExecStart=${PYTHONDIR}/bin/python ${SRCDIR}/klipper/moonraker/moonraker.py 
Restart=always
RestartSec=10
EOF
# Use systemctl to enable the klipper systemd service script
    sudo systemctl enable moonraker.service
}

# Step 3: Start server
start_software()
{
    report_status "Launching Moonraker API Server..."
    sudo systemctl stop klipper
    sudo systemctl restart moonraker
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
set -e

# Find SRCDIR from the pathname of this script
SRCDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. && pwd )"

# Run installation steps defined above
verify_ready
check_klipper
install_script
start_software
