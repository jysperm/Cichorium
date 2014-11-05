exports.defineGetter = (object, name, getter) ->
  Object.defineProperty object, name,
    configurable: true
    enumerable: true
    get: getter
