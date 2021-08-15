Rasterization With Metal
=================

1. Three Different Shading + Texture Mapping
The following results are exported from Metal debugging tool. Here's the results is in orthographic view:

shader type | image
- | -
wireframe | ![](img/wireframe_o.png)
flatshading | ![](img/flat_o.png)
per-vertex shading | ![](img/pervertex_o.png)
texture mapping | ![](img/texture_o.png)

2. Perspective View

shader type | image
- | -
wireframe | ![](img/wireframe_p.png)
flatshading | ![](img/flat_p.png)
per-vertex shading | ![](img/pervertex_p.png)
texture mapping | ![](img/texture_p.png)

3. Object Transformation
The following results are produced by screen recording tool. The actual annimation is much smoother.

shader type | image
- | -
wireframe | ![](img/wireframe.gif)
flatshading | ![](img/flat.gif)
per-vertex shading | ![](img/pervertex.gif)
texture mapping | ![](img/texture.gif)

References
-----------
[1]Using a Render Pipeline to Render Primitives. (2020). Retrieved 22 December 2020, from https://developer.apple.com/documentation/metal/using_a_render_pipeline_to_render_primitives?language=objc

[2]Creating and Sampling Textures. (2020). Retrieved 22 December 2020, from https://developer.apple.com/documentation/metal/creating_and_sampling_textures

