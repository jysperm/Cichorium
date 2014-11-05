{defineGetter} = require './utils'

exports.param = (name, default_value) ->
  param = @params ? {}
  query = @query ? {}
  body = @body ? {}

  return param[name] ? query[name] ? body[name] ? default_value

defineGetter exports, 'ip', ->
  return @connection.remoteAddress
