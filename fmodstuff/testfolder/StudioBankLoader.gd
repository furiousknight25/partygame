extends StudioBankLoader

@export var event: EventAsset
var instance: EventInstance

func start(): #devmode
	instance = FMODRuntime.create_instance(event)
	instance.start()
	

func mute():
	instance.set_volume(0.0)
	
	
func change_level(level = 0):
	#var mew_addon = instance.get_parameter_by_name('progress')['value'] + 1
	print(instance)
	instance.set_parameter_by_name("progress", level, false)
	print(instance.get_parameter_by_name('progress'))

