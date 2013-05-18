unless window?
  MS = require("../Net.js").MessageSerializer
  Vec2 = require("../Vec2.js").Vec2
  TYPES = require("../Net.js").NetTypes.TYPES
else
  MS = MIKE.MessageSerializer
  Vec2 = MIKE.Vec2
  TYPES = MIKE.NetTypes.TYPES

m = {
  type: TYPES.POS_UPD,
  data: {
    id: 234234,
    pos: new Vec2(2, 4),
    vel: new Vec2(2, 4),
    dir: new Vec2(2, 4)
  }
}

console.log MS.serialize(m)