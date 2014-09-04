#!/usr/bin/env slimerjs

webpage = require("webpage")
system = require("system")
fs = require("fs")

module.exports = insight2png =
  run: (url, filename, response, callbacks={}) ->
    getImage = =>
      try
        imgData = @renderPage page, filename
        return callbacks.success(imgData, response) if callbacks.success?
        slimer.exit 0
      catch error
        return callbacks.error(error, response) if callbacks.error?

    start = new Date()
    page = webpage.create()

    # below for debugging
    page.onAlert = (text) ->
      console.log("Alert: " +text);

    page.viewportSize =
      width: 800
      height: 500

    # below required for typekit (maybe not? commenting out to test)
    # page.settings.userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1312.57 Safari/537.17"
    # page.customHeaders = Referer: url

    # this callback is only triggered
    # for insights with visualizations
    page.onCallback = (arg) ->
      clearTimeout chartTimeout
      console.log arg + "Visualization loaded"
      getImage()
    chartTimeout = null

    page.open url, (status) =>
      if status isnt "success"
        console.log "Unable to open URL."
        return callbacks.error("Unable to open URL", response) if callbacks.error?
        slimer.exit 1
      else
        vis = page.evaluate ->
          google.visualization
        if vis?
          chartTimeout = setTimeout getImage, 6e3
        else
          getImage()


  renderPage: (page, filename) ->
    page.evaluate ->
      # this is for smoothing over on xvfb; don't use if don't have to
      $('.user-name, .user-text').css('font-size', '14.25px')
      $('.panel-body-inner p').css('font-size', '14.25px')
      $('.panel-title').css('font-weight', 'bold')
      $('.panel-subtitle').css('font-weight', 'lighter')
        .css('font-size', '14.5px')
      $('body').css('font', 'helvetica')
      # $('.panel-body-inner').css('font-size', '16px')
      $('.insight-metadata').css('font-size', '12.5px')
      $('.tweet-action.tweet-action-permalink').css('font-size', '12.5px')

    offset = page.evaluate ->
      $('.insight').offset()

    crop = @getImageDimensions page, '.insight'

    page.clipRect =
      top: offset.top
      left: offset.left
      width: crop.width
      height: crop.height

    console.log 'Rendering page'
    page.render("screenshots/#{filename}")
    page.renderBase64('png')

  readFile: (filename, response, callbacks={}) ->
    start = new Date()
    page = webpage.create()
    url = "#{fs.workingDirectory}/screenshots/#{filename}.png"
    page.open url, (status) =>
      if status isnt "success"
        return callback.error("Unable to open URL", response) if callbacks.error?
        slimer.exit 1
      else
        try
          size = @getImageDimensions page, '.decoded'
          page.viewportSize =
            width: size.width
            height: size.height

          imgData = page.renderBase64('png')
          # @logTime(start)
          return callbacks.success(imgData, response) if callbacks.success?
          slimer.exit 0
          return
        catch error
          return callbacks.error(error, response) if callbacks.error?

  getImageDimensions: (page, selector) ->
    size = page.evaluate (selector) ->
      insight = document.querySelector(selector)
      throw "Insight not found on page" unless insight?
      offset =
        height: insight.offsetHeight
        width: insight.offsetWidth
    , selector

  logTime: (start) ->
    end = new Date()
    console.log("#{(end-start)/1000} seconds\n")

unless system.args[0].match /server\.coffee/
  if system.args.length < 2 or system.args.length > 3
    console.log "Usage: insight2png URL filename"
    slimer.exit 1
  else
    url = system.args[1]
    filename = system.args[2]
    insight2png.run(url, filename)
