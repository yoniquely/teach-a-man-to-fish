extends Node2D

var gamespeed = .5
var fishTime = 10
var teachTime = 20
var dayTime = 60

var day = 0
var fishTotal = 0
var fishOverallTotal = 0
var villagerFishOverallTotal = 0
var fishermanTotal = 0
var villagers = 3
var fishCaught = 0

var timeLeftInDay = 120 #2 minutes

var fishMult = 0
var teachingMult = 0

var fishMultUpgradeReq = 4
var teachMultUpgradeReq = 2

var villagerInc1 = 0
var villagerInc2 = 0

var villagerFishMult = 0
var villagerFishMultUpgradeReq = 4

var LineEditAllowed = true ## Once timers end allows players to edit the textbox again
@export var LineEditVarPath : NodePath
var LineEditVar
@export var ResponseVarPath : NodePath
var ResponseVar
@export var FishTotalVarPath : NodePath
var FishTotalVar
@export var VillagersTotalVarPath : NodePath
var VillagersTotalVar
@export var DayVarPath : NodePath
var DayVar
@export var FishermanTotalVarPath : NodePath
var FishermanTotalVar
@export var LevelUpTextPath : NodePath
var LevelUpTextVar
@export var DayScriptPath : NodePath
var DayScriptVar
@export var FishermanCatchPath : NodePath
var FishermanCatchVar
@export var ProgressBarPath : NodePath
var ProgressBarVar
@export var GameOverPath : NodePath
var GameOverVar
@export var DaySummaryPath : NodePath
var DaySummaryVar
@export var SummaryFishCaughtTotal_Path : NodePath
var SummaryFishCaughtTotal
@export var SummaryVillagersTotal_Path : NodePath
var SummaryVillagersTotal
@export var SummaryFishermanTotal_Path : NodePath
var SummaryFishermanTotal


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	LineEditVar = get_node(LineEditVarPath)
	LineEditVar.grab_focus()
	ResponseVar = get_node(ResponseVarPath)
	FishTotalVar = get_node(FishTotalVarPath)
	VillagersTotalVar = get_node(VillagersTotalVarPath)
	DayVar = get_node(DayVarPath)
	FishermanTotalVar = get_node(FishermanTotalVarPath)
	LevelUpTextVar = get_node(LevelUpTextPath)
	DayScriptVar = get_node(DayScriptPath)
	FishermanCatchVar = get_node(FishermanCatchPath)
	ProgressBarVar = get_node(ProgressBarPath)
	GameOverVar = get_node(GameOverPath)
	DaySummaryVar = get_node(DaySummaryPath)
	SummaryFishCaughtTotal = get_node(SummaryFishCaughtTotal_Path)
	SummaryVillagersTotal = get_node(SummaryVillagersTotal_Path)
	SummaryFishermanTotal = get_node(SummaryFishermanTotal_Path)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	ProgressBarVar.value = 60 - $dayTimer.time_left
	if Input.is_action_just_pressed("ui_accept"):
		if LineEditVar.text.to_lower() == "go fishin" and LineEditAllowed == true:
			##LineEditVar.visab
			#LineEditVar.editable = false ## This may be causing issues with focus and edit mode
			LineEditVar.set_placeholder('')
			LineEditVar.clear()
			LineEditVar.visible = false
			ResponseVar.visible = true
			ResponseVar.text = "fishin..."
			$loadTimer.start()
			$fishTimer.start(fishTime*gamespeed)
		elif LineEditVar.text.to_lower() == "teach a man to fish" and LineEditAllowed == true:
			if fishermanTotal < villagers:
				##LineEditVar.editable = false
				LineEditVar.clear()
				LineEditVar.visible = false
				ResponseVar.visible = true
				ResponseVar.text = "teachin..."
				$loadTimer.start()
				$teachTimer.start(teachTime*gamespeed)
			else:
				LineEditVar.clear()
				ResponseVar.visible = true
				ResponseVar.text = "there are no men left to teach"
	
	FishTotalVar.text = "fish caught today: %s" % fishTotal
	VillagersTotalVar.text = "villagers: %s" % villagers
	DayVar.text =  "day %s" % day
	FishermanTotalVar.text =  "fishermen: %s" % fishermanTotal
	DayScriptVar.text = "its day %s
	Time to go fishin
	you have %s hungry mouths to feed
	lucky you've got %s villagers who can help" % [day,villagers,fishermanTotal]
	
	levelCheck()

