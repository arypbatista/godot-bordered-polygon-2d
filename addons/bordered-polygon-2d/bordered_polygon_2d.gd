tool
# Original code by Jonathan T. Arnold
# Modifications by Ary Pablo Batista

#!!!!!!!! to make borders work you must turn on repeat on textures

extends Polygon2D
export(int) var border_size = 50 setget set_border_size
export(int) var border_overlap = 25 setget set_border_overlap

# You can set a tileset with border textures.
# Tileset must have 2^n sprites. Sprites textures will be used
# as borders. You must order the sprites in the tileset clockwise so
# first tile will be the upper border.
#
# How will this work? Few examples:
# - Tileset with 1 sprite will use same border everywhere
# - Tileset with 2 sprite will use one sprite for top/left borders
#   and a different one for right/bottom borders
# - Tilesets with 4 sprites will use different sprites for
#   top/left/bottom/right borders but diagonal will use the nearest.
# - Tileset with 8 sprtes will apply 8 different borders to 8 different
#   directions.
# - Tilesets with 16 sprites will be really smooth.
# - etcetera...
export (TileSet) var border_textures = null setget set_border_textures
# Border textures will be rotated clock wise to the left
export (int) var border_clockwise_shift = 0 setget set_border_clockwise_shift

export (Texture) var border_texture = null setget set_border_texture
export (Vector2) var border_texture_scale = Vector2(1,1) setget set_border_texture_scale
export (Vector2) var border_texture_offset = Vector2(0,0) setget set_border_texture_offset
export (float) var border_texture_rotation = 0.0 setget set_border_texture_rotation
export (float, 0.0, 1.0, 0.1) var smooth_level = 0.0 setget set_smooth_level

const QUAD_TOP_1    = 1
const QUAD_TOP_2    = 0
const QUAD_BOTTOM_1 = 3
const QUAD_BOTTOM_2 = 2

var inner_border = []

var clockwise = null


onready var _is_ready = true

var borders = []

func tileset_size(tileset):
	return tileset.get_tiles_ids().size()

func update():
	if _is_ready:
		update_borders()

func invalidate():
	clockwise = null

func cross_product_z(a, b):
	# Cross product:
	#         | a1.b3 - a3.b2 |
	# a x b = | a3.b1 - a1.b3 |
	#         | a1.b2 - a2.b1 |
	#
	# We will take only third component
	# that will help us understand the
	# orientation of the shape
	return a.x * b.y - a.y * b.x

func is_clockwise_shape(shape):
	if shape.size() >= 3:
		var v0_to_1 = shape[1] - shape[0]
		var v0_to_2 = shape[2] - shape[0]
		var res = cross_product_z(v0_to_1, v0_to_2)
		return res < 0
	else:
		return false

func is_clockwise():
	if clockwise == null:
		clockwise = is_clockwise_shape(get_polygon())
	return clockwise

func set_polygon(polygon):
	.set_polygon(polygon)
	update()

func set_border_size(value):
	border_size = value
	update()

func set_border_overlap(value):
	border_overlap = value
	update()

func set_border_texture_offset(value):
	border_texture_offset = value
	update()

func set_border_texture_scale(value):
	border_texture_scale = value
	update()

func set_border_texture_rotation(value):
	border_texture_rotation = value
	update()

func set_border_texture(value):
	border_texture = value
	update()

func set_border_textures(value):
	border_textures = value
	update()

func set_border_clockwise_shift(value):
	border_clockwise_shift = value
	update()
	
func set_smooth_level(value):
	smooth_level = value
	update()

func get_max_angle_smooth():
	return PI/2 * (1.0 - smooth_level)
	
func smooth_shape_points(shape_points, max_radian):	
	max_radian = abs(max_radian)
	if max_radian < .25:
		max_radian = .25
		
	for i in range(5): # max passes 
		var point_to_smooth = []
		var angles_smoothed_this_round = 0
		var current_shape_size = shape_points.size()
		
		for i in range(shape_points.size()):
			var a = shape_points[(i + current_shape_size - 1) % current_shape_size]
			var b = shape_points[i]
			var c = shape_points[(i + 1) % current_shape_size]
			
			var subtract_a_b = (b - a).normalized()
			var subtract_c_b = (c - b).normalized()
			var radian = abs(subtract_a_b.angle_to(subtract_c_b))
			
			if radian > max_radian:
				var smoothed_points = smooth_three_points(a, b, c)
				point_to_smooth.append([i, smoothed_points])
				
		var num_added_points = 0
		for point_info in point_to_smooth:
			shape_points.remove(point_info[0] + num_added_points)
			shape_points.insert(point_info[0] + num_added_points, point_info[1][2])
			shape_points.insert(point_info[0] + num_added_points, point_info[1][1])
			angles_smoothed_this_round += 1
			num_added_points += 1

		if angles_smoothed_this_round != 0 and shape_points.size() > 3:
			continue
		break
	
	return shape_points
	
func smooth_three_points(point_a, point_b, point_c):
	var a_b_length = point_a.distance_to(point_b)
	var c_b_length = point_c.distance_to(point_b)

	var split_b_point_1 = point_b + (point_a - point_b).normalized() * (a_b_length/4)
	var split_b_point_2 = point_b + (point_c - point_b).normalized() * (c_b_length/4) 
	
	var output_points = []
	output_points.append(point_a)
	output_points.append(split_b_point_1)
	output_points.append(split_b_point_2)
	output_points.append(point_c)
	
	return output_points

