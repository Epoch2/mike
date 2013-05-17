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
      color: "#FFFFFF",
      name: "Mike"
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
      id: 234234,
      pos: new Vec2(2, 5),
      vel: new Vec2(5, 1),
      dir: new Vec2(2, 3)
    }
  }
  {
    type: TYPES.NEW_CLIENT,
    data: {
      id: 23847,
      name: "Kent",
      color: "#fff000",
      pos: new Vec2(3, 9)
    }
  }
]

messages_d = [
  "01|#ffddaa|234",
  "02|true|#FFFFFF|Mike",
  "03|true|false|true",
  "04|12345|@>4.3.0|@>2.3.0|@>5.5.0"
  "05|12345|Kent|#fff000|@>8.2.0"
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


