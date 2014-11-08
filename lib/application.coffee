async = require 'async'
http = require 'http'
util = require 'util'
_ = require 'underscore'

exports.init = ->
  @stack = []

# app.use [layer], [prefix], fn...
exports.use = (args...) ->
  if _.isObject(_.first(args)) and not _.isFunction _.first(args)
    layer = args.shift()
  else
    layer =
      match_stack: []

  if _.isString _.first args
    prefix = args.shift()
    layer.match_stack.push (req) ->
      if req.url[... prefix.length] == prefix
        return true

  for fn in args
    @stack.push _.extend fn, layer

exports.useMethod = (method, args...) ->
  layer =
    match_stack: []

  layer.match_stack.push (req) ->
    return req.method == method.toUpperCase()

  exports.use.apply @, [layer].concat args

['GET', 'POST', 'PUT', 'HEAD', 'DELETE', 'OPTIONS', 'PATCH'].forEach (method) ->
  exports[method.toLowerCase()] = ->
    param = [method].concat _.toArray arguments
    exports.useMethod.apply @, param

exports.handle = (req, res, next) ->
  unless next
    next = ->

  matched_stack = _.filter @stack, (layer) ->
    for match in layer.match_stack
      unless match req
        return false

    return true

  if _.isEmpty matched_stack
    res.statusCode = 404
    res.header 'Content-Type', 'text/html; charset=utf-8'
    return res.end "Cannot #{req.method} #{req.url}\n"

  async.eachSeries matched_stack, (layer, callback) ->
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