func levelCheck():
	if fishOverallTotal > fishMultUpgradeReq:
		fishMult += 1
		fishMultUpgradeReq += 2
		fishOverallTotal = 0
		LevelUpTextVar.text = "fish mastery up!"
		LevelUpTextVar.get_node("displayTimer2").start()
		
	if villagerFishOverallTotal > villagerFishMultUpgradeReq:
		villagerFishMult += 1
		villagerFishMultUpgradeReq += 2
		villagerFishOverallTotal = 0
		LevelUpTextVar.text = "fisherman's fish mastery up!"
		LevelUpTextVar.get_node("displayTimer2").start()

func catchFish():
	var fishChance : float = (fishMult*3 + 80)/100.0
	print(fishChance)
	if randf_range(0,1) < fishChance:
		return 1
	else:
		return 0


func ResetLineEdit():
	## LineEditVar.editable = true
	LineEditVar.clear()
	LineEditAllowed = true
	LineEditVar.visible = true
	await get_tree().process_frame
	LineEditVar.grab_focus() ## Shouldn't be needed


func dayReset():
	$dayTimer.stop()
	$loadTimer.stop()
	$fishTimer.stop()
	$teachTimer.stop()
	$villagerFishTimer.stop()
	ResponseVar.visible = false
	LineEditVar.set_placeholder('go fishin')
	ResetLineEdit()


func _on_timer_timeout() -> void:
	$loadTimer.stop()
	fishCaught = catchFish()
	if fishCaught == 1:
		ResponseVar.text = "you caught a fish!"
	else:
		ResponseVar.text = "the fish have eluded you"
	fishTotal += fishCaught
	fishOverallTotal += fishCaught
	ResetLineEdit()


func _on_teach_timer_timeout() -> void:
	$loadTimer.stop()
	fishermanTotal += 1
	villagers += 1
	ResponseVar.text = "you taught a man to fish"
	ResetLineEdit()


func _on_load_timer_timeout() -> void:
	ResponseVar.text += "."


func _on_day_timer_timeout() -> void:
	dayReset()
	SummaryFishCaughtTotal.text = str(fishTotal)
	SummaryVillagersTotal.text = str(villagers)
	SummaryFishermanTotal.text = str(fishermanTotal)
	get_tree().paused = true
	DaySummaryVar.visible = true


func _on_button_pressed() -> void:
	get_tree().paused = false
	if fishTotal >= villagers:
		day += 1
		villagers = villagers + villagerInc1 + villagerInc2
		villagerInc1 = villagerInc2
		villagerInc2 += 1
		DaySummaryVar.visible = false
		fishTotal = 0
		$villagerFishTimer.start(fishTime*gamespeed)
		$dayTimer.start(dayTime * gamespeed)
	else:
		GameOverVar.visible = true
		## TODO create a reset button and set it to be visable here


func _on_villager_fish_timer_timeout() -> void:
	if fishermanTotal > 0:
		for f in fishermanTotal:
			var fishChance : float = (villagerFishMult*3 + 80)/100.0
			#print(fishChance)
			if randf_range(0,1) < fishChance:
				fishTotal += 1
				FishermanCatchVar.visible = true
				FishermanCatchVar.get_node("displayTimer").start()


func _on_display_timer_timeout() -> void:
	FishermanCatchVar.visible = false


func _on_display_timer_2_timeout() -> void:
	LevelUpTextVar.visible = false
