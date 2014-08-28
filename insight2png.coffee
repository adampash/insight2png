webpage = require("webpage")
system = require("system")

if system.args.length < 2 or system.args.length > 3
  console.log "Usage: insight2png URL filename"
  phantom.exit 1
else
  start = new Date()
  page = webpage.create()
  url = system.args[1]
  filename = system.args[2]
  page.viewportSize =
    width: 800
    height: 500

  # below required for typekit
  page.settings.userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1312.57 Safari/537.17"
  page.customHeaders = Referer: url

  page.open url, (status) ->
    if status isnt "success"
      console.log "Unable to open URL."
      phantom.exit 1
    else
      # window.setTimeout (->
      renderPage page, filename
      end = new Date()
      console.log("#{(end-start)/1000} seconds")
      phantom.exit 0
      return
      # ), 4000
    return


renderPage = (page, filename) ->
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

  crop = page.evaluate ->
    insight = document.querySelector('.insight')
    # insight = document.querySelectorAll('.insight')[8]
    offset =
      height: insight.offsetHeight
      width: insight.offsetWidth

  page.clipRect =
    top: offset.top
    left: offset.left
    width: crop.width
    height: crop.height

  console.log 'rendering page'
  page.render("screenshots/#{filename}")
