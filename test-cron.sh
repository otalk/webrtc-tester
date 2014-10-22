#!/bin/bash
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

# Run test
cd /opt/sbin/webrtc-tester/
TEST=$(./test-runner.sh "$1" "$2")

# A pass produces no output, so test for string for a test fail
if [ -n "$TEST" ]; then
  echo "[alert] $1: WEBRTC TEST FAIL" | tee /opt/sbin/webrtc-tester/test.log
  echo "$TEST" | tee -a /opt/sbin/webrtc-tester/test.log

  # Send your alert
  /opt/sbin/send-alert.sh /opt/sbin/webrtc-tester/test.log
fi