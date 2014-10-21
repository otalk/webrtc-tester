webrtc-tester
=============

WebRTC Deployment Testing Toolkit

See [this blogpost](https://blog.andyet.com/2014/09/29/testing-webrtc-applications) about how we use this for testing [Talky](https://talky.io) deployments.

#Required software
* xvfb
* sqlite3
* python-pip
* google-chrome
* chromium browser
* firefox
  * mozrunner (via pip/easy\_install)

#Recommended reading
The webrtc team has published two excellent blog posts on automatted interop testing between Firefox and Chrome:
* [Chrome - Firefox WebRTC Interop Test - Part 1](http://googletesting.blogspot.se/2014/08/chrome-firefox-webrtc-interop-test-pt-1.html)
* [Chrome - Firefox WebRTC Interop Test - Part 2](http://googletesting.blogspot.se/2014/09/chrome-firefox-webrtc-interop-test-pt-2.html)

The test scripts in this repository are based on a technique demonstrated by the
[turn-prober.sh](https://github.com/GoogleChrome/webrtc/blob/master/samples/web/content/apprtc/turn-prober/turn-prober.sh) script.
