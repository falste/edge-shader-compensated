Shader "Custom/EdgeDetectionShader"
{
    Properties
    {
        _NormalThreshold("NormalThreshold", float) = 0.1
		_DepthThreshold("DepthThreshold", float) = 0.4
        _EdgeColor("Edge color", Color) = (0,0,0,1)

		[HideInInspector] _MainTex("Texture", 2D) = "white" {}

		// Shall be automatically fed into shader
		[HideInInspector] _hFOV("hFOV", float) = -1 // Horizontal field of view
		[HideInInspector] _vFOV("vFOV", float) = -1 // Vetical field of view
    }

    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
 
			sampler2D _MainTex;
			float4 _MainTex_TexelSize;

			sampler2D _CameraDepthNormalsTexture;
			float _NormalThreshold;
			float _DepthThreshold;
			float4 _EdgeColor;

			float _vFOV;
			float _hFOV;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            struct v2f
            {
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
            };

			// Shortest angle between two vectors in rad, output between 0 and pi
			inline float AngleBetween(float3 x, float3 y) {
				return acos(dot(x, y) / (length(x)*length(y)));
			}

			// Returns the normal and depth value at a given uv coordinate
            float4 GetPixelNormalDepth(float2 uv) {
                float3 normal;
                float depth;
                DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, uv), depth, normal);
				depth = depth * _ProjectionParams.z; // https://forum.unity.com/threads/decodedepthnormal-linear01depth-lineareyedepth-explanations.608452/#post-4070806

                return float4(normal, depth);
            }

			// Calculates the intersection point of a plane and line a line through the origin
			// The plane is defined by the normal n_s and point p_plane
			// The line defined by the vector n_v
			// Returns the depth of the intersection point
			inline float GetPlaneDepth(float3 n_s, float3 p_plane, float3 n_v) {
				float k = dot((p_plane - 0), n_s) / dot(n_v, n_s);
				float3 intersect = n_v * k + 0;

				return -intersect.z;
				// return length(intersect); // Uses distance instead
			}

			// Calculates the distance of a point from the vector n_v_orig and the depth d_orig
			// The distance is then used to calculate the position and orientation of a plane
			// Returns the depth of the intersection between the plane and a line through the origin defined by n_v_sample
			float GetPlaneDepthFromVec(float3 n_s, float3 n_v_orig, float d_orig, float3 n_v_sample) {
				float3 n_camera = float3(0, 0, -1);
				float distance = d_orig / cos(AngleBetween(n_v_orig, n_camera)); // Calculate distance from view vector and depth

				return GetPlaneDepth(n_s, normalize(n_v_orig)*distance, n_v_sample);
			}

			// Vertex function
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			// Fragment function
            float4 frag (v2f i) : SV_Target
            {
                float4 col = tex2D(_MainTex, i.uv);
                float d = GetPixelNormalDepth(i.uv).w;
				float3 n_s = GetPixelNormalDepth(i.uv).xyz;


				// Offsets are used to define a 3x3 square around the current pixel
                float2 offsets[8] = {
					float2(0, -1),
					float2(0, 1),
					float2(-1, 0),
					float2(1, 0),
                    float2(-1, -1),
                    float2(-1, 1),
                    float2(1, -1),
                    float2(1, 1)
                };

				float3 normalsDiff;
				float depthDiff = 0;
				float3 sampledAvgNormal = fixed3(0, 0, 0);
				
				// Go through each of the neighboring pixels, get their depth and normal values,
				// compare the depth differences and normal differences
				// and store two combined values in normalsDiff and depthDiff
                for(int j = 0; j < 8; j++) {
					float4 sampleData = GetPixelNormalDepth(i.uv + offsets[j] * _MainTex_TexelSize.xy);
					sampledAvgNormal += sampleData.xyz;

					depthDiff = max(depthDiff, abs(sampleData.w - d));
                }
				sampledAvgNormal *= 0.125;
                normalsDiff = sampledAvgNormal - n_s;

				/*
				 * Depth correction for shallow angles
				*/
				
				float2 FOV = float2(_hFOV, _vFOV);

				// Angles in x and y direction between neighboring pixels in radians
				float2 alpha = radians(FOV) * _MainTex_TexelSize.xy;
				// Angles in x and y direction of currently inspected pixel relative to center of screen in radians
				float2 phi = (i.uv-0.5) * radians(FOV);

				// Normalized vector from camera to currently processed pixel
				float3 n_v;
				n_v.x = tan(phi.x);
				n_v.y = tan(phi.y);
				n_v.z = -1;
				n_v = normalize(n_v);

				// Normalized vectors from camera to neighboring pixels
				float3 n_v_sample[8];
				for (j = 0; j < 8; j++) {
					n_v_sample[j].x = tan(phi.x + offsets[j].x * alpha.x);
					n_v_sample[j].y = tan(phi.y + offsets[j].y * alpha.y);
					n_v_sample[j].z = -1;
					n_v_sample[j] = normalize(n_v_sample[j]);
				}

				// Calculate the difference in depth you would expect due
				// to the discrete nature of pixels in combination with
				// the potential shallow angles of surfaces
				float expectedDepthDiff = 0;
				float d_s;
				for (j = 0; j < 8; j++) {
					d_s = GetPlaneDepthFromVec(n_s, n_v, d, n_v_sample[j]);
					expectedDepthDiff = max(expectedDepthDiff, abs(d_s - d));
				}

				/*
				 * Calculation of pixel color
				 */

				float edgeConfidence = max(
					step(_NormalThreshold, length(normalsDiff)),
					step(_DepthThreshold, abs(depthDiff - expectedDepthDiff))); // Use expectedDepthDiff
					//step(_DepthThreshold, depthDiff)); // Ignore expectedDepthDiff

				//return float4(abs(depthDiff - expectedDepthDiff).xxx, 1); // Useful for debugging
                return lerp(col, _EdgeColor, edgeConfidence);
            }
            ENDCG
        }
    }
}