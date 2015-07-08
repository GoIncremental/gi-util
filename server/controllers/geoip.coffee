request = require 'request'
common = require '../common'

module.exports = () ->
  apiEndpoint = process.env.GOINC_API_ENDPOINT
  apiVer = process.env.GOINC_API_VERSION

  my: (req, res) ->
    common.log "IP request: " + req.ip + "X-Forwarded-For: " + req.get('x-forwarded-for')
    request apiEndpoint + "/" + apiVer + "/" + "/geoip/" + req.get('x-forwarded-for')
    , (err, response, body) ->
      common.log 'back from goinc api'
      if err?
        common.log err
        res.json 500, err.toString()
      else
        common.log body
        res.json 200, JSON.parse(body)
