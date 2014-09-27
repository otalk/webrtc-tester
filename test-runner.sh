#!/bin/bash
TIMEOUT="60"
DISPLAY=
HOST="beta.talky.io"
ROOM="automatedtesting_${RANDOM}"
COND="P2P connected" # talky
#COND="data channel open" # talky pro
#COND="ICE connection state changed to: connected" # apprtc
#COND="onCallActive" # go
#COND="Data channel opened" # meet

# make sure we kill any Xvfb instances
function cleanup() {
  function xvfb_pids() {
    ps x -o "%p %r %c" | grep Xvfb | grep $$ | awk '{print $1}'
  }
  while [ ! -z "$(xvfb_pids)" ]; do
    kill $(xvfb_pids)
  done
  pkill -HUP -P $pidwatch
  pkill -HUP -P $pidwatch2
}
trap cleanup EXIT
# this timeout is for the overall test process
( sleep ${TIMEOUT} ) &
pidwatcher=$!
 
# browser #1
( ./test-chrome.sh google-chrome $HOST "${ROOM}" "${COND}" >> log1.log 2>&1 ; kill $pidwatcher 2> /dev/null ) 2>/dev/null &
pidwatch=$!
 
# browser #2
( ./test-firefox.sh firefox $HOST "${ROOM}" "${COND}" >> log2.log 2>&1 ; kill $pidwatcher 2> /dev/null ) 2>/dev/null &
pidwatch2=$!
 
echo "${pidwatcher} watching ${pidwatch} ${pidwatch2}"
 
if wait $pidwatcher 2>/dev/null; then
  echo "--- timedout"
else
  echo "--- success"
fi
 
