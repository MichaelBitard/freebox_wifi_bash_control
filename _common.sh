#!/bin/bash
set -e

APP_ID="fr.free.bashwifi"
FREEBOX_ADDRESS="http://mafreebox.freebox.fr"

function check_authorization {
  source .data

  local AUTHORIZATION_CHECK=`curl -s ${FREEBOX_ADDRESS}/api/v1/login/authorize/${TRACK_ID}`

  if [[ ${AUTHORIZATION_CHECK} == *"granted"* ]]
  then
    echo "Authorization ok"
  else
    echo "Something wrong, be sure that the applicaiton is authorized."
    echo "If you want to register the application again, delete '.data'"
    exit 1
  fi
}
