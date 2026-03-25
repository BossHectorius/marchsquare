extends Node2D
class_name Chunk

@export var size: Vector2 = Vector2(16, 16)
@export var res: Vector2 = Vector2(16, 16)

var first_row: Array
var right_neigh: Chunk
var down_neigh: Chunk
var diag_neigh: Chunk
var points: Array[Array]
var last_row: Array


func _generate_chunk(noise: FastNoiseLite, noise_offset: Vector2 = Vector2(0, 0),) -> void:
	for x in size.x:
		points.append([])
		for y in size.y:
			var value := noise.get_noise_2d(x + noise_offset.x, y + noise_offset.y)
			value = smoothstep(0, 0, value)
			points[x].append(Vector4(x * res.x, y * res.y, value, 0))
			if x==0:
				first_row.append(Vector4(x * res.x, y * res.y, value, 0))
			elif x == size.x:
				last_row.append(Vector4(x * res.x, y * res.y, value, 0))
	draw.emit()

class Cell:
	var value := 0
	var edges: Dictionary = {
		"a" : null,
		"b" : null,
		"c" : null,
		"d" : null
	}
	
	func _init(a: Vector4, b: Vector4, c: Vector4, d: Vector4) -> void:
		self.edges["a"] = a
		self.edges["b"] = b
		self.edges["c"] = c
		self.edges["d"] = d

func _generate_shape() -> void:
	#if right_neigh:
		#points.append(right_neigh.first_row)
	#if down_neigh:
		#for X in range(0, down_neigh.points.size()):
			#points[X].append(down_neigh.points[X][down_neigh.points[X].size() - 1])
	#if diag_neigh:
		#points[points.bsearch(points.back())].append(diag_neigh.points.front().front())
	for x in range(points.size() - 1):
		for y in range(points[x].size() - 1):
			var a: Vector4 = points[x][y]
			var b: Vector4 = points[x + 1][y]
			var c: Vector4 = points[x + 1][y + 1]
			var d: Vector4 = points[x][y + 1]
			triangulate(Cell.new(a, b, c, d))
	if right_neigh:
		triangulate_gap_column(right_neigh.first_row)

func triangulate_gap_row(row: Array) -> void:
	pass
func triangulate_gap_column(column: Array) -> void:
	for y in range(0, len(column) - 1):
		#TODO: fix the positions. The first row from the adyacent chunk is in that chunk's local position, which gives a ton of errors.
		#So, turn it into global position and then into this chunk's local position
		var a: Vector4 = last_row[y]
		var b: Vector4 = column[y]
		var c: Vector4 = column[y + 1]
		var d: Vector4 = last_row[y + 1]
		b.x += res.x
		c.x += res.x
		print("this cell is at %s %s %s %s" % [a, b, c, d])
		triangulate(Cell.new(a, b, c, d))

func _to_base10(a: int, b: int, c: int, d: int) -> int:
	return a * 8 + b * 4 + c * 2 + d * 1

func triangulate(cell: Cell) -> void:
	var a: Vector4 = cell.edges.get("a")
	var b: Vector4 = cell.edges.get("b")
	var c: Vector4 = cell.edges.get("c")
	var d: Vector4 = cell.edges.get("d")
	var ahat := Vector2(a.x, a.y)
	var bhat := Vector2(b.x, b.y)
	var chat := Vector2(c.x, c.y)
	var dhat := Vector2(d.x, d.y)
	@warning_ignore("narrowing_conversion")
	var total := _to_base10(a.z, b.z, c.z, d.z)
	var A: Vector2 = Vector2(a.x + res.x * 0.5, a.y)
	var B: Vector2 = Vector2(b.x, b.y + res.y * 0.5)
	var C: Vector2 = Vector2(c.x - res.x * 0.5, c.y)
	var D: Vector2 = Vector2(d.x, d.y - res.y * 0.5)
	cell.value = total
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
