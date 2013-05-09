class NetMessageHelper
  @CODE_LENGTH = 2
  @CODES = {
    INV: "00",
    INV_RES: "01",
    POS_UPD: "02"
  }

  assertKeys = (obj, checks) ->
    # Asserts that an object, 'obj', contains the keys
    # specified, and that the values of the keys are of the right type.
    #
    # In the example below the object 'pos' is asserted
    # to contain two numbers with the keys 'x' and 'y' and
    # one boolean with the key "isCoordinate"
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

  compressBool = (bool) ->
    return false unless typeof bool is "boolean"
    if bool is false
      return "0"
    else
      return "1"

  # Assertions
  # Key is message code, value is function that asserts messages with the said code
  @ASSERT_TYPE = {}
  @ASSERT_TYPE[@CODES.INV] = (msg) => return msg.type is @CODES.INV and assertKeys(msg, {"string": ["color"], "number": ["gameStart"]})
  @ASSERT_TYPE[@CODES.INV_RES] = (msg) => return msg.type is @CODES.INV_RES and assertKeys(msg, {"boolean": ["accept"], "string": ["color"]})
  @ASSERT_TYPE[@CODES.POS_UPD] = (msg) => return msg.type is @CODES.POS_UPD and assertKeys(msg, {"boolean": ["move", "left", "right"]})

  @serialize: (msg_obj) ->
    return false unless @assertType(msg_obj, msg_obj.type)
    out = msg_obj.type #always prepend fixed length type

    switch msg_obj.type
      when @CODES.INV
        out += msg_obj.color
        out += msg_obj.gameStart

      when @CODES.POS_UPD
        bools = ["move", "left", "right"]
        do(->out += compressBool(msg_obj[bool])) for bool in bools

    return out

  @deserialize: (msg_raw) ->
    return false unless msg_raw.length isnt >= @CODE_LENGTH #catch empty messages
    type = msg_raw[..(@CODE_LENGTH-1)]
    return false unless type in @CODES                      #catch invalid types
    out = {type: type}

    switch type
      when @CODES.INV
        return false unless msg_raw.length is >= @CODE_LENGTH+8   # 8 = 7 digits hex color + at least one digit of time
        out.color = msg_raw[@CODE_LENGTH..(@CODE_LENGTH+6)]       # 7 digits hex color
        out.gameStart = msg_raw[(@CODE_LENGTH+6)..]               # the rest is time

      when @CODES.INV_RES

      when @CODES.POS_UPD
        return false unless msg_raw.length is @CODE_LENGTH+3      # 3 = move, right, left
        out.move = msg_raw[@CODE_LENGTH]
        out.left = msg_raw[@CODE_LENGTH+1]
        out.right = msg_raw[@CODE_LENGTH+2]
        return out

  @assertType: (obj, type) ->
    assertion = @ASSERT_TYPE[type]
    return assertion(obj)

  @typeOf: (obj) ->
    return Number(type) for type, assertion of @ASSERT_TYPE when assertion(obj)

if not window?
  module.exports = exports
  exports.NetMessage = NetMessage
else
  window.NetMessage = NetMessage