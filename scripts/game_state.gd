extends Node

signal xp_changed(current_xp: int, needed_xp: int) 
signal leveled_up(new_level: int)  # sent when the player reaches a new level

const XP_PER_LEVEL: int = 100  # each level needs this much more XP than the last one

var level: int = 1  # the player's current level
var xp: int = 0  # XP earned toward the next level


func get_xp_needed() -> int:  # how much XP the current level needs
	return XP_PER_LEVEL * level  


func add_xp(amount: int) -> void:  # gives the player XP, like after catching a fish
	if amount <= 0:  # skip zero or negative XP
		return  # stop here
	xp += amount  
	while xp >= get_xp_needed():  # level up as many times as the XP allows
		xp -= get_xp_needed()  # use up the XP this level needed
		level += 1 
		leveled_up.emit(level)  # tell the game about the new level
	xp_changed.emit(xp, get_xp_needed())  
