class MikeGame
  constructor: (@clients) ->
    @PHYSICS_DT = 2
    @MAX_RENDER_DT = 1000/30
    @time = unless window? then performance.now else Date.now
    @currentTime = @time()
    @newTime = 0
    @accumulator = 0
    @t = 0

  gameLoop: ->
    @newTime = @time
    frameTime = Math.min(newTime - @currentTime, @MAX_RENDER_DT)
    @currentTime = @newTime

    # Add to the time that needs to be simulated
    @accumulator += frameTime

    # Update physics in PYSICS_DT chunks
    while @accumulator >= @PHYSICS_DT
      client.snake.update(@PHYSICS_DT) for client in @clients
      @t += PHYSICS_DT
      @accumulator -= PHYSICS_DT

    unless window?
      setTimeout(gameLoop, 1000/60)
    else
      requestAnimationFrame(gameLoop)