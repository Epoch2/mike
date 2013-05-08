###
  FPS AND MS COUNTER (STATS)
###

# FPS
fpsStats = new Stats()
fpsStats.setMode(0)
fpsStats.domElement.style.position = "absolute"
fpsStats.domElement.style.left = "0px"
fpsStats.domElement.style.top = "0px"
document.body.appendChild(fpsStats.domElement)

# MS
msStats = new Stats()
msStats.setMode(1)
msStats.domElement.style.position = "absolute"
msStats.domElement.style.left = "80px"
msStats.domElement.style.top = "0px"
document.body.appendChild(msStats.domElement)

###
  THE GAME
###

# Window / Canvas
resizeWindow = ->
  canvas.width = $(window).width()
  canvas.height = $(window).height()

$(window).bind("resize", resizeWindow)

window.canvas = $("canvas").get(0)
resizeWindow()

window.ctx = canvas.getContext("2d")

# Game logic

niceColor = ->
  letters = "56789abcdef".split("")
  color = "#"
  for i in [0.. 5]
    color += letters[Math.floor(Math.random()*(letters.length-1))]
  color

#particle = new MC.Particle(new Vec2(canvas.width/2,canvas.height/2), 10, niceColor(), new Vec2(0,0))
player = new MC.Snake(new MC.Vec2(canvas.width/2,canvas.height/2), niceColor(), "Mike")

update = (dt) ->
  player.update(dt)

render = (blending) ->
  ctx.clearRect(0, 0, canvas.width, canvas.height)
  player.render(blending)

# Game loop
PHYSICS_DT = 2
MAX_RENDER_DT = 1000/30
window.t = 0;
currentTime = performance.now()
accumulator = 0

gameLoop = ->
  fpsStats.begin()
  msStats.begin()

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

  fpsStats.end()
  msStats.end()

  requestAnimationFrame(gameLoop)
requestAnimationFrame(gameLoop)

###
  KEYBOARD
###

# Up key
MC.Keyboard.bind("press", {
    key: 38,
    callback: (-> player.move = true)
});
MC.Keyboard.bind("release", {
    key: 38,
    callback: (-> player.move = false)
});

# Right key
MC.Keyboard.bind("press", {
    key: 39,
    callback: (-> player.right = true)
});
MC.Keyboard.bind("release", {
    key: 39,
    callback: (-> player.right = false)
});

# Left key
MC.Keyboard.bind("press", {
    key: 37,
    callback: (-> player.left = true)
});
MC.Keyboard.bind("release", {
    key: 37,
    callback: (-> player.left = false)
});