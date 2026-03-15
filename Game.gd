# Game.gd - Tournament Mode (Godot 4.x) - PERFECTED VERSION
extends Node2D

# --- EDİTÖRDE ATANACAK SAHNELER ---
@export_category("Scenes")
@export var plane_black_scene: PackedScene
@export var plane_yellow_scene: PackedScene
@export var fuel_item_scene: PackedScene    # Benzin Bidonu Sahnesi
@export var speed_boost_scene: PackedScene  # Yıldırım/Hız Sahnesi (YENİ)

# --- EDİTÖRDE ATANACAK GÖRSELLER ---
@export_category("Decoration Textures")
@export var texture_tree: Texture2D    
@export var texture_pyramid: Texture2D 
@export var texture_igloo: Texture2D

@export var pyramid_y_offset: float = 0.0  # Piramitleri ne kadar aşağı iteceğiz?
@export var igloo_y_offset: float = -40.0    # İgloları ne kadar aşağı iteceğiz?   
@export var tree_y_offset: float = -40.0

enum GameState { PLAYER1_AIM, PLAYER2_AIM, FLYING, ROUND_OVER, TOURNAMENT_OVER }

var current_state: GameState = GameState.PLAYER1_AIM
var current_player: int = 1
var current_plane: RigidBody2D 

# Fizik Parametreleri
var base_power_speed: float = 600.0
var base_angle_speed: float = 40.0

var launch_power: float = 500.0
var max_power: float = 1500.0
var min_power: float = 200.0
var power_direction: int = 1

var launch_angle: float = -45.0
var min_angle: float = -80.0
var max_angle: float = -10.0
var angle_direction: int = 1

var launch_position: Vector2 = Vector2(100, 400)
var aiming_stage: String = "angle"

# Node Referansları
var arrow: Sprite2D
var player_black: Sprite2D
var player_yellow: Sprite2D
var camera: Camera2D
var ground_rect: ColorRect
var bg_rect: ColorRect

# İniş ve Kamera Kontrolü
var landing_check_timer: float = 0.0
var is_camera_resetting: bool = false 

# --- BOOST SİSTEMİ ---
var max_boost_fuel: float = 100.0
var current_boost_fuel: float = 100.0
var boost_force: float = 200.0
var fuel_consumption: float = 90.0

# --- ÇEVRESEL EFEKT AYARLARI ---
var sky_color_day = Color("3174ff")
var sky_color_space = Color("000015")
var ground_color_grass = Color("008926")
var ground_color_desert = Color("e0c055")
var ground_color_snow = Color("efffff")

var height_ground_level: float = 500.0
var height_space_level: float = -4000.0

# --- YENİ MESAFE SINIRLARI (İSTEK 4) ---
var dist_grass_limit: float = 3000.0   # 0-3000m: Yeşil
var dist_desert_limit: float = 6000.0  # 3000-6000m: Sarı 5000-10000m: Sarı
var dist_snow_limit: float = 15000.0   # 10000m+: Beyaz

# Sinyaller
signal update_ui_text(text: String)
signal update_power_bar(power: float, min_p: float, max_p: float)
signal update_angle(angle: float)
signal update_score_display(p1_total: float, p2_total: float, p1_rounds: int, p2_rounds: int, p1_throws: int, p2_throws: int)
signal show_round_results(p1_total: float, p2_total: float, winner: int)
signal show_tournament_results(p1_rounds: int, p2_rounds: int, winner: int)
signal update_boost_bar(current: float, max_fuel: float)

func _ready() -> void:
	arrow = $Arrow
	player_black = $PlayerBlack
	player_yellow = $PlayerYellow
	camera = $Camera2D
	ground_rect = $Ground/ColorRect
	bg_rect = $BackgroundLayer/BG
	
	if has_node("/root/Global"):
		base_power_speed *= Global.difficulty_speed_multiplier
		base_angle_speed *= Global.difficulty_speed_multiplier
	
	spawn_decorations()
	start_tournament()

