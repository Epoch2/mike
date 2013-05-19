unless window?
  Vec2 = require("./Vec2.js").Vec2
  Spring = require("./Spring.js").Spring
  Particle = require("./Particle.js").Particle
  Maths = require("./Maths.js").Maths
else
  Vec2 = MIKE.Vec2
  Spring = MIKE.Spring
  Particle = MIKE.Particle
  Maths = MIKE.Maths

class BasicSnake
  constructor: (position, color, @name) ->
    @anim = 0
    @dir = new Vec2(-1, 0)
    @iterations = 0

    # Controles
    @move = false
    @left = false
    @right = false

    # Options
    @speed = 0.005
    num = 10
    radius = 8
    springConst = 0.0004
    springLen = 3
    springFriction = 0.00005

    # Build snake
    @particles = []
    @springs = []

    # Particles
    pos = new Vec2(position.x, position.y)
    for i in [0..num-1]
      rad = radius*(1-i/num)
      pos = pos.plus(new Vec2(springLen, 0))
      @particles.push(new Particle(pos, rad, color, new Vec2(0,0)))
    @particles[0].head = true
    @head = @particles[0]
    # Springs
    for i in [0.. num-2]
      @springs.push(new Spring(@particles[i], @particles[i+1], springConst, springLen, springFriction))

  getPos: -> @head.getPos()
  getVel: -> @head.getVel()
  getDir: -> @dir.copy()
  getRad: -> @head.getRad()
  getColor: -> @head.getColor()

  update: (dt) ->
    @iterations++

    for spring in @springs
      spring.solve()

    if @move
      @dir.rotate(Maths.toRadians(-0.5)) if @right
      @dir.rotate(Maths.toRadians(0.5)) if @left
      @dir.rotate(Maths.toRadians(Math.sin(@anim+=0.04)))
      @head.vel.add(@dir.times_s(@speed))
    #else
      #@dir = @head.getPos().minus(@particles[2].getPos()).unit()

    for particle in @particles
      particle.update(dt)

class ClientSnake extends BasicSnake
  constructor: (position, color, name) ->
    super(position, color, name)

    @consoleBuffer = ""

    # Correction Blending
    @correctionBlendTime = 1
    @correctionPrevTime = performance.now()
    @correctionPos = @head.getPos()
    @correctionVel = @head.getVel()
    @correctionDir = @dir

  correctionUpdate: (pos, vel, dir) ->
    consoleBuffer += "------------\nCorrection Update\n------------\n"
    currTime = performance.now()
    @correctionBlendTime = currTime - @correctionPrevTime
    @correctionPrevTime = currTime

    @correctionPos = pos
    @correctornVel = vel
    @correctionDir = dir

    ###
    @head.currPos = pos
    @head.vel = vel
    @dir = dir
    ###

  update: (dt) ->
    super(dt)
    # Correction blending
    correctionTime = performance.now() - @correctionPrevTime
    blending = Math.min(correctionTime / @correctionBlendTime, 1)
    @consoleBuffer += blending+"\n"

    if @iterations % 200 is 0
      console.log @consoleBuffer
      @consoleBuffer = ""

    @head.currPos = @correctionPos.times_s(blending).plus(@head.getPos().times_s(1-blending))
    @head.vel = @correctionVel.times_s(blending).plus(@head.getVel().times_s(1-blending))
    @dir = @correctionDir.times_s(blending).plus(@dir.times_s(1-blending))
    @dir.normalize()

  render: (ctx, blending) ->
    for i in [@particles.length-1..0]
      @particles[i].render(ctx, blending)

    ctx.font = "15px Arial"
    ctx.fillStyle = "#fff"
    pos = @head.currPos.plus(new Vec2(@name.split("").length * -3, -20))
    ctx.fillText(@name, pos.x, pos.y)

class ServerSnake extends BasicSnake
  constructor: (position, color, name) ->
      super(position, color, name)

unless window?
  module.exports = exports
  exports.ClientSnake = ClientSnake
  exports.ServerSnake = ServerSnake
else
  MIKE.ClientSnake = ClientSnake
  MIKE.ServerSnake = ServerSnake