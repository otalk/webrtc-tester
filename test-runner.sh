#!/bin/bash
TIMEOUT="60"
DISPLAY=
HOST="beta.talky.io"
ROOM="automattedtesting_${RANDOM}"
COND="P2P connected" # talky
#COND="data channel open" # talky pro

# this timeout is for the overall test process
( sleep ${TIMEOUT} ) &
pidwatcher=$!
 
# browser #1
( ./test-chrome.sh $HOST "${ROOM}" "${COND}" >> log1.log 2>&1 ; kill $pidwatcher ) &
pidwatch=$!
 
# browser #2
( ./test-chrome.sh $HOST "${ROOM}" "${COND}" >> log2.log 2>&1 ; kill $pidwatcher ) &
pidwatch2=$!
 
# now give them some time to connect
 
echo "${pidwatcher} watching ${pidwatch} ${pidwatch2}"
 
if wait $pidwatcher ; then
  echo "--- timedout"
else
  echo "--- finished"
fi
 
pkill -HUP -P $pidwatch
pkill -HUP -P $pidwatch2
