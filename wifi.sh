#!/bin/bash
set -e
BASE=$(dirname $0)

APP_ID="fr.free.bashwifi"
FREEBOX_ADDRESS="http://mafreebox.freebox.fr"

function check_authorization {
  source ${BASE}/.data

  local AUTHORIZATION_CHECK=`curl -s ${FREEBOX_ADDRESS}/api/v1/login/authorize/${TRACK_ID}`

  if [[ ${AUTHORIZATION_CHECK} != *"granted"* ]]
  then
    echo "Something wrong, be sure that the applicaiton is authorized."
    echo "If you want to register the application again, delete '.data'"
    exit 1
  fi
}


function expect_success() {
  local RESULT=${1}
  local SUCCESS=`echo -n "${RESULT}" | sed 's/.*success":\([^,]*\).*/\1/g'`
  if [ "${SUCCESS}" == "false" ]; then
    echo "Something went wrong"
    echo ${RESULT}
    exit 1
  fi
}

WIFI_STATUS=${1}

# REGISTER APPLICATION
if [ ! -f ${BASE}/.data ]; then
  AUTORIZE_RESPONSE=`curl -s --header "Content-type: application/json" --header "charset: utf-8" --header "Accept: text/plain" -X POST -d '{ "app_id": "'"${APP_ID}"'", "app_name": "bash_wifi_control", "app_version": 1.0, "device_name": "Bash Wifi Control" }' ${FREEBOX_ADDRESS}/api/v1/login/authorize/`
  APP_TOKEN=`echo -n ${AUTORIZE_RESPONSE} | sed 's/.*app_token":"\([^"]*\).*/\1/g' | sed 's/\\\//g'`
  TRACK_ID=`echo -n ${AUTORIZE_RESPONSE} | sed 's/.*track_id":\([0-9]*\).*/\1/g'`
  echo 'Accept this application on the Freebox menu'
  echo "Dont forget to add the settings rights in the administration section"
  echo "#!/bin/bash" > ${BASE}/.data
  echo "APP_TOKEN=\"${APP_TOKEN}\"" >> ${BASE}/.data
  echo "TRACK_ID=\"${TRACK_ID}\"" >> ${BASE}/.data
  exit 0
fi

check_authorization


LOGIN_RESPONSE=`curl -s ${FREEBOX_ADDRESS}/api/v1/login/`

# GET CHALLENGE FROM LOGIN_RESPONSE
CHALLENGE=`echo -n ${LOGIN_RESPONSE} | sed 's/.*challenge":"\([^"]*\).*/\1/g' | sed 's/\\\//g'`

HASHED_PASSWORD=`echo -n "${CHALLENGE}" | openssl dgst -sha1 -hmac "${APP_TOKEN}" | sed 's/^.* //'`

SESSION_RESPONSE=`curl -s --header "Content-type: application/json" --header "charset: utf-8" --header "Accept: text/plain" -X POST -d "{\"app_id\":\"${APP_ID}\",\"password\":\"${HASHED_PASSWORD}\"}" ${FREEBOX_ADDRESS}/api/v1/login/session/`

SESSION_TOKEN=`echo -n "${SESSION_RESPONSE}" | sed 's/.*session_token":"\([^"]*\).*/\1/g' | sed 's/\\\//g'`

SETTINGS_RIGHTS=`echo -n "${SESSION_RESPONSE}" | sed 's/.*settings":\([^,]*\).*/\1/g'`

if [ "${SETTINGS_RIGHTS}" == "false" ]; then
  echo "You must activate the right 'settings' in the application section of your freebox: ${FREEBOX_ADDRESS}"
fi


if [ "${WIFI_STATUS}" == "on" ]; then
  RESULT=`curl -s --header "Content-type: application/json" --header "X-Fbx-App-Auth: ${SESSION_TOKEN}" -X PUT -d "{\"ap_params\" : {\"enabled\": true}}"  ${FREEBOX_ADDRESS}/api/v1/wifi/config/`
  expect_success ${RESULT}
fi


if [ "${WIFI_STATUS}" == "off" ]; then
  RESULT=`curl -s --header "Content-type: application/json" --header "X-Fbx-App-Auth: ${SESSION_TOKEN}" -X PUT -d "{\"ap_params\" : {\"enabled\": false}}"  ${FREEBOX_ADDRESS}/api/v1/wifi/config/`
  expect_success ${RESULT}
fi
