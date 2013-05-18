ClientGame = MIKE.ClientGame

# Get the canvas
canvas = $("canvas").get 0

# Sizing
resizeCanvas = (canvas) ->
  canvas.width = $(window).width()
  canvas.height = $(window).height()
$(window).bind "resize", resizeCanvas
resizeCanvas(canvas)

# Get the ball rolling
clientGame = new ClientGame(canvas)
clientGame.gameLoop()