http = require 'http'
async = require 'async'

exports.init = ->
  @stack = []

exports.use = (fn) ->
  fn.match = -> true
  @stack.push fn

exports.handle = (req, res, next) ->
  unless next
    next = ->

  async.eachSeries @stack, (fn, callback) ->
    unless fn.match req
      return callback()

    fn req, res, callback

  , next

exports.listen = (port, callback) ->
  server = http.createServer @
  return server.listen.apply server, arguments
