class Maths
  constructor: ->

  @toRadians: (deg) -> deg * (Math.PI/180)
  @toDegrees: (rad) -> rad * (180 / Math.PI)

if not window?
  module.exports = exports
  exports.Maths = Maths
else
  MIKE.Maths = Maths