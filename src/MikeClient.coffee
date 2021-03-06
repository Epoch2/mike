unless window?
  Emitter = require("./Emitter.js").Emitter
else
  Emitter = MIKE.Emitter

class MikeClient extends Emitter
  constructor: (@connection) ->
    if @connection?
      @connection.on "message", (msg) =>
        @emit "message", msg

      @connection.on "ready", =>
        @emit "ready"

      @connection.on "close", (code, reason) => # When is code and reason used?
        @emit "disconnect"

  addSnake: (snake) ->
    @snake = snake

unless window?
  module.exports = exports
  exports.MikeClient = MikeClient
else
  MIKE.MikeClient = MikeClient