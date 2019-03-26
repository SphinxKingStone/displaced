
extends Node

var currentenemies
var area
var turns = 0
var animationskip = false

var encountercode

var combatlog = ''

var instantanimation = null

var shotanimationarray = [] #supposedanimation = {code = 'code', runnext = false, delayuntilnext = 0}

var CombatAnimations = preload("res://src/CombatAnimations.gd").new()

var debug = false

var allowaction = false
var highlightargets = false
var allowedtargets = {}
var turnorder = []
var fightover = false

var playergroup = {}
var enemygroup = {}
var currentactor

var summons = [];

var activeaction
var activeitem
var activecharacter

var cursors = {
	default = load("res://assets/images/gui/universal/cursordefault.png"),
	attack = load("res://assets/images/gui/universal/cursorfight.png"),
	support = load("res://assets/images/gui/universal/cursorsupport.png"),
	
}



var enemypaneltextures = {
	normal = null,
	target = null,
}
var playerpaneltextures = {
	normal = null,
	target = null,
	disabled = null,
}

var battlefield = {}
onready var battlefieldpositions = {1 : $Panel/PlayerGroup/Front/left, 2 : $Panel/PlayerGroup/Front/mid, 3 : $Panel/PlayerGroup/Front/right,
4 : $Panel/PlayerGroup/Back/left, 5 : $Panel/PlayerGroup/Back/mid, 6 : $Panel/PlayerGroup/Back/right,
7 : $Panel2/EnemyGroup/Front/left, 8 : $Panel2/EnemyGroup/Front/mid, 9 : $Panel2/EnemyGroup/Front/right,
10: $Panel2/EnemyGroup/Back/left, 11 : $Panel2/EnemyGroup/Back/mid, 12 : $Panel2/EnemyGroup/Back/right}

var testenemygroup = {1 : 'elvenrat', 5 : 'elvenrat', 6 : 'elvenrat'}
var testplayergroup = {4 : 'elvenrat', 5 : 'elvenrat', 6 : 'elvenrat'}

func _ready():
	for i in range(1,13):
		battlefield[i] = null
	add_child(CombatAnimations)
	$ItemPanel/debugvictory.connect("pressed",self, 'cheatvictory')
	$Rewards/CloseButton.connect("pressed",self,'FinishCombat')


func cheatvictory():
	for i in enemygroup.values():
		i.hp = 0
	#checkwinlose()

func _process(delta):
	pass


func start_combat(newenemygroup, background):
	$Background.texture = images.backgrounds[background]
	$Combatlog/RichTextLabel.clear()
	enemygroup.clear()
	playergroup.clear()
	turnorder.clear()
	input_handler.SetMusic("combattheme")
	fightover = false
	$Rewards.visible = false
	allowaction = false
	enemygroup = newenemygroup
	playergroup = state.combatparty
	buildenemygroup(enemygroup)
	buildplayergroup(playergroup)
	#victory()
	#start combat triggers
	for p in playergroup.values():
		p.basic_check(variables.TR_COMBAT_S)
	for p in enemygroup.values():
		p.basic_check(variables.TR_COMBAT_S)
	select_actor()

func FinishCombat():
	for i in battlefield:
		if battlefield[i] != null:
			battlefield[i].displaynode.queue_free()
			battlefield[i].displaynode = null
			battlefield[i] = null
	hide()
	input_handler.emit_signal("CombatEnded", encountercode)
	input_handler.SetMusic("towntheme")
	get_parent().levelupscheck()
	globals.call_deferred('EventCheck')


func select_actor():
	ClearSkillTargets()
	ClearSkillPanel()
	ClearItemPanel()
	checkdeaths()
	if checkwinlose() == true:
		return
	if turnorder.empty():
		newturn()
		calculateorder()
	currentactor = turnorder[0].pos
	turnorder.remove(0)
	#currentactor.update_timers()
	if currentactor < 7:
		player_turn(currentactor)
	else:
		enemy_turn(currentactor)

func newturn():
	for i in playergroup.values() + enemygroup.values():
#		for k in i.buffs.values():
#			k.duration -= 1
#			if k.duration < 0:
#				i.remove_buff(k.code)
		i.update_temp_effects()
		i.basic_check(variables.TR_TURN_S)

#func debuff_all():
#	for i in playergroup.values() + enemygroup.values():
#		for k in i.buffs:
#			i.remove_buff(k.code)

