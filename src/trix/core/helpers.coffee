memos = 0

Trix.Helpers =
  extend: (object, properties) ->
    for key, value of properties
      object[key] = value
    object

  defer: (fn) ->
    setTimeout fn, 1

  memoize: (fn) ->
    memo = memos++
    ->
      @memos ?= {}
      @memos[memo] ?= fn.apply(this, arguments)

  trace: (name, fn) -> ->
    result = fn.apply(this, arguments)
    args = (formatValue(arg) for arg in arguments)
    Trix.Logger.log("methodTraces", name, "(", args..., ") =", result)
    result

  benchmark: (name, fn) -> ->
    logger = Trix.Logger.get("benchmarks")
    logger.time(name)
    result = fn.apply(this, arguments)
    logger.timeEnd(name)
    result

  proxyMethod: (name, {onConstructor, onObject, toObject, toMethod, toProperty, optional} = {}) ->
    destination = onObject ? onConstructor.prototype
    destination[name] = ->
      object = if toObject?
        toObject
      else if toMethod?
        if optional then @[toMethod]?() else @[toMethod]()
      else if toProperty?
        @[toProperty]

      if optional
        object?[name]?.apply(object, arguments)
      else
        object[name].apply(object, arguments)

  arraysAreEqual: (a, b) ->
    return false unless a.length is b.length
    for value, index in a
      return false unless value is b[index]
    true

formatValue = (value) ->
  value?.inspect?() ? (try JSON.stringify(value)) ? value
