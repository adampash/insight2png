converter = require './convert'
http = require 'http'

console.log converter

http.createServer (req, res) ->
  return if req.url is '/favicon.ico'

  console.log req.url

  res.writeHead 200,
   'Content-Type': 'text/plain'

  if req.url is '/shot'
    converter.screencap "https://adampash.thinkup.com", ->
      res.write 'shot'
      res.end()
  else
    res.write 'foo'
    res.end()
.listen 1337, "127.0.01"
