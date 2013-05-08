WebSocketServer = require("ws").Server
fs = require("fs")
https = require("https")
http = require("http")
request = require("request")
MS = require("./message.js").Message

class GameClientConnection
  constructor: (@ws, @callback) ->
    @ID = undefined
    @authenticated = false
    @callbacks = {
      "message": undefined,
      "close": undefined
    }

    @ws.on "message", (message) =>
      @emit("message", message)

    @ws.on "close", (code, reason) =>
      @emit("close")

  emit: (event, arg) ->
    callback(arg) for evt, callback of @callbacks when evt is event and typeof callback is "function"

  on: (event, callback) ->
    do(=>
      @callbacks[event] = callback
    ) if typeof event is "string" and typeof callback is "function"

  transmit: (msgObject) ->
    try
      @ws.send(MS.serialize(msgObject))
      return null
    catch error
      return error

class NetServer
  constructor: (@config) ->
    server = if @config.https is true then https.createServer(config) else http.createServer()
    server.listen(@config.port or 1337)

    @wss = new WebSocketServer({server: server})
    @clients = []
    @clientID = 0

    @callbacks = {
      "connect": undefined,
      "close": undefined
    }

    @wss.on "connection", (ws) =>
      client = new GameClientConnection(ws)
      client.on "message", (message) =>
        @handleClientRequest(client, MS.deserialize(message))

      client.on "close", =>
        connectedClient = @getClientByWS(client.ws)
        @delClientByWS(client.ws) if connectedClient?

  emit: (event, arg) ->
    callback(arg) for evt, callback of @callbacks when evt is event and typeof callback is "function"

  on: (event, callback) ->
    do(=>
      @callbacks[event] = callback
    ) if typeof event is "string" and typeof callback is "function"

  addIDTo: (client) =>
    client.ID = @clientID
    @clientID++

  handleClientRequest: (client, request) =>
    console.log "lol"
    # switch MS.typeOf(request)
      # when something
        # something else

  authenticateUser: (client) =>
    @addClient(@addIDTo(client))
    @emit("client connect", client.ID)
    return true

  addClient: (client) ->
    @clients.push(client) if client.ws? and client.ID?

  delClientByWS: (ws) ->
    @clients.splice(i,1) for client, i in @clients when client?.ws is ws

  getClientByID: (ID) ->
    return client for client in @clients when client?.ID is ID
    return null

  getClientByWS: (ws) ->
    return client for client in @clients when client?.ws is ws
    return null

  getClientCount: ->
    return @clients.length