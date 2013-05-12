Emitter = MIKE.Emitter
Connection = MIKE.Connection
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
      @handleMessage(MS) if @ready

  handleMessage: (msg) ->
    switch msg.type
      when TYPES.INV
        @assignedColor = msg.color
        @emit "invite", msg.data.gameStart, msg.data.color, acceptInvite

      when TYPES.POS_UPD
        @emit "pos_upd", msg.data

  acceptInvite = (name) =>
    @connection.transmit MS.serialize({
      type: TYPES.INV_RES,
      data: {
        accept: true,
        color: @assignedColor,
        name: name
      }
    })