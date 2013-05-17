unless window?
  Game = require("./Game.js").Game

class ServerGame extends Game
  constructor: (@clients) ->
    throw "Server-side MikeGame constructor needs client array!" unless @clients?
    @currentTime = new Date().now()

  update: (dt) ->
    client.update dt for client in @clients

  gameLoop: ->
    newTime = new Date().now()
    frameTime = Math.min newTime-@currentTime, @MAX_RENDER_DT
    @currentTime = newTime

    # Add to the time that needs to be simulated
    @accumulator += frameTime

    # Update physics in PYSICS_DT chunks
    while @accumulator >= @PHYSICS_DT
      update @PHYSICS_DT
      @t += @PHYSICS_DT
      @accumulator -= @PHYSICS_DT

    setTimeout(gameLoop, 5)

module.exports = exports
exports.ServerGame = ServerGame