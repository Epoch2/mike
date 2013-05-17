ConnectionServer = require("./ConnectionServer.js").ConnectionServer
Emitter = require("./Emitter.js").Emitter
ColorUtil = require("./ColorUtil.js").ColorUtil
Snake = require("./Snake.js").Snake
MikeClient = require("./MikeClient.js").MikeClient
MikeGame = require("./MikeGame.js").MikeGame
MS = require("./Net.js").MessageSerializer
TYPES = require("./Net.js").NetTypes.TYPES

class MikeServer
  constructor: (config) ->
    @connectionserver = new ConnectionServer(config)
    @clients = []
    @activeColors = []
    @NET_UPDATE_FREQ = 1000/60

    @connectionserver.on "new", (connection) =>
      client = new MikeClient(connection)

      client.on "message", (msg) =>
        @handleClientMessage(msg, client)

      genColor (color) =>
        client.color = color
        client.connection.transmit({
            type: TYPES.INV,
            data: {
              color: color
            }
          })

  handleClientMessage: (msg, client) ->
    switch msg.type
      when TYPES.INV_RES
        x = Math.random()*200
        y = Math.random()*200
        snake = new ControllableSnake(new Vec2(x, y), client.color, msg.data.name)
        client.snake = snake
        addClient(client) if msg.data.color is client.color and msg.data.accept

      when TYPES.MOV_UPD
        return false unless getClient(client)? # Don't update nonexistent clients
        client.snake.move = msg.data.move
        client.snake.left = msg.data.left
        client.snake.right = msg.data.right

  broadcast: (message) ->
    client.transmit(MS.serialize(message)) for client in @clients

  addClient: (client) ->
    if client.connection? and client.snake?
      client.id = @IDs
      @IDs++
      # Make sure client is removed upon disconnect
      # (null pointer prevention)
      client.on "disconnect", =>
        @delClient(client)
      @clients.push(client)
      @broadcast {
        type: TYPES.NEW_CLIENT,
        data: {
          id: client.id,
          name: client.snake.name,
          color: client.snake.color,
          pos: client.snake.initPos
        }
      }

  delClient: (client) ->
    @clients.splice(i,1) for cli, i in @clients when cli is client

  delClientByID: (ID) ->
    @clients.splice(i,1) for client, i in @clients when client?.ID is ID

  getClient: (client) ->
    return cli for cli in @clients when cli is client
    return null

  getClientByID: (ID) ->
    return client for client in @clients when client?.ID is ID
    return null

  getClientCount: ->
    return @clients.length

  genColor: (callback) ->
    process.nextTick(=>
      comparison = 1
      while comparison >= 0.8
        newColor = ColorUtil.niceColor()
        comparison = Math.max(comparison, ColorUtil.compareColors(newColor, color)) for color in @activeColors
      callback(newColor)
    )

  broadcastLoop: ->
    for client in @clients
      broadcast {
        type: TYPES.POS_UPD,
        data: {
          id: client.id,
          pos: client.snake.getPos(),
          vel: client.snake.getVel(),
          dir: client.snake.getDir()
        }
      }
    this()

  runGame: ->
    game = new MikeGame(@clients)
    game.gameLoop()

config = {

}
mikeserver = new MikeServer(config)
mikeserver.gameLoop()