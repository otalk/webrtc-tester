webrtc-tester
=============

WebRTC Deployment Testing Toolkit

See [this blogpost](https://blog.andyet.com/2014/09/29/testing-webrtc-applications) about how we use this for testing [Talky](https://talky.io) deployments.

#Required software (tested in Ubuntu only)
* xvfb
* sqlite3
* python-pip
* google-chrome
* chromium-browser
* firefox
  * mozrunner (via pip/easy\_install)

#Running test-cron.sh
test-cron.sh should be supervised by Runit or the supervisor of your choice. Parallel execution of test-runner.sh will cause CPU thrashing on many systems and test results become unreliable. Crontab would not be able to guarantee serial execution of test-runner.sh - hence the supervised approach.

#webrtc-test-runner.runit
Included is a sample Runit directory. After installing [Runit](http://smarden.org/runit/install.html):
* clone this repo to `/opt/sbin/webrtc-tester`
* modify the `# Send your alert` line of test-cron.sh to point to a script to send an alert on failure
* move `webrtc-test-runner.runit` to `/etc/sv/webrtc-test-runner`
* create a log directory in `/var/log/webrtc-test-runner`
* Symlink the directory to `/etc/service/webrtc-test-runner`
* You are now monitoring some webrtc sites!

#Recommended reading
The webrtc team has published two excellent blog posts on automatted interop testing between Firefox and Chrome:
* [Chrome - Firefox WebRTC Interop Test - Part 1](http://googletesting.blogspot.se/2014/08/chrome-firefox-webrtc-interop-test-pt-1.html)
* [Chrome - Firefox WebRTC Interop Test - Part 2](http://googletesting.blogspot.se/2014/09/chrome-firefox-webrtc-interop-test-pt-2.html)

The test scripts in this repository are based on a technique demonstrated by the
[turn-prober.sh](https://github.com/GoogleChrome/webrtc/blob/master/samples/web/content/apprtc/turn-prober/turn-prober.sh) script.
