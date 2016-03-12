#!/bin/bash
source _common.sh
if [ ! -f .data ]; then
  AUTORIZE_RESPONSE=`curl -s --header "Content-type: application/json" --header "charset: utf-8" --header "Accept: text/plain" -X POST -d '{ "app_id": "'"${APP_ID}"'", "app_name": "bash_wifi_control", "app_version": 1.0, "device_name": "Bash Wifi Control" }' ${FREEBOX_ADDRESS}/api/v1/login/authorize/`
  APP_TOKEN=`echo -n ${AUTORIZE_RESPONSE} | sed 's/.*app_token":"\([^"]*\).*/\1/g' | sed 's/\\\//g'`
  TRACK_ID=`echo -n ${AUTORIZE_RESPONSE} | sed 's/.*track_id":\([0-9]*\).*/\1/g'`
  echo 'Accept this application on the Freebox menu'
  echo "#!/bin/bash" > .data
  echo "APP_TOKEN=\"${APP_TOKEN}\"" >> .data
  echo "TRACK_ID=\"${TRACK_ID}\"" >> .data
  exit 0
fi

check_authorization
