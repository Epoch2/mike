unless window?
  BasicSnake = require("./Snake.js").BasicSnake
  OtherSnake = require("./Snake.js").OtherSnake
  ControllableSnake = require("./Snake.js").ControllableSnake
else
  BasicSnake = MIKE.BasicSnake
  OtherSnake = MIKE.OtherSnake
  ControllableSnake = MIKE.ControllableSnake

class MikeClient
  constructor: (@connection) ->
    if @connection?
      console.log "hasConnection"
      @connection.on "message", (msg) =>
        console.log "MikeClient message #{msg}"
        @emit "message", msg

      @connection.on "close", (code, reason) => # When is code and reason used?
        @emit "disconnect"

      console.log "constructor done"

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