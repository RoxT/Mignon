extends Node2D

var save_game:AllChickens
onready var last_show_chicken := $BuyBackLast/ShowChicken
onready var buy_back_btn := $BuyBackLast/BuyBack

onready var small_pen_btn := $Farm/SmallMove
onready var medium_pen_btn := $Farm/MediumMove
onready var large_pen_btn := $Farm/LargeMove

func multiplier(pen:String)->int:
	match pen:
		"Starter":
			return 1
		"Medium": 
			return 2
		"Large":
			return 3
	return -1

# Called when the node enters the scene tree for the first time.
func _ready():
	save_game = M.save_game
	$UI/Money.text = "Money: $" + str(save_game.money)
	$UI/Food/Panel/FoodBox/BEST.count = save_game.foods[save_game.FOOD_TYPES.BEST]
	$UI/Food/Panel/FoodBox/GOOD.count = save_game.foods[save_game.FOOD_TYPES.GOOD]
	$UI/Food/Panel/FoodBox/BASIC.count = save_game.foods[save_game.FOOD_TYPES.BASIC]
	$UI/Food/Panel/FoodBox/Label.visible = save_game.foods == [0,0,0]
	
	if save_game.has_medium_pen == true:
		medium_pen_btn.text = "Move back $" + str(round(M.MEDIUM_PRICE/3.0))
	else:
		$Farm/MediumDesc.text = "???????\n???????????????????????????\n"
		medium_pen_btn.disabled = true
	
	if save_game.has_large_pen == true:
		large_pen_btn.text = "Move back $" + str(round(M.LARGE_PRICE/3.0))
	else:
		$Farm/LargeDesc.text = "???????\n???????????????????????????\n???????????"
		large_pen_btn.disabled = true
		
	small_pen_btn.text = "Move back $" + str(round(M.STARTER_PRICE/3.0))
	
	match save_game.pen:
		"Starter": current_button(small_pen_btn)
		"Medium": current_button(medium_pen_btn)
		"Large": current_button(large_pen_btn)
	
	if save_game.last_sold_chicken is Chicken:
		last_show_chicken.stats = save_game.last_sold_chicken
		last_show_chicken.show()
		buy_back_btn.disabled = false
		buy_back_btn.text = "Buy $" + str(last_show_chicken.stats.get_price())
	else:
		last_show_chicken.hide()
		buy_back_btn.disabled = true

func current_button(btn:Button):
	btn.disabled = true
	btn.text = "Current Farm"

func _on_BuyBack_pressed():
	save_game.buy_back_last()
	_on_ToCoop_pressed()
	
func _on_ToCoop_pressed():
	save_game.save()
	var err := get_tree().change_scene("res://Coop.tscn")
	if err != OK:
		push_error("Error switching scenes: " + str(err))

func _on_More_pressed():
	var err := get_tree().change_scene("res://Store/Store.tscn")
	if err != OK:
		push_error("Error switching scenes to page 1: " + str(err))

func _on_Move_pressed(extra_arg_0):
	assert(extra_arg_0 == "Starter" or extra_arg_0 == "Medium" or extra_arg_0 == "Large")
	var price:float
	var food_multiplier:= float(multiplier(save_game.pen))/float(multiplier(extra_arg_0))
	match extra_arg_0:
		"Starter": 
			price = round(M.STARTER_PRICE/3.0)
		"Medium": 
			price = round(M.MEDIUM_PRICE/3.0)
		"Large": 
			price = round(M.LARGE_PRICE/3.0)
	save_game.money -= price
	save_game.pen = extra_arg_0
	for i in save_game.foods.size():
		if save_game.foods[i] > 1:
			save_game.foods[i] = round(save_game.foods[i] * food_multiplier)
			save_game.foods[i] = max(1, save_game.foods[i])
		
	_on_ToCoop_pressed()
