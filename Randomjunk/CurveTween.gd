extends Node
class_name CurveTween

signal curve_tween(sat)

@export var curve : Curve
var start := 0.0
var end := 1.0

func play(duration = 1.0, start_in = 0.0, end_in = 1.0):
	assert(curve, 'needa curve my brother bro bro')
	start = start_in
	end = end_in
	var tween = get_tree().create_tween()
	var x 
	tween.tween_method(interp.bind(), 0.0, 1.0, duration)
	
func interp(sat):
	emit_signal('curve_tween', start + ((end-start) * curve.sample(sat)))
	
