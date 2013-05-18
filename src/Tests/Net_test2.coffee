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

md = "05|0|>-2222.703898683537,1161.1309609646084|>-0.6901142526676146,0.27300661393386977|>-0.9901130848398448,0.1402714483734131"

console.log MS.serialize(m)
console.log MS.deserialize(md)