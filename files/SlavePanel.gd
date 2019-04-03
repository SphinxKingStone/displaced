extends "res://files/Close Panel Button/ClosingPanel.gd"

var currenttask
var currentworker

func _ready():
	$TaskPanel/StopButton.connect("pressed", self, 'StopTask')
	globals.AddPanelOpenCloseAnimation($TaskPanel)
	input_handler.connect("WorkerAssigned", self, 'update')


func update(args):
	if self.visible == true:
		BuildSlaveList()


func BuildSlaveList():
	ClearScene()
	show()
	globals.ClearContainer($ScrollContainer/VBoxContainer)
	for i in state.workers.values():
		var newbutton = globals.DuplicateContainerTemplate($ScrollContainer/VBoxContainer)
		newbutton.get_node("Icon").texture = load(i.icon)
		newbutton.get_node("Name").text = i.name
		newbutton.get_node("Task").visible = i.task != null
		#newbutton.get_node("Line").connect("mouse_entered",self, 'SelectSlave', [i])
		newbutton.get_node("Button").connect("pressed",self, 'SelectSlave', [i.id])
		newbutton.get_node("Use").connect("pressed",self, 'SlaveFeed', [i])
		newbutton.get_node("Remove").connect("pressed",self, 'SlaveRemove', [i])
		newbutton.get_node("Energy").text = str(i.energy) + '/' + str(i.maxenergy)

func SlaveFeed(worker):
	currentworker = worker
	globals.ItemSelect(self, 'edible', 'SlaveFeedItem')

func SlaveFeedItem(item):
	pass

func SlaveRemove(worker):
	currentworker = worker
	input_handler.ShowConfirmPanel(self, 'SlaveRemoveConfirm', tr('SLAVEREMOVECONFIRM'))

func SlaveRemoveConfirm():
	if currentworker.task != null:
		globals.CurrentScene.stoptask(currentworker.task)
	state.workers.erase(currentworker.id)
	BuildSlaveList()

func ClearScene():
	currenttask = null
	$TaskPanel.hide()

func SelectSlave(worker):
	var text = tr("CURRENTTASK") + ': '
	currentworker = worker
	
	var temptask
	for i in state.tasks:
		if i.worker == currentworker:
			temptask = i
			break
	if temptask == null:
		$TaskPanel.hide()
		$TaskList.tasklist()
		$TaskList.selectedworker = worker
	else:
		$TaskList.hide()
		text += temptask.taskdata.name
		ShowTaskInformation(temptask)


func ShowTaskInformation(task):
	currenttask = task
	$TaskPanel.show()
	if task.instrument != null:
		input_handler.itemshadeimage($TaskPanel/ToolImage, state.items[task.instrument])
		state.items[task.instrument].tooltip($TaskPanel/ToolImage)
	else:
		$TaskPanel/ToolImage.hide()
	var text = task.taskdata.name
	$TaskPanel/EnergyIcon/EnergyCost.text = str(task.taskdata.energycost)
	$TaskPanel/TimeIcon/TimeCost.text = str(task.threshold)
	$TaskPanel/TaskDescript.bbcode_text = text
	$TaskPanel/Head.text = text
	$TaskPanel/TaskProgress.value = globals.calculatepercent(task.time,task.threshold)

func StopTask():
	input_handler.ShowConfirmPanel(self, 'StopTaskConfirm', tr("STOPTASKCONFIRM"))

func StopTaskConfirm():
	globals.CurrentScene.stoptask(currenttask)
	BuildSlaveList()

