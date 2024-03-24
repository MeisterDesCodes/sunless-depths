extends Node2D


class_name StateMachine

@export var initialState: State

var states: Dictionary = {}
var currentState: State


func _ready():
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





