unless window?
  Emitter = require("./Emitter.js").Emitter
else
  Emitter = MIKE.Emitter

class Connection extends Emitter
  # Polymorphic class for seemlessly handling
  # differences between client-side and
  # server-side WebSocket implementations

  constructor: (@ws) ->
    unless window?
      @ws.on "message", (message) =>
        console.log "conn server msg"
        @emit "message", message

      @ws.on "close", (code, reason) =>
        @emit "close", code, reason

    else
      @ws.onmessage = (message) =>
        console.log "conn client msg"
        console.log message.data
        @emit "message", message.data

      @ws.onopen = =>
        @emit "ready"

      @ws.onclose = (evt) =>
        @emit "close", evt.code, evt.reason

  transmit: (msg) ->
    try
      @ws.send(msg)
      return null
    catch error
      return error

unless window?
  module.exports = exports
  exports.Connection = Connection
else
  MIKE.Connection = Connection