# UI.gd - Tournament UI (Godot 4.x)
extends CanvasLayer

signal retry_game
signal back_to_menu

var status_label: Label
var power_bar: ProgressBar
var boost_bar: ProgressBar
var results_panel: PanelContainer
var results_text: Label
var p1_score_text: Label
var p2_score_text: Label
var message_timer: Timer

# Score Display (SAĞ ÜST KÖŞE - Skor Tablosu)
var score_display: PanelContainer
var score_label: Label

func _ready() -> void:
	message_timer = $MessageTimer
	
	status_label = $StatusLabel
	power_bar = $PowerBar
	boost_bar = $BoostBar
	results_panel = $ResultsPanel
	results_text = $ResultsPanel/VBoxContainer/ResultsText
	p1_score_text = $ResultsPanel/VBoxContainer/P1ScoreText
	p2_score_text = $ResultsPanel/VBoxContainer/P2ScoreText
	
	# SAĞ ÜST - Skor Tablosu (YENİ EKLENEN)
	create_score_display()
	
	results_panel.visible = false
	
	# SOL ÜST - PowerBar ve BoostBar (zaten var, dokunmuyoruz)
	if power_bar:
		power_bar.visible = true
	
	if boost_bar:
		boost_bar.visible = true
	
	if status_label:
		status_label.visible = true
	
	# Buton bağlantıları
	$ResultsPanel/VBoxContainer/RetryButton.pressed.connect(_on_retry_button_pressed)
	$ResultsPanel/VBoxContainer/MenuButton.pressed.connect(_on_menu_button_pressed)

func create_score_display() -> void:
	# SAĞ ÜST KÖŞE için skor paneli oluştur
	score_display = PanelContainer.new()
	add_child(score_display)
	
	# Ekran boyutuna göre dinamik konum (SAĞ ÜST)
	var viewport_size = get_viewport().get_visible_rect().size
	score_display.position = Vector2(viewport_size.x - 290, 10)
	score_display.custom_minimum_size = Vector2(270, 120)
	
	# Arka plan rengi (koyu yarı saydam)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.7)
	style.set_border_width_all(2)
	style.border_color = Color(1, 1, 1, 0.3)
	style.set_corner_radius_all(8)
	score_display.add_theme_stylebox_override("panel", style)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	score_display.add_child(margin)
	
	score_label = Label.new()
	score_label.add_theme_font_size_override("font_size", 16)
	score_label.add_theme_color_override("font_color", Color(1, 1, 1))
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	margin.add_child(score_label)

func _on_game_update_ui_text(text: String) -> void:
	# SOL ÜST - Oyun durumu mesajları
	if status_label:
		status_label.text = text
	if "Speed Boost!" in text or "Throw" in text:
		message_timer.start()

func _on_message_timer_timeout() -> void:
	pass

func _on_game_update_angle(_angle: float) -> void:
	pass

func _on_game_update_power_bar(power: float, min_p: float, max_p: float) -> void:
	if power_bar:
		power_bar.min_value = min_p
		power_bar.max_value = max_p
		power_bar.value = power
		
		var percentage = (power - min_p) / (max_p - min_p)
		var bar_color = Color(percentage, 1.0 - percentage, 0.0)
		power_bar.modulate = bar_color

func _on_game_update_boost_bar(current_fuel: float, max_fuel: float) -> void:
	if boost_bar:
		boost_bar.max_value = max_fuel
		boost_bar.value = current_fuel

func _on_game_update_score_display(p1_total: float, p2_total: float, p1_rounds: int, p2_rounds: int, p1_throws: int, p2_throws: int) -> void:
	# SAĞ ÜST - Skor tablosu güncelleme
	if score_label:
		var text = "🏆 TOURNAMENT 🏆\n"
		
		# Round skorunu noktalarla + sayılarla göster
		text += "⚫ "
		for i in range(p1_rounds):
			text += "● "
		text += "(%d) - (%d) " % [p1_rounds, p2_rounds]
		for i in range(p2_rounds):
			text += "● "
		text += "🟡\n\n"
		
		text += "🖤 BLACK: %.1fm (%d/3)\n" % [p1_total, p1_throws]
		text += "💛 YELLOW: %.1fm (%d/3)" % [p2_total, p2_throws]
		score_label.text = text

func _on_game_show_round_results(p1_total: float, p2_total: float, winner: int) -> void:
	if results_panel:
		results_panel.visible = true
	
	if p1_score_text:
		p1_score_text.text = "🖤 P1 Total: %.1f m" % p1_total
	
	if p2_score_text:
		p2_score_text.text = "💛 P2 Total: %.1f m" % p2_total
	
	if results_text:
		if winner == 1:
			results_text.text = "🏆 BLACK WINS ROUND! 🏆\nScore: %d - %d" % [Global.p1_rounds_won, Global.p2_rounds_won]
		elif winner == 2:
			results_text.text = "🏆 YELLOW WINS ROUND! 🏆\nScore: %d - %d" % [Global.p1_rounds_won, Global.p2_rounds_won]
		else:
			results_text.text = "⚖️ ROUND TIE! ⚖️\nScore: %d - %d" % [Global.p1_rounds_won, Global.p2_rounds_won]
	
	# Hide buttons during round results
	$ResultsPanel/VBoxContainer/RetryButton.visible = false
	$ResultsPanel/VBoxContainer/MenuButton.visible = false
	
	# Auto-hide after 3 seconds
	await get_tree().create_timer(3.0).timeout
	results_panel.visible = false

func _on_game_show_tournament_results(_p1_rounds: int, _p2_rounds: int, winner: int) -> void:
	if results_panel:
		results_panel.visible = true
	
	if p1_score_text:
		p1_score_text.text = "🖤 Black Rounds: %d" % Global.p1_rounds_won
	
	if p2_score_text:
		p2_score_text.text = "💛 Yellow Rounds: %d" % Global.p2_rounds_won
	
	if results_text:
		if winner == 1:
			results_text.text = "🏆🏆 BLACK WINS TOURNAMENT! 🏆🏆"
		elif winner == 2:
			results_text.text = "🏆🏆 YELLOW WINS TOURNAMENT! 🏆🏆"
		else:
			results_text.text = "⚖️ TOURNAMENT TIE! ⚖️"
	
	# Show buttons for final results
	$ResultsPanel/VBoxContainer/RetryButton.visible = true
	$ResultsPanel/VBoxContainer/MenuButton.visible = true

func _on_retry_button_pressed() -> void:
	if results_panel:
		results_panel.visible = false
	emit_signal("retry_game")

func _on_menu_button_pressed() -> void:
	emit_signal("back_to_menu")
