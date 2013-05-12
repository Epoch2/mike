unless window?
  Snake = require("./Snake.js").Snake
  BasicSnake = require("./Snake.js").BasicSnake
else
  Snake = MIKE.Snake
  BasicSnake = MIKE.BasicSnake

class MikeClient
  constructor: (@connection) ->
    if connection?
      @connection.on "message", (msg) =>
        @emit "message", (msg)

      @connection.on "close", (code, reason) =>
        @emit "disconnect"

  addSnake: (snake) ->
    if snake instanceof BasicSnake or snake instanceof Snake
      @snake = snake
    else
      throw "Illegal snake of type #{typeof snake}"