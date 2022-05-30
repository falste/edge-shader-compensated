# edge-shader-compensated
This is a normal- and depth-based edge detection shader for Unity3D, that compensates for falsely depth-wise detected edges due to shallow viewing angles.

With more than the 8 bit per pixel of depth data that are available through Unity3D from the combined depth-normal-texture, the results could be improved.

The project is updated for Unity3D 2020.3.30f1.

# Examples
The usual method of detecting and highlighting edges by comparing the normals and depth of each pixel with those of its neighboring pixels. As the viewing angle gets more shallow, the depth difference between pixels becomes too big and the pixels are incorrectly detected as edges:
![Usual method of edge detection by comparing normals and depth with neighboring pixels. As the viewing angle gets more shallow, the depth difference between pixels becomes too big and the pixels are incorrectly detected as edges](exampleimages/example03.png?raw=true)

Active compensation for shallow viewing angles. As is visible at the bottom of the cable drum in the bottom left, some depth-based edges are missed due to the selected sensitivity:
![Working edge detection, which misses some depth-based edges](exampleimages/example01.png?raw=true)

Increased sensitivity for the depth-based edge detection, which creates artifacts due to the low resolution of the depth data:
![More sensitive depth-based edge-detection, which creates artifacts](exampleimages/example02.png?raw=true)

# How to use
- Create a scene with some objects.
- Add the ImageEffectScript to your camera.
- Set the scripts Image Effect Material to the EdgeShaderMaterial.
- Try out different settings for material properties. Good starting values are NormalThreshold = 0.1 and DepthThreshold = 0.6, but they depend on your scene geometry.
