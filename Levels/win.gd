extends Node2D

@onready var survivor = $Survivor

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in Director.players['points']
