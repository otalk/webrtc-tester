#!/bin/bash -e
# Copyright © 2014 &yet
#
# based on https://github.com/GoogleChrome/webrtc/blob/master/samples/web/content/apprtc/turn-prober/turn-prober.sh
# Copyright (c) 2014, The WebRTC project authors. All rights reserved.
# see https://github.com/GoogleChrome/webrtc/blob/master/LICENSE

#DISPLAY=
HOST=$1
ROOM=$2
URL=https://${HOST}/${ROOM}

D=`mozprofile --pref="media.navigator.permission.disabled:true"`

# prefill localstorage
REVERSEHOST=`echo ${HOST} | rev` 
sqlite3 "${D}/webappsstore.sqlite" << EOF
    CREATE TABLE webappsstore2 (scope TEXT, key TEXT, value TEXT, secure INTEGER, owner TEXT);
    CREATE UNIQUE INDEX scope_key_index ON webappsstore2(scope, key);
    INSERT INTO webappsstore2 (scope, key, value) VALUES ("${REVERSEHOST}.:https:443", "skipHaircheck", "true");
    INSERT INTO webappsstore2 (scope, key, value) VALUES ("${REVERSEHOST}.:https:443", "useFirefoxFakeDevice", "true");
EOF

LOG_FILE="${D}/firefox.log"
touch $LOG_FILE

XVFB="xvfb-run -a -e $LOG_FILE -s '-screen 0 1024x768x24'"
if [ -n "$DISPLAY" ]; then
  XVFB=""
fi
BROWSER="mozrunner -p ${D} --binary firefox --app-arg=${URL}"

# "eval" below is required by $XVFB containing a quoted argument.
eval $XVFB $BROWSER > $LOG_FILE 2>&1 &

PID=$!
echo "PID: ${PID}"
exit 0
