extends Spatial
# A Space represents a single area of work for all visual elements, spawned
# through the config.

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export (int) var width = 3
# A gridshape of allowed placement types.
export var placement = [
	1, 0, 1,
	1, 1, 1,
	1, 0, 1,
]

# Set the mutliply step for each placement. Applying -1 steps the z _backward_
# To place each respective to the _placement_ location.
# e.g, with backstep -1, a text char will print correctly:
# s = [
#	0,1,1,1,0
#	0,1,0,0,0
#	0,1,1,1,0
#	0,0,0,1,0
#	0,1,1,1,0
#]
export var backstep = -1
# The width in _godot units_ of a single cell when placed.
# Considering a standard scale is `1`, the base mesh (cube)
# has a base size of 2 _world units_. This seems to be counted in floor grid spacing
export var cell_width = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	gen_space(width, placement)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.is_pressed():

		var _placement = []
		for i in placement.size():
			var place =  (sin(i % 5))
			place = int(rand_range(0,2))
			#place = 1
			#print(place)
			_placement.append(place)
		gen_space(width, _placement)


static func delete_children(node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()


func gen_space(width, places):
	# tuple(math.ceil((x+1)/5)-1 for x in range(len(p)))
	# tuple(x % w for x in r)
	delete_children(self)
	var size = places.size()
	var space_offset = width #0#(width * cell_width) / 2 - (width * cell_width*.5) / 2
	var height = float(size) / width

	var points = make_floor(places, size, width, height)
	var walls = make_walls(points, places, size, width, height)
	for wall in walls:
		add_child(wall.wall)

var active_mat = preload("res://green_mat.tres")
var red_mat = preload("res://red_mat.tres")

func make_floor(places, size, width, height):
	var points = []

	for i in range(size):
		var x = ceil( (i+1)/float(width) ) - 1
		var z = i % width
		var v = Vector2(
			(x*cell_width + (cell_width*.5))  - width,
			(z*cell_width + (cell_width*.5))  - height)
		if places[i] == null:
			continue
		var item = make_grid_item(places[i], i,
			v.x, v.y
		)
		if i == 0 and item != null:
			item.get_node('On').material_override = active_mat
		points.append({'item':item, 'v':v})
	return points

const OnObj = preload("res://On.tscn")

func make_walls(points, places, size, width, height):

	var all_walls = []

	for i in range(0, points.size()):
		var row = ceil( (i+1)/float(width) ) - 1
		var col = (i % width)
		var point = points[i]
		var place = places[i]
		var walls = []

		if place < .5:
			# not a cell to draw boundaries.
			continue

		# print(Vector3(row, col, i), ' ', point, ' ', place)
		# Now check each side for a sibling

		var above = (row-1) * width + col
		var below = (row+1) * width + col
		var left = (row) * width + col - 1
		var right = (row) * width + col + 1

		if (above < points.size() and (places[above] < .5 or (above < 0))):
			# check the cell is within the grid, then if the grid content is drawable,
			#   or if there is no above cell.
			walls.append(wall_info(point, row, col, Vector2(-1, 0)))

		if  below >= points.size() or (below <= places.size() and places[below] < .5):
			# below is nothing
			walls.append(wall_info(point, row, col, Vector2(1, 0), 3.14))

		if left < 0 or col == 0 or places[left] < .5:
			walls.append(wall_info(point, row, col, Vector2(0, 1), 3.14*.5))

		if right >= places.size() or points[right].v.x != point.v.x or places[right] < .5:
			walls.append(wall_info(point, row, col, Vector2(0, -1), 3.14*-.5))

		if walls.size() == 4:
			print('Ophsm')
			point.item.get_node('On').material_override = red_mat

		all_walls += walls

	return all_walls

func wall_info(current, row, col, offset, y_rot=0):

	var res = {
		'x': current.v.x + offset.x,
		'z': -current.v.y + offset.y,
		'rotation': y_rot,
		'wall': add_wall(current, row, col, offset, y_rot)
		}
	return res

func add_wall(current, row, col, direction, y_rot=0):
	var wall = Wall.instance()
	wall.translation.x = current.v.x + direction.x
	wall.translation.z = -current.v.y + direction.y
	wall.rotation.y = y_rot
	#add_child(wall)
	return wall

func make_grid_item(value, _index, x, z):
	#print('value ', value, 'index ', index)
	# print('x ', x, ' z ', z)
	if value < .5:
		return

	var inst = OnObj.instance()
	inst.translation = Vector3(x, 0, z*backstep)
	add_child(inst)
	return inst

const Wall = preload("res://Wall.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var el = get_node('/root/World/Space')
	el.rotation_degrees.y += 0.1
	#print(el)
#	pass
