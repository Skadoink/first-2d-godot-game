extends Node

@export var mob_scene: PackedScene
@export var feeder_scene: PackedScene
var score

# Called when the node enters the scene tree for the first time.
func _ready():
	#new_game()
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
var difficulty = 3 #default is 3 (out of 1-5)
var counter = 0

func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()
	$Music.stop()
	$DeathSound.play()

func new_game():
	score = 0
	print(difficulty)
	$MobTimer.set_wait_time(0.25 / (difficulty / 3))
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	$Player.start($StartPosition.position)
	$StartTimer.start()
	get_tree().call_group("mobs", "queue_free")
	get_tree().call_group("feeders", "queue_free")
	$Music.play()

func _on_score_timer_timeout():
	score += 1
	$HUD.update_score(score)

func _on_start_timer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()

func _on_mob_timer_timeout():
	# Create a new instance of either Mob or feeder scene.
	var mob
	if counter % 2 == 0:
		mob = mob_scene.instantiate()
	else:
		mob = feeder_scene.instantiate()
	counter += 1

	# Choose a random location on Path2D.
	var mob_spawn_location = get_node("MobPath/MobSpawnLocation")
	mob_spawn_location.progress_ratio = randf()
	# Set the mob's position to a random location.
	mob.position = mob_spawn_location.position

	# Set the mob's direction perpendicular to the path direction.
	var direction = mob_spawn_location.rotation + PI / 2
	# Add some randomness to the direction.
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction
	
	# Choose the velocity for the mob.
	var velocity = Vector2(randf_range(150.0, 250.0) * difficulty / 3, 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)

func _on_hud_new_difficulty():
	difficulty = $HUD.difficulty

func _on_player_eat():
	score += 1
	$HUD.update_score(score)
