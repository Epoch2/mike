Robert = MIKE.Robert
Snake = MIKE.Snake
Keyboard = MIKE.Keyboard
Game = MIKE.Game
MikeClient = MIKE.MikeClient
Vec2 = MIKE.Vec2

class ClientGame extends Game
  constructor: (@canvas) ->
    super()

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
    @clients = []
    #@server = new Robert("ws://127.0.0.1:1337")
    @server = new Robert("ws://arch.jvester.se:1337")
    console.log @server

    @server.on "game:invite", (@gameStart, color, acceptInvite) =>
      #name = prompt("Enter your name", "Mike")
      name = color
      acceptInvite(name)

    @server.on "client:player", (client) =>
      Keyboard.bind "press", { key: 38, callback: (=> client.snake.move = true; @server.sendMovUpdate(client.snake.move, client.snake.left, client.snake.right)) }
      Keyboard.bind "release", { key: 38, callback: (=> client.snake.move = false; @server.sendMovUpdate(client.snake.move, client.snake.left, client.snake.right)) }
      Keyboard.bind "press", { key: 39, callback: (=> client.snake.right = true; @server.sendMovUpdate(client.snake.move, client.snake.left, client.snake.right)) }
      Keyboard.bind "release", { key: 39, callback: (=> client.snake.right = false; @server.sendMovUpdate(client.snake.move, client.snake.left, client.snake.right)) }
      Keyboard.bind "press", { key: 37, callback: (=> client.snake.left = true; @server.sendMovUpdate(client.snake.move, client.snake.left, client.snake.right)) }
      Keyboard.bind "release", { key: 37, callback: (=> client.snake.left = false; @server.sendMovUpdate(client.snake.move, client.snake.left, client.snake.right)) }
      @clients.push client
      @player = client
      console.log "In control of ##{client.id}"

    @server.on "client:new", (client) =>
      @clients.push client
      console.log "##{client.id} was added to the game."

    @server.on "client:delete", (id) =>
      @clients.splice(i,1) for client, i in @clients when client.id is id

    @server.on "client:pos_upd", (update) =>
      # Update position of client with id "id"
      for client in @clients
        if client.id is update.id
          client.snake.correctionUpdate(update.pos.copy(), update.vel.copy(), update.dir.copy())
          break

    @$largeStars = $("div.large.stars")
    @$smallStars = $("div.small.stars")

  update: (dt) ->
    client.snake.update dt for client in @clients
    @$smallStars.css("background-position", Math.floor(@player.snake.getPos().x*-0.15)+"px "+Math.floor(@player.snake.getPos().y*-0.15)+"px") if @player?
    @$largeStars.css("background-position", Math.floor(@player.snake.getPos().x*-0.2)+"px "+Math.floor(@player.snake.getPos().y*-0.2)+"px") if @player?

  render: (blending) ->
    @ctx.clearRect 0, 0, @canvas.width, @canvas.height
    client.snake.render @ctx, blending for client in @clients

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
      @update @PHYSICS_DT
      @t += @PHYSICS_DT
      @accumulator -= @PHYSICS_DT

    # Render with blending
    blending = @accumulator / @PHYSICS_DT
    @render blending

    @fpsStats.end() if @fpsStats?
    @msStats.end() if @msStats?

    requestAnimFrame(=>@gameLoop())

MIKE.ClientGame = ClientGame