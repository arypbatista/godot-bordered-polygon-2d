tool
extends EditorPlugin

func _enter_tree():
    # Initialization of the plugin goes here
    # Add the new type with a name, a parent type, a script and an icon
    add_custom_type('BorderedPolygon2D', 'Polygon2D', preload('bordered_polygon_2d.gd'), preload('icon.png'))
    print('Registered BorderedPolygon2D')

func _exit_tree():
    # Clean-up of the plugin goes here
    # Always remember to remove it from the engine when deactivated
    remove_custom_type('BorderedPolygon2D')

