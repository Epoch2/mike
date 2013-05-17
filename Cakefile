{spawn, exec} = require "child_process"
os = require("os")

launch = (cmd, options=[]) ->
  app = spawn cmd, options
  app.stdout.pipe(process.stdout)
  app.stderr.pipe(process.stderr)
  # app.on 'exit', (status) -> callback?() if status is 0

task 'build', 'Build src/ to build/.', ->
  platform = os.platform()
  switch platform
    when "win32"
      launch "coffee.cmd", ["-c", "-o", "build/", "src/"]

    when "darwin"
      launch "coffee", ["-c", "-o", "build/", "src/"]