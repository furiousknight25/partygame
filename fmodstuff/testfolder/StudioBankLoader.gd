extends StudioBankLoader

@export var event: EventAsset
var instance: EventInstance


func _ready():
	instance = FMODRuntime.create_instance(event)
	
func start(): #devmode
	instance.start()
	
func mute():
	instance.set_volume(0.0)
	

@rpc("any_peer", "call_local")
func change_level(level = 0):
	#var mew_addon = instance.get_parameter_by_name('progress')['value'] + 1
	#print(level)
	#print(instance)
	instance.set_parameter_by_name("progress", level, false)
	#print(instance.get_parameter_by_name('progress'))

