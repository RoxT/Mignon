extends Node2D


var enemies:Array
export var total :float= 1000

# Called when the node enters the scene tree for the first time.
func _ready():
	enemies = AllChickens.generate_enemy_list()
	print("Runs: " + str(int(total)))
	print("Speed, Wins, Ratio")
	for chicken in get_children():
		do_runs(chicken)
	
func do_runs(chicken):
	var wins :float= 0
	var stats :Chicken = chicken.stats
	stats.top_speed = 260
	
	for _i in range(total):
		if do_run(stats):
			wins += 1
	
	var ratio:float = wins/total
	ratio = ratio * 100
	ratio = round(ratio)
	var speed := stats.get_speed()
	chicken.label(wins, ratio)
	print(str(speed) + "," + str(wins) + "," + str(ratio))

func do_run(hero:Chicken)->bool:
	var farms:= AllChickens.choose_farms(3, AllChickens.bag(enemies.size()), enemies)
	var competition := []
	for f in farms:
		f = f as Farm
		competition.append(f.chickens[randi() % f.chickens.size()])
	for c in competition:
		if c.get_speed() > hero.get_speed():
			return false
	return true
