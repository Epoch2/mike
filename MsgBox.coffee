class MsgBoxManager
	constructor: ->
		$msgBox = $("<div id='msgBox'><header><h1></h1></header><div class='body'></div><footer></footer></div>")
		$msgBox.css "display", "none"
		$("body").append $msgBox

	@show: (box) ->
		$("msgBox header h1").innerHTML box.title
		$("msgBox .body").innerHTML box.body
		$("msgBox footer").innerHTML box.footer
		$("msgBox").css "display", "absolute"

	@hide: ->
		$("msgBox").css "display", "none"
		$("msgBox header h1").innerHTML ""
		$("msgBox .body").innerHTML ""
		$("msgBox footer").innerHTML ""

class MsgBoxBasic
	constructor: (@title, @body) ->
		@footer = "<a href='http://www.horizon.adsa.se'>New Horizon website</a>"
		@$temp = $("<div id='msgBoxTemp' style='display: none;'></div>")

class MsgBoxStart extends MsgBoxBasic
	constructor: ->
		title = "Mike"
		body = "<p><strong>What is Game Title?</strong><br>This game was created as a dev demo for New Horizon. Your goal is to collect as many points as posible in the time span of 30 seconds. After that time period has passed the match restarts. Good luck!</p><p><strong>Enter your name</strong><br><input type='text'><a href='#'' class='button'>Play!</a></p>"
		super(title, body)

class MsgBoxScoreboard extends MsgBoxBasic
	constructor: ->
		title = "Scoreboard"
		body = "<div class='yscroll'><table></table></div>"
		super(title, body)

	addPlayer: (name, score) ->
		$("body").append(@temp)
		$("msgBoxTemp").append($(@body))
		$("msgBoxTemp table").append($("<tr>#{name}<td></td><td>#{score}</td></tr>"))
		@body = $("msgBoxTemp").html()