class Maths

    constructor: ->

    @toRadians: (deg) -> deg * (Math.PI/180)
    @toDegrees: (rad) -> rad * (180 / Math.PI)

window.Maths = Maths