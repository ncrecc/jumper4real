statemachine = {
	states = {
		["game"] = game,
		["menu"] = menu,
		["editor"] = editor
	},
	currentstate = menu
}

function statemachine.setstate(state)
	print ("statemachine: changing to state \"" .. state .. "\"!")
	statemachine.currentstate:stop() --why is this a colon. gamestates don't need "self"
	statemachine.currentstate = statemachine.states[state]
	statemachine.currentstate:begin()
end