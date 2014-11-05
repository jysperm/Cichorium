_ = require 'underscore'

application = require './lib/application'
request = require './lib/request'
response = require './lib/response'

module.exports = ->
  app = (req, res, next) ->
    _.extend req, request
    _.extend res, response

    app.handle req, res, next

  _.extend app, application

  app.init()

  return app
