class Game
  constructor: ->
    @PHYSICS_DT = 2
    @MAX_RENDER_DT = 1000/30
  	@currentTime = null # Set this in child constructor
  	@accumulator = 0
  	@t = 0

unless window?
  module.exports = exports
  exports.Game = Game
else
  MIKE.Game = Game