extends Node2D
class_name WorldManager

var chunks: Array[Array]
@export_category("World size")
@export var wsize: Vector2 = Vector2(16, 16)
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
		chunks.append([])
		for y in range(0, wsize.y):
			chunks[x].append([])
			yoff += 1
			var chunk := Chunk.new()
			chunk._generate_chunk(noise, noise_offset)
			noise_offset += chunk.size
			chunk.position = Vector2(chunk_size.x * xoff, chunk_size.y * yoff)
			add_child(chunk)
			chunks[x][y] = chunk
			chunk._generate_shape(chunk.points)
			
		yoff = 0
	xoff = 0
	#for c in chunks:
		#for chunk in c:
			#if chunk is Chunk:
				#var cright = chunks[xoff + 1][yoff] as Chunk
				#var cdown = chunks[xoff][yoff + 1] as Chunk
				#var cdig = chunks[xoff + 1][yoff + 1] as Chunk
				#var crightp: Array = cright.points[0]
				#chunk.points.append(crightp)
				#for x in cdown.points:
					#if x is Array:
						#print(" length of row %s is %s and its value is %s" % [xoff, len(x), x[len(x) - 1]])
						#chunk.points[xoff].append(x[len(x) - 1])
						#xoff += 1
				#var clen := len(cdig.points)
				#chunk.points[8].append(cdig.points[clen - 1][clen - 1])
				#xoff = 0
