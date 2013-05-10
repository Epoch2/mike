WebSocketServer = require("ws").Server
https = require("https")
http = require("http")
NMS = require("./NetMessageHelper.js").NetMessageHelper
Emitter = require("./Emitter.js").Emitter

class ClientConnection extends Emitter
  constructor: (@ws, @callback) ->
    @ID = undefined
    @authenticated = false
    @callbacks = {}

    @ws.on "message", (message) =>
      @emit "message", NMS.deserialize(message)

    @ws.on "close", (code, reason) =>
      @emit "close"

  transmit: (msgObject) ->
    try
      @ws.send(NMS.serialize(msgObject))
      return null
    catch error
      return error

class SocketServer extends Emitter
  constructor: (@config) ->
    server = if @config.https is true then https.createServer(config) else http.createServer()
    server.listen(@config.port or 1337)

    @wss = new WebSocketServer({server: server})

    @callbacks = {}

    @wss.on "connection", (ws) =>
      client = new ClientConnection(ws)
      @emit "new", client