func checkdeaths():
	for i in battlefield:
		if battlefield[i] != null && battlefield[i].defeated != true && battlefield[i].hp <= 0:
			battlefield[i].death()
			turnorder.erase(battlefield[i])
			if summons.has(i):
				battlefield[i].displaynode.queue_free()
				battlefield[i].displaynode = null
				battlefield[i] = null
				summons.erase(i);
				#not yet implemented clearing of related panel
				#make_fighter_panel(battlefield[i], i)

func checkwinlose():
	var playergroupcounter = 0
	var enemygroupcounter = 0
	for i in battlefield:
		if battlefield[i] == null:
			continue
		if battlefield[i].defeated == true:
			continue
		if i in range(1,7):
			playergroupcounter += 1
		else:
			enemygroupcounter += 1
	if playergroupcounter <= 0:
		defeat()
		return true
	elif enemygroupcounter <= 0:
		victory()
		return true

var rewardsdict

func victory():
	yield(get_tree().create_timer(0.5), 'timeout')
	fightover = true
	$Rewards/CloseButton.disabled = true
	input_handler.StopMusic()
	#fastfinish all temp effects
	for p in playergroup.values():
		p.remove_all_temp_effects();
	#on combat ends triggers
	for p in playergroup.values():
		p.basic_check(variables.TR_COMBAT_F)
	
	var tween = input_handler.GetTweenNode($Rewards/victorylabel)
	tween.interpolate_property($Rewards/victorylabel,'rect_scale', Vector2(1.5,1.5), Vector2(1,1), 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	
	input_handler.PlaySound("victory")
	
	rewardsdict = {materials = {}, items = [], xp = 0}
	for i in enemygroup.values():
		if i == null:
			continue
		rewardsdict.xp += i.xpreward
		var loot = {}
		if Enemydata.loottables[i.loottable].has('materials'):
			for j in Enemydata.loottables[i.loottable].materials:
				if randf()*100 <= j.chance:
					loot[j.code] = round(rand_range(j.min, j.max))
			globals.AddOrIncrementDict(rewardsdict.materials, loot)
		if Enemydata.loottables[i.loottable].has('usables'):
			for j in Enemydata.loottables[i.loottable].usables:
				if randf()*100 <= j.chance:
					var newitem = globals.CreateUsableItem(j.code, round(rand_range(j.min, j.max)))
					rewardsdict.items.append(newitem)
	
	globals.ClearContainer($Rewards/HBoxContainer/first)
	globals.ClearContainer($Rewards/HBoxContainer/second)
	globals.ClearContainer($Rewards/ScrollContainer/HBoxContainer)
	for i in playergroup.values():
		var newbutton = globals.DuplicateContainerTemplate($Rewards/HBoxContainer/first)
		if $Rewards/HBoxContainer/first.get_children().size() >= 5:
			$Rewards/HBoxContainer/first.remove_child(newbutton)
			$Rewards/HBoxContainer/second.add_child(newbutton)
		newbutton.get_node('icon').texture = i.portrait_circle()
		newbutton.get_node("xpbar").value = i.baseexp
		var level = i.level
		i.baseexp += rewardsdict.xp*i.xpmod
		var subtween = input_handler.GetTweenNode(newbutton)
		if i.level > level:
			subtween.interpolate_property(newbutton.get_node("xpbar"), 'value', newbutton.get_node("xpbar").value, 100, 0.8, Tween.TRANS_CIRC, Tween.EASE_OUT, 1)
			subtween.interpolate_property(newbutton.get_node("xpbar"), 'modulate', newbutton.get_node("xpbar").modulate, Color("fffb00"), 0.2, Tween.TRANS_CIRC, Tween.EASE_OUT, 1)
			subtween.interpolate_callback(input_handler, 1, 'DelayedText', newbutton.get_node("xpbar/Label"), tr("LEVELUP")+ ': ' + str(i.level) + "!")
			subtween.interpolate_callback(input_handler, 1, 'PlaySound', "levelup")
		else:
			subtween.interpolate_property(newbutton.get_node("xpbar"), 'value', newbutton.get_node("xpbar").value, i.baseexp, 0.8, Tween.TRANS_CIRC, Tween.EASE_OUT, 1)
			subtween.interpolate_callback(input_handler, 2, 'DelayedText', newbutton.get_node("xpbar/Label"), '+' + str(rewardsdict.xp))
		subtween.start()
	$Rewards.visible = true
	$Rewards.set_meta("result", 'victory')
	for i in rewardsdict.materials:
		var item = Items.Materials[i]
		var newbutton = globals.DuplicateContainerTemplate($Rewards/ScrollContainer/HBoxContainer)
		newbutton.hide()
		newbutton.texture = item.icon
		newbutton.get_node("Label").text = str(rewardsdict.materials[i])
		state.materials[i] += rewardsdict.materials[i]
		globals.connectmaterialtooltip(newbutton, item)
	for i in rewardsdict.items:
		var newnode = globals.DuplicateContainerTemplate($Rewards/ScrollContainer/HBoxContainer)
		newnode.hide()
		newnode.texture = load(i.icon)
		globals.AddItemToInventory(i)
		globals.connectitemtooltip(newnode, state.items[globals.get_item_id_by_code(i.itembase)])
		if i.amount == null:
			newnode.get_node("Label").visible = false
		else:
			newnode.get_node("Label").text = str(i.amount)
	
	yield(get_tree().create_timer(1.7), 'timeout')
	
	for i in $Rewards/ScrollContainer/HBoxContainer.get_children():
		if i.name == 'Button':
			continue
		tween = input_handler.GetTweenNode(i)
		yield(get_tree().create_timer(1), 'timeout')
		i.show()
		input_handler.PlaySound("itemget")
		tween.interpolate_property(i,'rect_scale', Vector2(1.5,1.5), Vector2(1,1), 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
	
	#yield(get_tree().create_timer(1), 'timeout')
	$Rewards/CloseButton.disabled = false
	
	


func defeat():
	$Rewards.visible = true
	$Rewards.set_meta("result", 'defeat')
	for i in battlefield:
		if battlefield[i] != null:
			battlefield[i] = null

func player_turn(pos):
	var selected_character = playergroup[pos]
	selected_character.update_timers()
	if !selected_character.can_act():
		call_deferred('select_actor')
		return
	allowaction = true
	activecharacter = selected_character
	RebuildSkillPanel()
	RebuildItemPanel()
	SelectSkill(selected_character.selectedskill)

#rangetypes melee, any, backmelee

func UpdateSkillTargets():
	var skill = globals.skills[activeaction]
	var fighter = activecharacter
	var targetgroups = skill.allowedtargets
	var targetpattern = skill.targetpattern
	var rangetype = skill.userange
	
	ClearSkillTargets()
	
	for i in $SkillPanel/ScrollContainer/GridContainer.get_children() + $ItemPanel/ScrollContainer/GridContainer.get_children():
		if i.has_meta('skill'):
			i.pressed = i.get_meta('skill') == skill.code
	
	
	if rangetype == 'weapon':
		if activecharacter.gear.rhand == null:
			rangetype = 'melee'
		else:
			var weapon = state.items[activecharacter.gear.rhand]
			rangetype = weapon.weaponrange
	
	
	highlightargets = true
	
	allowedtargets.clear()
	allowedtargets = {ally = [], enemy = []}
	
	
	if targetgroups.has('enemy'):
		for i in enemygroup:
			if enemygroup[i].defeated == true:
				continue
			if rangetype == 'any':
				allowedtargets.enemy.append(i)
			elif rangetype == 'melee':
				if CheckMeleeRange('enemy'):
					allowedtargets.enemy.append(i)
				else:
					if i in [7,8,9]:
						allowedtargets.enemy.append(i)
	if targetgroups.has('ally'):
		for i in playergroup:
			if playergroup[i].defeated == true || playergroup[i] == fighter:
				continue
			allowedtargets.ally.append(i)
	if targetgroups.has('self'):
		allowedtargets.ally.append(fighter.position)
	Highlight(currentactor,'selected')
	for i in allowedtargets.enemy:
		Highlight(i, 'target')
	for i in allowedtargets.ally:
		Highlight(i, 'targetsupport')

func ClearSkillTargets():
	for i in battlefield:
		if battlefield[i] != null && battlefield[i].displaynode != null:
			StopHighlight(i)
	

func CheckMeleeRange(group): #Check if enemy front row is still in place
	var rval = false
	var counter = 0

	match group:
		'enemy':
			for i in range(7,10):
				if battlefield[i] == null || battlefield[i].defeated == true:
					counter += 1
		'player':
			for i in range(1,4):
				if battlefield[i] == null || battlefield[i].defeated == true:
					counter += 1
	if counter == 3:
		rval = true
	return rval

func FindFighterRow(fighter):
	var pos = fighter.position
	if pos in range(4,7) || pos in range(10,13):
		pos = 'backrow'
	else:
		pos = 'frontrow'
	return pos



func enemy_turn(pos):
	var fighter = enemygroup[pos]
	fighter.update_timers()
	if !fighter.can_act():
		call_deferred('select_actor')
		return
	
	var castskill = []
	var target = []
	
	#Selecting active skill
	
	Highlight(pos, 'enemy')
	
	for i in fighter.skills:
		var skill = globals.skills[i]
		if fighter.cooldowns.has(skill.code):
			continue
		if skill.aipatterns.has('attack'):
			castskill.append([skill, skill.aipriority])
	
	castskill = input_handler.weightedrandom(castskill)
	
	#Figuring Casting Skill range
	var skillrange = castskill.userange
	if skillrange == 'weapon':
		if fighter.gear.rhand == null:
			skillrange = 'melee'
		else:
			var weapon = state.items[fighter.gear.rhand]
			skillrange = weapon.weaponrange
	
	#Making possible targets array
	if castskill.allowedtargets.has('enemy'):
		for i in playergroup:
			if playergroup[i].defeated == true:
				continue
			if skillrange == 'melee' && !CheckMeleeRange('player') && i in [4,5,6]:
				continue
			
			
			target.append([playergroup[i], 1])
	elif castskill.allowedtargets.has('ally'):
		for i in enemygroup:
			target.append([enemygroup[i], 1])
	elif castskill.allowedtargets.has('self'):
		target.append([fighter, 1]);
	
	target = input_handler.weightedrandom(target)
	
	if target == null:
		print(fighter.name, ' no target found')
		return
	
	use_skill(castskill.code, fighter, target)

func calculateorder():
	turnorder.clear()
	for i in playergroup:
		if playergroup[i].defeated == true:
			continue
		turnorder.append({speed = playergroup[i].speed + randf() * 5, pos = i})
	for i in enemygroup:
		if enemygroup[i].defeated == true:
			continue
		turnorder.append({speed = enemygroup[i].speed + randf() * 5, pos = i})
	
	turnorder.sort_custom(self, 'speedsort')

func speedsort(first, second):
	if first.speed > second.speed:
		return true
	else:
		return false

func make_fighter_panel(fighter, spot):
	#need to implement clearing panel if fighter is null for the sake of removing summons
	#or simply implement func clear_fighter_panel(pos)
	var container = battlefieldpositions[spot]
	var panel = $Panel/PlayerGroup/Back/left/Template.duplicate()
	panel.material = $Panel/PlayerGroup/Back/left/Template.material.duplicate()
	fighter.displaynode = panel
	panel.name = 'Character'
	panel.set_script(load("res://files/FighterNode.gd"))
	panel.position = spot
	fighter.position = spot
	panel.fighter = fighter
	panel.connect("signal_RMB", self, "ShowFighterStats")
	panel.connect("signal_RMB_release", self, 'HideFighterStats')
	panel.connect("signal_LMB", self, 'FighterPress')
	panel.connect("mouse_entered", self, 'FighterMouseOver', [fighter])
	panel.connect("mouse_exited", self, 'FighterMouseOverFinish', [fighter])
	if variables.CombatAllyHpAlwaysVisible && fighter.combatgroup == 'ally':
		panel.get_node("hplabel").show()
		panel.get_node("mplabel").show()
	panel.set_meta('character',fighter)
	panel.get_node("Icon").texture = fighter.combat_portrait()
	panel.update_hp()
	panel.get_node("Mana").value = globals.calculatepercent(fighter.mana, fighter.manamax)
	if fighter.manamax == 0:
		panel.get_node("Mana").value = 0
	panel.get_node("Label").text = fighter.name
	container.add_child(panel)
	panel.rect_position = Vector2(0,0)
	#setuping target glowing
	var g_color;
	if spot < 7:
		g_color = Color(0.0, 1.0, 0.0, 0.0);
	else:
		g_color = Color(1.0, 0.0, 0.0, 0.0);
	panel.material.set_shader_param('modulate', g_color);
	
	panel.visible = true

var fighterhighlighted = false

func FighterShowStats(fighter):
	var panel = fighter.displaynode
	panel.get_node("hplabel").show()
	panel.get_node("mplabel").show()

func FighterMouseOver(fighter):
	FighterShowStats(fighter)
	if allowaction == true && (allowedtargets.enemy.has(fighter.position) || allowedtargets.ally.has(fighter.position)):
		if fighter.combatgroup == 'enemy':
			Input.set_custom_mouse_cursor(cursors.attack)
		else:
			Input.set_custom_mouse_cursor(cursors.support)
		var cur_targets = [];
		cur_targets = CalculateTargets(Skillsdata.skilllist[activeaction], activecharacter, fighter); 
		for c in cur_targets:
			Target_Glow(c.position);


func FighterMouseOverFinish(fighter):
	var panel = fighter.displaynode
	fighterhighlighted = false
	if variables.CombatAllyHpAlwaysVisible == false || fighter.combatgroup == 'enemy':
		panel.get_node("hplabel").hide()
		panel.get_node("mplabel").hide()
	Input.set_custom_mouse_cursor(cursors.default)
	Stop_Target_Glow();

func ShowFighterStats(fighter):
	if fightover == true:
		return
	var text = ''
	if fighter.combatgroup == 'ally':
		$StatsPanel/hp.text = 'Health: ' + str(fighter.hp) + '/' + str(fighter.hpmax())
		if fighter.manamax > 0:
			$StatsPanel/mana.text = "Mana: " + str(fighter.mana) + '/' + str(fighter.manamax)
		else:
			$StatsPanel/mana.text = ''
	else:
		$StatsPanel/hp.text = 'Health: ' + str(globals.calculatepercent(fighter.hp, fighter.hpmax())) + "%"
		if fighter.manamax > 0:
			$StatsPanel/mana.text = "Mana: " + str(globals.calculatepercent(fighter.mana, fighter.manamax)) + "%"
		else:
			$StatsPanel/mana.text = ''
	$StatsPanel/damage.text = "Damage: " + str(fighter.damage) 
	$StatsPanel/crit.text = tr("CRITICAL") + ": " + str(fighter.critchance) + "%/" + str(fighter.critmod*100) + '%' 
	$StatsPanel/hitrate.text = "Hit Rate: " + str(fighter.hitrate)
	$StatsPanel/armorpen.text = "Armor Penetration: " + str(fighter.armorpenetration)
	
	$StatsPanel/armor.text = "Armor: " + str(fighter.armor) 
	$StatsPanel/mdef.text = "M. Armor: " + str(fighter.mdef)
	$StatsPanel/evasion.text =  "Evasion: " + str(fighter.evasion) 
	$StatsPanel/speed.text = "Speed: " + str(fighter.speed)
	for i in ['fire','water','earth','air']:
		get_node("StatsPanel/resist"+i).text = "Resist " + i.capitalize() + ": " + str(fighter['resist'+i]) + " "
	$StatsPanel.show()
	$StatsPanel/name.text = tr(fighter.name)
	$StatsPanel/descript.text = fighter.flavor
	$StatsPanel/TextureRect.texture = fighter.combat_full_portrait()

func HideFighterStats():
	$StatsPanel.hide()

func FighterPress(pos):
	if allowaction == false || (!allowedtargets.enemy.has(pos) && !allowedtargets.ally.has(pos)):
		return
	ClearSkillTargets()
	ClearItemPanel()
	ClearSkillPanel()
	use_skill(activeaction, activecharacter, battlefield[pos])


func buildenemygroup(enemygroup):
	for i in range(1,7):
		if enemygroup[i] != null:
			enemygroup[i+6] = enemygroup[i]
		enemygroup.erase(i)
	
	for i in enemygroup:
		if enemygroup[i] == null:
			continue
		var tempname = enemygroup[i]
		enemygroup[i] = globals.combatant.new()
		enemygroup[i].createfromenemy(tempname)
	
	for i in enemygroup:
		if enemygroup[i] == null:
			continue
		enemygroup[i].combatgroup = 'enemy'
		battlefield[i] = enemygroup[i]
		make_fighter_panel(battlefield[i], i)

func buildplayergroup(group):
	var newgroup =  {}
	
	for i in group:
		if group[i] == null:
			continue
		var fighter = state.heroes[group[i]]
		fighter.combatgroup = 'ally'
		battlefield[i] = fighter
		make_fighter_panel(battlefield[i], i)
		newgroup[i] = fighter
	playergroup = newgroup

func summon(montype, limit):
	# for now summoning is implemented only for opponents
	# cause i don't know if ally summons must be player- or ai-controlled
	# and don't know if it is possible to implement ai-controlled ally
	if summons.size() >= limit: return
	#find empty slot in enemy group
	var group = [7,8,9,10,11,12];
	var pos = [];
	for p in group:
		if battlefield[p] == null: pos.push_back(p);
	if pos.size() == 0: return;
	var sum_pos = pos[randi() % pos.size()];
	summons.push_back(sum_pos);
	enemygroup[sum_pos] = globals.combatant.new();
	enemygroup[sum_pos].createfromenemy(montype);
	enemygroup[sum_pos].combatgroup = 'enemy'
	battlefield[sum_pos] = enemygroup[sum_pos];
	make_fighter_panel(battlefield[sum_pos], sum_pos);
	pass

func SendSkillEffect(skilleffect, caster, target):
	var endtargets = []
	if skilleffect.target == 'self':
		endtargets.append(caster)
	elif skilleffect.target == 'target':
		endtargets.append(target)
	
	var data = {caster = caster}
	if skilleffect.has('value'):
		data.value = skilleffect.value
	
	for i in endtargets:
		if skilleffect.has('chance') && skilleffect.chance < randf():
			continue
		data.target = i
		globals.skillsdata.call(skilleffect.effect, data)
	

func use_skill(skill_code, caster, target):
	combatlogadd('\n'+ caster.name + ' uses ' + skill_code + ". ")
	allowaction = false
	
	var skill = globals.skills[skill_code]
	
	caster.mana -= skill.manacost
	
	for i in skill.casteffects:
		var tmp = Effectdata.effect_table[i]
		if tmp.trigger != variables.TR_CAST:
			continue
		caster.apply_effect(i)
	caster.basic_check(variables.TR_CAST) #can do this as on_skill_check(), but this can lead to more code rewriting, since this reqires providing access to skill parameters that are not yet determined
	
	var targets = CalculateTargets(skill, caster, target)

	var repeat = 1;
	if skill.has('repeat'):
		repeat = skill.repeat;
	
	for n in range(repeat):
		var animations = skill.sfx
		var animationdict = {windup = [], predamage = []}
		
		
		#sort animations
		for i in animations:
			animationdict[i.period].append(i)
		
		#casteranimations
		if skill.sounddata.initiate != null:
			input_handler.PlaySound(skill.sounddata.initiate)
		for i in animationdict.windup:
			var sfxtarget = ProcessSfxTarget(i.target, caster, target)
			CombatAnimations.call(i.code, sfxtarget)
			yield(CombatAnimations, 'pass_next_animation')
		
		if animationdict.windup.size() > 0:
			yield(CombatAnimations, 'cast_finished')
		for i in targets:
			if skill.sounddata.strike != null:
				if skill.sounddata.strike == 'weapon':
					input_handler.PlaySound(get_weapon_sound(caster))
				else:
					input_handler.PlaySound(skill.sounddata.strike)
			for j in animationdict.predamage:
				var sfxtarget = ProcessSfxTarget(j.target, caster, i)
				CombatAnimations.call(j.code, sfxtarget)
				yield(CombatAnimations, 'pass_next_animation')
			if animationdict.predamage.size() > 0:
				yield(CombatAnimations, 'predamage_finished')
			if skill.damagetype == 'summon':
				summon(skill.value[0], skill.value[1]);
			else: 
				execute_skill(skill_code, caster, i);
			if skill.sounddata.hit != null:
				if skill.sounddata.hittype == 'absolute':
					input_handler.PlaySound(skill.sounddata.hit)
				elif skill.sounddata.hittype == 'bodyarmor':
					input_handler.PlaySound(calculate_hit_sound(skill, caster, target))
		if animationdict.predamage.size() > 0:
			yield(CombatAnimations, 'alleffectsfinished')
	if activeitem != null:
		activeitem.amount -= 1
		activeitem = null
		SelectSkill('attack')
	
	
	
	if fighterhighlighted == true:
		FighterMouseOver(target)
	#print(caster.name + ' finished attacking') 
	#on end turn triggers
	caster.basic_check(variables.TR_TURN_F)
	call_deferred('select_actor')

func ProcessSfxTarget(sfxtarget, caster, target):
	match sfxtarget:
		'caster':
			return caster.displaynode
		'target':
			return target.displaynode



var rows = {
	1:[1,4],
	2:[2,5],
	3:[3,6],
	4:[7,10],
	5:[8,11],
	6:[9,12],
} # was completely non-intuitive because there were columns stored not rows
var lines = {
	1 : [1,2,3],
	2 : [4,5,6],
	3 : [7,8,9],
	4 : [10,11,12],
}

func CalculateTargets(skill, caster, target):
	var array = []
	
	var targetgroup
	var skilltargetgroups = skill.allowedtargets
	
	if target.position in range(1,7):
		targetgroup = 'player'
	else:
		targetgroup = 'enemy'
	
	match skill.targetpattern:
		'single':
			array = [target]
		'row':
			for i in rows:
				if rows[i].has(target.position):
					for j in rows[i]:
						if battlefield[j] != null && battlefield[j].defeated != true:
							array.append(battlefield[j])
		'line':
			for i in lines:
				if lines[i].has(target.position):
					for j in lines[i]:
						if battlefield[j] != null && battlefield[j].defeated != true:
							array.append(battlefield[j])
		'all':
			for i in battlefield:
				if i in range(1,7) && targetgroup == 'player':
					array.append(battlefield[i])
				elif i in range(7, 13) && targetgroup == 'enemy':
					array.append(battlefield[i])
	#print(array)
	return array

func calculate_number_from_string_array(array, caster, target):
	var endvalue = 0
	var firstrun = true
	for i in array:
		var modvalue = i
		if i.find('.') >= 0:
			i = i.split('.')
			if i[0] == 'caster':
				modvalue = str(caster[i[1]])
			elif i[0] == 'target':
				modvalue = str(target[i[1]])
		if !modvalue[0].is_valid_float():
			if modvalue[0] == '-' && firstrun == true:
				endvalue += float(modvalue)
			else:
				input_handler.string_to_math(endvalue, modvalue)
		else:
			endvalue += float(modvalue)
		firstrun = false
	return endvalue

func execute_skill(skill, caster, target):
	var s_skill = Skillsdata.S_Skill.new(caster, target)
	s_skill.createfromskill(skill)
	s_skill.hit_roll()
	var endvalue = 0
	#value pre_calculation, using in triggers
	endvalue = calculate_number_from_string_array(s_skill.long_value, caster, target)
	var rangetype
	if s_skill.userange == 'weapon':
		if caster.gear.rhand == null:
			rangetype = 'melee'
		else:
			var weapon = state.items[caster.gear.rhand]
			rangetype = weapon.weaponrange
	if rangetype == 'melee' && FindFighterRow(caster) == 'backrow' && !CheckMeleeRange(caster.combatgroup):
		endvalue /= 2
	s_skill.value = endvalue
	#apply triggers
	for t in s_skill.casteffects:
		s_skill.apply_effect(t, variables.TR_HIT)
	caster.on_skill_check(s_skill, variables.TR_HIT)
	target.on_skill_check(s_skill, variables.TR_DEF)
	#apply resists and modifiers
	if s_skill.hit_res == variables.RES_MISS:
		miss(target)
		combatlogadd(target.name + " evades the damage.")
		return
	s_skill.calculate_dmg()
	if s_skill.tags.has('heal'):
		combatlogadd("\n" + target.name + " restores " + str(s_skill.value) + " health.")
	else:
		combatlogadd("\n" + target.name + " takes " + str(s_skill.value) + " damage.")
	#deal damage
	if s_skill.tags.has('heal'): target.heal(s_skill.value)
	else: target.deal_damage(s_skill.value, s_skill.damagesrc)
	if target.hp <= 0:
		caster.basic_check(variables.TR_KILL)
	checkdeaths()


func miss(fighter):
	CombatAnimations.miss(fighter.displaynode)

#func makebuff(buff, caster, target):
#	var newbuff = {code = buff.code, caster = caster, duration = buff.duration, effects = [], tags = []}
#	if buff.has('icon'):
#		newbuff.icon = buff.icon
#	for i in buff.effects:
#		var value = calculate_number_from_string_array(i.value, caster, target)
#		var buffeffect = {value = value, stat = i.stat}
#		newbuff.effects.append(buffeffect)
#
#	return newbuff

func checkreqs(passive, caster, target):
	var rval = true
	
	if passive.has('casterreq'):
		if !input_handler.requirementcombatantcheck(passive.casterreq, caster):
			return false
	if passive.has('targetreq'):
		if !input_handler.requirementcombatantcheck(passive.targetreq, target):
			return false
	
	return rval

func Highlight(pos, type):
	var node = battlefieldpositions[pos].get_node("Character")
	match type:
		'selected':
			input_handler.SelectionGlow(node)
#		'target':
#			input_handler.TargetGlow(node)
#		'targetsupport':
#			input_handler.TargetSupport(node)
#		'enemy':
#			input_handler.TargetEnemyTurn(node)

func StopHighlight(pos):
	var node = battlefieldpositions[pos].get_node("Character")
	input_handler.StopTweenRepeat(node)

func Target_Glow (pos):
	var node = battlefieldpositions[pos].get_node("Character");
	if node == null: return;
	var temp = node.material.get_shader_param('modulate');
	temp.a = 1.0;
	node.material.set_shader_param('modulate', temp);

func Stop_Target_Glow ():
	for pos in range(1,13):
		var p_node = battlefieldpositions[pos];
		if !p_node.has_node('Character'): continue;
		var node = p_node.get_node("Character");
		#if node == null: continue;
		#node.material.shader_param.Modulate.a = 0.0;
		var temp = node.material.get_shader_param('modulate');
		temp.a = 0.0;
		node.material.set_shader_param('modulate', temp);

func ClearSkillPanel():
	globals.ClearContainer($SkillPanel/ScrollContainer/GridContainer)

func RebuildSkillPanel():
	ClearSkillPanel()
	for i in activecharacter.skills:
		var newbutton = globals.DuplicateContainerTemplate($SkillPanel/ScrollContainer/GridContainer)
		var skill = globals.skills[i]
		newbutton.get_node("Icon").texture = skill.icon
		newbutton.get_node("manacost").text = str(skill.manacost)
		if skill.manacost <= 0:
			newbutton.get_node("manacost").hide()
		newbutton.connect('pressed', self, 'SelectSkill', [skill.code])
		if activecharacter.mana < skill.manacost:
			newbutton.disabled = true
		newbutton.set_meta('skill', skill.code)
		#globals.connecttooltip(newbutton, skill.description)
		globals.connecttooltip(newbutton, activecharacter.skill_tooltip_text(i))

func SelectSkill(skill):
	skill = globals.skills[skill]
	if activecharacter.mana < skill.manacost:
		SelectSkill('attack')
		return
	activecharacter.selectedskill = skill.code
	activeaction = skill.code
	UpdateSkillTargets()

func RebuildItemPanel():
	var array = []
	
	ClearItemPanel()
	
	for i in state.items.values():
		if i.itemtype == 'usable':
			array.append(i)
	
	for i in array:
		var newbutton = globals.DuplicateContainerTemplate($ItemPanel/ScrollContainer/GridContainer)
		newbutton.get_node("Icon").texture = load(i.icon)
		newbutton.get_node("Label").text = str(i.amount)
		newbutton.set_meta('skill', i.useskill)
		newbutton.connect('pressed', self, 'ActivateItem', [i])
		globals.connectitemtooltip(newbutton, i)

func ClearItemPanel():
	globals.ClearContainer($ItemPanel/ScrollContainer/GridContainer)

func ActivateItem(item):
	activeaction = item.useskill
	activeitem = item
	SelectSkill(activeaction)
	#UpdateSkillTargets()

func get_weapon_sound(caster):
	var item = caster.gear.rhand
	if state.items.has(item):
		item = state.items[item]
	else:
		item = null
	if item == null:
		return 'dodge'
	else:
		return item.hitsound

func calculate_hit_sound(skill, caster, target):
	var rval
	var hitsound
	if skill.sounddata.strike == 'weapon':
		hitsound = get_weapon_sound(caster)
	else:
		hitsound = skill.sounddata.strike
	
	match hitsound:
		'dodge':
			match target.bodyhitsound:
				'flesh':pass
				'wood':pass
				'stone':pass
		'blade':
			match target.bodyhitsound:
				'flesh':pass
				'wood':pass
				'stone':pass
	rval = 'fleshhit'
	
	return rval

func combatlogadd(text):
	$Combatlog/RichTextLabel.append_bbcode(text)
