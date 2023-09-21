extends Node2D
var save_game:AllChickens
onready var food_box := $Food/Panel/FoodBox
onready var money := $Money
onready var buy_best := $BuyBest
onready var buy_good := $BuyGood
onready var buy_basic := $BuyBasic
onready var tab_container := $TabContainer

const BACKYARD_COST := 5
const SMALL_FARM_COST := 10 

const FOOD_COPY := "$%s for %s - %s"
const COPY := "COPY"
const COST := "COST"
const AMOUNT := "AMOUNT"
const LARGE := "Large"
const MEDIUM := "Medium"
const STARTER := "Starter"
enum {BALCONY, BACKYARD, SMALL_FARM}

var foods := {
	"BEST" :  {STARTER: {COST : 10, AMOUNT : 5 }, MEDIUM: {COST : 10,  AMOUNT : 20 }, LARGE: {COST : 30,  AMOUNT : 30 }, COPY: "A delicious blend of herbs and insects. " },
	"GOOD" :  {STARTER: {COST : 5,  AMOUNT : 5 }, MEDIUM: {COST : 10,  AMOUNT : 20 }, LARGE: {COST : 30,  AMOUNT : 30 }, COPY: "Fine grasses" },
	"BASIC" : {STARTER: {COST : 5,  AMOUNT : 10 }, MEDIUM: {COST : 10,  AMOUNT : 20 }, LARGE: {COST : 30,  AMOUNT : 30 }, COPY: "Nutritious pellets in bulk" }
}

# Called when the node enters the scene tree for the first time.
func _ready():
	if AllChickens.exists():
		save_game = load(AllChickens.PATH)
	else:
		save_game = AllChickens.new()
		save_game.save()
	$BuyBest.text = food_text("BEST")
	$BuyGood.text = food_text("GOOD")
	$BuyBasic.text = food_text("BASIC")
	$TabContainer/BackyardPen/Unlock.text = "Unlock for $" + str(BACKYARD_COST)
	$TabContainer/SmallFarm/Unlock.text = "Unlock for $" + str(SMALL_FARM_COST)
	tab_container.current_tab = pen_to_tab(save_game.pen)
	can_buy_food(true)
	tab_container.connect("tab_changed", self, "_on_tab_changed")
	ui()

func _on_tab_changed(new_tab:int):
	ui()

func pen_to_tab(pen_name:String)->int:
	match pen_name:
		LARGE: return 2
		MEDIUM: return 1
		STARTER: return 0
	return -1


func food_text(type:String):
	var active_pen := save_game.pen as String
	return FOOD_COPY % [foods[type][active_pen][COST], foods[type][active_pen][AMOUNT],foods[type][COPY]]

func pen_name(value:int)->String:
	match value:
		0: return STARTER
		1: return MEDIUM
		2: return LARGE
	return "None"

func can_buy_food(value:bool):
	buy_best.visible = value
	buy_good.visible = value
	buy_basic.visible = value

func _on_BuyFood_pressed(type:String):
	var pen : = pen_name(tab_container.current_tab)
	type = type.to_upper()
	save_game.add_food(AllChickens.FOOD_TYPES[type], foods[type][pen][AMOUNT], foods[type][pen][COST])
	ui()

func ui():
	food_box.get_node("BEST").count = save_game.foods[AllChickens.FOOD_TYPES.BEST]
	food_box.get_node("GOOD").count = save_game.foods[AllChickens.FOOD_TYPES.GOOD]
	food_box.get_node("BASIC").count = save_game.foods[AllChickens.FOOD_TYPES.BASIC]
	money.text = "Money: $" + str(save_game.money)
	$TabContainer/BackyardPen/Unlock.disabled = save_game.money < BACKYARD_COST
	$TabContainer/BackyardPen/Unlock.visible = save_game.pen == STARTER
	$TabContainer/SmallFarm/Unlock.visible = save_game.pen == MEDIUM
	$TabContainer/SmallFarm/Unknown.visible = save_game.pen == STARTER
	can_buy_food(pen_to_tab(save_game.pen) == tab_container.current_tab)


func _on_ToCoop_pressed():
	save_game.save()
	var err = get_tree().change_scene("res://Coop.tscn")
	match err:
		 OK: return
		 ERR_CANT_OPEN: push_error("ERR_CANT_OPEN Coop Scene path cannot be loaded into a PackedScene")
		 ERR_CANT_CREATE : push_error("ERR_CANT_CREATE Coop Scene cannot be instantiated.")
	push_error("Error " + str(err))


func _on_UnlockBackyard_pressed():
	save_game.money -= BACKYARD_COST
	save_game.pen = MEDIUM
	save_game.save()
	ui()


func _on_UnlockSmallFarm_pressed():
	save_game.money -= SMALL_FARM_COST
	save_game.pen = LARGE
	save_game.save()
	ui()
