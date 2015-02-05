#!/bin/bash
SLEEP=300 # time between attempts
SERVERNUM=99

# Argument 1: host
if [ -z "$1" ]; then
    echo "missing 'host' argument (string)"
    exit 1
fi

# Argument 2: condition
if [ -z "$2" ]; then
    echo "missing 'condition' argument (string)"
    exit 1
fi

HOST=$1
COND=$2
# start Xvfb
export DISPLAY=:$SERVERNUM
# TODO: steal the automagic servernum from xvfb-run
Xvfb $DISPLAY >/dev/null 2>&1 &
#FIXME: check Xvfb actually works...

test_run () {
  TEST=$(./test-runner.sh $HOST $COND)
  # A pass produces no output, so test for string for a test fail
  if [ -n "$TEST" ]; then
    echo "[alert] $host: WEBRTC TEST FAIL" | tee test.log
    echo "$TEST" | tee -a test.log
    # Send your alert
    # assumes a send-alert.sh script in /opt/sbin obviously
    /opt/sbin/send-alert.sh test.log
  fi
}

# Run test forever
while true;
do
  test_run
  # set sleep as needed to increase/decrease frequency of test_run
  sleep $SLEEP
done
