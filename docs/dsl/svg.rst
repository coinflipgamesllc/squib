svg
===

Renders an entire svg file at the given location. Uses the SVG-specified units and DPI to determine the pixel width and height.  If neither data nor file are specified for a given card, this method does nothing.

.. note::

  Note: if alpha transparency is desired, set that in the SVG.


Options
-------
.. include:: /args/expansion.rst

file
  default: ``''`` (empty string)

  file(s) to read in. As in :doc:`/arrays`, if this a single file, then it's use for every card in range. If the parameter is an Array of files, then each file is looked up for each card. If any of them are nil or '', nothing is done for that card.

  By default, if ``file`` is not found, a warning is logged. This behavior can be configured in :doc:`/config`

.. include:: /args/xy.rst

data
  default: ``nil``

  render from an SVG XML string. Overrides ``file`` if both are specified (a warning is shown).

id
  default: ``nil``

  if set, then only render the SVG element with the given id. Prefix '#' is optional. Note: the x-y coordinates are still relative to the SVG document's page.

force_id
  default: ``false``

  if set to ``true``, then this svg will not be rendered at all if the id is empty or nil. If not set, the entire SVG is rendered. Useful for putting multiple icons in a single SVG file.

width
  default: ``native``

  the pixel width that the image should scale to. Setting this to ``:deck`` will scale to the deck height. ``:scale`` will use the width to scale and keep native the aspect ratio. SVG scaling is done with vectors, so the scaling should be smooth. When set to ``:native``, uses the DPI and units of the loaded SVG document. Supports :doc:`/units` and :doc:`/shorthands`.

height
  default: ``:native``

  the pixel width that the image should scale to. ``:deck`` will scale to the deck height. ``:scale`` will use the width to scale and keep native the aspect ratio. SVG scaling is done with vectors, so the scaling should be smooth. When set to ``:native``, uses the DPI and units of the loaded SVG document. Supports :doc:`/units` and :doc:`/shorthands`.

blend
  default: ``:none``

  the composite blend operator used when applying this image. See Blend Modes at http://cairographics.org/operators.
  The possibilties include ``:none``, ``:multiply``, ``:screen``, ``:overlay``, ``:darken``, ``:lighten``, ``:color_dodge``, ``:color_burn``, ``:hard_light``, ``:soft_light``, ``:difference``, ``:exclusion``, ``:hsl_hue``, ``:hsl_saturation``, ``:hsl_color``, ``:hsl_luminosity``. String versions of these options are accepted too.


angle
  default: ``0``

  rotation of the image in radians. Note that this rotates around the upper-left corner, making the placement of x-y coordinates slightly tricky.

mask
  default: ``nil``

  if specified, the image will be used as a mask for the given color/gradient. Transparent pixels are ignored, opaque pixels are the given color. Note: the origin for gradient coordinates is at the given x,y, not at 0,0 as it is most other places.

.. warning::

    For implementation reasons, your vector image will be rasterized when mask is applied. If you use this with, say, PDF, the images will be embedded as rasters, not vectors.

placeholder
  default: ``nil``

  if ``file`` does not exist, but the file pointed to by this string does, then draw this image instead.

  No warning is thrown when a placeholder is used.

  If this is non-nil, but the placeholder file does not exist, then a warning is thrown and no image is drawn.

  Examples of how to use placeholders are below.

crop_x
  default: ``0``

  crop the loaded image at this x coordinate. Supports :doc:`/units`

crop_y
  default: ``0``

  crop the loaded image at this y coordinate. Supports :doc:`/units`

crop_corner_radius
  default: ``0``

  Radius for rounded corners, both x and y. When set, overrides crop_corner_x_radius and crop_corner_y_radius. Supports :doc:`/units`

crop_corner_x_radius
  default: ``0``

  x radius for rounded corners of cropped image. Supports :doc:`/units`

crop_corner_y_radius
  default: ``0``

  y radius for rounded corners of cropped image. Supports :doc:`/units`

crop_width
  default: ``0``

  width of the cropped image. Supports :doc:`/units`

crop_height
  default: ``0``

  ive): Height of the cropped image. Supports :doc:`/units`

flip_horizontal
  default: ``false``

  Flip this image about its center horizontally (i.e. left becomes right and vice versa).

flip_vertical
  default: ``false``

  Flip this image about its center verticall (i.e. top becomes bottom and vice versa).

.. include:: /args/range.rst
.. include:: /args/layout.rst


Examples
--------

These examples live here: https://github.com/andymeneely/squib/tree/dev/samples/images

.. literalinclude:: ../../samples/images/_images.rb
  :linenos:

.. raw:: html

  <img src="../images/_images_00_expected.png" width=600 class="figure">

.. literalinclude:: ../../samples/images/_placeholders.rb
  :linenos:

First placeholder expected output.

.. raw:: html

  <img src="../images/placeholder_sheet_00_expected.png" width=100 class="figure">

Second placeholder expected output.

.. raw:: html

  <img src="../images/multi_placeholder_sheet_00_expected.png" width=100 class="figure">