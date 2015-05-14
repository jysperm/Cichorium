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
errorResolvedError = new Error 'Error resolved'

nextRoute = ->
  throw nextRouteError

errorResolved = ->
  throw errorResolvedError

###
  Public: Cichorium
###
class Cichorium
  ###
    Public: Constructor

    * `routes` {Array} of {Route}, {Route} can be one of:

      * {Array} of {Route}.
      * {Function} represents a middleware `(req, res) -> Promise`.

  ###
  constructor: (routes) ->
    @routes = routes ? []

    @errorRoutes = [
      (req, res, err) ->
        console.error err.message, err.stack
        res.send 500, err.message
    ]

  ###
    Public: Skip other middleware on this route.
  ###
  nextRoute: nextRoute

  ###
    Public: Resolved current error.
  ###
  errorResolved: errorResolved

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

    Return {Promise} resolve when finished all middleware.
  ###
  handle: (req, res) ->
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

    handleRoute(@routes, [req, res]).done ->
      unless executedRoutes
        res.send 404, "Cannot #{req.method} #{req.url}"

      unless res.finished and !socket.writable
        res.res.end()

    , (err) =>
      async.eachSeries @errorRoutes, (route) ->
        handleRoute(route, [req, res, err]).catch (latestErr) ->
          if latestErr == errorResolvedError
            if err.lastError
              err = err.lastError
            else
              throw latestErr
          else
            latestErr.lastError = err
            err = latestErr
      .catch (err) ->
        unless err == errorResolvedError
          throw err

  ###
    Public: Push a error route.

    * `route` {Route}

  ###
  catch: (route) ->
    @errorRoutes.push route

  ###
    Public: Push a route.

    * `route` {Route}

  ###
  pushRoute: (route) ->
    @routes.push route

  ###
    Public: Shorthand to add routes match specified prefix.

    * `prefix` (optional) {String} or {RegExp} match url.
    * `route...` {Route}

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

    * `method` {String} or {Array}.
    * `prefix` (optional) {String} or {RegExp}.
    * `route...` {Route}

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
