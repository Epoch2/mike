ConnectionServer = require("./ConnectionServer.js").ConnectionServer
Emitter = require("./Emitter.js").Emitter
ColorUtil = require("./ColorUtil.js").ColorUtil
Snake = require("./Snake.js").Snake
Vec2 = require("./Vec2.js").Vec2
MikeClient = require("./MikeClient.js").MikeClient
ServerGame = require("./ServerGame.js").ServerGame
MS = require("./Net.js").MessageSerializer
TYPES = require("./Net.js").NetTypes.TYPES

class MikeServer
  constructor: (config) ->
    @connectionserver = new ConnectionServer(config)
    @clients = []
    @IDs = 0
    @activeColors = []
    @NET_UPDATE_DT = 1000/60
    @msg_pretime = 0
    @msg_posttime = 0
    @msg_count = 0
    @msg_rate = 0
    @msg_print_dt = 0

    @time = ->
      t = process.hrtime()
      return (t[0] * 1e9 + t[1])/1000000

    @connectionserver.on "new", (connection) =>
      console.log "MS new connection"
      client = new MikeClient(connection)

      client.on "message", (msg) =>
        @handleClientMessage(MS.deserialize(msg), client)

      @genColor (color) =>
        client.color = color
        client.connection.transmit(MS.serialize({
            type: TYPES.INV,
            data: {
              color: color,
              gameStart: 23049
            }
          }))

  handleClientMessage: (msg, client) ->
    switch msg.type
      when TYPES.INV_RES
        console.log "INV_RES"
        x = Math.random()*200
        y = Math.random()*200
        snake = new Snake(new Vec2(x, y), client.color, msg.data.name)
        snake.move = true
        client.addSnake snake
        @addClientAsync(client) if msg.data.color is client.color and msg.data.accept

      when TYPES.MOV_UPD
        return false unless getClient(client)? # Don't update nonexistent clients
        client.snake.move = msg.data.move
        client.snake.left = msg.data.left
        client.snake.right = msg.data.right

  broadcast: (message) ->
    client.connection.transmit(MS.serialize(message)) for client in @clients

  addClientAsync: (client) ->
    if client.connection? and client.snake?
      process.nextTick(=>
        client.id = @IDs
        @IDs++
        # Make sure client is removed upon disconnect
        # (null pointer prevention)
        client.on "disconnect", =>
          @delClientAsync(client)
        @broadcast {
          type: TYPES.NEW_CLIENT,
          data: {
            id: client.id,
            name: client.snake.name,
            color: client.snake.color,
            pos: client.snake.getPos()
          }
        }

        @clients.push(client)
      )
    else
      throw "addClientAsync won't add client without connection or snake"


  delClientAsync: (client) ->
    process.nextTick(=>
      @clients.splice(i,1) for cli, i in @clients when cli is client
    )

  delClientByIDAsync: (ID) ->
    process.nextTick(=>
      @clients.splice(i,1) for client, i in @clients when client?.ID is ID
    )

  clientExists: (client) ->
    for cli in @clients
      if cli is client
        return true
    return false

  clientExistsAsync: (client, callback) ->
    process.nextTick(=>
      for cli in @clients
        if cli is client
          callback(true)
          return
      callback(false)
    )

  getClient: (client) ->
    return cli for cli in @clients when cli is client
    return null

  getClientAsync: (client, callback) ->
    process.nextTick(=>
      for cli in @clients
        if cli is client
          callback(cli)
          return
      callback(null)
    )

  getClientByID: (ID) ->
    return client for client in @clients when client?.ID is ID
    return null

  genColor: (callback) ->
    process.nextTick(=>
      comparison = 1
      while comparison >= 0.8
        newColor = ColorUtil.niceColor()
        if @activeColors.length > 0
          for activeColor in @activeColors
            comparison = Math.max(comparison, ColorUtil.compareColors(newColor, activeColor))
        else
          comparison = 0
      callback(newColor)
    )

  broadcastLoop: ->
    @msg_rate = Math.round(((@msg_count/((@msg_posttime - @msg_pretime)/1000))*10)/10)
    if (@time() - @msg_print_dt) > 1000
      @msg_print_dt = @time()
      console.log "#{@msg_rate} msg/s"
    @msg_count = 0
    @msg_pretime = @time()

    for client in @clients
      console.log client.snake.getPos()
      @msg_count++
      @broadcast({
        type: TYPES.POS_UPD,
        data: {
          id: client.id,
          pos: client.snake.getPos(),
          vel: client.snake.getVel(),
          dir: client.snake.getDir()
        }
      })
    @msg_posttime = @time()

    setTimeout (=> @broadcastLoop()), @NET_UPDATE_DT

  runGame: ->
    game = new ServerGame(@clients)
    game.gameLoop()
    @broadcastLoop()

config = {
  https: false,
  port: 1337
}
mikeserver = new MikeServer(config)
mikeserver.runGame()