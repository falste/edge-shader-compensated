# edge-shader-compensated
An attempt at creating a normal- and depth-based edge detection shader for Unity3D, that compensates for falsely detected edges due to shallow viewing angles.

Because only 8 bit of depth data are available through Unity3D from the depth-normal-texture, results are not optimal.

# How to use
Add the ImageEffectScript to your camera, set the scripts Image Effect Material to the EdgeShaderMaterial.