# --- DEKORASYON SİSTEMİ (OFFSET AYARLI) ---

func spawn_decorations() -> void:
	seed(123456) # SABİT MAP
	if has_node("Decorations"):
		for child in $Decorations.get_children(): child.queue_free()
	else:
		var dec_node = Node2D.new()
		dec_node.name = "Decorations"
		add_child(dec_node)
		move_child(dec_node, 2) 
	
	var parent = $Decorations
	var current_x = 400.0 
	
	# 1. BÖLGE: AĞAÇLAR (Offset yok veya 0)
	if texture_tree:
		while current_x < dist_grass_limit:
			var sc = randf_range(0.3, 0.5)
			if current_x + (texture_tree.get_width() * sc) > dist_grass_limit: break 
			
			spawn_sprite(parent, texture_tree, current_x, sc, tree_y_offset)

			current_x += randf_range(150.0, 350.0)

	# 2. BÖLGE: PİRAMİTLER (pyramid_y_offset kullanılıyor)
	current_x = dist_grass_limit + 50 
	if texture_pyramid:
		while current_x < dist_desert_limit:
			var sc = randf_range(0.4, 0.7)
			if current_x + (texture_pyramid.get_width() * sc) > dist_desert_limit: break
			
			# BURASI DÜZELDİ: Inspector'dan gelen değeri kullanıyor
			spawn_sprite(parent, texture_pyramid, current_x, sc, pyramid_y_offset)
			current_x += randf_range(400.0, 800.0)

	# 3. BÖLGE: İGLOLAR (igloo_y_offset kullanılıyor)
	current_x = dist_desert_limit + 50
	if texture_igloo:
		while current_x < 25000.0: 
			var sc = randf_range(0.3, 0.6)
			
			# BURASI DÜZELDİ: Inspector'dan gelen değeri kullanıyor
			spawn_sprite(parent, texture_igloo, current_x, sc, igloo_y_offset)
			current_x += randf_range(400.0, 800.0)

# Offset (y_shift) hesaplaması burada yapılıyor
func spawn_sprite(parent: Node, texture: Texture2D, x_pos: float, scale_val: float, y_shift: float) -> float:
	var sprite = Sprite2D.new()
	sprite.texture = texture
	sprite.scale = Vector2(scale_val, scale_val)

	var half_height = (texture.get_height() * scale_val) / 2.0
	sprite.position = Vector2(
		x_pos,
		height_ground_level - half_height + y_shift
	)

	parent.add_child(sprite)

	return texture.get_width() * scale_val

# --- OYUN DÖNGÜSÜ ---
func start_tournament() -> void:
	Global.reset_tournament()
	start_new_round()

func start_new_round() -> void:
	Global.reset_current_round()
	current_player = 1
	setup_turn()
	emit_signal("update_score_display", 0.0, 0.0, Global.p1_rounds_won, Global.p2_rounds_won, 0, 0)
	set_state(GameState.PLAYER1_AIM)

