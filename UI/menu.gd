extends Control

@onready var animation_p = $AnimationPlayer
@onready var animation_t = $AnimationTree
@onready var select = $select
@onready var main = $Main
@onready var level_select = $select/OptionButton

@export var container : PackedScene

@onready var multiplayer_manager = get_parent().get_parent()
enum STATES {START, MENU, CHARACTER}
var cur_state = STATES.START

func _ready():
	for i in DirAccess.open("res://Levels/level_rotation/").get_files():
		level_select.add_item(i, i.find(i))
func _process(delta):
	match cur_state:
		STATES.START:
			#$Start.position = Vector2.ZERO
			if Input.is_anything_pressed():
				set_menu()
				var tween = get_tree().create_tween()
				tween.tween_property($Start/Button, "scale", Vector2(1.4,0), 1).set_trans(Tween.TRANS_QUINT)
			$Start/Button.modulate.a = 0 if Engine.get_frames_drawn() % 400 >= 200 else 1.0
		STATES.MENU:
			menu(delta)
		STATES.CHARACTER:
			character(delta)

func menu(delta):
#region blinking
	$Start/Button.modulate.a = 0 if Engine.get_frames_drawn() % 40 >= 20 else 1.0 
	#$Main/Control.position.y = (sin(delta * Engine.get_frames_drawn()) * .1) + old_y
	#@onready var old_y = $Main/Control.position.y
#endregion
func character(delta):
	pass

func set_menu():
	cur_state = STATES.MENU
	main.position = Vector2.ZERO


func set_character(client):
	cur_state = STATES.CHARACTER
	select.position = Vector2.ZERO
	#main.modulate.a = 0
	main.position = main.position + Vector2(100000,1000000)
	if client == 'host':
		multiplayer_manager._on_host_pressed() #egh, tis jank but it'll do, just keep it in mind
	if client == 'join':
		multiplayer_manager._on_join_pressed()

@rpc('authority')
func _start_game():
	position = position + Vector2(100000,1000000)
	multiplayer_manager.start_game()

@rpc("authority")
func _on_option_button_item_selected(index):
	position = position + Vector2(100000,1000000)
	multiplayer_manager._on_option_button_item_selected(index)
