Emitter = MIKE.Emitter
Connection = MIKE.Connection
MikeClient = MIKE.MikeClient
OtherSnake = MIKE.OtherSnake
MS = MIKE.MessageSerializer
TYPES = MIKE.NetTypes.TYPES

class Robert extends Emitter
  constructor: (server) ->
    @connection = new Connection(new WebSocket(server))
    @ready = false
    @assignedColor = ""

    @connection.on "ready", =>
      console.log "Robert ready"
      @ready = true

    @connection.on "message", (message) => # When is message used?
      console.log "Robert message"
      console.log message
      @handleMessage(MS) if @ready

  handleMessage: (msg) ->
    switch msg.type
      when TYPES.INV
        @assignedColor = msg.color
        @emit "invite", msg.data.gameStart, msg.data.color, acceptInvite

      when TYPES.POS_UPD
        @emit "pos_upd", msg.data

      when TYPES.NEW_CLIENT
        newClient = new MikeClient()
        newClient.id = msg.data.id
        newClient.addSnake(new OtherSnake(msg.data.pos, msg.data.color, msg.data.name))
        @emit "new_client", newClient

  acceptInvite = (name) =>
    if name?
      @connection.transmit MS.serialize({
        type: TYPES.INV_RES,
        data: {
          accept: true,
          color: @assignedColor,
          name: name
        }
      })

MIKE.Robert = Robert