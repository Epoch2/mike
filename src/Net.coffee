if not window?
  Vec2 = require("./Vec2.js").Vec2
else
  Vec2 = MIKE.Vec2

class NetTypes
  # Static
  @TYPE_LENGTH: 2
  @TYPES: {
    INV: "00",
    INV_RES: "01",
    MOV_UPD: "02",
    POS_UPD: "03"
  }

class MessageSerializer
  # Public
  # Static

  @TYPES: NetTypes.TYPES
  @TYPE_LENGTH: NetTypes.TYPE_LENGTH
  @DELIMITER: "|"
  @OBJECT_IDENT: "@"

  # Assertion methods
  @ASSERTIONS: {}
  @ASSERTIONS[@TYPES.INV] = (data) => return @assertKeys(data, {"string": ["color"], "number": ["gameStart"]})
  @ASSERTIONS[@TYPES.INV_RES] = (data) => return @assertKeys(data, {"boolean": ["accept"], "string": ["color"]})
  @ASSERTIONS[@TYPES.MOV_UPD] = (data) => return @assertKeys(data, {"boolean": ["move", "left", "right"]})
  @ASSERTIONS[@TYPES.POS_UPD] = (data) => return @assertKeys(data, {"number": ["x", "y", "dx", "dy",], "object": ["dir"]})

  # Compression patterns
  @COMPRESSION_PATTERNS: {}
  @COMPRESSION_PATTERNS[@TYPES.INV] = ["color", "gameStart"]
  @COMPRESSION_PATTERNS[@TYPES.INV_RES] = ["accept", "color"]
  @COMPRESSION_PATTERNS[@TYPES.MOV_UPD] = ["move", "left", "right"]
  @COMPRESSION_PATTERNS[@TYPES.POS_UPD] = ["x", "y", "dx", "dy", "dir"]

  # Classes with serialization methods
  @COMPRESSIBLE_CLASSES: [Vec2]

  # Decompression keys
  @OBJECT_KEYS: {
    ">": Vec2
  }

  @serialize: (msg_obj) ->
    return false unless @assertType(msg_obj.type, msg_obj.data)
    out = msg_obj.type #always prepend fixed length type
    out += @compress(msg_obj.type, msg_obj.data)
    return out

  @deserialize: (msg_raw) ->
    return false unless msg_raw.length >= @TYPE_LENGTH
    type = @pullTypeFrom(msg_raw)
    msg_raw = @removeTypeFrom(msg_raw)
    out = {
      type: type,
      data: null
    }

    out.data = @decompress(type, msg_raw)
    return out

  @compress: (type, data) ->
    # Compress data using proper
    # serialization order if it's
    # available, else fall back on
    # JSON.stringify

    out = ""
    if type of @COMPRESSION_PATTERNS
      # Type has compression pattern
      for key in @COMPRESSION_PATTERNS[type]
        out += @DELIMITER
        d = data[key]
        if typeof d is "object"
          for cla in @COMPRESSIBLE_CLASSES
            if d instanceof cla
              # d is of compressible class
              if "serialize" of cla
                # d's class has serialization methods
                out += (@OBJECT_IDENT + cla.serialize(d))
                break
              else
                throw "Cannot serialize object of type #{cla}"
        else
          out += "#{data[key]}"
    else
      out += JSON.stringify(data)
    return out

  @decompress: (type, data) ->
    out = {}
    if type of @COMPRESSION_PATTERNS
      # Type has compression pattern
      vals = data.split(@DELIMITER)
      i = 0
      for key in @COMPRESSION_PATTERNS[type]
        val = vals[i]
        if val[0] is @OBJECT_IDENT
          # This val is an object
          # Deserialize it correctly by determining its type with the type identifier at val[1]
          (out[key] = cla.deserialize(val); break) for id, cla of @OBJECT_KEYS when id is val[1]
        else
          out[key] = val
        i++
    else
      out = JSON.parse(data)
    return out

  @pullTypeFrom: (msg_raw) ->
    return msg_raw.substring(0, @TYPE_LENGTH)

  @removeTypeFrom: (msg_raw) ->
    # Returns message stripped of its type (and the delimiter succeeding the type)
    return msg_raw.substring(@TYPE_LENGTH+1)

  @assertType: (type, obj) ->
    return @ASSERTIONS[type](obj)

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
      continue unless type in allowedTypes # Ignore invalid assertion types
      for key in keys
        if obj[key] isnt undefined
          return false unless typeof obj[key] is type
        else
          return false

    return true

if not window?
  module.exports = exports
  exports.MessageSerializer = MessageSerializer
  exports.NetTypes = NetTypes
else
  MIKE.MessageSerializer = MessageSerializer
  MIKE.NetTypes = NetTypes