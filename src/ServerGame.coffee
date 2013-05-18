unless window?
  Game = require("./Game.js").Game

class ServerGame extends Game
  constructor: (@clients) ->
    super()
    throw "ServerGame constructor requires clients[] arg" unless @clients?
    @time = ->
      t = process.hrtime()
      return (t[0] * 1e9 + t[1])/1000000
    @currentTime = @time()
    @accumulator = 0

  update: (dt) ->
    client.snake.update dt for client in @clients

  gameLoop: ->
    newTime = @time()
    frameTime = Math.min(newTime-@currentTime, @MAX_RENDER_DT)
    @currentTime = newTime

    # Add to the time that needs to be simulated
    @accumulator += frameTime

    # Update physics in PYSICS_DT chunks
    while @accumulator >= @PHYSICS_DT
      @update @PHYSICS_DT
      @t += @PHYSICS_DT
      @accumulator -= @PHYSICS_DT

    setTimeout (=> @gameLoop()), @PHYSICS_DT

module.exports = exports
exports.ServerGame = ServerGame