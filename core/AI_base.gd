extends Reference
class_name ai_base

var app_obj  #applied character

var ai_data = {}
var skill_targets = {} #s_name:[targets]

var current_state
var next_state

func _init():
	current_state = 0
	next_state = 0

func _ready():
	pass # Replace with function body.

func set_single_state(data):
	var state = {}
	state['transmissions'] = []
	state['choices'] = data.duplicate() 
	ai_data[0] = state

func set_simple_ai(profile):
	ai_data = AI_data.get(profile).duplicate()

func _set_next_state():
	#next state set up by previous action
	#only actual for inherited complex ais
	if next_state != current_state:
		current_state = next_state 
		return
	# controlled_object_state-based state change 
	for line in ai_data[current_state].transmissions:
		if app_obj.process_check(line.check):
			current_state = line.next_state
			return

func calculate_target_list(hide_ignore = false): #utility checks and targets calculating 
	#for most of the cases reimplementing this function in inherited classes is not reqired
	#works worser for skills with repeat and random targets
	for s_n in app_obj.skills:
		var t_skill = Skillsdata.skilllist[s_n]
		var target_array = []
		var starget
		if t_skill.allowedtargets.has('self'): starget = 'self'
		if t_skill.allowedtargets.has('ally'): starget = 'ally'
		if t_skill.allowedtargets.has('enemy'): starget = 'enemy'
		match starget:
			'self':
				var target_dir = {target = app_obj.position, quality = 1.0}
				var act_targets = globals.combat_node.CalcuateTargets(t_skill, app_obj)
				if act_targets.size() == 0: 
					target_dir.quality = 0
					target_array.push_back(target_dir)
				else:
					#heal value degrades with current hp
					if t_skill.tags.has('heal'):
						for t in act_targets:
							target_dir.quality += t.need_heal() / act_targets.size()
					#assuming cd of buffs is not lesser than their duration
					#buffs are always effective
					if t_skill.tags.has('buff'): 
						target_dir.quality = max(target_dir.quality, 1.0)
					target_array.push_back(target_dir)
			'ally':
				var pos_targets = globals.combat_node.get_allied_targets(app_obj)
				for target in pos_targets:
					var target_dir = {target = target.position, quality = 1.0}
					var act_targets = globals.combat_node.CalcuateTargets(t_skill, target)
					if act_targets.size() == 0: 
						target_dir.quality = 0
						target_array.push_back(target_dir)
					else:
						#heal value degrades with current hp
						if t_skill.tags.has('heal'):
							for t in act_targets:
								target_dir.quality += t.need_heal() / act_targets.size()
						#assuming cd of buffs is not lesser than their duration
						#buffs are always effective
						if t_skill.tags.has('buff'): 
							target_dir.quality = max(target_dir.quality, 1.0)
						#aoe skills are more desired if there are more targets in area
						match t_skill.target_number:
							'all':
								if act_targets.size() < 4: target_dir.quality *= 0.5
								if act_targets.size() < 2: target_dir.quality *= 0.5
							'line':
								if act_targets.size() < 2: target_dir.quality *= 0.4
							'row':
								if act_targets.size() < 2: target_dir.quality *= 0.5
						target_array.push_back(target_dir)
			'enemy':
				var pos_targets
				match t_skill.userange:
					'melee', 'weapon': pos_targets = globals.combat_node.get_enemy_targets_melee(app_obj, hide_ignore)
					'any': pos_targets = globals.combat_node.get_enemy_targets_all(app_obj, hide_ignore)
				for target in pos_targets:
					var target_dir = {target = target.position, quality = 1.0}
					var act_targets = globals.combat_node.CalculateTargets(t_skill, target)
					if act_targets.size() == 0: 
						target_dir.quality = 0
						target_array.push_back(target_dir)
					else:
						#assuming debuffs and damage are always effective
						#not true, but implementing resist check is not trivial
						#aoe skills are more desired if there are more targets in area
						match t_skill.targetpattern:
							'all':
								if act_targets.size() < 4: target_dir.quality *= 0.5
								if act_targets.size() < 2: target_dir.quality *= 0.5
							'line':
								if act_targets.size() < 2: target_dir.quality *= 0.5
							'row':
								if act_targets.size() < 2: target_dir.quality *= 0.5
						target_array.push_back(target_dir)
		skill_targets[s_n] = target_array

func if_has_target(s_name, t_pos):
	for t in skill_targets[s_name]:
		if t.position == t_pos: return true
	return false

func _get_weight_for_skill(s_name):
	var res = 0
	var t_skill = Skillsdata.skilllist[s_name]
	if !app_obj.can_use_skill(t_skill): return 0
	#check if skill is in cooldown
	if app_obj.cooldowns.has(s_name): return res
	#no targets check
	if skill_targets[s_name].size() == 0: return res
	#empty ai_data check
	if ai_data[current_state].choices.size() == 0:
		return 1.0
	#calculate base weight for current state

	for tag in ai_data[current_state].choices:
		if t_skill.tags.has(tag): res += ai_data[current_state].choices[tag]
	#correct weight for skills with only bad-quality targets
	var tmp  = 0.0
	for target in skill_targets[s_name]: tmp = max(target.quality, tmp)
	tmp = clamp(tmp, 0.3, 0.75)*2.0 - 0.5
	res *= tmp
	if app_obj.taunt != null:
		var taunt_t = state.heroes[app_obj.taunt]
		if !if_has_target(s_name, taunt_t.position): res = 0
	return res

func _get_action(hide_ignore = false):
	calculate_target_list(hide_ignore)
	if !hide_ignore: _set_next_state()
	var actions = []
	for s_n in app_obj.skills:
		var tmp = _get_weight_for_skill(s_n)
		if tmp > 0: actions.push_back([s_n, tmp])
	if actions.size() == 0:
		if app_obj.taunt != null:
			print ("can't attack taunt")
			app_obj.taunt = null
			return _get_action(hide_ignore)
		else:
			print ('ERROR IN AI TEMPLATE')
	var res = input_handler.weightedrandom(actions)
	return res

func _get_target(s_name):#for chosen with _get_action() func
	var targets = []
	if app_obj.taunt != null:
		var taunt_t = state.heroes[app_obj.taunt]
		return taunt_t.position
	for t in skill_targets[s_name]:
		targets.push_back([t.target, t.quality])
	return input_handler.weightedrandom(targets)

func get_spec_data():
	return 0