func expand_or_contract_shape_points(shape_points, amount, offset=Vector2(0,0)):
	var points_count = shape_points.size()
	var expand_or_contract_amount = 0.0

	var output_points = []
	for i in range(points_count):
		var a = shape_points[(i + points_count - 1) % points_count]
		var b = shape_points[i]
		var c = shape_points[(i + 1) % points_count]

		# get normals
		var subtractA_B = (b - a).normalized()
		var subtractC_B = (c - b).normalized()

		var a_forty_5 = Vector2(subtractA_B.y, -subtractA_B.x)
		var c_forty_5 = Vector2(subtractC_B.y, -subtractC_B.x)

		var vectorBetween
		var newVector

		newVector = (a_forty_5 + c_forty_5).normalized() * 1 * amount  + b

		output_points.append(newVector)

	return output_points

func add_border(border):
	add_child(border)
	borders.append(border)

func remove_borders():
	for border in borders:
		border.queue_free()
	borders = []

func possitive_angle(angle):
	if angle < 0:
		return PI*2 + angle
	else:
		return angle

func quad_angle(quad):
	# Vector for top quad segment
	var v = quad[QUAD_TOP_1] - quad[QUAD_TOP_2]
	
	# Perpendicular vector to the segment vector
	# This is the angle for the segment, the face angle
	var vp = Vector2(v.y, v.x * -1)
	
	# Make angle clockwise
	var angle = possitive_angle(PI*2 - vp.angle())
	return angle

func _360_partition(partition_count):
	return PI*2/partition_count

func partition_id(angle, partition_size):
	return int(rad2deg(angle) / rad2deg(partition_size))

func texture_idx_from_angle(tileset, angle):
	var texture_count = tileset_size(tileset)
	var partition_size = _360_partition(texture_count)
	var angle_offset = -partition_size/2
	var idx = partition_id(angle + angle_offset, partition_size) % texture_count
	idx = (idx + 1 - border_clockwise_shift) % texture_count
	if idx < 0: # Possitive indexes only
		idx = texture_count + idx
	return idx

func has_border_textures():
	return has_single_border_texture() or has_tileset_border_textures()

func has_single_border_texture():
	return border_texture != null

func has_tileset_border_textures():
	return border_textures != null and tileset_size(border_textures) >= 1

func get_border_texture_for_angle(angle):
	var texture = null
	if has_tileset_border_textures():
		var texture_idx = texture_idx_from_angle(border_textures, angle)
		texture = get_border_texture(texture_idx)
	else:
		texture = border_texture
	return texture

func invert_scale(scale):
	return Vector2(1/scale.x, 1/scale.y)

func create_border(width, height, quad, offset=Vector2(0,0)):
	var border = Polygon2D.new()
	var border_angle = quad_angle(quad)
	border.set_uv( [ Vector2(width, 0), Vector2(0, 0), Vector2(0, height), Vector2(width, height)])
	border.set_polygon(quad)
	border.set_texture_offset(offset)
	
	var tex = get_border_texture_for_angle(border_angle)
	tex.set_flags(tex.get_flags() | Texture.FLAG_REPEAT)
	border.set_texture(tex)
	
	var texture_rotation = deg2rad(border_texture_rotation) + PI
	border.set_texture_rotation(texture_rotation)
	border.set_texture_scale(invert_scale(border_texture_scale))
	return border

func calculate_quad(index, points, border_points_count):
	# Quad order: [topRight, topLeft, bottomLeft, bottomRight]
	var quad = [
		points[(index + 1) % border_points_count],
		points[index % border_points_count],
		points[(index + border_points_count/2) % border_points_count],
		points[(index + border_points_count/2 + 1) % border_points_count]
	]
		
	# If quad twisted
	var intersect_point = Geometry.segment_intersects_segment_2d(quad[0], quad[3], quad[1], quad[2])
	if intersect_point != null:
		quad = [quad[1], quad[0], quad[2], quad[3]]
	
	return quad

func is_shape(shape_points):
	return shape_points.size() >= 3

func calculate_border_points(shape_points, border_size, border_overlap=0):
	var border_inner_points = expand_or_contract_shape_points(shape_points, - border_overlap)
	var border_outer_points = expand_or_contract_shape_points(border_inner_points, border_size - border_overlap)

	border_inner_points = bytes2var(var2bytes(border_inner_points))
	# close outer shape
	border_inner_points.append(border_inner_points[0] + Vector2(0.0001, 0))
	for i in range(border_outer_points.size()):
		border_inner_points.append(border_outer_points[i])
	# close inner inner shape
	border_inner_points.append(border_outer_points[0] + Vector2(0, 0.0001))
	return border_inner_points

func get_border_texture(idx):
	if border_textures != null:
		return border_textures.tile_get_texture(idx)
	else:
		return border_texture

func get_texture_width():
	return get_border_texture(0).get_size().x

func make_border(border_size):
	var border_offset = Vector2(0, border_overlap * -1)
	var shape_points = get_polygon()
	if is_clockwise_shape(shape_points):
	if smooth_level > 0:
		shape_points = smooth_shape_points(shape_points, get_max_angle_smooth())
	inner_border = shape_points
	if is_shape(shape_points):
		var border_points = calculate_border_points(shape_points, border_size, border_overlap)
		
		# Turn points to quads
		var lastborder_texture_offset = 0
		var border_points_count = border_points.size()
		var image_width = get_texture_width()

		for i in range(border_points_count/2 - 1):
			var quad = calculate_quad(i, border_points, border_points_count)
			var width = quad[0].distance_to(quad[1])
			var current_offset = lastborder_texture_offset
			var border = create_border(width, border_size, quad, Vector2(current_offset + border_texture_offset.x, border_texture_offset.y))
			lastborder_texture_offset = image_width - (width - current_offset)
			add_border(border)

func update_borders():
	# Remove old borders
	remove_borders()
	if has_border_textures():
		make_border(border_size)

func _ready():
	update()
	if get_tree().is_editor_hint() == false:
		set_polygon(inner_border)
