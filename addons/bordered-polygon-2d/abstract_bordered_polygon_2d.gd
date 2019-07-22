extends Polygon2D

#
# AbstractBorderedPolygon2D
#
# Holds the API and exported options.
#

export(int) var border_size = 50 setget set_border_size
export(int) var border_overlap = 25 setget set_border_overlap
export(Color) var border_color = Color(0, 0, 0)

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
export (ShaderMaterial) var border_material = null setget set_border_material
export (Vector2) var border_texture_scale = Vector2(1,1) setget set_border_texture_scale
export (Vector2) var border_texture_offset = Vector2(0,0) setget set_border_texture_offset
export (float) var border_texture_rotation = 0.0 setget set_border_texture_rotation
export (float, 0.0, 1.0, 0.1) var smooth_level = 0.0 setget set_smooth_level
export (int, 0, 179) var smooth_max_angle = 90 setget set_smooth_max_angle


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

func set_border_material(value):
	border_material = value
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

func set_smooth_max_angle(value):
	smooth_max_angle = value
	update()

func set_polygon(polygon):
	.set_polygon(polygon)
	create_inner_polygon()
	update()

func create_inner_polygon():
	# Subclass Responsibility
	pass

