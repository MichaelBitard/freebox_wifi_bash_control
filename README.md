# freebox_wifi_bash_control
Control your wifi via bash

## Usage

* Launch ./wifi.sh
    * It will create a .data file where the application token and it's id will be stored
* Go to your freebox and accept the application
* Relaunch the script, there will be an error message telling you to add the 'settings' permission to the application
* Go to the freebox administration page --> Access settings --> Applications and for 'bash_wifi_control' check the 'Freebox settings modifications' and save
* You can now type './wifi.sh off' and './wifi.sh on' to turn it off and on again
