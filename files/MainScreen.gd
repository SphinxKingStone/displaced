extends Node

var blacksmith
var debug = true

var gamespeed = 1
var gamepaused = false
var previouspeed
var daycolorchange = false
var tasks = [] #Task Data Dict var data = {function = selectedtask.triggerfunction, taskdata = selectedtask, time = 0, threshold = selectedtask.basetimer, worker = selectedworker, instrument = selectedtool}
onready var timebuttons = [$"TimeNode/0speed", $"TimeNode/1speed", $"TimeNode/2speed"]
onready var BS = $BlackScreen;


func _ready():
	#self.visible = false
	#$BlackScreen.visible = true
	#$BlackScreen.modulate.a = 1
	input_handler.SystemMessageNode = $SystemMessageLabel
	globals.CurrentScene = self
	tasks = state.tasks
#	var x = 3
#	while x > 1:
#		var y = combatantdata.combatant.new()
#		y.createfromclass('warrior')
#		x -= 1
#		state.heroes[y.id] = y
	
	var character = globals.combatant.new()
	character.createfromname('Arron')
	state.heroes[character.id] = character
	
	character = globals.combatant.new()
	character.createfromname('Rose')
	state.heroes[character.id] = character
	
	character = globals.combatant.new()
	character.createfromname('Ember')
	state.heroes[character.id] = character
	
	input_handler.SetMusic("towntheme")
	
	var speedvalues = [0,1,10]
	var tooltips = [tr('PAUSEBUTTONTOOLTIP'),tr('NORMALBUTTONTOOLTIP'),tr('FASTBUTTONTOOLTIP')]
	var counter = 0
	for i in timebuttons:
		i.hint_tooltip = tooltips[counter]
		i.connect("pressed",self,'changespeed',[i])
		i.set_meta('value', speedvalues[counter])
		counter += 1
	$ControlPanel/Inventory.connect('pressed',self,'openinventory')
	$ControlPanel/Slavelist.connect('pressed',self,'SlavePanelShow')
	$ControlPanel/Options.connect("pressed",self, 'openmenu')
	$ControlPanel/Herolist.connect('pressed',self, 'openherolist')
	$TownHallNode.connect("pressed",self,'opentownhall')
	$BlacksmithNode.connect("pressed",self,'openblacksmith')
	$WorkBuildNode.connect("pressed",self,'OpenSlaveMarket')
	$TownHallNode.connect("pressed",self,'OpenTownhall')
	#$HeroBuildNode.connect("pressed",self,'openheroguild')
	$Lumber.connect("pressed", self, '_on_Lumber_pressed')
	$Gate.connect("pressed",self,'explorescreen')
	
	if debug == true:
		state.OldEvents['Market'] = 0
		
		var worker = globals.worker.new()
		worker.create(TownData.workersdict.goblin)
		worker = globals.worker.new()
		worker.create(TownData.workersdict.goblin)
		worker = globals.worker.new()
		worker.create(TownData.workersdict.goblin)
		#globals.AddItemToInventory(globals.crea
		globals.AddItemToInventory(globals.CreateGearItem('axe', {ToolHandle = 'wood', Blade = 'wood'}))
		#state.items[0].durability = floor(rand_range(1,5))
		globals.AddItemToInventory(globals.CreateGearItem('axe', {ToolHandle = 'wood', Blade = 'elvenwood'}))
		globals.AddItemToInventory(globals.CreateGearItem('basicchest', {ArmorBase = 'goblinmetal', ArmorTrim = 'wood'}))
		globals.AddItemToInventory(globals.CreateGearItem('sword', {ToolHandle = 'elvenwood', Blade = 'goblinmetal'}))
		globals.AddItemToInventory(globals.CreateUsableItem('meatsteak', 2))
		#state.items[1].durability = floor(rand_range(1,5))
#		globals.AddItemToInventory(globals.CreateGearItem('heavychest', {ArmorPlate = 'stone', ArmorTrim = 'wood'}))
#		globals.AddItemToInventory(globals.CreateGearItem('heavychest', {ArmorPlate = 'stone', ArmorTrim = 'wood'}))
#		globals.AddItemToInventory(globals.CreateGearItem('heavychest', {ArmorPlate = 'stone', ArmorTrim = 'wood'}))
#		globals.AddItemToInventory(globals.CreateGearItem('heavychest', {ArmorPlate = 'stone', ArmorTrim = 'wood'}))
#		globals.AddItemToInventory(globals.CreateGearItem('heavychest', {ArmorPlate = 'stone', ArmorTrim = 'wood'}))
	globals.call_deferred('EventCheck');
	$testbutton.connect("pressed", self, "testfunction")
	changespeed($"TimeNode/0speed", false)
	#buildscreen()

