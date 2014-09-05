# Requirements:

* [slimerjs](http://slimerjs.org/)
* xvfb (`apt-get install xvfb`)

# Run:
```
xvfb-run slimerjs server.coffee
```

Point browser to:

```
http://localhost:8080/insight.png?url=<full_url_of_insight>
```

And get an image.

# Fun:

That's right, there's fun, too! There's a bookmarklet to generate the image from an insight permalink. Unfortunately you can't embed javascript links in GitHub, but you can get it [here](http://files.adampash.com/thinkup/bookmarklet/).

## Develop

I had to move insight2png.coffee to a src dir and compile it to js b/c slimer's coffeescript compiler wasn't handling the new object-ified version of insight2png. If you're developing, just run `./watch` while and edits to insight2png.coffee in the src dir will compile to insight2png.js.

## Installation

This is the current configuration of the server:

* m1.small
* ami-08389d60
* "shares" Security Group
* Region Virginia
* AZ C
* "thinkup" PEM

```
$ sudo -s
# apt-get update
# apt-get -y dist-upgrade
# dpkg-reconfigure tzdata
	[America]
	[New_York]
# apt-get -y install libc6 libstdc++6 libgcc1 libgtk2.0-0 libasound2 libxrender1 git firefox xvfb
# wget http://download.slimerjs.org/releases/0.9.2/slimerjs-0.9.2-linux-x86_64.tar.bz2
# bzip2 -d slimerjs-0.9.2-linux-x86_64.tar.bz2
# tar -xf slimerjs-0.9.2-linux-x86_64.tar
# git clone https://github.com/adampash/insight2png.git i2p (Calling it "insight2png" confuses slimer's module loading)
# export SLIMERJSLAUNCHER=/usr/bin/firefox
# cp i2p/config/prefs.js slimerjs-0.9.2/defaults/preferences/prefs.js
# cp i2p/init/insight2png.conf /etc/init
# start insight2png
```

This logs to `/var/log/insight2png.log.i`
