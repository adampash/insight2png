#!/usr/bin/env slimerjs

system = require("system")
server = require("webserver").create()
insight2png = require 'insight2png'
fs = require('fs')

TU_REGEX = /^https:\/\/.+\.thinkup\.com\/\?u=/

if system.args.length < 2 or system.args.length > 3
  domain = "localhost"
  port = 8080
else
  domain = system.args[1]
  port = system.args[2]

console.log "Server is running on #{domain}:#{port}\n"
server.listen "#{domain}:#{port}", (request, response) ->
  return if request.url is '/favicon.ico'
  response.start = new Date()
  if request.url.match /^\/insight/
    url = request.queryString.split('url=')[1]
    return fourOhFour(response, url) unless url? and url.match TU_REGEX
    hashedUrl = hashCode(url)
    if fs.exists "screenshots/#{hashedUrl}.png"
      console.log "Screenshot exists; returning image"
      insight2png.readFile hashedUrl, response, handleImageResponse
    else
      console.log "First request; generating #{hashedUrl}.png"
      insight2png.run url, "#{hashedUrl}.png", response, handleImageResponse

  else
    fourOhFour(response)





handleImageResponse =
  success: (imgData, response) ->
    writeImageToClient response, imgData
  error: (error, response) ->
    console.log "Something went wrong: #{error}"
    fourOhFour(response, error)


writeImageToClient = (response, imgData) ->
  response.writeHead(200, 'Content-Type': 'image/png' )
  response.setEncoding('binary')
  response.write(atob(imgData))
  close(response)


fourOhFour = (response, url="No url requested") ->
  console.log "404:"
  console.log "Requested url:"
  console.log "#{url}"
  response.statusCode = 404
  response.write('<!DOCTYPE html>\n<html><head><meta charset="utf-8"><title>404</title></head><body>404: Resource not found</body></html>')
  close(response)


close = (response) ->
  logTime(response.start)
  response.close()


logTime = (start) ->
  console.log("#{(new Date()-start)/1000} seconds\n")


# quick hashing function pulled from
# http://stackoverflow.com/questions/7616461/
hashCode = (s)->
  s.split("").reduce (a,b) ->
    a=((a<<5)-a)+b.charCodeAt(0)
    return a&a
  , 0
