# FuelItem.gd
extends Area2D

signal fuel_collected

func _ready():
	# Uçak (RigidBody2D) alana girdiğinde tetiklenecek
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	# Eğer çarpan obje bir RigidBody2D ise (yani bizim uçaksa)
	if body is RigidBody2D: 
		emit_signal("fuel_collected")
		queue_free() # Bidonu sahneden sil
