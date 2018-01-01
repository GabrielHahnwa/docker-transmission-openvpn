#!/bin/bash

PROXY_CONF='/etc/tinyproxy.conf'

if [ "${WEBPROXY_ENABLED}" = "true" ]; then

  echo "STARTING TINYPROXY"

  if [ -z "$WEBPROXY_PORT" ] ; then
    set_port $WEBPROXY_PORT
  else
    # Always default back to port 8888
    set_port 8888
  fi

  /etc/init.d/tinyproxy start
  echo "Tinyproxy startup script complete."

fi


set_port () {

  re='^[0-9]+$'
  if ! [[ $1 =~ $re ]] ; then
    echo "Port: Not a number" >&2; exit 1
  fi

  # Port: Specify the port which tinyproxy will listen on.  Please note
  # that should you choose to run on a port lower than 1024 you will need
  # to start tinyproxy using root.

  if [ $1 \< 1024 ];
  then 
    echo "tinyproxy: $1 is lower than 1024. Ports below 1024 are not permitted.";
    exit 1
  fi;

  echo "Setting tinyproxy port to $1";
  sed -i -e"s,^Port .*,Port $1," $PROXY_CONF

}
