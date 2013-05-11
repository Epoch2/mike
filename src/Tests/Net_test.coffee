if not window?
  MS = require("../Net.js").MessageSerializer
  TYPES = require("../Net.js").NetTypes.TYPES
  Vec2 = require("../Vec2.js").Vec2
else
  MS = MIKE.MessageSerializer
  TYPES = MIKE.NetTypes.TYPES
  Vec2 = MIKE.Vec2

messages_c = [
  {
    type: TYPES.INV,
    data: {
      color: "#FFFFFF",
      gameStart: 234
    }
  },
  {
    type: TYPES.INV_RES,
    data: {
      accept: true,
      color: "#FFFFFF"
    }
  },
  {
    type: TYPES.MOV_UPD,
    data: {
      move: true,
      right: true,
      left: false
    }
  },
  {
    type: TYPES.POS_UPD,
    data: {
      x: 12345,
      y: 12354,
      dx: 23444,
      dy: 13234,
      dir: new Vec2(5, 5)
    }
  }
]

messages_d = [
  "00|#FFFFFF|234",
  "01|true|#FFFFFF",
  "02|true|false|true",
  "03|12345|12354|23444|13234|@>5.5.0"
]

console.log "start"
for message in messages_c
  console.log(message.type)
  console.log(MS.serialize(message))
  console.log("----------")

console.log "========================="

for message in messages_d
  console.log message
  des = MS.deserialize(message)
  console.log des
  for key, val of des
    if typeof val is "object"
      for k, v of val
        console.log typeof v
    else
      console.log val
  console.log "----------"


