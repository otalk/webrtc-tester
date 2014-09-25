#!/bin/bash
TIMEOUT="60"
HOST="beta.talky.io"
ROOM="automattedtesting_${RANDOM}"
COND="P2P connected" # talky
#COND="data channel open" # talky pro


# chrome #1
( ./test-chrome.sh $HOST "${ROOM}" "${COND}" >> log1.log 2>&1 ) &
pidwatch=$!

# chrome #2
( ./test-chrome.sh $HOST "${ROOM}" "${COND}" >> log2.log 2>&1 ) &
pidwatch2=$!

# now give them some time to connect

# this timeout is for the overall test process
( sleep ${TIMEOUT} ; kill $pidwatch > /dev/null 2>&1 ; kill $pidwatch2 > /dev/null 2>&1 ; echo "timedout" ) &
pidwatcher=$!

echo "${pidwatch} ${pidwatch2} ${pidwatcher}"

if wait $pidwatch2 ; then
  echo "--- finished" #                 | tee -a ~/test_run.log
else
  echo "--- stopped" #                  | tee -a ~/test_run.log
fi

pkill -HUP -P $pidwatcher
