# SAMPLE game class
# To be replaced

class MikeGame
  constructor: (@clients) ->
    @PHYSICS_DT = 2
    @MAX_RENDER_DT = 1000/30
    @time = unless window? then performance.now else Date.now
    @currentTime = @time()
    @newTime = 0
    @accumulator = 0
    @t = 0

    unless window?
      throw "Server-side MikeGame constructor needs client array!" unless @clients?
      @gameLoop = =>
        @newTime = @time()
        frameTime = Math.min(newTime - @currentTime, @MAX_RENDER_DT)
        @currentTime = @newTime

        # Add to the time that needs to be simulated
        @accumulator += frameTime

        # Update physics in PYSICS_DT chunks
        while @accumulator >= @PHYSICS_DT
          client.snake.update(@PHYSICS_DT) for client in @clients
          @t += PHYSICS_DT
          @accumulator -= PHYSICS_DT

    else
      @gameLoop = (fpsStats, msStats) =>
        fpsStats.begin() if fpsStats?
        msStats.begin() if msStats?

        newTime = performance.now()
        frameTime = Math.min(newTime - currentTime, MAX_RENDER_DT)
        currentTime = newTime

        # Add to the time that needs to be simulated
        accumulator += frameTime

        # Update physics in PYSICS_DT chunks
        while accumulator >= PHYSICS_DT
          update(PHYSICS_DT)
          t += PHYSICS_DT
          accumulator -= PHYSICS_DT

        # Render with blending
        blending = accumulator / PHYSICS_DT
        render(blending)

        fpsStats.end() if fpsStats?
        msStats.end() if msStats?

        requestAnimationFrame(gameLoop)