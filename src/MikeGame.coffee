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
      @gameLoop = =>
        # Client gameLoop