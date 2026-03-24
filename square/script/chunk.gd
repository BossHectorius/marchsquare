extends Node2D
class_name Chunk

@export var size: Vector2 = Vector2(8, 8)
@export var res: Vector2 = Vector2(16, 16)

var points: Array[Array]= []


func _generate_chunk(noise: FastNoiseLite, noise_offset: Vector2 = Vector2(0, 0)) -> void:
	for x in size.x:
		points.append([])
		for y in size.y:
			var value := noise.get_noise_2d(x + noise_offset.x, y + noise_offset.y)
			value = smoothstep(0, 0, value)
			points[x].append([])
			points[x][y] = Vector4(x * res.x, y * res.y, value, 0)
	_generate_shape(points)
	draw.emit()

func _generate_shape(plist: Array) -> void:
	for x in range(0, size.x - 1):
		for y in range(0, size.y - 1):
			var a: Vector4 = plist[x][y]
			var b: Vector4 = plist[x + 1][y]
			var c: Vector4 = plist[x + 1][y + 1]
			var d: Vector4 = plist[x][y + 1]
			var ahat := Vector2(a.x, a.y)
			var bhat := Vector2(b.x, b.y)
			var chat := Vector2(c.x, c.y)
			var dhat := Vector2(d.x, d.y)
			var total := _to_base10(a.z, b.z, c.z, d.z)
			var A: Vector2 = Vector2(a.x + res.x * 0.5, a.y)
			var B: Vector2 = Vector2(b.x, b.y + res.y * 0.5)
			var C: Vector2 = Vector2(c.x - res.x * 0.5, c.y)
			var D: Vector2 = Vector2(d.x, d.y - res.y * 0.5)
			match total:
				0:
					pass
				1:
					_create_polygon([C, dhat, D])
				2:
					_create_polygon([C, chat, B])
				3:
					_create_polygon([D, dhat, chat, B])
				4:
					_create_polygon([A, bhat, B])
				5:
					_create_polygon([bhat, B, C, dhat, D, A])
				6:
					_create_polygon([A, bhat, chat, C])
				7:
					_create_polygon([A, bhat, chat, dhat, D])
				8:
					_create_polygon([ahat, A, D])
				9:
					_create_polygon([ahat, A, C, dhat])
				10:
					_create_polygon([ahat, A, B, chat, C, A])
				11:
					_create_polygon([ahat, A, B, chat, dhat])
				12:
					_create_polygon([ahat, bhat, B, D])
				13:
					_create_polygon([ahat, bhat, B, C, dhat])
				14:
					_create_polygon([ahat, bhat, chat, C, D])
				15:
					_create_polygon([ahat, bhat, chat, dhat])


func _to_base10(a: int, b: int, c: int, d: int) -> int:
	return a * 8 + b * 4 + c * 2 + d * 1

func _create_polygon(p: Array) -> void:
	var polygon := Polygon2D.new()
	polygon.polygon = p
	add_child(polygon)

func _draw() -> void:
	for x in size.x:
		for y in size.y:
			var posx: int = points[x][y].x
			var posy: int = points[x][y].y
			var value: int = points[x][y].z
			draw_circle(Vector2(posx, posy), 3, Color(value, value, value, 1), true)
