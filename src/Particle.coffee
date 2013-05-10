class Particle
  constructor: (pos, @radius, @color, @forces) ->
    dencity = 0.001
    @mass = Math.PI * @radius * @radius * dencity
    @airResistance = @radius * @radius * 0.00001

    @prevPos = new MC.Vec2(pos.x, pos.y)
    @currPos = new MC.Vec2(pos.x, pos.y)
    @vel = new MC.Vec2(0,0)

  applyForce: (force) ->
    @forces.add(force)

  update: (dt) ->
    @prevPos.set(@currPos.x, @currPos.y)

    @applyForce(@vel.times_s(-@airResistance))

    @vel.add(@forces.dividedWith_s(@mass).times_s(dt))

    @currPos.add(@vel)
    @forces.set(0,0,0)

  render: (blending) ->
    pos = @currPos.times_s(blending).plus(@prevPos.times_s(1-blending))
    ctx.beginPath()
    ctx.arc(pos.x, pos.y, @radius, 0, Math.PI*2, true)
    ctx.closePath()
    ctx.fillStyle = @color
    ctx.fill()

if not window?
  module.exports = exports
  exports.Particle = Particle
else
  MC.Particle = Particle