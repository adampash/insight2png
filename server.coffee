#!/usr/bin/env slimerjs

system = require("system")
server = require("webserver").create()
Insight2png = require 'insight2png'
fs = require('fs')

TU_REGEX = /^tu=.+&u=.+&n=.+&d=.+&s=.+&share=1$/

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
    params = decodeURIComponent request.queryString.split()
    unless params? and params.match TU_REGEX
      return fourOhFour(response, "Not a valid request")
    tuUser = params.substr(3).split('&')[0]
    url = "https://#{tuUser}.thinkup.com/?#{params.split("tu=#{tuUser}&")[1]}"
    console.log url
    filename = "#{hashCode(url)}.png"
    insight2png = new Insight2png(url, filename, response)
    if fs.exists "screenshots/#{filename}"
      console.log "Screenshot exists; returning image"
      insight2png.readFile handleImageResponse
    else
      console.log "First request; generating #{filename}"
      insight2png.run handleImageResponse

  else
    fourOhFour(response)





handleImageResponse =
  success: (imgData, response) ->
    writeImageToClient response, imgData
  error: (error, response) ->
    msg = error
    fourOhFour(response, msg)


writeImageToClient = (response, imgData) ->
  response.writeHead(200, 'Content-Type': 'image/png' )
  response.setEncoding('binary')
  response.write(atob(imgData))
  close(response)


fourOhFour = (response, msg="No url requested") ->
  console.log "404:"
  console.log "#{msg}"
  response.statusCode = 404
  response.write("<!DOCTYPE html>\n<html><head><meta charset=\"utf-8\"><title>404</title></head><body>404: #{msg}</body></html>")
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
