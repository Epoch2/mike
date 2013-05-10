WebSocketServer = require("ws").Server
https = require("https")
http = require("http")
Connection = require("./Connection.js").Connection
Emitter = require("./Emitter.js").Emitter

class ConnectionServer extends Emitter
  constructor: (@config) ->
    server = if @config.https is true then https.createServer(config) else http.createServer()
    server.listen(@config.port or 1337)

    @wss = new WebSocketServer({server: server})

    @wss.on "connection", (ws) =>
      client = new Connection(ws)
      @emit "new", client

module.exports = exports
exports.ConnectionServer = ConnectionServer