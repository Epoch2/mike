SocketServer = require("./SocketServer.js").SocketServer
Emitter = require("./Emitter.js").Emitter
ColorUtil = require("./ColorUtil.js").ColorUtil
Snake = require("./Snake.js").Snake
MikeClient = require("./MikeClient.js").MikeClient
MS = require("./NetMessage.js").MessageSerializer
TYPES = require("./NetMessage.js").NetTypes.TYPES

class MikeServer
  constructor: (config) ->
    @socketserver = new ConnectionServer(config)
    @clients = []
    @activeColors = []

    @socketserver.on "new", (connection) =>
      client = new MikeClient(connection)

      client.on "message", (msg) =>
        @handleClientMessage(msg, client)

      genColor (color) =>
        client.color = color
        client.sendInvite(color)

  handleClientMessage: (msg, client) ->
    switch msg.type
      when TYPES.INV_RES
        snake = new BasicSnake(new Vec2(msg.wx/2, msg.wy/2), client.color, msg.name)
        addClient(snake) if msg.color is client.color and msg.accept

      when TYPES.MOV_UPD
        a = "empty"

  broadcast: (message) ->
    client.transmit(MS.serialize(message)) for client in @clients

  addClient: (client) ->
    if client.connection?
      client.id = @IDs
      @IDs++
      # Make sure client is removed upon disconnect
      # (null pointer prevention)
      client.on "close", (code, reason) =>
        @delClient(client)
      @clients.push(client)
      @broadcast {
        type: TYPES.NEW_CLIENT,
        data: {
          id: client.id,
          name: client.snake.name,
          color: client.snake.color
        }
      }

  delClient: (client) ->
    @clients.splice(i,1) for cli, i in @clients when cli is client

  delClientByID: (ID) ->
    @clients.splice(i,1) for client, i in @clients when client?.ID is ID

  getClientByID: (ID) ->
    return client for client in @clients when client?.ID is ID
    return null

  getClientCount: ->
    return @clients.length

  genColor: (callback)->
    process.nextTick(->
      comparison = 1
      while comparison >= 0.8
        newColor = ColorUtil.niceColor()
        comparison = Math.max(comparison, ColorUtil.compareColors(newColor, color)) for color in @activeColors
      callback(newColor)
    )

  runGame: ->
