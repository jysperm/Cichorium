_ = require 'lodash'

###
  Public: Request Wrapper
###
module.exports = class Request
  constructor: (@req) ->
    _.extend @, @req

  ###
    Public: Get remote address.

    Return {String}.
  ###
  ip: ->
    return @req.connection.remoteAddress
