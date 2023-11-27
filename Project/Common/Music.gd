extends Node

var player:AudioStreamPlayer
var tween_out :Tween
onready var rng = RandomNumberGenerator.new()
var err := OK

const PATH := "res://Common/ChillJazzMusicPackEasyLoopOGG/%s.ogg"

const ACTIVITY_IN_PROGRESS : ="ActivityinProgress"
const AT_THE_PAD := "AtthePad"
const BRASS_TACKS := "BrassTacks"
const CHALLENGE_IN_PROGRESS := "ChallengeinProgress"
const CHILLOUTMAN := "ChillOutMan"
const NEW_TECH := "NewTech"

const FAILURE1 := "JingleFailure1"
const FAILURE2 := "JingleFailure2"
const FULL_SUCCESS := "JingleFullSuccess"
const MIXED_SUCCESS := "JingleMixedSuccess"

const transition_duration := 10.0
const transition_type := 0 # TRANS_SINE

var songs := [ACTIVITY_IN_PROGRESS, AT_THE_PAD, BRASS_TACKS, CHALLENGE_IN_PROGRESS, CHILLOUTMAN, NEW_TECH]

# Called when the node enters the scene tree for the first time.
func _ready():
	rng = RandomNumberGenerator.new()
	rng.randomize()
	player = AudioStreamPlayer.new()
	add_child(player)
	tween_out = Tween.new()
	add_child(tween_out)
	
	play_random()
	
func play_random():
	if tween_out.is_active():
		err = tween_out.stop_all()
		if err != OK and err != FAILED: push_error("Tween Failed: " + str(err))
	rng.randomize()
	var song:AudioStreamOGGVorbis = load(
		PATH % songs[rng.randi_range(0, songs.size()-1)])
	player.stream = song
	player.play()
	
func get_success()->AudioStreamOGGVorbis:
	return load(PATH % FULL_SUCCESS) as AudioStreamOGGVorbis
	
func get_failure()->AudioStreamOGGVorbis:
	return load(PATH % FAILURE1) as AudioStreamOGGVorbis

func began_race():
	# https://ask.godotengine.org/27939/how-to-fade-in-out-an-audio-stream
	# tween music volume down to 0
	err = tween_out.interpolate_property(
		player, "volume_db", 0, -40, 
		transition_duration, transition_type, Tween.EASE_IN, 0)
	if err != OK and err != FAILED : push_error("Tween Failed: " + str(err))
	err = tween_out.start()
	if err != OK and err != FAILED  : push_error("Tween Failed: " + str(err))

func race_finished():
	player.volume_db = 0
	play_random()
	
	
func _on_TweenOut_tween_completed(object, _key):
	# stop the music -- otherwise it continues to run at silent volume
	object.stop()
