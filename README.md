webrtc-tester
=============

WebRTC Deployment Testing Toolkit

#Required software
* xvfb
* sqlite3
* firefox:
* pip
* mozrunner (via pip/easy\_install)

#Recommended reading
Google has published two excellent blog posts on automatted interop testing between 
Firefox and Chrome:
* [Part 1](http://googletesting.blogspot.se/2014/08/chrome-firefox-webrtc-interop-test-pt-1.html)
* [Part 2](http://googletesting.blogspot.se/2014/09/chrome-firefox-webrtc-interop-test-pt-2.html)

The test scripts in this repository are based on a technique demonstrated by the 
[turn-prober.sh](https://github.com/GoogleChrome/webrtc/blob/master/samples/web/content/apprtc/turn-prober/turn-prober.sh)
