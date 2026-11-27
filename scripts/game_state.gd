extends Node

signal xp_changed(current_xp: int, needed_xp: int)
signal leveled_up(new_level: int)  # sent when the player reaches a new level

const XP_PER_LEVEL: int = 100  # each level needs this much more XP than the last one
const MAP_SCENE := "res://scenes/main.tscn"
const FIGHT_SCENE := "res://scenes/fight_arena.tscn"

var level: int = 1  # the player's current level
var xp: int = 0  # XP earned toward the next level

var intro_done: bool = false  # so the intro tips only show the first time the map loads
var fight_fish: FishType = null
var return_position: Vector2 = Vector2.ZERO  # where the player was on the map before the fight
var current_map: String = MAP_SCENE  # the world the player is in, so fights send you back to it
var fight_result: String = "" 


func get_xp_needed() -> int:  # how much XP the current level needs
	return XP_PER_LEVEL * level


func add_xp(amount: int) -> void:  # gives the player XP, like after catching a fish
	if amount <= 0:  
		return 
	xp += amount
	while xp >= get_xp_needed():  # level up as many times as the XP allows
		xp -= get_xp_needed()  # use up the XP this level needed
		level += 1
		leveled_up.emit(level)  
	xp_changed.emit(xp, get_xp_needed())


func start_fight(fish: FishType, player_position: Vector2) -> void:  # leaves the map to fight this fish
	fight_fish = fish
	return_position = player_position
	fight_result = ""
	get_tree().change_scene_to_file.call_deferred(FIGHT_SCENE)  # deferred so it happens after this frame


func finish_fight(won: bool) -> void:  # goes back to the map and remembers how the fight went
	fight_result = "won" if won else "lost"
	get_tree().change_scene_to_file.call_deferred(current_map)


func go_to_map(scene_path: String) -> void:  # moves the player to another world, like through the gate
	current_map = scene_path
	return_position = Vector2.ZERO  # start at the new world's spawn point
	get_tree().change_scene_to_file.call_deferred(scene_path)


# reusable level check, the gate uses 3 and the boss spot can use 5
func has_level(required: int) -> bool:
	return level >= required


# same locked message everywhere so it reads the same
func level_lock_message(required: int) -> String:
	return "You need to be level " + str(required) + " to go here. You are level " + str(level) + "."
