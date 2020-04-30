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
I made for my own use and I have tested on a Beaglebone Black but YMMV
I have include a script for the Pi but as I do not have one it is untested.

Usage

cd ~/

git clone https://github.com/BlackStump/mainsail-install.git

./mainsail-install/pre-install-nginx.sh

for a debian os

./mainsail-install/nginx-debian_install.sh

for pi os

./mainsail-install/nginx-pi_install.sh

If you have not already changed to Arksine's Remote API Branch

./mainsail-install/arksine_install.sh

