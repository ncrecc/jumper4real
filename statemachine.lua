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
	statemachine.currentstate.stop()
	statemachine.currentstate = statemachine.states[state]
	statemachine.currentstate.begin()
end