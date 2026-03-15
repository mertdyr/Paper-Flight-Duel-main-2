# Global.gd - Tournament System for Godot 4.x
extends Node

# Difficulty
var difficulty_speed_multiplier: float = 1.0

# --- TOURNAMENT MODE VARIABLES ---
var tournament_mode: bool = true  # Turnuva modu aktif

# Round System (Best of 3)
var rounds_to_win: int = 2  # İlk 2 round kazanan şampiyon
var p1_rounds_won: int = 0
var p2_rounds_won: int = 0

# Throw System (3 throws per player per round)
var max_throws_per_round: int = 3
var p1_current_throw: int = 0
var p2_current_throw: int = 0

# Score tracking for current round
var p1_throw_scores: Array = [0.0, 0.0, 0.0]  # Her atışın skoru
var p2_throw_scores: Array = [0.0, 0.0, 0.0]

# Total scores per round (3 atışın toplamı)
var p1_total_score_this_round: float = 0.0
var p2_total_score_this_round: float = 0.0

# --- PROGRESSION SYSTEM ---
var total_coins: int = 0

# Reset tournament
func reset_tournament() -> void:
	p1_rounds_won = 0
	p2_rounds_won = 0
	reset_current_round()

# Reset current round
func reset_current_round() -> void:
	p1_current_throw = 0
	p2_current_throw = 0
	p1_throw_scores = [0.0, 0.0, 0.0]
	p2_throw_scores = [0.0, 0.0, 0.0]
	p1_total_score_this_round = 0.0
	p2_total_score_this_round = 0.0

# Record a throw
func record_throw(player: int, distance: float) -> void:
	if player == 1:
		p1_throw_scores[p1_current_throw] = distance
		p1_total_score_this_round += distance  
		p1_current_throw += 1
	else:
		p2_throw_scores[p2_current_throw] = distance
		p2_total_score_this_round += distance  
		p2_current_throw += 1

# Check if round is complete
func is_round_complete() -> bool:
	return p1_current_throw >= max_throws_per_round and p2_current_throw >= max_throws_per_round

func get_round_winner() -> int:
	if p1_total_score_this_round > p2_total_score_this_round:
		return 1
	elif p2_total_score_this_round > p1_total_score_this_round:
		return 2
	else:
		return 0 # Beraberlik


# Award round win
func award_round_win(player: int) -> void:
	if player == 1:
		p1_rounds_won += 1
	elif player == 2:
		p2_rounds_won += 1


# Check if tournament is over
func is_tournament_over() -> bool:
	return p1_rounds_won >= rounds_to_win or p2_rounds_won >= rounds_to_win

# Get tournament winner
func get_tournament_winner() -> int:
	if p1_rounds_won >= rounds_to_win:
		return 1
	elif p2_rounds_won >= rounds_to_win:
		return 2
	else:
		return 0  # Henüz kazanan yok
