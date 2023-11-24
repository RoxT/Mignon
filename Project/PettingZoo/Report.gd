extends Panel

export(int) var children = 0
export(int) var adults = 0
const ADMISSION := 2

const CHILDREN := "Children: "
const ADULTS := "Adults: "
const ADMISSIONS := "Admissions: $"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func adult():
	adults += 1
	$AdultCount.text = ADULTS + str(adults)
	admissions()

func child():
	children += 1
	$ChildCount.text = CHILDREN + str(children)
	admissions()

func admissions():
	$Admissions.text = ADMISSIONS + str(collect_money())
	
func show_all(set_children:int, set_adults:int):
	children = set_children
	adults = set_adults
	$ChildCount.text = CHILDREN + str(children)
	$AdultCount.text = ADULTS + str(adults)
	admissions()
	
func collect_money()->int:
	return (children+adults) * ADMISSION
