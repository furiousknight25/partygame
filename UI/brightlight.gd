extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready():
	show()
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, 'scale', Vector2(1,0), .2)

