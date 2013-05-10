if not window?
  MS = require("../Net.js").MessageSerializer
  CODES = require("../Net.js").NetCodes
else
  MS = MIKE.MessageSerializer
  CODES = MIKE.NetCodes

messages = [
  {
    type: CODES.INV,
    data: {
      color: "#FFFFFF",
      gameStart: 234
    }
  },
  {
    type: CODES.INV_RES,
    data: {
      accept: true,
      color: "#FFFFFF"
    }
  },
  {
    type: CODES.MOV_UPD,
    data: {
      move: true,
      right: true,
      left: false
    }
  },
  {
    type: CODES.POS_UPD,
    data: {
      x: 12345,
      y: 12354,
      dx: 23444,
    }
  }


]