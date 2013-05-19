unless window?
  Emitter = require("./Emitter.js").Emitter
  WebSocket = require("ws")
else
  Emitter = MIKE.Emitter

class Connection extends Emitter
  # Polymorphic class for seemlessly handling
  # differences between client-side and
  # server-side WebSocket implementations

  constructor: (@ws) ->
    unless window?
      @ws.on "message", (message) =>
        @emit "message", message

      @ws.on "open", =>
        @emit "ready"

      @ws.on "close", (code, reason) =>
        @emit "close", code, reason

    else
      @ws.onmessage = (message) =>
        @emit "message", message.data

      @ws.onopen = =>
        @emit "ready"

      @ws.onclose = (evt) =>
        @emit "close", evt.code, evt.reason

  readyCheck: (callback) ->
    if @ws.readyState is WebSocket.OPEN
      if callback? and typeof callback is "function"
        callback()
        return
      else
        throw "readyCheck: invalid callback of type #{typeof callback}"
    else
      setTimeout (=> @readyCheck(callback)), 0  # Put this on the call stack

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