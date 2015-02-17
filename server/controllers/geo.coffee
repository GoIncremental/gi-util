request = require 'request'
module.exports =
  country: (req, res) ->
    request 'http://ipinfo.io/geo', (error, response, body) ->
      g = JSON.parse(body)
      res.json response.statusCode, {countryCode: g.country}
