async = require 'async'
http = require 'http'
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

['GET', 'POST', 'HEAD', 'OPTIONS'].forEach (method) ->
  exports[method.toLowerCase()] = ->
    param = [method].concat _.toArray arguments
    exports.useMethod.apply @, param

exports.handle = (req, res, next) ->
  unless next
    next = ->

  async.eachSeries @stack, (layer, callback) ->
    for match in layer.match_stack
      unless match req
        return callback()

    layer req, res, callback

  , next

exports.listen = (port, callback) ->
  server = http.createServer @
  return server.listen.apply server, arguments
