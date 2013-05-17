Robert = MIKE.Robert
ControllableSnake = MIKE.ControllableSnake
Keyboard = MIKE.Keyboard
Game = MIKE.Game

class ClientGame extends Game
  constructor: (@canvas) ->

    # Render context
    @ctx = @canvas.getContext("2d")

    # FPS
    @fpsStats = new Stats()
    @fpsStats.setMode 0
    @fpsStats.domElement.style.position = "absolute"
    @fpsStats.domElement.style.left = "0px"
    @fpsStats.domElement.style.top = "0px"
    document.body.appendChild @fpsStats.domElement

    # MS
    @msStats = new Stats()
    @msStats.setMode 1
    @msStats.domElement.style.position = "absolute"
    @msStats.domElement.style.left = "80px"
    @msStats.domElement.style.top = "0px"
    document.body.appendChild @msStats.domElement

    @currentTime = performance.now()
    @snakes = new Array()
    @server = new Robert("ws://mike.com")

    @server.on("invite", (@gameStart, color, acceptInvite) =>
      name = "Mike"
      
      player = new ControllableSnake(new Vec2(300,300), color, name)

      Keyboard.bind "press", { key: 38, callback: (-> player.move = true) }
      Keyboard.bind "release", { key: 38, callback: (-> player.move = false) }
      Keyboard.bind "press", { key: 39, callback: (-> player.right = true) }
      Keyboard.bind "release", { key: 39, callback: (-> player.right = false) }
      Keyboard.bind "press", { key: 37, callback: (-> player.left = true) }
      Keyboard.bind "release", { key: 37, callback: (-> player.left = false) }

      @snakes.push player

      acceptInvite name
    )

    @server.on("new_clients", (client) =>
      @snakes.push client
    )

  update: (dt) ->
    snake.update dt for snake in @snakes
    
  render: (blending) ->
    @ctx.clearRect 0, 0, canvas.width, canvas.height
    snake.render @ctx, blending for snake in @snakes

  gameLoop: ->
    @fpsStats.begin() if @fpsStats?
    @msStats.begin() if @msStats?

    newTime = performance.now()
    frameTime = Math.min newTime-@currentTime, @MAX_RENDER_DT
    @currentTime = newTime

    # Add to the time that needs to be simulated
    @accumulator += frameTime

    # Update physics in PYSICS_DT chunks
    while @accumulator >= @PHYSICS_DT
      update @PHYSICS_DT
      @t += @PHYSICS_DT
      @accumulator -= @PHYSICS_DT

    # Render with blending
    blending = @accumulator / @PHYSICS_DT
    render @blending

    @fpsStats.end() if @fpsStats?
    @msStats.end() if @msStats?

    requestAnimationFrame gameLoop

MIKE.ClientGame = ClientGame