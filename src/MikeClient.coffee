unless window?
  Emitter = require("./Emitter.js").Emitter
  Snake = require("./Snake.js").Snake
else
  Emitter = MIKE.Emitter
  BasicSnake = MIKE.BasicSnake
  OtherSnake = MIKE.OtherSnake
  ControllableSnake = MIKE.ControllableSnake

class MikeClient extends Emitter
  constructor: (@connection) ->
    if @connection?
      @connection.on "message", (msg) =>
        @emit "message", msg

      @connection.on "close", (code, reason) => # When is code and reason used?
        @emit "disconnect"

  addSnake: (snake) ->
    if snake instanceof Snake
      @snake = snake
    else
      throw "Illegal snake of type #{typeof snake}"

unless window?
  module.exports = exports
  exports.MikeClient = MikeClient
else
  MIKE.MikeClient = MikeClient