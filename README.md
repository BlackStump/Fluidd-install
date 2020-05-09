# mainsail-install
Mainsail easy install scripts

[Mainsail](https://github.com/meteyou/mainsail)

These scripts will install

    * Mainsail Ver 0.0.9
    * Tornado
    * Nginx
    * Nginx config for Mainsail
    * Add the Klipper-API to printer.cfg
    * Change to Arksine Remote API Branch of Klipper
    
Cautionary fine print
I made for my own use and I have tested on a Beaglebone Black with a Debian OS

Usage

cd ~/

git clone https://github.com/BlackStump/mainsail-install.git

./mainsail-install/pre-install-nginx.sh

For a Debian OS

./mainsail-install/nginx-debian_install.sh

If you have not already changed to [Arksine's](https://github.com/Arksine/klipper/tree/work-web_server-20200131) Remote API Branch

./mainsail-install/arksine_install.sh

For RaspberryPi OS
use the [meteyou](https://github.com/meteyou/mainsail) recommended [Installer](https://github.com/ArmyAg08/mainsail-installer)

