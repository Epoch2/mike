Emitter = MIKE.Emitter
Connection = MIKE.Connection
MikeClient = MIKE.MikeClient
Snake = MIKE.Snake
MS = MIKE.MessageSerializer
TYPES = MIKE.NetTypes.TYPES

class Robert extends Emitter
  constructor: (server) ->
    @connection = new Connection(new WebSocket(server))
    @ready = false
    @assignedColor = ""

    @connection.on "ready", =>
      @ready = true

    @connection.on "message", (message) =>
      @handleMessage(MS.deserialize(message)) if @ready

  handleMessage: (msg) ->
    switch msg.type
      when TYPES.INV
        @assignedColor = msg.data.color
        @emit "game:invite", msg.data.gameStart, msg.data.color, @acceptInvite

      when TYPES.POS_UPD
        @emit "client:pos_upd", msg.data

      when TYPES.NEW_CLIENT
        alert("Someone joined!")
        newClient = new MikeClient()
        newClient.id = msg.data.id
        newClient.addSnake(new Snake(msg.data.pos, msg.data.color, msg.data.name))
        @emit "client:new", newClient

      when TYPES.PLR_CLIENT
        newClient = new MikeClient()
        newClient.id = msg.data.id
        newClient.addSnake(new Snake(msg.data.pos, msg.data.color, msg.data.name))
        @emit "client:player", newClient

      when TYPES.DEL_CLIENT
        console.log "del client"
        @emit "client:delete", msg.data.id

  acceptInvite: (name) =>
    if name?
      @connection.transmit(MS.serialize({
        type: TYPES.INV_RES,
        data: {
          accept: true,
          color: @assignedColor,
          name: name
        }
      }))

  sendMovUpdate: (move, left, right) ->
    @connection.transmit(MS.serialize({
      type: TYPES.MOV_UPD,
      data: {
        move: move,
        left: left,
        right: right
      }
    }))

MIKE.Robert = Robert