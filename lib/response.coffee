_ = require 'underscore'

# res.header name, value
# res.header object
exports.header = (name, value) ->
  headers = name

  unless _.isObject headers
    headers = {}
    headers[name] = value

  for name, value of headers
    @setHeader name, value

# res.send status, data
# res.send status
# res.send data
exports.send = (status, data) ->
  unless _.isNumber status
    [status, data] = [null, status]

  if status
    @statusCode = status

  @end data

# res.json status, object
# res.json object
exports.json = (status, data) ->
  unless _.isNumber status
    [status, data] = [null, status]

  if status
    @statusCode = status

  @header 'Content-Type', 'application/json'
  @send JSON.stringify data

exports.cookie = (name, value, options) ->

exports.redirect = (status, url) ->

exports.render = (view, view_data, callback) ->
