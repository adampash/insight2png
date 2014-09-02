server = require("webserver").create()
insight2png = require 'insight2png'
fs = require('fs')

console.log 'Server is running'
server.listen 8080, (request, response) ->
  if request.url.match /^\/insight/
    url = request.queryString.split('url=')[1]
    hashedUrl = hashCode(url)
    console.log "checking for #{hashedUrl}.png"
    try
      file = fs.readFileSync "screenshots/#{hashedUrl}.png"
      console.log file
      # imgData = file.toString('base64')
      # console.log 'imgData'
      # console.log imgData

      # response.writeHead(200, 'Content-Type': 'image/png' )
      # response.setEncoding('binary')
      # response.write(atob(imgData))

      response.writeHead(200, 'Content-Type': 'text/plain' )
      response.write('Already exists')
      response.close()
    catch error
      console.log error
      console.log "first request for #{hashedUrl}.png"
      insight2png.run url, "#{hashedUrl}.png", (img, imgData) ->
        response.writeHead(200, 'Content-Type': 'image/png' )
        response.setEncoding('binary')
        response.write(atob(imgData))
        response.close()
  else
    response.statusCode = 200
    response.write('<!DOCTYPE html>\n<html><head><meta charset="utf-8"><title>hello world</title></head><body>nothing!</body></html>')
    response.close()

# fast-hashing function pulled from
# http://stackoverflow.com/questions/7616461/
hashCode = (s)->
  s.split("").reduce (a,b) ->
    a=((a<<5)-a)+b.charCodeAt(0)
    return a&a
  , 0
