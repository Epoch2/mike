class ColorUtil
  @niceColor: ->
    letters = "0123456789abcdef".split("")
    color = "#"
    for i in [0.. 5]
      color += letters[Math.floor(Math.random()*(letters.length-1))]
    return color

  @rgbToHex = (r, g, b) ->
    return "" + ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1)

  @hexToRgbRegex: /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i
  @hexToRgb: (hex) ->
    result = @hexToRgbRegex.exec(hex)
    return {
      r: parseInt(result[1], 16),
      g: parseInt(result[2], 16),
      b: parseInt(result[3], 16)
    }

  @compareColors: (color1, color2) ->
    # Compares two colors for similarity.
    # Returns a number between 0 and 1
    # where 1 are identical colors
    # and 0 are opposites (such as #FFFFFF
    # vs #000000)

    color1 = @hexToRgb(color1)
    color2 = @hexToRgb(color2)

    return Math.abs(((441-Math.sqrt(Math.pow((color2.r-color1.r), 2) + Math.pow((color2.g-color1.g), 2) + Math.pow((color2.b-color1.b), 2)))/441)).toFixed(2)

module.exports = exports
exports.ColorUtil = ColorUtil