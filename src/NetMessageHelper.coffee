

class NetMessageHelper
  @CODE_LENGTH = 2
  @CODES = {
    INV: "00",
    INV_RES: "01",
    MOV_UPD: "02",
    POS_UPD: "03"
  }

  assertKeys: (obj, checks) ->
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

  compressBool: (bool) ->
    return false unless typeof bool is "boolean"
    if bool is false
      return "0"
    else
      return "1"

  # Assertions
  # Key is message code, value is function that asserts messages with said code
  @ASSERT_TYPE = {}
  @ASSERT_TYPE[@CODES.INV] = (msg) => return msg.type is @CODES.INV and assertKeys(msg, {"string": ["color"], "number": ["gameStart"]})
  @ASSERT_TYPE[@CODES.INV_RES] = (msg) => return msg.type is @CODES.INV_RES and assertKeys(msg, {"boolean": ["accept"], "string": ["color"]})
  @ASSERT_TYPE[@CODES.MOV_UPD] = (msg) => return msg.type is @CODES.MOV_UPD and assertKeys(msg, {"boolean": ["move", "left", "right"]})
  @ASSERT_TYPE[@CODES.POS_UPD] = (msg) => return msg.type is @CODES.POS_UPD and assertKeys(msg, {"number": ["x", "y", "dir", "dx", "dy"]})

  @serialize: (msg_obj) ->
    return false unless @assertType(msg_obj, msg_obj.type)
    out = msg_obj.type #always prepend fixed length type

    switch msg_obj.type
      when @CODES.INV
        out += msg_obj.color
        out += msg_obj.gameStart

      when @CODES.INV_RES
        out += compressBool(msg_obj.accept)
        out += msg_obj.color

      when @CODES.MOV_UPD
        bools = ["move", "left", "right"]
        do(->out += compressBool(msg_obj[bool])) for bool in bools

      when @CODES.POS_UPD
        numbers = ["x", "y", "dir", "dx", "dy"]
        do(->out += msg_obj[number]) for number in numbers

      else
        return false

    return out

  @deserialize: (msg_raw) ->
    return false unless msg_raw.length isnt >= @CODE_LENGTH #catch empty messages
    type = msg_raw[..(@CODE_LENGTH-1)]
    return false unless type in @CODES                      #catch invalid types
    out = {type: type}

    switch type
      when @CODES.INV
        return false unless msg_raw.length is >= @CODE_LENGTH+8   # 8 = 7 chars hex color + at least 1 digit of time
        out.color = msg_raw[@CODE_LENGTH..(@CODE_LENGTH+6)]       # 7 chars hex color
        out.gameStart = msg_raw[(@CODE_LENGTH+6)..]               # the rest is time

      when @CODES.INV_RES
        return false unless msg_raw.length is @CODE_LENGTH+8      # 8 = 1 char accept, 7 chars hex color
        out.accept = msg_raw[@CODE_LENGTH]
        out.color = msg_raw[(@CODE_LENGTH+1)..]

      when @CODES.MOV_UPD
        return false unless msg_raw.length is @CODE_LENGTH+3      # 3 = 1 char for each (move, left, right)
        out.move = msg_raw[@CODE_LENGTH]
        out.left = msg_raw[@CODE_LENGTH+1]
        out.right = msg_raw[@CODE_LENGTH+2]

      when @CODES.POS_UPD
        return false unless msg_raw.length is @CODE_LENGTH+25     # 25 = 5 char for each (x, y, dir, dx, dy)
        keys = ["x", "y", "dir", "dx", "dy"]
        i = @CODE_LENGTH
        for key in keys
          out[key] = msg_raw[i..(i+4)]
          i++

      else
        return false

      return out

  @assertType: (obj, type) ->
    assertion = @ASSERT_TYPE[type]
    return assertion(obj)

  @typeOf: (obj) ->
    return Number(type) for type, assertion of @ASSERT_TYPE when assertion(obj)

if not window?
  module.exports = exports
  exports.NetMessageHelper = NetMessageHelper
else
  window.NetMessageHelper = NetMessageHelper