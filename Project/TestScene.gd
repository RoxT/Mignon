extends Node

func _ready():
	print(EnemyChickens.get_nom(5))
	generate_enemy_list()

func get_series():
	var r := RandomNumberGenerator.new()
	r.randomize()
	var nums := []
	for i in range(50):
		nums.append(round(r.randfn(230, 115) + 40) as int)
		print(str(nums[i]))


func generate_enemy_list()->Array:
	var e := []
	var file := File.new()
	file.open("res://Common/JSON/enemy_chickens.json", File.READ)
	var content = file.get_as_text()
	var list_of_farms:Dictionary = JSON.parse(content).result
	for f_key in list_of_farms.keys():
		var farm := Farm.new()
		farm.nom = f_key
		for c_key in list_of_farms[f_key].chickens.keys():
			var chicken := Chicken.new()
			chicken.nom = c_key
			var this_chicken:Dictionary = list_of_farms[f_key].chickens[c_key]
			for k in this_chicken.keys():
				chicken.set(k,this_chicken[k])
			chicken.farm = f_key
			farm.chickens.append(chicken)
		e.append(farm)
	
	file.close()
	return e