func buildscreen():
	$Gate.visible = state.townupgrades.has('bridge')

func testfunction():
	input_handler.ActivateTutorial('tutorial1')

func _process(delta):
	if self.visible == false:
		return
	$TimeNode/HidePanel.visible = gamepaused
	settime()
	
	#buildscreen()
	
	if gamepaused == false:
		for i in get_tree().get_nodes_in_group("pauseprocess"):
			if i.visible == true:
				previouspeed = gamespeed
				changespeed(timebuttons[0], false)
				gamepaused = true
	else:
		var allnodeshidden = true
		for i in get_tree().get_nodes_in_group("pauseprocess"):
			if i.visible == true:
				allnodeshidden = false
				break
		if allnodeshidden == true:
			restoreoldspeed(previouspeed)
			gamepaused = false
	
	$ControlPanel/Gold.text = str(state.money)
	$ControlPanel/Food.text = str(state.food)
	
	$BlackScreen.visible = $BlackScreen.modulate.a > 0.0
	if gamespeed != 0:
		state.daytime += delta * gamespeed
		
		movesky()
		for i in tasks:
			i.time += delta*gamespeed
			updatecounter(i)
			
			if i.time >= i.threshold:
				i.time -= i.threshold
				taskperiod(i)
				#call(i.function, i)
		
		if daycolorchange == false:
			
			if floor(state.daytime) == 0.0:
				EnvironmentColor('morning')
			elif floor(state.daytime) == floor(variables.TimePerDay/4):
				EnvironmentColor('day')
			elif floor(state.daytime) == floor(variables.TimePerDay/4*2):
				EnvironmentColor('evening')
			elif floor(state.daytime) == floor(variables.TimePerDay/4*3):
				EnvironmentColor('night')


func movesky():
	$Sky.region_rect.position.x += gamespeed
	if $Sky.region_rect.position.x > 3500:
		$Sky.region_rect.position.x = -500


