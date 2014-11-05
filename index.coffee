http = require 'http'
_ = require 'underscore'

application = require './lib/application'
request = require './lib/request'
response = require './lib/response'

request.__proto__ = http.IncomingMessage.prototype
response.__proto__ = http.ServerResponse.prototype

module.exports = ->
  app = (req, res, next) ->
    req.__proto__ = request
    res.__proto__ = response

    app.handle req, res, next

  _.extend app, application

  app.init()

  return app
