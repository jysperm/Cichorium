{IncomingMessage} = require 'http'
_ = require 'lodash'

module.exports = class Request extends IncomingMessage
  constructor: (req) ->
    _.extend @, req

  ip: ->
    return @connection.remoteAddress
