# Bordered Polygon2D for Godot 4

Add borders to your Polygon2Ds. Useful for creating maps using textures.

*Note: The base for Bordered Polygon2D has been updated to support Godot 4/ GDScript 2 syntax. Additional tweaks may be needed in the provided examples. This has been tested in Godot 4.0, future versions of Godot 4 may change the GDScript syntax meaning that modifcations may be needed to the .gd files in this package*

![Preview](./docs/images/preview2.png)


# Usage

## Setup

To use this addon in an existing godot project, download this repo as a zip and extract it.

Copy the `addon` folder and paste it inside your [Godot project folder](https://docs.godotengine.org/en/stable/tutorials/plugins/editor/installing_plugins.html#installing-a-plugin).

Finally, go to `project settings > Plugins` and click `enable` under the Bordered Polygon2D plugin. For more information see [Godot's documentation](Bordered Polygon2D).

Once the plugin has been enabled, you can create a bordered polygon either in the scene editor or programmatically. 


## Creating a bordered polygon via the scene editor

Create a `BorderedPolygon2D` node in your scene.

![Usage 1](./docs/images/usage1.png)

Attach either a single border texture or a TileSet with several border texures.
You might need to use options to proper align/rotate/scale texture.

![Usage 2](./docs/images/usage2.png)

Draw your polygon and voilà!

![Usage 3](./docs/images/usage3.png)

## Creating a bordered polygon programmatically

To create a bordered polygon programmatically (i.e. in your code), you can use add the following lines of code:
```
var bp = BorderedPolygon.new()
bp.prepare()
bp.set_polygon(the_poly)
add_child(bp)
```

Here `the_poly` is a [PackedVector2Array](https://docs.godotengine.org/en/stable/classes/class_packedvector2array.html) that contains the pixl coordinates of the polygon. This is the same thing you would use in the `set_polygon()` method in the built-in [Polygon2D class](https://docs.godotengine.org/en/stable/classes/class_polygon2d.html#class-polygon2d-property-polygon).

## Options

There are some options available to customize BorderedPolygon2D:

- **Border Size**: The border size in pixels.
- **Border Overlap**: The border overlap in pixels. Specify how many pixels of
    the border should overlap with the inner texture. Possitive numbers will
    overlap. Negative will move the borders away from the fill texture.
- **Border Texture**: A single texture\* for all borders.
- **Border Textures**: Tileset with border textures\*. This is basically a
    collection of sprites. BorderPolygon2D will take the texture inside each
    sprite. If set, "Border Texture" option's value will be ignored. Image order
    is important here, first image should be the north border image and the next
    image should be the right border clockwise, and so on. For example, if you
    have four images, you will need to arrange them as tileset children like this:
    [0:North, 1:East, 2:South, 3:West]
- **Border Material**: A material to apply to borders. You can also include
    materials in your tileset border sprites, these materials will take
    precedence over the defined in this option.
- **Border Clockwise Shift**: Apply clockwise shift to border textures.
- **Border Texture Scale**: Apply scale to all border textures.
- **Border Texture Offset**: Apply offset to all border textures.
- **Border Texture Rotation**: Apply rotation to all border textures.
- **Smooth Level**: This option determines how smooth will be your borders. Set
    0.0 for sharp and 1.0 for smooth. The more smooth, the more border polygons
    that will be created.
- **Smooth Max Angle**: Select the max angle to smooth. Tipically, a sharp corner
    will be between 0° and 45° degrees, but you could also smooth 90° angles.
    This option allows a maximum of 179° degrees. Default value is 90° degrees.

\*All textures must have same orentation (north) and will be
automatically rotated when inserted into borders.

## Future Work

Want to know what is ahead? Visit the [features list for the next version](../../milestone/2)!
