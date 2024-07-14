extends Node2D


class_name StateMachine

@export var entityScene: CharacterBody2D
@export var initialState: State

var states: Dictionary = {}
var currentState: State
var lastState: State


func _ready():
	for state in get_children():
		if entityScene.entityResource.states.filter(func(stateKey): return UtilsS.getEnumValue(Enums.enemyStates,stateKey).to_lower() == state.name.to_lower()).is_empty():
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
	lastState = oldState
	currentState = newState


func getState(state: Enums.enemyStates):
	var stateString: String = UtilsS.getEnumValue(Enums.enemyStates, state).to_lower()
	return states[stateString] if stateString in states else null
