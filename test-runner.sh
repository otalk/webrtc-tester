#!/bin/bash
(
  flock -x -w 10 200 || exit 1

  TIMEOUT="90"
  DISPLAY=
  HOST=${1:-"beta.talky.io"}
  ROOM="automatedtesting_${RANDOM}"
  COND=${2:-"P2P connected"} # talky
  #COND="data channel open" # talky pro
  #COND="ICE connection state changed to: connected" # apprtc
  #COND="onCallActive" # go
  #COND="Data channel opened" # meet

  # make sure we kill any Xvfb instances
  function cleanup() {
    function xvfb_pids() {
      ps x -o "%r %p %c" | grep X[v]fb | grep $$ | awk '{print $2}'
    }
    function xvfb_ppids() {
      ps x -o "%r %p %c" | grep X[v]fb | grep $PPID | awk '{print $2}'
    }
    exec 3>&2
    exec 2>/dev/null
    while [ ! -z "$(xvfb_pids)" ]; do
      kill $(xvfb_pids)
    done
    # account for other scripts running this
    while [ ! -z "$(xvfb_ppids)" ]; do
      kill $(xvfb_ppids)
    done
    pkill -HUP -P $pidwatch
    pkill -HUP -P $pidwatch2
    exec 2>&3
    exec 3>&-
  }
  trap cleanup EXIT

  # this timeout is for the overall test process
  ( sleep ${TIMEOUT} ) &
  pidwatcher=$!

  # browser #1
  ( ./test-browser.sh google-chrome $HOST "${ROOM}" "${COND}" >> log1.log 2>&1 ; kill $pidwatcher 2> /dev/null ) 2>/dev/null &
  pidwatch=$!

  # browser #2
  ( ./test-browser.sh chromium-browser $HOST "${ROOM}" "${COND}" >> log2.log 2>&1 ; kill $pidwatcher 2> /dev/null ) 2>/dev/null &
  pidwatch2=$!

  #echo "${pidwatcher} watching ${pidwatch} ${pidwatch2}"

  if wait $pidwatcher 2>/dev/null; then
    echo "--- timedout"
    cat log1.log
    cat log2.log
  fi
  # do nothing in the case of success
) 200>/var/lock/webrtc-tester.exclusivelock
