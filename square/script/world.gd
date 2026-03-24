extends Node2D
class_name WorldManager

var chunks: Array[Chunk]
@export_category("World size")
@export var wsize: Vector2 = Vector2(8, 8)
@export var chunk_size: Vector2


func _ready() -> void:
	var noise := FastNoiseLite.new()
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	_generate_start(noise)


func _generate_start(noise: FastNoiseLite) -> void:
	var noise_offset: Vector2 = Vector2(0, 0)
	var xoff: int = 0
	var yoff: int = 0
	for x in range(0, wsize.x):
		xoff += 1
		for y in range(0, wsize.y):
			yoff += 1
			var chunk := Chunk.new()
			chunk._generate_chunk(noise, noise_offset)
			noise_offset += chunk.size
			chunk.position = Vector2(chunk_size.x * xoff, chunk_size.y * yoff)
			add_child(chunk)
		yoff = 0
