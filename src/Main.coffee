ClientGame = MIKE.ClientGame

# Sizing
resizeWindow = ->
  @canvas.width = $(window).width()
  @canvas.height = $(window).height()
$(window).bind "resize", resizeWindow
resizeCanvas()

# Get the ball rolling
canvas = $("canvas").get 0
clientGame = new ClientGame(canvas)