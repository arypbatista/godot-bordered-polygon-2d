extends Polygon2D

#
# AbstractBorderedPolygon2D
#
# Holds the API and exported options.
#

@export var border_size: int = 50:
	set = set_border_size
	
@export var border_overlap: int = 25:
	set = set_border_overlap
	
@export var border_color: Color = Color(0,0,0)

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
@export var border_textures: TileSet  = null:
	set = set_border_textures
# Border textures will be rotated clock wise to the left
@export var border_clockwise_shift: int = 0:
	set = set_border_clockwise_shift
@export var border_texture: Texture = null:
	set = set_border_texture
@export var border_material: ShaderMaterial = null:
	set = set_border_material
@export var border_texture_scale: Vector2 = Vector2.ONE:
	set = set_border_texture_scale
@export var border_texture_offset: Vector2 = Vector2.ZERO:
	set = set_border_texture_offset
@export var border_texture_rotation: float = 0.0:
	set = set_border_texture_rotation
@export_range(0.0, 1.0, 0.1) var smooth_level: float = 0.0:
	set = set_smooth_level
@export_range(0, 179) var smooth_max_angle: int = 90:
	set = set_smooth_max_angle

func set_border_size(value):
	border_size = value
	queue_redraw()

func set_border_overlap(value):
	border_overlap = value
	queue_redraw()

func set_border_texture_offset(value):
	border_texture_offset = value
	queue_redraw()

func set_border_texture_scale(value):
	border_texture_scale = value
	queue_redraw()

func set_border_texture_rotation(value):
	border_texture_rotation = value
	queue_redraw()

func set_border_material(value):
	border_material = value
	queue_redraw()

func set_border_texture(value):
	border_texture = value
	queue_redraw()

func set_border_textures(value):
	border_textures = value
	queue_redraw()

func set_border_clockwise_shift(value):
	border_clockwise_shift = value
	queue_redraw()

func set_smooth_level(value):
	smooth_level = value
	queue_redraw()

func set_smooth_max_angle(value):
	smooth_max_angle = value
	queue_redraw()

func set_polygon(polygon):
	super.set_polygon(polygon)
	create_inner_polygon()
	queue_redraw()

func create_inner_polygon():
	# Subclass Responsibility
	pass

