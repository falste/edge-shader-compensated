# edge-shader-compensated
An attempt at creating a normal- and depth-based edge detection shader for Unity3D, that compensates for falsely depth-wise detected edges due to shallow viewing angles.

Because only 8 bit of depth data are available through Unity3D from the depth-normal-texture, results are not optimal.

The project is updated for Unity3D 2020.3.30f1.

# Examples
Usual method of edge detection by comparing normals and depth with neighboring pixels. As the viewing angle gets more shallow, the depth difference between pixels becomes too big and the pixels are incorrectly detected as edges:
![Usual method of edge detection by comparing normals and depth with neighboring pixels. As the viewing angle gets more shallow, the depth difference between pixels becomes too big and the pixels are incorrectly detected as edges](exampleimages/example03.png?raw=true)

Active compensation for shallow viewing angles, which misses some depth-based edges at the selected sensitivity, like at the bottom of the cable drum in the bottom left:
![Working edge detection, which misses some depth-based edges](exampleimages/example01.png?raw=true)

More sensitive depth-based edge-detection, which creates artifacts due to low resolution of depth data:
![More sensitive depth-based edge-detection, which creates artifacts](exampleimages/example02.png?raw=true)

# How to use
- Create a scene with some objects.
- Add the ImageEffectScript to your camera.
- Set the scripts Image Effect Material to the EdgeShaderMaterial.
- Try out different settings for material properties. Good starting values are NormalThreshold = 0.1 and DepthThreshold = 0.6, but they depend on your scene geometry.
