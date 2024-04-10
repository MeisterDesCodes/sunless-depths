extends Node2D


class_name StateMachine

@export var entityScene: CharacterBody2D
@export var initialState: State

var states: Dictionary = {}
var currentState: State


func _ready():
	for state in get_children():
		if entityScene.entityResource.states.filter(func(stateKey): return Enums.enemyStates.keys()[stateKey].to_lower() == state.name.to_lower()).is_empty():
			state.get_parent().remove_child(state)
	
	for state in get_children():
		states[state.name.to_lower()] = state
		state.onChange.connect(onChange)
	
	if initialState:
		initialState.enter()
		currentState = initialState


func _process(delta):
	currentState.update(delta)


func onChange(oldState: State, newState: State):
	oldState.exit()
	newState.enter()
	currentState = newState


func getState(state: Enums.enemyStates):
	var stateString: String = Enums.enemyStates.keys()[state].to_lower()
	return states[stateString] if states.has(stateString) else null
