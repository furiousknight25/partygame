extends VBoxContainer

@onready var points = $points
@onready var nam = $name



func _ready():
	points.text = "0"
	nam.text = "player " + name

func update(point):
	points.text = var_to_str(point)

func play():
	$AnimationPlayer.play('ding!')
