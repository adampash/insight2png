server = require("webserver").create()
insight2png = require 'insight2png'

console.log 'server listening on 8083'
server.listen 8083, (request, response) ->

  if request.url.match /^\/shot/
    url = request.queryString.split('url=')[1]
    insight2png.run url, "#{uniqueId()}.png", ->
      response.statusCode = 200
      response.write('<!DOCTYPE html>\n<html><head><meta charset="utf-8"><title>hello world</title></head><body><img src="/screenshots/server.png" /></body></html>')
      response.close()
  else
    response.statusCode = 200
    response.write('<!DOCTYPE html>\n<html><head><meta charset="utf-8"><title>hello world</title></head><body>nothing!</body></html>')
    response.close()

uniqueId = (length=8) ->
  id = ""
  id += Math.random().toString(36).substr(2) while id.length < length
  id.substr 0, length
