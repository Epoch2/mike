unless window?
  Game = require("./Game.js").Game

class ServerGame extends Game
  @time: ->
    t = process.hrtime()
    return (t[0] * 1e9 + t[1])/1000

  constructor: (@clients) ->
    throw "Server-side MikeGame constructor needs client array!" unless @clients?
    @currentTime = ServerGame.time()

  update: (dt) ->
    client.update dt for client in @clients

  gameLoop: ->
    newTime = ServerGame.time()
    frameTime = Math.min(newTime-@currentTime, @MAX_RENDER_DT)
    @currentTime = ServerGame.time()

    # Add to the time that needs to be simulated
    @accumulator += frameTime

    # Update physics in PYSICS_DT chunks
    while @accumulator >= @PHYSICS_DT
      update @PHYSICS_DT
      @t += @PHYSICS_DT
      @accumulator -= @PHYSICS_DT

    setTimeout(@gameLoop, 5)

module.exports = exports
exports.ServerGame = ServerGame