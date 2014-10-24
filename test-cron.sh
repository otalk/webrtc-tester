#!/bin/bash
IFS=$'\n\t'
declare -A ITEMS=(
    ["andyet.talky.io"]="data channel open"
    ["beta.talky.io"]="P2P connected"
    ["talky.io"]="P2P connected"
)
for host in "${!ITEMS[@]}"; do
    TEST=$(/opt/sbin/webrtc-tester/test-runner.sh "$host" "${ITEMS["$host"]}")
    # A pass produces no output, so test for string for a test fail
    if [ -n "$TEST" ]; then
      echo "[alert] $host: WEBRTC TEST FAIL" | tee /opt/sbin/webrtc-tester/test.log
      echo "$TEST" | tee -a /opt/sbin/webrtc-tester/test.log
      # Send your alert
      /opt/sbin/send-alert.sh /opt/sbin/webrtc-tester/test.log
    fi
done
