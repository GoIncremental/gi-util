loggly = require 'loggly'

logglyClient = null
prefix = ""
tags = []

configure = () ->
  customer = process.env.GI_CUSTOMER
  product = process.env.GI_PRODUCT
  environment = process.env.GI_APP_ENVIRONMENT
  version = process.env.GI_APP_VERSION

  if customer?
    prefix += customer
    tags.push customer
  else
    prefix = "NO CUSTOMER"
    tags.push ["NO CUSTOMER"]
  if product?
    prefix += ":" + product
    tags.push product
  if environment?
    prefix += ":" + environment
    tags.push environment
  if version?
    prefix += ":" + version
    tags.push version

  prefix += ": "

  if process.env.LOGGLY_API_KEY?
    logglyClient = loggly.createClient
      token: process.env.LOGGLY_API_KEY
      subdomain: process.env.LOGGLY_SUB_DOMAIN
      json: true
  else
    console.log 'loggly not available'

log = (msg) ->
  if logglyClient?
    if (typeof msg) is 'string'
      logglyClient.log(prefix + msg, tags)
    else
      msg.prefix = prefix
      logglyClient.log msg, tags

module.exports =
  configure: configure
  log: log
