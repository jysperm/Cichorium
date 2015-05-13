_ = require 'lodash'

module.exports = class Request
  constructor: (@req) ->
    _.extend @, req

  ip: ->
    return @req.connection.remoteAddress
