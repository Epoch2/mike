class Emitter
  @callbacks = {}
  emit: (event, arg) ->
    callback(arg) for evt, callback of @callbacks when evt is event and typeof callback is "function"

  on: (event, callback) ->
    do(=>
      @callbacks[event] = callback
    ) if typeof event is "string" and typeof callback is "function"

if not window?
  module.exports = exports
  exports.Emitter = Emitter
else
  MC.Emitter = Emitter