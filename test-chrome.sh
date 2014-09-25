#!/bin/bash -e
# Copyright © 2014 &yet
#
# based on https://github.com/GoogleChrome/webrtc/blob/master/samples/web/content/apprtc/turn-prober/turn-prober.sh
# Copyright (c) 2014, The WebRTC project authors. All rights reserved.
# see https://github.com/GoogleChrome/webrtc/blob/master/LICENSE

CHROME="google-chrome"
CHROME_ARGS="--use-fake-ui-for-media-stream --use-fake-device-for-media-stream"
HOST=$1
ROOM=$2
COND=$3
URL=https://${HOST}/${ROOM}

function chrome_pids() {
  ps axuwww|grep $D|grep c[h]rome|awk '{print $2}'
}

cd $(dirname $0)
export D=$(mktemp -d)

# prefill localstorage
LOCALSTORAGE_DIR="${D}/Default/Local Storage/"
mkdir -p "${LOCALSTORAGE_DIR}"
sqlite3 "${LOCALSTORAGE_DIR}/https_${HOST}_0.localstorage" << EOF
    PRAGMA encoding = "UTF-16";
    CREATE TABLE ItemTable (key TEXT UNIQUE ON CONFLICT REPLACE, value BLOB NOT NULL ON CONFLICT FAIL);
    INSERT INTO ItemTable (key, value) VALUES ("debug", "true");
    INSERT INTO ItemTable (key, value) VALUES ("skipHaircheck", "true");
EOF


LOG_FILE="${D}/chrome_debug.log"
touch $LOG_FILE

XVFB="xvfb-run -a -e $LOG_FILE -s '-screen 0 1024x768x24'"
if [ -n "$DISPLAY" ]; then
  XVFB=""
fi

# "eval" below is required by $XVFB containing a quoted argument.
eval $XVFB $CHROME \
  --enable-logging=stderr \
  --no-first-run \
  --user-data-dir=$D \
  ${CHROME_ARGS} \
  --vmodule="*media/*=3,*turn*=3" \
  "${URL}" > $LOG_FILE 2>&1 &
CHROME_PID=$!

while ! grep -q "${COND}" $LOG_FILE && chrome_pids|grep -q .; do
  sleep 0.1
done
# wait for the peer to notice
sleep 5

# Suppress bash's Killed message for the chrome above.
exec 3>&2
exec 2>/dev/null
while [ ! -z "$(chrome_pids)" ]; do
  kill -9 $(chrome_pids)
done
exec 2>&3
exec 3>&-

DONE=$(grep "${COND}" $LOG_FILE)
EXIT_CODE=0
if ! grep -q "${COND}" $LOG_FILE; then
  cat $LOG_FILE
  EXIT_CODE=1
fi

rm -rf $D
exit $EXIT_CODE
