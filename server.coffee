#!/usr/bin/env slimerjs

server = require("webserver").create()
insight2png = require 'insight2png'
fs = require('fs')

console.log 'Server is running'
server.listen 8080, (request, response) ->
  if request.url.match /^\/insight/
    url = request.queryString.split('url=')[1]
    hashedUrl = hashCode(url)
    if fs.exists "screenshots/#{hashedUrl}.png"
      console.log "Screenshot exists; returning image"
      insight2png.readFile hashedUrl, response, handleImageResponse
    else
      console.log "First request; generating #{hashedUrl}.png"
      insight2png.run url, "#{hashedUrl}.png", response, handleImageResponse

  else
    response.statusCode = 200
    response.write('<!DOCTYPE html>\n<html><head><meta charset="utf-8"><title>hello world</title></head><body>nothing!</body></html>')
    response.close()

handleImageResponse =
  success: (imgData, response) ->
    writeImageToClient response, imgData
  error: (error) ->
    console.log "Something went wrong: #{error}"

writeImageToClient = (response, imgData) ->
  response.writeHead(200, 'Content-Type': 'image/png' )
  response.setEncoding('binary')
  response.write(atob(imgData))
  response.close()


# fast-hashing function pulled from
# http://stackoverflow.com/questions/7616461/
hashCode = (s)->
  s.split("").reduce (a,b) ->
    a=((a<<5)-a)+b.charCodeAt(0)
    return a&a
  , 0
