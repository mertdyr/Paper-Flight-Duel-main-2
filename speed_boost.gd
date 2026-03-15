# speed_boost.gd
extends Area2D

# Game.gd bu sinyali dinliyor
signal collected(body)

func _ready():
	# Bir şey çarparsa tetiklensin
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	# Sadece uçak (RigidBody2D) çarparsa çalışsın
	if body is RigidBody2D:
		emit_signal("collected", body)
		queue_free() # Ekrandan sil