func setup_turn() -> void:
	launch_power = min_power
	power_direction = 1
	launch_angle = (min_angle + max_angle) / 2.0
	angle_direction = 1
	aiming_stage = "angle"
	is_camera_resetting = false
	
	emit_signal("update_power_bar", min_power, min_power, max_power)
	current_boost_fuel = max_boost_fuel
	emit_signal("update_boost_bar", current_boost_fuel, max_boost_fuel)
	
	var tween = create_tween()
	tween.tween_property(camera, "position", Vector2(launch_position.x + 200, 321), 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	if arrow: arrow.visible = true
	if player_black: player_black.visible = (current_player == 1)
	if player_yellow: player_yellow.visible = (current_player == 2)
	
	# --- SES DÜZELTMESİ ---
	# Yeni tur başlarken rüzgar sesi takılı kaldıysa kesinlikle sustur
	if has_node("SfxWind"): $SfxWind.stop()
	
	spawn_air_items()

# --- İTEM SİSTEMİ (GÜNCELLENMİŞ - TÜM GÖKYÜZÜ) ---
func spawn_air_items() -> void:
	# Önceki itemleri temizle
	if has_node("AirItems"):
		for child in $AirItems.get_children(): child.queue_free()
	else:
		var node = Node2D.new()
		node.name = "AirItems"
		add_child(node)
	
	# Başlangıç noktası (Fırlatmadan biraz ileri)
	var current_x = launch_position.x + 600.0
	var max_distance = 20000.0 # Haritanın sonuna kadar
	
	# Tüm harita boyunca döngü
	while current_x < max_distance:
		var is_fuel = randf() > 0.5 # %50 şansla Benzin veya Hız
		var item = null
		
		if is_fuel and fuel_item_scene:
			item = fuel_item_scene.instantiate()
			# FuelItem.gd içindeki sinyal
			if item.has_signal("fuel_collected"):
				item.fuel_collected.connect(_on_fuel_collected)
				
		elif not is_fuel and speed_boost_scene:
			item = speed_boost_scene.instantiate()
			# SpeedBoost.gd içindeki sinyal (collected)
			if item.has_signal("collected"):
				item.collected.connect(_on_speed_boost_collected)
		
		if item:
			# 1. BOYUT KÜÇÜLTME (Scale)
			# Görsellerin çok büyükse bu değerleri daha da küçült (örn: 0.2)
			var random_scale = randf_range(0.25, 0.4) 
			item.scale = Vector2(random_scale, random_scale)
			
			# 2. GÖKYÜZÜNE YERLEŞTİRME (Y Ekseni)
			# Ground Level = 500.0 (Zemin)
			# Değer küçüldükçe yukarı çıkar.
			# -1200 (Çok yüksek/Uzay) ile 350 (Alçak uçuş) arası rastgele
			var rand_y = randf_range(-1200.0, 350.0)
			
			item.position = Vector2(current_x, rand_y)
			$AirItems.add_child(item)
		
		# Bir sonraki item için 500m ile 1000m arası ileri git
		current_x += randf_range(500.0, 1000.0)

func _on_fuel_collected() -> void:
	current_boost_fuel = min(current_boost_fuel + 15.0, max_boost_fuel) # %15 doldur
	emit_signal("update_boost_bar", current_boost_fuel, max_boost_fuel)
	emit_signal("update_ui_text", "⛽ Fuel Refilled!")
	
	if has_node("SfxFuel"): $SfxFuel.play()

func _on_speed_boost_collected(plane_body: Node2D) -> void:
	# Hızlandırma (Yıldırım)
	if plane_body is RigidBody2D:
		plane_body.linear_velocity *= 1.5 # %50 anlık hız artışı
		emit_signal("update_ui_text", "⚡ SUPER SPEED!")
		
		if has_node("SfxBoost"):
			$SfxBoost.play()

func _process(delta: float) -> void:
	if camera:
		bg_rect.size = Vector2(30000, 15000)
		bg_rect.global_position = camera.global_position - (bg_rect.size / 2.0)
		ground_rect.global_position.x = camera.global_position.x - get_viewport_rect().size.x
		ground_rect.size.x = get_viewport_rect().size.x * 3

	update_environment_visuals()

	# Shader varsa parametre gönder
	if camera and ground_rect and ground_rect.material is ShaderMaterial:
		var sm := ground_rect.material as ShaderMaterial
		sm.set_shader_parameter("camera_x", camera.global_position.x)

	if current_state == GameState.PLAYER1_AIM or current_state == GameState.PLAYER2_AIM:
		handle_aiming(delta)
	elif current_state == GameState.FLYING:
		check_plane_landed(delta)
		
		# --- KRİTİK DÜZELTME BURADA ---
		# Eğer uçak indiyse (process_landing çalıştıysa) process durdurulmuştur.
		# Hemen fonksiyonu terk etmeliyiz, yoksa aşağıdaki kod rüzgarı tekrar başlatır.
		if not is_processing(): return

		update_camera_follow(delta)
		handle_player_boost(delta)
		
		# Ses Mantığı: Launch bittiyse ve Rüzgar çalmıyorsa başlat
		if has_node("SfxLaunch") and has_node("SfxWind"):
			if not $SfxLaunch.playing and not $SfxWind.playing:
				$SfxWind.play()

func update_environment_visuals() -> void:
	var target_y: float = 0.0

	if is_instance_valid(current_plane):
		target_y = current_plane.global_position.y
	elif camera:
		target_y = camera.global_position.y
	# Gökyüzü
	var sky_t = remap(target_y, height_ground_level, height_space_level, 0.0, 1.0)
	sky_t = clamp(sky_t, 0.0, 1.0)
	bg_rect.color = sky_color_day.lerp(sky_color_space, sky_t)
	if has_node("BackgroundLayer/Stars"):
		$BackgroundLayer/Stars.modulate.a = sky_t


func handle_player_boost(delta: float) -> void:
	if current_boost_fuel <= 0 or not is_instance_valid(current_plane): return

	if Input.is_action_pressed("p1_up"):
		current_boost_fuel -= fuel_consumption * delta
		var force_direction = Vector2.RIGHT.rotated(current_plane.rotation)
		current_plane.apply_central_force(force_direction * boost_force)
		emit_signal("update_boost_bar", current_boost_fuel, max_boost_fuel)

func handle_aiming(delta: float) -> void:
	if aiming_stage == "angle":
		launch_angle += base_angle_speed * angle_direction * delta
		if launch_angle >= max_angle:
			launch_angle = max_angle
			angle_direction = -1
		elif launch_angle <= min_angle:
			launch_angle = min_angle
			angle_direction = 1
		if arrow: arrow.rotation_degrees = launch_angle
		emit_signal("update_angle", launch_angle)
		
	elif aiming_stage == "power":
		launch_power += base_power_speed * power_direction * delta
		if launch_power >= max_power:
			launch_power = max_power
			power_direction = -1
		elif launch_power <= min_power:
			launch_power = min_power
			power_direction = 1
		emit_signal("update_power_bar", launch_power, min_power, max_power)
	
	if Input.is_action_just_pressed("p1_launch") or Input.is_action_just_pressed("p2_launch"):
		if aiming_stage == "angle":
			aiming_stage = "power"
			if arrow: arrow.visible = false
			update_ui_for_power()
		elif aiming_stage == "power":
			launch_plane()

func update_camera_follow(delta: float) -> void:
	if is_camera_resetting: return
	
	if current_plane and is_instance_valid(current_plane) and camera:
		var target_x = current_plane.global_position.x + 200 
		var target_y = current_plane.global_position.y
		camera.position.x = lerp(camera.position.x, target_x, 10.0 * delta)
		camera.position.y = lerp(camera.position.y, target_y, 10.0 * delta)

func update_ui_for_power() -> void:
	var p_name = "🖤 P1" if current_player == 1 else "💛 P2"
	var throw_num = Global.p1_current_throw + 1 if current_player == 1 else Global.p2_current_throw + 1
	emit_signal("update_ui_text", "%s - Throw %d/3 - SET POWER!" % [p_name, throw_num])

func launch_plane() -> void:
	var scene = plane_black_scene if current_player == 1 else plane_yellow_scene
	if !scene: return
	
	current_plane = scene.instantiate()
	current_plane.position = launch_position
	current_plane.rotation_degrees = launch_angle
	add_child(current_plane)
	current_plane.sleeping = false
	
	var impulse = Vector2.from_angle(deg_to_rad(launch_angle)) * launch_power
	current_plane.apply_central_impulse(impulse)
	
	landing_check_timer = 0.5
	set_state(GameState.FLYING)
	
	# Sadece Fırlatma Sesi Çal
	if has_node("SfxLaunch"): 
		$SfxLaunch.play()
	
	# Rüzgarın daha önce çalıyorsa durduğundan emin ol
	if has_node("SfxWind"): 
		$SfxWind.stop()

func check_plane_landed(delta: float) -> void:
	if landing_check_timer > 0:
		landing_check_timer -= delta
		return

	if current_plane and (current_plane.sleeping or current_plane.linear_velocity.length() < 10):
		process_landing()

func process_landing() -> void:
	set_process(false) 
	
	# --- BU KISMI EKLE (En başa) ---
	if has_node("SfxWind"): $SfxWind.stop() # Rüzgar sussun
	if has_node("SfxLand"): $SfxLand.play() # Çarpma sesi gelsin
	
	var distance = max(0, current_plane.global_position.x - launch_position.x)
	Global.record_throw(current_player, distance)
	
	var throw_num = Global.p1_current_throw if current_player == 1 else Global.p2_current_throw
	var p_name = "🖤 P1" if current_player == 1 else "💛 P2"
	emit_signal("update_ui_text", "%s - Throw %d: %.1fm" % [p_name, throw_num, distance])
	emit_signal("update_score_display", Global.p1_total_score_this_round, Global.p2_total_score_this_round, Global.p1_rounds_won, Global.p2_rounds_won, Global.p1_current_throw, Global.p2_current_throw)
	
	await get_tree().create_timer(2.0).timeout
	
	if is_instance_valid(current_plane):
		current_plane.queue_free()
		current_plane = null
	
	decide_next_turn()
	set_process(true)

func decide_next_turn() -> void:
	# 1. Kontrol: İki oyuncu da haklarını bitirdi mi?
	if Global.p1_current_throw >= Global.max_throws_per_round and Global.p2_current_throw >= Global.max_throws_per_round:
		finish_round()
		return

	# 2. Kontrol: Sıra kimde? (Sıralı Atış Mantığı)
	# Eğer P1'in atış sayısı P2'den fazlaysa, sıra P2'ye geçer.
	# Eğer atış sayıları eşitse, sıra tekrar P1'e gelir (çünkü tura P1 başlar).
	
	if Global.p1_current_throw > Global.p2_current_throw:
		# Sıra Oyuncu 2'de
		current_player = 2
		setup_turn()
		set_state(GameState.PLAYER2_AIM)
	else:
		# Sıra Oyuncu 1'de (Eşit olduklarında veya yeni turda)
		current_player = 1
		setup_turn()
		set_state(GameState.PLAYER1_AIM)

func finish_round() -> void:
	is_camera_resetting = true
	var winner = Global.get_round_winner()
	Global.award_round_win(winner)
	
	emit_signal("show_round_results", Global.p1_total_score_this_round, Global.p2_total_score_this_round, winner)
	
	await get_tree().create_timer(4.0).timeout
	
	if Global.is_tournament_over():
		finish_tournament()
	else:
		start_new_round()

func finish_tournament() -> void:
	var winner = Global.get_tournament_winner()
	emit_signal("show_tournament_results", Global.p1_rounds_won, Global.p2_rounds_won, winner)
	set_state(GameState.TOURNAMENT_OVER)

func set_state(new_state: GameState) -> void:
	current_state = new_state
	var current_round = Global.p1_rounds_won + Global.p2_rounds_won + 1
	match current_state:
		GameState.PLAYER1_AIM:
			var throw_num = Global.p1_current_throw + 1
			emit_signal("update_ui_text", "Round %d - 🖤 P1 - Throw %d/3 - AIM" % [current_round, throw_num])
		GameState.PLAYER2_AIM:
			var throw_num = Global.p2_current_throw + 1
			emit_signal("update_ui_text", "Round %d - 💛 P2 - Throw %d/3 - AIM" % [current_round, throw_num])
		GameState.FLYING:
			emit_signal("update_ui_text", "✈️ Flying...")

func _on_ui_retry_game() -> void:
	for child in get_children():
		if child is RigidBody2D: child.queue_free()
	start_tournament()

func _on_ui_back_to_menu() -> void:
	get_tree().change_scene_to_file("res://MainMenu.tscn")


# Ana Menüye Dönme Butonu
func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://MainMenu.tscn")
