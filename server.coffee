server = require("webserver").create()
insight2png = require 'insight2png'

server.listen 8083, (request, response) ->
  server.registerFile('/screenshots/server.png', '/Users/ap/code/insight2png/screenshots/server.png')

  if request.url.match /^\/shot/
    url = request.queryString.split('url=')[1]
    insight2png.run url, 'server.png', ->
      response.statusCode = 200
      response.write('<!DOCTYPE html>\n<html><head><meta charset="utf-8"><title>hello world</title></head><body><img src="/screenshots/server.png" /></body></html>')
      response.close()
  else
    response.statusCode = 200
    response.write('<!DOCTYPE html>\n<html><head><meta charset="utf-8"><title>hello world</title></head><body>nothing!</body></html>')
    response.close()
