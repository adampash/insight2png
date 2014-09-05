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
