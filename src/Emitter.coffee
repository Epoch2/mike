class Emitter
  callbacks = {}
  emit: (event, args...) ->
    try
      callback.apply(this, args) for evt, callback of callbacks when evt is event and typeof callback is "function"

  on: (event, callback) ->
    do(=>
      callbacks[event] = callback
    ) if typeof event is "string" and typeof callback is "function"

unless window?
  module.exports = exports
  exports.Emitter = Emitter
else
  MIKE.Emitter = Emitter