requestOptions = require './requestOptions'
querySplitter = require './querySplitter'

module.exports = () ->
  describe 'public', ->
    requestOptions()
  describe 'private', ->
    querySplitter()