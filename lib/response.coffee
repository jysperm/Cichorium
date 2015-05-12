{ServerResponse} = require 'http'
_ = require 'lodash'

module.exports = class Response extends ServerResponse
  constructor: (req) ->
    _.extend @, req

  # res.header name, value
  # res.header object
  header: (name, value) ->
    headers = name

    unless _.isObject headers
      headers = {}
      headers[name] = value

    for name, value of headers
      @setHeader name, value

  # res.send status, data
  # res.send status
  # res.send data
  send: (status, data) ->
    unless !status or _.isNumber status
      [status, data] = [null, status]

    if status
      @statusCode = status

    @end data

  # res.json status, object
  # res.json object
  json: (status, data) ->
    @header 'Content-Type', 'application/json'
    @send status, JSON.stringify data

  # res.redirect status, url
  # res.redirect url
  redirect: (status, url) ->
    @header 'Location', url
    @send status ? 302

  cookie: (name, value, options) ->

  clearCookie: (name, options) ->

  render: (view, view_data) ->
