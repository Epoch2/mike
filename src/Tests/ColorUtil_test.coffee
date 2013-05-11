if not window?
  CU = require("../ColorUtil.js").ColorUtil
else
  CU = MIKE.ColorUtil

R = 255
G = 242
B = 52

HEX = "#FFF234"


console.log CU.hexToRgb(HEX)                        # Should be 255, 242, 52
console.log CU.rgbToHex(R, G, B)                    # Should be #fff234
console.log CU.compareColors("#FFFFFC", "#FFFFFF")  # Should be 0.99