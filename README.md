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

That's right, there's fun, too! Here's a bookmarklet to generate the image:

[insight2image](javascript:(function(){var e;e=function(){return window.location.href="http://shares.thinkup.com/insight?url="+window.location.href},e()}).call(this);)