func EnvironmentColor(time):
	
	var morning = Color8(189,182,128)
	var day = Color8(255,255,255)
	var night = Color8(73,73,91)
	var evening = Color8(120, 96, 96)
	var tween = input_handler.GetTweenNode(self)
	var array = [$Background, $Sky, $WorkBuildNode, $TavernNode, $BlacksmithNode, $Gate, $TownHallNode]
	
	var currentcolor
	var nextcolor
	
	var changetime = 2
	
	daycolorchange = true
	
	match time:
		'morning':
			currentcolor = night
			nextcolor = morning
		'day':
			currentcolor = morning
			nextcolor = day
		'evening':
			currentcolor = day
			nextcolor = evening
		'night':
			currentcolor = evening
			nextcolor = night
	
	for i in array:
		tween.interpolate_property(i, 'modulate', currentcolor, nextcolor, changetime, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
	tween.interpolate_callback(self, changetime, 'finishcolorchange')

func finishcolorchange():
	daycolorchange = false

func buildcounter(task):
	var newnode = globals.DuplicateContainerTemplate($TaskCounter)
	newnode.get_node('Icon').texture = task.worker.icon
	newnode.get_node("Progress").value = globals.calculatepercent(task.time, task.threshold)
	newnode.connect("pressed", self, "OpenWorkerTask", [task])
	newnode.set_meta('task', task)
	task.counter = newnode

func OpenWorkerTask(task):
	$SlavePanel.BuildSlaveList()
	$SlavePanel.SelectSlave(task.worker)

func updatecounter(task):
	if task.counter == null:
		return
	task.counter.get_node("Progress").value = globals.calculatepercent(task.time, task.threshold)

func deletecounter(task):
	task.counter.queue_free()



func openmenu():
	if !$MenuPanel.visible:
		$MenuPanel.show()
	else:
		$MenuPanel.hide()

func openherolist():
	if $HeroList.visible == false:
		$HeroList.open()
	else:
		$HeroList.hide()


func OpenTownhall():
	$TownHall.open()

func OpenSlaveMarket():
	$SlaveMarket.open()

func changespeed(button, playsound = true):
	var oldvalue = gamespeed
	var newvalue = button.get_meta('value')
	for i in timebuttons:
		i.pressed = i == button
	gamespeed = newvalue
	var soundarray = ['time_stop', 'time_start', 'time_up']
	if oldvalue != newvalue && playsound:
		input_handler.PlaySound(soundarray[int(button.name[0])])
	input_handler.emit_signal("SpeedChanged", gamespeed)

func restoreoldspeed(value):
	for i in timebuttons:
		if i.get_meta("value") == value:
			changespeed(i, false)

func settime():
	if state.daytime > variables.TimePerDay:
		state.date += 1
		state.daytime = 0
		globals.EventCheck();
	$TimeNode/Date.text = tr("DAY") + ": " + str(state.date)
	$TimeNode/TimeWheel.rect_rotation = (state.daytime / variables.TimePerDay * 360) - 90

func FadeToBlackAnimation(time = 1):
	input_handler.UnfadeAnimation($BlackScreen, time)
	input_handler.emit_signal("ScreenChanged")
	input_handler.FadeAnimation($BlackScreen, time, time)


func openinventory(hero = null):
	$Inventory.open('hero', hero)

func openinventorytrade():
	$Inventory.open("shop")

func openblacksmith():
	$blacksmith.show()

func openherohiretab():
	$herohire.show()

func opentownhall():
	pass


func BuildingOptions(building = {}):
	var node = $BuildingOptions
	var targetnode = building.node
	globals.ClearContainer($BuildingOptions/VBoxContainer)
	node.popup()
	var pos = targetnode.get_global_rect()
	pos = Vector2(pos.position.x, pos.end.y + 10)
	node.set_global_position(pos)

func assignworker(data):
	data.worker.task = data
	buildcounter(data)
	if data.instrument != null:
		data.instrument.task = data
	tasks.append(data)

func stoptask(data):
	data.worker.task = null
	if data.instrument != null:
		data.instrument.task = null
	deletecounter(data)
	tasks.erase(data)

func taskperiod(data):
	var taskdata = data.taskdata
	var worker = data.worker
	for i in taskdata.workerproducts[worker.type]:
		#Calculate results and reward player
		
		#Check if requirements are met
		if randf()*100 >= i.chance:
			continue
		
		var taskresult = i.amount
		
		if randf()*100 <= i.critchance:
			taskresult = i.critamount
			#print('crit triggered')
		
		
		
		
		#Check if need to access multiple subcategory  
		if i.code.find('.') != -1:
			var array = i.code.split('.')
			state[array[0]][array[1]] += taskresult
			while taskresult > 0:
				flyingitemicon(data.counter, array[1])
				taskresult -= 1
		else:
			state[i] += taskresult
		
		#targetvalue 
		data.worker.energy -= taskdata.energycost
		if data.instrument != null:
			data.instrument.durability -= taskdata.tasktool.durabilityfactor
			if data.instrument.durability <= 0:
				stoptask(data)
				#globals.logupdate(data.instrument.name + tr("TOOLBROKEN"))
	
	if data.worker.energy < taskdata.energycost:
		if data.worker.autoconsume == true:
			var state = data.worker.restoreenergy()
			if state == false:
				tasks.erase(data)
				
	elif data.instrument != null && data.instrument.durability <= 0 && taskdata.tasktool.required != false:
		tasks.erase(data)

var itemicon = preload("res://src/ItemIcon.tscn")

func flyingitemicon(taskbar, item):
	var x = itemicon.instance()
	add_child(x)
	x.texture = Items.Materials[item].icon
	x.rect_global_position = taskbar.rect_global_position
	input_handler.PlaySound("itemget")
	input_handler.ResourceGetAnimation(x, taskbar.rect_global_position, $ControlPanel/Inventory.rect_global_position)
	yield(get_tree().create_timer(0.7), 'timeout')
	x.queue_free()




func _on_Lumber_pressed():
	$SelectWorker.show()
	$SelectWorker.OpenSelectTab(TownData.tasksdict.woodcutting)


func SlavePanelShow():
	$SlavePanel.BuildSlaveList()


func _on_Herolist_pressed():
	globals.ClearContainer($HeroList/VBoxContainer)
	for i in state.heroes.values():
		var newbutton = globals.DuplicateContainerTemplate($HeroList/VBoxContainer)
		newbutton.text = i.name
		newbutton.connect("pressed",self,'OpenHeroTab', [i])

func OpenHeroTab(hero):
	$HeroPanel.open(hero)

func openheroguild():
	$HeroGuild.open()

func explorescreen():
	$ExploreScreen.show()
	globals.call_deferred('EventCheck');