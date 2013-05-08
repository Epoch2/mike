class MC.Vec2
  constructor: (@x, @y) -> @restAngle = 0;

  @vecClosestToDir: (dir, vecs) ->
    closest = vecs[0]
    (closest = vec if dir.dot(vec.unit()) > dir.dot(closest.unit())) for vec in vecs
    closest

  @vecFurthestFromDir: (dir, vecs) ->
    closest = vecs[0]
    (closest = vec if dir.dot(vec.unit()) < dir.dot(closest.unit())) for vec in vecs
    closest

  @angLessThan: (angle, vec1, vec2) -> vec1.unit().dot(vec2.unit()) < Math.cos(angle)

  sqrdLength: -> @x*@x + @y*@y
  length: -> Math.sqrt(@sqrdLength())
  sqrdDistTo: (vec) -> @minus(vec).sqrdLength()
  distTo: (vec) -> Math.sqrt(@sqrdDistTo(vec));

  sqrt: -> new Vec2(Math.sqrt(@x), Math.sqrt(@y))
  sqrd: -> new Vec2(@x*@x, @y*@y)

  unit: -> len = @length(); new Vec2(@x/len, @y/len)
  normalize: -> len = @length(); @x /= len; @y /= len;

  copy: -> new Vec2(@x, @y)
  set: (x, y) -> @x = x; @y = y;
  equals: (vec) -> @x is vec.x and @y is vec.y

  add: (vec) -> @x += vec.x; @y += vec.y;
  plus: (vec) -> new Vec2(@x+vec.x, @y+vec.y)
  subtract: (vec) -> @x -= vec.x; @y -= vec.y;
  minus: (vec) -> new Vec2(@x-vec.x, @y-vec.y)

  times_v: (vec) -> new Vec2(@x*vec.x, @y*vec.y)
  times_s: (scalar) -> new Vec2(@x*scalar, @y*scalar)
  multiply_v: (vec) -> @x *= vec.x; @y *= vec.y;
  multiply_s: (scalar) -> @x *= scalar; @y *= scalar;

  devide_v: (vec) -> @x /= vec.x; @y /= vec.y;
  devide_s: (scalar) -> @x /= scalar; @y /= scalar;
  devidedWith_v: (vec) -> new Vec2(@x/vec.x, @y/vec.y)
  devidedWith_s: (scalar) -> new Vec2(@x/scalar, @y/scalar)

  dot: (vec) -> @x*vec.x + @y*vec.y
  cross: (vec) -> @x*vec.y - @y*vec.x

  projectedOnto: (vec) -> dir = vec.unit(); dir.times_s(@dot(dir))

  perpCCW: -> new Vec2(-@y, @x);
  perpCW: -> new Vec2(@y, -@x);

  midpoint: (vec, mp) -> @times_s(1-mp).plus(vec.times_s(mp))

  angle: -> Math.atan2(@y, @x)
  rotated: (tiltAngle) ->
    angle = @angle()
    angle -= tiltAngle;
    len = @length()
    new Vec2(len * Math.cos(angle), len * Math.sin(angle))

  rotate: (tiltAngle) ->
    @restAngle += tiltAngle
    angle = @angle()
    angle -= tiltAngle;
    len = @length()
    @x = len * Math.cos(angle)
    @y = len * Math.sin(angle)


  restoreRotation: ->
    angle = @angle()
    len = @length()
    angle += @restAngle
    @x = len * Math.cos(angle)
    @y = len * Math.sin(angle)
    @restAngle = 0


window.Vec2 = Vec2