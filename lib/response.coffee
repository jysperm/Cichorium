_ = require 'lodash'

module.exports = class Response
  constructor: (@res) ->
    _.extend @, @res

  # res.header name, value
  # res.header object
  header: (name, value) ->
    headers = name

    unless _.isObject headers
      headers = {}
      headers[name] = value

    for name, value of headers
      @res.setHeader name, value

  # res.send status, data
  # res.send status
  # res.send data
  send: (status, data) ->
    if _.isNumber status
      @res.statusCode = status
    else if data == undefined
      data = status

    @res.end data

  # res.json status, object
  # res.json object
  json: (status, data) ->
    unless _.isNumber status
      data = status
      status = null

    @header 'Content-Type', 'application/json'
    @send status, JSON.stringify data

  # res.redirect status, url
  # res.redirect url
  redirect: (status, url) ->
    unless _.isNumber status
      url = status
      status = 302

    @header 'Location', url
    @send status

  cookie: (name, value, options) ->

  clearCookie: (name, options) ->

  render: (view, view_data) ->
