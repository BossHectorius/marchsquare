extends Node2D
class_name WorldManager

var chunks: Dictionary
@export_category("World size")
@export var wsize: Vector2 = Vector2(8, 8)
@export var chunk_size: Vector2 = Vector2(256, 256)

#TODO: first, I need to make this properly
#Secondly, I need to make it so that it generates chunks as the player moves along and removes the unnecesary ones.


func _ready() -> void:
	var noise := FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 0.0321
	noise.fractal_octaves = 8
	noise.seed = randi()
	_generate_start(noise)


func _generate_start(noise: FastNoiseLite) -> void:
	var noise_offset: Vector2 = Vector2(0, 0)
	var xoff: int = 0
	var yoff: int = 0
	for x in range(0, wsize.x):
		for y in range(0, wsize.y):
			var chunk := Chunk.new()
			noise_offset = Vector2(x * chunk_size.x, chunk_size.y * y)
			chunk.position = Vector2(chunk_size.x * xoff, chunk_size.y * yoff)
			chunk._generate_chunk(noise, noise_offset)
			add_child(chunk)
			chunks[Vector2(xoff, yoff)] = chunk
			yoff += 1
		yoff = 0
		xoff += 1
	xoff = 0
	for c in range(0, wsize.x):
		for y in range(0, wsize.y):
			var cright: Chunk = null
			var cdown: Chunk = null
			var cdig: Chunk = null
			if chunks.has(Vector2(c+1, y)):
				cright = chunks[Vector2(c + 1, y)] as Chunk
			if chunks.has(Vector2(c, y + 1)):
				cdown = chunks[Vector2(c, y + 1)] as Chunk
			if chunks.has(Vector2(c + 1, y + 1)):
				cdig = chunks[Vector2(c+1, y+1)]
			var chunk = chunks[Vector2(c, y)] as Chunk
			chunk.down_neigh = cdown
			chunk.right_neigh = cright
			chunk.diag_neigh = cdig
			chunk._generate_shape()
