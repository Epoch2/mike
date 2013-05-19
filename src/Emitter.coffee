class Emitter
  emit: (event, args...) ->
    @callbacks = @callbacks or {}
    try
      callback.apply(this, args) for evt, callback of @callbacks when evt is event and typeof callback is "function"

  on: (event, callback) ->
    @callbacks = @callbacks or {}
    do(=>
      @callbacks[event] = callback
    ) if typeof event is "string" and typeof callback is "function"

unless window?
  module.exports = exports
  exports.Emitter = Emitter
else
  MIKE.Emitter = Emitter