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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$LineEdit.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$ProgressBar.value = 60 - $dayTimer.time_left
	if Input.is_action_just_pressed("ui_accept"):
		if $LineEdit.text.to_lower() == "go fishin" and LineEditAllowed == true:
			##$LineEdit.visab
			#$LineEdit.editable = false ## This may be causing issues with focus and edit mode
			$LineEdit.set_placeholder('')
			$LineEdit.clear()
			$LineEdit.visible = false
			$response.visible = true
			$response.text = "fishin..."
			$loadTimer.start()
			$fishTimer.start(fishTime*gamespeed)
		elif $LineEdit.text.to_lower() == "teach a man to fish" and LineEditAllowed == true:
			if fishermanTotal < villagers:
				##$LineEdit.editable = false
				$LineEdit.clear()
				$LineEdit.visible = false
				$response.visible = true
				$response.text = "teachin..."
				$loadTimer.start()
				$teachTimer.start(teachTime*gamespeed)
			else:
				$LineEdit.clear()
				$response.visible = true
				$response.text = "there are no men left to teach"
	
	$fishTotal.text = "fish caught today: %s" % fishTotal
	$villagersTotal.text = "villagers: %s" % villagers
	$day.text =  "day %s" % day
	$fishermenTotal.text =  "fishermen: %s" % fishermanTotal
	$dayScript.text = "its day %s
	Time to go fishin
	you have %s hungry mouths to feed
	lucky you've got %s villagers who can help" % [day,villagers,fishermanTotal]
	
	levelCheck()

func levelCheck():
	if fishOverallTotal > fishMultUpgradeReq:
		fishMult += 1
		fishMultUpgradeReq += 2
		fishOverallTotal = 0
		$levelupText.text = "fish mastery up!"
		$levelupText/displayTimer2.start()
		
	if villagerFishOverallTotal > villagerFishMultUpgradeReq:
		villagerFishMult += 1
		villagerFishMultUpgradeReq += 2
		villagerFishOverallTotal = 0
		$levelupText.text = "fisherman's fish mastery up!"
		$levelupText/displayTimer2.start()

func catchFish():
	var fishChance : float = (fishMult*3 + 80)/100.0
	print(fishChance)
	if randf_range(0,1) < fishChance:
		return 1
	else:
		return 0


func ResetLineEdit():
	## $LineEdit.editable = true
	$LineEdit.clear()
	LineEditAllowed = true
	$LineEdit.visible = true
	await get_tree().process_frame
	$LineEdit.grab_focus() ## Shouldn't be needed


func dayReset():
	$dayTimer.stop()
	$loadTimer.stop()
	$fishTimer.stop()
	$teachTimer.stop()
	$villagerFishTimer.stop()
	$response.visible = false
	$LineEdit.set_placeholder('go fishin')
	ResetLineEdit()


func _on_timer_timeout() -> void:
	$loadTimer.stop()
	fishCaught = catchFish()
	if fishCaught == 1:
		$response.text = "you caught a fish!"
	else:
		$response.text = "the fish have eluded you"
	fishTotal += fishCaught
	fishOverallTotal += fishCaught
	ResetLineEdit()


func _on_teach_timer_timeout() -> void:
	$loadTimer.stop()
	fishermanTotal += 1
	villagers += 1
	$response.text = "you taught a man to fish"
	ResetLineEdit()


func _on_load_timer_timeout() -> void:
	$response.text += "."


func _on_day_timer_timeout() -> void:
	dayReset()
	$daySummary/daySummaryTitle.text = "DAY %s COMPLETE" % day
	$daySummary/fishCaught_total.text = str(fishTotal)
	$daySummary/villagers_total.text = str(villagers)
	$daySummary/fishermen_total.text = str(fishermanTotal)
	get_tree().paused = true
	$daySummary.visible = true


func _on_button_pressed() -> void:
	get_tree().paused = false
	if fishTotal >= villagers:
		day += 1
		villagers = villagers + villagerInc1 + villagerInc2
		villagerInc1 = villagerInc2
		villagerInc2 += 1
		$daySummary.visible = false
		fishTotal = 0
		$villagerFishTimer.start(fishTime*gamespeed)
		$dayTimer.start(dayTime * gamespeed)
	else:
		$gameover.visible = true


func _on_villager_fish_timer_timeout() -> void:
	if fishermanTotal > 0:
		for f in fishermanTotal:
			var fishChance : float = (villagerFishMult*3 + 80)/100.0
			#print(fishChance)
			if randf_range(0,1) < fishChance:
				fishTotal += 1
				$fishermanCatch.visible = true
				$fishermanCatch/displayTimer.start()


func _on_display_timer_timeout() -> void:
	$fishermanCatch.visible = false


func _on_display_timer_2_timeout() -> void:
	$levelupText.visible = false
