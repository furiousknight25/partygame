extends CharacterBody2D

var open = false
@rpc("any_peer")
func hurt(direction, damage):
	if open: return
	open = true
	if multiplayer.is_server():
		print('hurt')
		$AnimationPlayer.play('open')
	else:
		hurt.rpc_id(1, direction, damage)

