async = require 'async'
http = require 'http'
util = require 'util'
_ = require 'underscore'

exports.support_methods = [
  'GET', 'POST', 'PUT', 'HEAD', 'DELETE', 'OPTIONS', 'PATCH'
]

exports.init = ->
  @layers = []

# app.use [layer], [prefix], fn...
exports.use = (args...) ->
  if _.isObject(args[0]) and !_.isFunction(args[0])
    layer = args.shift()
  else
    layer =
      match_stack: []

  if _.isString args[0]
    prefix = args.shift()
    layer.match_stack.push (req) ->
      if req.url[... prefix.length] == prefix
        return true

  for fn in args
    @layers.push _.extend fn, layer

exports.useMethod = (method, args...) ->
  layer =
    match_stack: []

  layer.match_stack.push (req) ->
    return req.method == method.toUpperCase()

  exports.use.apply @, [layer].concat args

exports.support_methods.forEach (method) ->
  exports[method.toLowerCase()] = ->
    param = [method].concat _.toArray arguments
    exports.useMethod.apply @, param

exports.handle = (req, res, next) ->
  unless next
    next = ->

  matched_layers = _.reject @layers, (layer) ->
    for match in layer.match_stack
      unless match req
        return true

  if _.isEmpty matched_layers
    res.statusCode = 404
    res.header 'Content-Type', 'text/html; charset=utf-8'
    return res.end "Cannot #{req.method} #{req.url}\n"

  async.eachSeries matched_layers, (layer, callback) ->
    try
      layer req, res, callback
    catch err
      callback err

  , (err) ->
    if err
      res.statusCode = 500
      res.send util.inspect err
    else
      unless res.finished and !socket.writable
        res.end()

    next()

exports.listen = (port, callback) ->
  server = http.createServer @
  return server.listen.apply server, arguments
