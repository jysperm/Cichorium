async = require 'async-q'
http = require 'http'
_ = require 'lodash'
Q = require 'q'

Request = require './request'
Response = require './response'

httpMethods = [
  'GET', 'HEAD', 'POST'
  'PUT', 'PATCH', 'DELETE', 'OPTIONS'
]

nextRouteError = new Error 'Next route'

nextRoute = ->
  throw nextRouteError

###
  Public: Cichorium
###
class Cichorium
  ###
    Public: Constructor

    * `routes` {Array} of:

      * {Array} of routes
      * {Function} a middleware `(req, res) -> Promise`

  ###
  constructor: (routes) ->
    @routes = routes ? []

    @errorRoutes = [
      (req, res, err) ->
        console.error err.message, err.stack
        res.send 500, err.message
    ]

  ###
    Public: Skip other middlewares on this route.

    This function will throw special exception which can be identified by Cichorium.
  ###
  nextRoute: nextRoute

  ###
    Public: Listen on specified port.

    * `port` {Number}

    Return {Promise} resolve with {http.Server}.
  ###
  listen: (port) ->
    server = http.createServer @handle.bind(@)

    Q.nfcall(server.listen.bind(server), arguments...).then ->
      return server

  ###
    Public: Request entry point.

    * `req` {http.IncomingMessage}
    * `res` {http.ServerResponse}

    Return {Promise} resolve when finished all middlewares.
  ###
  handle: (req, res, next) ->
    req = new Request req
    res = new Response res

    executedRoutes = 0

    handleRoutes = (routes, params) ->
      async.eachSeries routes, (route) ->
        handleRoute(route, params).then ->
          executedRoutes++
        , (err) ->
          unless err == nextRouteError
            throw err

    handleRoute = (route, params) ->
      if _.isArray route
        handleRoutes route, params
      else if _.isFunction route
        Q route params...
      else
        Q.reject new Error 'Route is not Array or Function'

    errorHandling = (err) =>
      async.eachSeries @errorRoutes, (route) ->
        handleRoute(route, [req, res, err]).catch (latestErr) ->
          err = latestErr

    handleRoute(@routes, [req, res]).done ->
      unless executedRoutes
        res.send 404, "Cannot #{req.method} #{req.url}"

      unless res.finished and !socket.writable
        res.res.end()

    , errorHandling

  ###
    Public: Push a error route.

    * `route` Can be one of:

      * {Array} of routes
      * {Function} a middleware `(req, res, err) -> Promise`

  ###
  catch: (route) ->
    @errorRoutes.push route

  ###
    Public: Push a route to end of routes.

    * `route` Can be one of:

      * {Array} of routes
      * {Function} a middleware `(req, res) -> Promise`

  ###
  pushRoute: (route) ->
    @routes.push route

  ###
    Public: Shorthand to add routes match specified prefix.

    * `prefix` (optional) {String} prefix of url, or {RegExp}
    * `routes...` {Array} of {Function} `(req, res) -> Promise`

  ###
  use: (prefix, routes...) ->
    if _.isString prefix
      routes.unshift (req, res) ->
        unless req.url[... prefix.length] == prefix
          nextRoute()

    else if _.isRegExp prefix
      routes.unshift (req, res) ->
        unless prefix.test req.url
          nextRoute()

    else
      routes.unshift prefix

    @pushRoute routes

  ###
    Public: Shorthand to add routes match specified method.

    * `method` {String} or {Array} of {String}.
    * `prefix` (optional) {String} prefix of url.
    * `routes...` {Array} of {Function} `(req, res) -> Promise`

  ###
  useWithMethod: (method, routes...) ->
    routes.unshift (req, res) ->
      unless req.method.toUpperCase() == method.toUpperCase()
        nextRoute()

    @use routes

httpMethods.forEach (method) ->
  Cichorium::[method.toLowerCase()] = ->
    @useWithMethod method, arguments...

module.exports = _.extend Cichorium,
  nextRoute: nextRoute
