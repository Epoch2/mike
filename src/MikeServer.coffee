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
    @msg_count = 0
    @cl_c = null

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
    if @cl_c?.id isnt client?.id
      console.log "DIFFERENT CLIENT"
      @cl_c = client
    else
      console.log "SAME CLIENT"
    switch msg.type
      when TYPES.INV_RES
        console.log "INV_RES"
        if msg.data.color is client.color and msg.data.accept
          x = Math.random()*600
          y = Math.random()*600
          snake = new Snake(new Vec2(x, y), client.color, msg.data.name)
          client.addSnake snake
          client.id = @IDs
          @IDs++
          @addClient(client)

          clientData = {
            id: client.id,
            name: client.snake.name,
            color: client.snake.getColor(),
            pos: client.snake.getPos()
          }

          # Tell everyone about client
          @broadcast({
            type: TYPES.NEW_CLIENT,
            data: clientData
          }, client)

          # Give client to player
          client.connection.transmit(MS.serialize({
            type: TYPES.PLR_CLIENT,
            data: clientData
          }))

          # Tell new client about everyone else
          for cli in @clients
            if cli isnt client
              client.connection.transmit(MS.serialize({
                type: TYPES.NEW_CLIENT,
                data: {
                  id: cli.id,
                  name: cli.snake.name,
                  color: cli.snake.getColor(),
                  pos: cli.snake.getPos()
                }
              }))

      when TYPES.MOV_UPD
        console.log "Movupd: #{client.id}"
        return false unless @clientExists(client) # Don't update nonexistent clients
        client.snake.move = msg.data.move
        client.snake.left = msg.data.left
        client.snake.right = msg.data.right

  broadcast: (message, exceptions...) ->
    process.nextTick(=>
      for client in @clients
        excepted = false
        for exp in exceptions
          excepted = if client.id is exp.id then true else false
        client.connection.transmit(MS.serialize(message)) unless excepted
    )

  addClient: (client) ->
    if client.connection? and client.snake?
      # Make sure client is removed upon disconnect
      # (null pointer prevention)
      client.on "disconnect", =>
        @delClientByID(client.id)
        @broadcast {
          type: TYPES.DEL_CLIENT,
          data: {
            id: client.id
          }
        }, client

      @clients.push(client)
    else
      throw "addClient won't add client with missing connection or snake"


  delClientAsync: (client) ->
    process.nextTick(=>
      @clients.splice(i,1) for cli, i in @clients when cli is client
    )

  delClientByID: (ID) ->
    @clients.splice(i,1) for client, i in @clients when client?.ID is ID

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
      @activeColors.push(newColor)
      callback(newColor)
    )

  broadcastLoop: ->
    for client in @clients
      @broadcast({
        type: TYPES.POS_UPD,
        data: {
          id: client.id,
          pos: client.snake.getPos(),
          vel: client.snake.getVel(),
          dir: client.snake.getDir()
        }
      })

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