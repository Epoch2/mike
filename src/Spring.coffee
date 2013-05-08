class MC.Spring
  constructor: (@particle1, @particle2, @springConst, @springLen, @frictionConst) ->

  solve: ->
    springVec = @particle2.currPos.minus(@particle1.currPos)
    len = springVec.length()
    force = new MC.Vec2(0,0)
    # Contraction force
    force.add(springVec.unit().times_s(len - @springLen).times_s(@springConst)) if len != 0
    # Friction force
    force.add(@particle1.vel.minus(@particle2.vel).times_s(-@frictionConst))

    # Apply equal and oposite forces
    @particle1.applyForce(force) if @particle1.head != true
    @particle2.applyForce(force.times_s(-1))