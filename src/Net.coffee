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

  @DELIMITER = "|"

  # Assertion methods
  @ASSERTIONS = {}
  @ASSERTIONS[@CODES.INV] = (msg) => return msg.type is @CODES.INV and assertKeys(msg.data, {"string": ["color"], "number": ["gameStart"]})
  @ASSERTIONS[@CODES.INV_RES] = (msg) => return msg.type is @CODES.INV_RES and assertKeys(msg.data, {"boolean": ["accept"], "string": ["color"]})
  @ASSERTIONS[@CODES.MOV_UPD] = (msg) => return msg.type is @CODES.MOV_UPD and assertKeys(msg.data, {"boolean": ["move", "left", "right"]})
  @ASSERTIONS[@CODES.POS_UPD] = (msg) => return msg.type is @CODES.POS_UPD and assertKeys(msg.data, {"number": ["x", "y", "dx", "dy",], "object": ["dir"]})

  # Serialization orders
  @SERIALIZATION_ORDERS = {}
  @SERIALIZATION_ORDERS[@CODES.INV] = ["color", "gameStart"],
  @SERIALIZATION_ORDERS[@CODES.INV_RES] = ["accept", "color"],
  @SERIALIZATION_ORDERS[@CODES.MOV_UPD] = ["move", "left", "right"],
  @SERIALIZATION_ORDERS[@CODES.POS_UPD] = ["x", "y", "dx", "dy", "dir"]

  # Classes with serialization methods
  @COMPRESSIBLE = [Vec2]

  @serialize: (msg_obj) ->
    return false unless @assertType(msg_obj.data, msg_obj.data.type)
    out = msg_obj.type #always prepend fixed length type
    out += @compress(msg_obj.type, msg_obj.data)
    return out

  @deserialize: (msg_raw) ->
    return false unless msg_raw.length >= @CODE_LENGTH            #catch empty messages
    type = msg_raw[..(@CODE_LENGTH-1)]
    return false unless type in @CODES                            #catch invalid types
    out = {
      type: type,
      data: null
    }

    out.data = @decompress(type, msg_raw[@CODE_LENGTH..])
    return out

  @compress: (type, data) ->
    # Compress data using proper
    # serialization order if it's
    # available, else fall back on
    # JSON.stringify

    out = ""
    if type in @SERIALIZATION_ORDERS
      for key in @SERIALIZATION_ORDERS[type]
        out += @DELIMITER
        d = data[key]
        if typeof d is object
          for cla in @COMPRESSIBLE
            if d instanceof cla
              if "serialize" in cla
                out += cla.serialize(d)
                break
              else
                throw "Cannot serialize object of type #{cla}"
        else
          out += "#{@DELIMITER}#{data[key]}"
    else
      out += JSON.stringify(data)
    return out

  @decompress: (type, data) ->
    out = {}
    if type in @SERIALIZATION_ORDERS
      for key in @SERIALIZATION_ORDERS[type]
        vals = data.split(@DELIMITER)
        do(=> out[key] = val) for val in vals

    else
      out = JSON.parse(data)
    return out

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

if not window?
  module.exports = exports
  exports.MessageSerializer = MessageSerializer
  exports.NetCodes = NetCodes
else
  MIKE.MessageSerializer = MessageSerializer
  MIKE.NetCodes = NetCodes