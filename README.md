# edge-shader-compensated
This is a normal- and depth-based edge detection shader for Unity3D, that compensates for falsely depth-wise detected edges due to shallow viewing angles.

Standard depth-based edge detection compares the depth difference between neighboring pixels and marks those pixels as edges if the difference is above a threshold. This is an issue when viewing a plane at a shallow angle. Because of the discrete nature of pixels, neighboring pixels will report different depths and will eventually exceed the detection threshold. (See examples)

These falsely detected edges are oftentimes prevented by mutliplying the depth difference with the dot product of the surface normal and the cameras forward vector, which leads to fewer detected edges when the viewing angle is shallow. This solution is imperfect and only works most of the time. The method used in this repository calculates the exact expected depth difference between neighboring pixels based on the surface normal of the surface at those pixels and factors in this expected difference when calculating edges.

With more than the 8 bit per pixel of depth data that are available through Unity3D from the combined depth-normal-texture, the results could be improved.

The project is updated for Unity3D 2020.3.30f1.

# Examples
The usual method of detecting and highlighting edges by comparing the normals and depth of each pixel with those of its neighboring pixels. As the viewing angle gets more shallow, the depth difference between pixels becomes too big and the pixels are incorrectly detected as edges:
![Usual method of edge detection by comparing normals and depth with neighboring pixels. As the viewing angle gets more shallow, the depth difference between pixels becomes too big and the pixels are incorrectly detected as edges](Media/example03.png?raw=true)

Active compensation for shallow viewing angles. As is visible at the bottom of the cable drum in the bottom left, some depth-based edges are missed due to the selected sensitivity:
![Working edge detection, which misses some depth-based edges](Media/example01.png?raw=true)

Increasing sensitiviy of the depth-based edge detection to also draw the missing edges, which creates artifacts due to the low resolution of the depth data:
![More sensitive depth-based edge-detection, which creates artifacts](Media/example02.png?raw=true)

# How to use
- Create a scene with some objects.
- Add the ImageEffectScript to your camera.
- Set the scripts Image Effect Material to the EdgeShaderMaterial.
- Try out different settings for material properties. Good starting values are NormalThreshold = 0.1 and DepthThreshold = 0.6, but they depend on your scene geometry.
