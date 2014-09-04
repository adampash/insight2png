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
