_ = require 'underscore'

application = require './lib/application'

module.exports = ->
  app = (req, res, next) ->
    app.handle req, res, next

  _.extend app, application

  app.init()

  return app
