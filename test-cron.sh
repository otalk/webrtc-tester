#!/bin/bash
#
# this script should be supervised by Runit or the supervisor of your choice
# test-runner.sh does not tolerate parallel execution on most systems (causes CPU thrashing)
# crontab would not be able to guarantee serial execution of test-runner.sh
#

SLEEP=15
IFS=$'\n\t'
declare -A ITEMS=(
    ["andyet.talky.io"]="data channel open"
    ["beta.talky.io"]="P2P connected"
    ["talky.io"]="P2P connected"
)

test_run () {
  for host in "${!ITEMS[@]}"; do
    # give enough time for previous test processes to be killed
    sleep $SLEEP
    echo "$host"
    # run the test
    TEST=$(/opt/sbin/webrtc-tester/test-runner.sh "$host" "${ITEMS["$host"]}")
    # A pass produces no output, so test for string for a test fail
    if [ -n "$TEST" ]; then
      echo "[alert] $host: WEBRTC TEST FAIL" | tee /opt/sbin/webrtc-tester/test.log
      echo "$TEST" | tee -a /opt/sbin/webrtc-tester/test.log
      # Send your alert
      /opt/sbin/send-alert.sh /opt/sbin/webrtc-tester/test.log
    fi
  done
}

while true;
do
  # set sleep as needed to increase/decrease frequency of test_run
  sleep 5
  test_run
done