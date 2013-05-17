unless window?
  Emitter = require("./Emitter.js").Emitter
  BasicSnake = require("./Snake.js").BasicSnake
  OtherSnake = require("./Snake.js").OtherSnake
  ControllableSnake = require("./Snake.js").ControllableSnake
else
  Emitter = MIKE.Emitter
  BasicSnake = MIKE.BasicSnake
  OtherSnake = MIKE.OtherSnake
  ControllableSnake = MIKE.ControllableSnake

class MikeClient extends Emitter
  constructor: (@connection) ->
    console.log @connection
    if @connection?
      @connection.on "message", (msg) =>
        @emit "message", msg

      @connection.on "close", (code, reason) => # When is code and reason used?
        @emit "disconnect"

  addSnake: (snake) ->
    if snake instanceof OtherSnake or snake instanceof ControllableSnake
      @snake = snake
    else
      throw "Illegal snake of type #{typeof snake}"

unless window?
  module.exports = exports
  exports.MikeClient = MikeClient
else
  MIKE.MikeClient = MikeClient