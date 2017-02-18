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
export (TileSet) var border_textures setget set_border_textures
# Border textures will be rotated clock wise to the left
export (int) var border_clockwise_shift = 0 setget set_border_clockwise_shift

export (Texture) var border_texture setget set_border_texture
export (Vector2) var border_texture_scale = Vector2(1,1) setget set_border_texture_scale
export (Vector2) var border_texture_offset = Vector2(0,0) setget set_border_texture_offset
export (float) var border_texture_rotation = 0.0 setget set_border_texture_rotation
export (float, 0.0, 1.0, 0.1) var smooth_level = 0.0 setget set_smooth_level

const QUAD_TOP_1    = 1
const QUAD_TOP_2    = 0
const QUAD_BOTTOM_1 = 3
const QUAD_BOTTOM_2 = 2

var innerBorder = []


onready var _is_ready = true

var borders = []

func tileset_size(tileset):
	return tileset.get_tiles_ids().size()

func update():
	if _is_ready:
		update_borders()

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
	print('Set smooth level to ', value)
	update()

func get_max_angle_smooth():
	return PI/2 * (1.0 - smooth_level)
	
func smooth_shape_points(shape_points, max_degree):	
	max_degree = abs(max_degree)
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
			var angle = rad2deg(abs(subtract_a_b.angle_to(subtract_c_b)))
			
			if angle > max_degree:
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
	var flip = 1
	for i in range(2):# need this
		var points_count = shape_points.size()
		var expand_or_contract_amount = 0.0

		var last_cross_facing = null
		var output_points = []
		for i in range(points_count):
			var a = shape_points[(i + points_count - 1) % points_count]
			var b = shape_points[i]# point being tested
			var c = shape_points[(i + 1) % points_count]

			# get the cross_2d
			var subtractA_B = (b - a).normalized()
			var subtractC_B = (c - b).normalized()
			var cross_2d = subtractA_B.x * subtractC_B.y - subtractA_B.y * subtractC_B.x 
			
			var dot_facing
			if cross_2d < 0:
				dot_facing = 0
			else:
				dot_facing = 1

			# if the cross_2d direction changes flip the direction of the add vector
			if i != 0 and last_cross_facing != dot_facing:
				flip = flip * -1
			last_cross_facing = dot_facing
			
			var vectorBetween
			var newVector
			if cross_2d == 0 : # if points in a straight line
				newVector = (b - a).normalized().rotated(PI/4) * flip * amount  + b
				output_points.append(newVector)
			else:
				vectorBetween = ((b - a).normalized() + (b - c).normalized()).normalized()
				newVector = vectorBetween * flip * amount  + b
				newVector = newVector + offset.rotated(newVector.angle())
				output_points.append(newVector)
				
		# check if the first flip was right (if it was not do it over again)
		var sides_length_original_points = 0.0
		for i in range(shape_points.size()):
			sides_length_original_points += shape_points[i].distance_to(shape_points[(i + 1) % points_count])

		var sides_length_output_points = 0.0
		for i in range(output_points.size()):
			sides_length_output_points += output_points[i].distance_to(output_points[(i + 1) % points_count])

		# if the shape is wrong size then flip was wrong (do it over)
		if sides_length_original_points > sides_length_output_points and  amount > 0: # if expanding
			flip = -1
			continue
		elif sides_length_original_points < sides_length_output_points and  amount < 0: # if contracting
			flip = -1
			continue
			
		return output_points

func add_border(border):
	add_child(border)
	borders.append(border)

func remove_borders():
	for c in borders:
		remove_child(c)
	borders = []

func possitive_angle(angle):
	if angle < 0:
		return PI*2 + angle
	else:
		return angle

func quad_angle(quad):
	# Vector Top1 <-- Top2
	var vtop = (quad[QUAD_TOP_1] - quad[QUAD_TOP_2])
	# Clockwise Perpendicular vector
	# This is the angle for the segment, the face angle
	var vperpendicular = Vector2(vtop.y, vtop.x * -1)
	# Make angle clockwise
	var angle = PI*2 - vperpendicular.angle()
	return possitive_angle(angle)

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

func set_tileset_texture(border, tileset):
	var angle = quad_angle(border.get_polygon())
	var texture_idx = texture_idx_from_angle(tileset, angle)
	var texture = tileset.tile_get_texture(texture_idx)
	texture.set_flags(texture.get_flags() | Texture.FLAG_REPEAT)
	border.set_texture(texture)

func invert_scale(scale):
	return Vector2(1/scale.x, 1/scale.y)

func create_border(width, height, quad, offset=Vector2(0,0)):
	var border = Polygon2D.new()
	border.set_uv( [ Vector2(width, 0), Vector2(0, 0), Vector2(0, height), Vector2(width, height)])
	border.set_polygon(quad)
	border.set_texture_offset(offset)
	if border_textures != null and tileset_size(border_textures) >= 1:
		set_tileset_texture(border, border_textures)
	else:
		border.set_texture(border_texture)
	border.set_texture_rotation(deg2rad(border_texture_rotation) + PI)
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

func make_border(border_size):
	var border_offset = Vector2(0, border_overlap * -1)
	var shape_points =	get_polygon()
	shape_points = smooth_shape_points(shape_points, rad2deg(get_max_angle_smooth()))
	innerBorder = shape_points
	if is_shape(shape_points):
		var border_points = calculate_border_points(shape_points, border_size, border_overlap)
		# Remove old borders
		remove_borders()
		# Turn points to quads
		var lastborder_texture_offset = 0
		var border_points_count = border_points.size()
		var image_width = 0
		if border_textures != null and tileset_size(border_textures) >= 1:
			image_width = border_textures.tile_get_texture(0).get_size().x
		elif border_texture != null:
			image_width = border_texture.get_size().x
		for i in range(border_points_count/2 - 1):
			var quad = calculate_quad(i, border_points, border_points_count)
			var width = quad[0].distance_to(quad[1])
			var current_offset = lastborder_texture_offset
			var border = create_border(width, border_size, quad, Vector2(current_offset + border_texture_offset.x, border_texture_offset.y))
			lastborder_texture_offset = image_width - (width - current_offset)
			add_border(border)

func update_borders():
	make_border(border_size)

func _ready():
	update()
	if get_tree().is_editor_hint() == false:
		set_polygon(innerBorder)
