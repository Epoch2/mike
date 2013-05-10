if not window?
  Vec2 = require("./Vec2.js").Vec2
else
  Vec2 = MIKE.Vec2

class NetCodes
  # Static
  @CODE_LENGTH = 2
  @CODES = {
    INV: "00",
    INV_RES: "01",
    MOV_UPD: "02",
    POS_UPD: "03"
  }

class MessageSerializer
  # Public
  # Static

  # Assertion methods
  @ASSERTIONS = {}
  @ASSERTIONS[@CODES.INV] = (msg) => return msg.type is @CODES.INV and assertKeys(msg.data, {"string": ["color"], "number": ["gameStart"]})
  @ASSERTIONS[@CODES.INV_RES] = (msg) => return msg.type is @CODES.INV_RES and assertKeys(msg.data, {"boolean": ["accept"], "string": ["color"]})
  @ASSERTIONS[@CODES.MOV_UPD] = (msg) => return msg.type is @CODES.MOV_UPD and assertKeys(msg.data, {"boolean": ["move", "left", "right"]})
  @ASSERTIONS[@CODES.POS_UPD] = (msg) => return msg.type is @CODES.POS_UPD and assertKeys(msg.data, {"number": ["x", "y", "dx", "dy",], "object": ["dir"]})

  # Compression methods
  @COMPRESSIONS = {}
  @COMPRESSIONS[@CODES.INV] = (data) => return "#{data.color}#{data.gameStart}"
  @COMPRESSIONS[@CODES.INV_RES] = (data) => return "#{compressBool(data.accept)}#{data.color}"
  @COMPRESSIONS[@CODES.MOV_UPD] = (data) => return (compressBool(data[bool]) for bool in ["move", "left", "right"]).join("")
  @COMPRESSIONS[@CODES.POS_UPD] = (data) => return (data[number] for number in ["x", "y", "dx", "dy"]).join("") + data.dir.x + data.dir.y + data.dir.restAngle

  # Regexes
  @REGEXES = {}
  @REGEXES[@CODES.INV] = /^(#[abcdef0123456789]{6})(\d*$)/
  @REGEXES[@CODES.INV_RES] = /^((0|1)(#[abcdef0123456789]{6})/
  @REGEXES[@CODES.MOV_UPD] = /^(0|1)(0|1)(0|1)/
  @REGEXES[@CODES.POS_UPD] = /^(\d{5})(\d{5})(\d{5})(\d{5})(\d{5})(\d{5})(\d{5})(\d{5})/

  # Decompression methods
  @DECOMPRESSIONS = {}
  @DECOMPRESSIONS[@CODES.INV] = (data) =>
    return {
      color: data[0],
      gameStart: Number(data[1])
    }

  @DECOMPRESSIONS[@CODES.INV_RES] = (data) =>
    return {
      accept: @decompressBool(data[0]),
      color: data[1]
    }

  @DECOMPRESSIONS[@CODES.MOV_UPD] = (data) =>
    return {
      move: @decompressBool(data[0]),
      left: @decompressBool(data[1]),
      right: @decompressBool(data[2])
    }

  @DECOMPRESSIONS[@CODES.POS_UPD] = (data) =>
    return {
      x: Number(data[0]),
      y: Number(data[1]),
      dx: Number(data[2]),
      dy: Number(data[3]),
      dir: new Vec2(data[4], data[5], data[6])
    }

  @serialize: (msg_obj) ->
    return false unless @assertType(msg_obj.data, msg_obj.data.type)
    out = msg_obj.type #always prepend fixed length type
    out += @compress(msg_obj.data)
    return out

  @deserialize: (msg_raw) ->
    return false unless msg_raw.length >= @CODE_LENGTH            #catch empty messages
    type = msg_raw[..(@CODE_LENGTH-1)]
    return false unless type in @CODES                            #catch invalid types
    out = {
      type: type,
      data: null
    }

    out.data = @decompress(msg_raw[@CODE_LENGTH..])
    return out

  @compress: (type, data) ->
    # Compress data using proper
    # compression method if it's
    # available, else fall back on
    # simple serialization
    return (if type in @COMPRESSIONS then @COMPRESSIONS[type](data) else JSON.stringify(data))

  @decompress: (type, data) ->
    return (if type in @DECOMPRESSIONS and type in @REGEXES then @DECOMPRESSIONS[type](data.match(@REGEXES[type])) else JSON.parse(data))

  @pullType: (msg_raw) ->
    return msg_raw[0...@CODE_LENGTH].join("")

  @assertType: (obj, type) ->
    assertion = @ASSERTIONS[type]
    return assertion(obj)

  @typeOf: (obj) ->
    return Number(type) for type, assertion of @ASSERTIONS when assertion(obj)

  @assertKeys: (obj, checks) ->
    # Asserts that an object, 'obj', contains the keys
    # specified, and that the values of the keys are of the right type.
    #
    # In the example below the object 'pos' is asserted
    # to contain two numbers with the keys 'x' and 'y' and
    # a boolean with the key "isCoordinate"
    #
    # assert(pos, {
    # "number": ["x"] ["y"],
    # "boolean": ["isCoordinate"]
    # })

    allowedTypes = [
      "boolean",
      "string",
      "number",
      "object",
      "function"
    ]

    for type, keys of checks
      continue if not type in allowedTypes #ignore invalid assertion types
      for key in keys
        if obj[key] isnt undefined
          return false unless typeof obj[key] is type
        else
          return false

    return true

  @compressBool: (bool) ->
    if bool is false
      return "0"
    else if bool is true
      return "1"
    else
      return false

  @decompressBool: (bool) ->
    if bool is "0"
      return false
    else if bool is "1"
      return true
    else
      return false
###
if not window?
  module.exports = exports
  exports.MessageSerializer = MessageSerializer
  exports.NetCodes = NetCodes
else
  MIKE.MessageSerializer = MessageSerializer
  MIKE.NetCodes = NetCodes
###