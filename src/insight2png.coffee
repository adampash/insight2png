#!/usr/bin/env slimerjs

webpage = require("webpage")
system = require("system")
fs = require("fs")

module.exports = class Insight2png
  constructor: (@url, @filename, @response, @callbacks) ->

  run: ->
    getImage = =>
      try
        imgData = @renderPage @page, @filename
      catch error
        @response.error = error
      finally
        if imgData?
          return @callbacks.success(imgData, @response) if @callbacks.success?
          slimer.exit 0
        else
          error = @response.error or "No insight on page"
          return @callbacks.error(error, @response) if @callbacks.error?

    start = new Date()
    @page = webpage.create()

    # below for debugging
    # @page.onAlert = (text) ->
    #   console.log("Alert: " +text);

    @page.viewportSize =
      width: 800
      height: 500

    # this callback is only triggered
    # for insights with visualizations
    @page.onCallback = =>
      clearTimeout chartTimeout
      @response.log += "Visualization loaded\n"
      # console.log "Visualization loaded"
      if @url.match /weekly_graph$/
        setTimeout ->
          getImage()
        , 1500
      else if @url.match /insight_tester.+&preview=1/
        setTimeout ->
          getImage()
        , 100
      else
        getImage()

    chartTimeout = null

    @page.open @url, (status) =>
      if status isnt "success"
        # console.log "Unable to open URL."
        @response.log += "Unable to open URL.\n"
        return @callbacks.error("Unable to open URL", @response) if @callbacks.error?
        slimer.exit 1
      else
        vis = @page.evaluate ->
          google.visualization
        if vis? or @url.match /insight_tester.+&preview=1/
          chartTimeout = setTimeout getImage, 6e3
        else
          getImage()


  renderPage: ->
    return null unless @page.evaluate ->
      $('.insight').length
    @page.evaluate ->
      # add brand to insight
      brand = "https://thinkup.thinkup.com/assets/img/thinkup-logo-white.png"
      if $('.insight').height() - $('.preview-headline').height() < 30
        $('.panel-title').height($('.panel-title').height() + 30)
      height = $('.insight').height() - 27
      # bottom left
      $('.panel-heading').append($("<img class=\"insight-brand\" style=\"height:18px; position: absolute; top: #{height}px;\" src=\"#{brand}\" />"))
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

    offset = @page.evaluate ->
      $('.insight').offset()

    crop = @getImageDimensions '.insight'

    @page.clipRect =
      top: offset.top
      left: offset.left
      width: crop.width
      height: crop.height

    @response.log += 'Rendering page: '
    @response.log += @filename
    # console.log 'Rendering page'
    # console.log @filename
    @page.render("screenshots/#{@filename}")
    @page.renderBase64('png')

  readFile: ->
    start = new Date()
    @page = webpage.create()
    @url = "#{fs.workingDirectory}/screenshots/#{@filename}"
    @page.open @url, (status) =>
      if status isnt "success"
        return @callbacks.error("Unable to open URL", @response) if @callbacks.error?
        slimer.exit 1
      else
        try
          size = @getImageDimensions '.decoded'
          return @callbacks.error("No image found on page", @response) if @callbacks.error? and !size?
          @page.viewportSize =
            width: size.width
            height: size.height

          imgData = @page.renderBase64('png')
          # @logTime(start)
        catch error
          @response.error = error
        finally
          if imgData?
            return @callbacks.success(imgData, @response) if @callbacks.success?
            slimer.exit 0
          else
            error = @response.error or "No image on page"
            return @callbacks.error(error, @response) if @callbacks.error?

  getImageDimensions: (selector) ->
    size = @page.evaluate (selector) ->
      insight = document.querySelector(selector)
      unless insight?
        return null
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
    new Insight2png(url, filename).run()

