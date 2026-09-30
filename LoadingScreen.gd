extends Control

@onready var progress_bar = $ProgressBar
var target_scene_path = "res://Game.tscn"

func _ready():
	# Start loading the game scene in a background thread
	ResourceLoader.load_threaded_request(target_scene_path)

func _process(_delta):
	var progress = []
	var status = ResourceLoader.load_threaded_get_status(target_scene_path, progress)
	
	if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		progress_bar.value = progress[0] * 100
	elif status == ResourceLoader.THREAD_LOAD_LOADED:
		progress_bar.value = 100
		set_process(false) # Stop checking
		
		# Wait a little bit so the user can see 100% completion
		await get_tree().create_timer(0.5).timeout
		
		# Change to the newly loaded scene
		var packed_scene = ResourceLoader.load_threaded_get(target_scene_path)
		get_tree().change_scene_to_packed(packed_scene)
	elif status == ResourceLoader.THREAD_LOAD_FAILED or status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		print("Failed to load the target scene!")
		set_process(false)
