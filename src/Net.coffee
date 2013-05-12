unless window?
  Vec2 = require("./Vec2.js").Vec2
else
  Vec2 = MIKE.Vec2

class NetTypes
  # Static
  @TYPE_LENGTH: 2
  @TYPES: {
    PING: "00",
    INV: "01"
    INV_RES: "02",
    MOV_UPD: "03",
    POS_UPD: "04",
    NEW_CLIENT: "05"
  }

class MessageSerializer
  # Public
  # Static

  @TYPES: NetTypes.TYPES
  @TYPE_LENGTH: NetTypes.TYPE_LENGTH
  @DELIMITER: "|"
  @OBJECT_IDENT: "@"

  # Message structure descriptions
  @STRUCTURES: {}
  @STRUCTURES[@TYPES.INV] = {"color": "string", "gameStart": "number"}
  @STRUCTURES[@TYPES.INV_RES] = {"accept": "boolean", "color": "string", "name": "string"}
  @STRUCTURES[@TYPES.MOV_UPD] = {"move": "boolean", "left": "boolean", "right": "boolean"}
  @STRUCTURES[@TYPES.POS_UPD] = {"id": "number", "pos": "object", "vel": "object", "dir": "object"}
  @STRUCTURES[@TYPES.NEW_CLIENT] = {"id": "number", "name": "string", "color": "string", "pos": "object"}

  # Compression patterns
  @COMPRESSION_PATTERNS: {}
  @COMPRESSION_PATTERNS[@TYPES.INV] = ["color", "gameStart"]
  @COMPRESSION_PATTERNS[@TYPES.INV_RES] = ["accept", "color", "name"]
  @COMPRESSION_PATTERNS[@TYPES.MOV_UPD] = ["move", "left", "right"]
  @COMPRESSION_PATTERNS[@TYPES.POS_UPD] = ["id", "pos", "vel", "dir"]
  @COMPRESSION_PATTERNS[@TYPES.NEW_CLIENT] = ["id", "name", "color", "pos"]

  # Classes with serialization methods
  @COMPRESSIBLE_CLASSES: [Vec2]

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

    # Deserialize string
    tempData = @decompress(type, msg_raw)
    try
      # Restructurize object
      out.data = @typecast(tempData, @STRUCTURES[type])
    catch error
      # Beautiful amazing error handling goes here
      console.log error
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
      # Message type has compression pattern
      vals = data.split(@DELIMITER)
      i = 0
      for key in @COMPRESSION_PATTERNS[type]
        val = vals[i]
        if val[0] is @OBJECT_IDENT
          console.log val
          # This val is an object
          # Deserialize it correctly by determining its type with the type identifier at val[1]
          (out[key] = cla.deserialize(val); break) for cla in @COMPRESSIBLE_CLASSES when val[1] is cla.TYPE_IDENT
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
    return @assertKeys(obj, @STRUCTURES[type])

  @assertKeys: (obj, checks) ->
    # Asserts that an object, 'obj', contains the keys
    # specified in 'checks', and that their values
    # are of the specified type.
    #
    # In the example below, the object 'pos' is
    #
    # assertKeys(pos, {
    #   "x": "number",
    #   "y": "number",
    #   "isCoordinate": "boolean"
    # })

    for key of obj
      return false unless typeof obj[key] is checks[key]
    return true

  @typecast: (obj, casts) ->
    # Casts all values of 'obj' to match the
    # types specified for the keys in 'casts'
    #
    # In the example below, the properties 'x'
    # and 'y' of the object 'pos' will
    # be casted to numbers while the
    # property "isCoordinate" will be
    # casted to boolean.
    #
    # typecast(pos, {
    #   "x": "number",
    #   "y": "number",
    #   "isCoordinate": "boolean"
    # })

    # Methods to use for casting.
    # Number() parses both ints and floats
    # as opposed to parseInt() and parseFloat()
    # whom only parses their own types
    # respectively.
    castMethods = {
      "boolean": Boolean,
      "string": String,
      "number": Number
    }

    for key, val of obj
      obj[key] = castMethods[casts[key]](val) if typeof val of castMethods
    return obj

unless window?
  module.exports = exports
  exports.MessageSerializer = MessageSerializer
  exports.NetTypes = NetTypes
else
  MIKE.MessageSerializer = MessageSerializer
  MIKE.NetTypes = NetTypes