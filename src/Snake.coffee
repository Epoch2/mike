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

class Snake
  constructor: (position, color, @name) ->
    @anim = 0
    @dir = new Vec2(-1, 0)

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

  correctionUpdate: (pos, vel, dir) ->
    @head.currPos = pos
    @head.vel = vel
    @dir = dir

  render: (ctx, blending) ->
    for i in [@particles.length-1..0]
      @particles[i].render(ctx, blending)

    ctx.font = "15px Arial"
    ctx.fillStyle = "#fff"
    pos = @head.currPos.plus(new Vec2(@name.split("").length * -3, -20))
    ctx.fillText(@name, pos.x, pos.y)

  update: (dt) ->
    for spring in @springs
      spring.solve()

    if @move
      @dir.rotate(Maths.toRadians(-0.5)) if @right
      @dir.rotate(Maths.toRadians(0.5)) if @left
      @dir.rotate(Maths.toRadians(Math.sin(@anim+=0.04)))
      @head.vel.add(@dir.times_s(@speed))
    #else
      #@dir = @head.currPos.minus(@particles[2].currPos).unit()

    for particle in @particles
      particle.update(dt)

unless window?
  module.exports = exports
  exports.Snake = Snake
else
  MIKE.Snake = Snake