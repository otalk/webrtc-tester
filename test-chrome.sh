#!/bin/bash -e
# Copyright © 2014 &yet
#
# based on https://github.com/GoogleChrome/webrtc/blob/master/samples/web/content/apprtc/turn-prober/turn-prober.sh
# Copyright (c) 2014, The WebRTC project authors. All rights reserved.
# see https://github.com/GoogleChrome/webrtc/blob/master/LICENSE

BROWSER="google-chrome"

# evaluate command line arguments
HOST=$1
ROOM=$2
COND=$3
URL=https://${HOST}/${ROOM}

function browser_pids() {
  case "$BROWSER" in
  "google-chrome")
    ps axuwww|grep $D|grep c[h]rome|awk '{print $2}'
    ;;
  "firefox")
    ps axuwww|grep $D|grep ${BROWSER}|awk '{print $2}'
    ;;
  esac
}

function cleanup() {
  # Suppress bash's Killed message for the chrome above.
  exec 3>&2
  exec 2>/dev/null
  while [ ! -z "$(browser_pids)" ]; do
    kill -9 $(browser_pids)
  done
  exec 2>&3
  exec 3>&-

  rm -rf $D
}
trap cleanup EXIT

# make a new profile
case "$BROWSER" in
  "google-chrome")
    cd $(dirname $0)
    D=$(mktemp -d)
    ;;
  "firefox")
    D=`mozprofile --pref="media.navigator.permission.disabled:true" --pref="browser.dom.window.dump.enabled:true"`
    ;;
esac

# prefill localstorage
case "$BROWSER" in
  "google-chrome")
    LOCALSTORAGE_DIR="${D}/Default/Local Storage/"
    mkdir -p "${LOCALSTORAGE_DIR}"
    sqlite3 "${LOCALSTORAGE_DIR}/https_${HOST}_0.localstorage" << EOF
        PRAGMA encoding = "UTF-16";
        CREATE TABLE ItemTable (key TEXT UNIQUE ON CONFLICT REPLACE, value BLOB NOT NULL ON CONFLICT FAIL);
        INSERT INTO ItemTable (key, value) VALUES ("debug", "true");
        INSERT INTO ItemTable (key, value) VALUES ("skipHaircheck", "true");
EOF
    ;;
  "firefox")
    REVERSEHOST=`echo ${HOST} | rev` 
    sqlite3 "${D}/webappsstore.sqlite" << EOF
        CREATE TABLE webappsstore2 (scope TEXT, key TEXT, value TEXT, secure INTEGER, owner TEXT);
        CREATE UNIQUE INDEX scope_key_index ON webappsstore2(scope, key);
        INSERT INTO webappsstore2 (scope, key, value) VALUES ("${REVERSEHOST}.:https:443", "debug", "true");
        INSERT INTO webappsstore2 (scope, key, value) VALUES ("${REVERSEHOST}.:https:443", "skipHaircheck", "true");
        INSERT INTO webappsstore2 (scope, key, value) VALUES ("${REVERSEHOST}.:https:443", "useFirefoxFakeDevice", "true");
EOF
    ;;
esac

# create log file
LOG_FILE="${D}/chrome_debug.log"
touch $LOG_FILE


# setup xvfb
XVFB="xvfb-run -a -e $LOG_FILE -s '-screen 0 1024x768x24'"
if [ -n "$DISPLAY" ]; then
  XVFB=""
fi

BROWSER_ARGS="--use-fake-ui-for-media-stream --use-fake-device-for-media-stream"

# run xvfb
# "eval" below is required by $XVFB containing a quoted argument.
eval $XVFB $BROWSER \
  --enable-logging=stderr \
  --no-first-run \
  --no-default-browser-check \
  --disable-translate \
  --user-data-dir=$D \
  ${BROWSER_ARGS} \
  --vmodule="*media/*=3,*turn*=3" \
  "${URL}" > $LOG_FILE 2>&1 &
PID=$!

# wait for stop condition to appear in log
while ! grep -q "${COND}" $LOG_FILE && browser_pids|grep -q .; do
  sleep 0.1
done

# give the peer a little time to notice
sleep 5

# evaluate whether we were successful
DONE=$(grep "${COND}" $LOG_FILE)
EXIT_CODE=0
if ! grep -q "${COND}" $LOG_FILE; then
  cat $LOG_FILE
  EXIT_CODE=1
fi

exit $EXIT_CODE
