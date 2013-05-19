WebSocketServer = require("ws").Server
https = require("https")
http = require("http")
Connection = require("./Connection.js").Connection
Emitter = require("./Emitter.js").Emitter

class ConnectionServer extends Emitter
  constructor: (@config) ->
    server = if @config?.https is true then https.createServer(config) else http.createServer()
    server.listen(@config.port or 1337)
    @wscount = 0

    @wss = new WebSocketServer({server: server})

    @wss.on "connection", (ws) =>
      conn = new Connection(ws)
      @emit "new", conn

module.exports = exports
exports.ConnectionServer = ConnectionServer