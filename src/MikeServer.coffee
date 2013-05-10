Emitter = require("./Emitter.js").Emitter
CODES = require("./NetMessageHelper.js").NetMessageHelper.CODES

class MikeClient extends Emitter
  constructor: (@connection) ->
    @connection.on "message", (msg) =>
      @emit "message", (msg)

    @connection.on "close", (code, reason) =>
      @emit "close", (code, reason)

  sendInvite: (color) ->
    @connection.transmit {
      type: NMS.INV,
      color: color
    }

  sendUpdate: (state) ->
    # ...


class MikeServer
  constructor: () ->
    @netserver = new NetServer()
    @clients = []
    @IDs = 0

    @netserver.on "new", (connection) =>
      client = new MikeClient(connection)

      client.on "message", (msg) =>
        @handleClientMessage(msg, client)

      color = genColor()
      client.color = color
      client.sendInvite(color)

  handleClientMessage: (msg, client) ->
    switch msg.type
      when CODES.INV_RES
        addClient(client) if msg.color is client.color and msg.accept

      when CODES.MOV_UPD
        # ...

  addClient: (client) ->
    if client.connection?
      client.ID = @IDs
      @IDs++
      # Make sure client is removed upon disconnect
      client.on "close", (code, reason) =>
        @delClientByID(client.ID)
      @clients.push(client)

  delClient: (client) ->
    @clients.splice(i,1) for cli, i in @clients when cli is client

  delClientByID: (ID) ->
    @clients.splice(i,1) for client, i in @clients when client?.ID is ID

  getClientByID: (ID) ->
    return client for client in @clients when client?.ID is ID
    return null

  getClientCount: ->
    return @clients.length

genColor = ->
  letters = "56789abcdef".split("")
  color = "#"
  for i in [0.. 5]
    color += letters[Math.floor(Math.random()*(letters.length-1))]
  color