Shader "tsune2ne/SimpleLambert"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
	}
	SubShader 
	{
		Tags { "RenderType"="Opaque" }

		Pass
		{
			Tags { "LightMode"="ForwardBase" }

			Cull Back
		
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv     : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv     : TEXCOORD0;
				float3 normal : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Color;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normal = UnityObjectToWorldNormal(v.normal);
				return o;
			}

			float3 frag(v2f i) : SV_Target
			{
				float4 col = tex2D(_MainTex, i.uv) * _Color;

				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				float3 NdotL = dot(i.normal, lightDir);
				float3 shade = max(0.0, NdotL) * _LightColor0.rgb;
				float3 diffuse = shade * col.xyz;
				diffuse += fixed4(0.2f, 0.2f, 0.2f, 1); // ŠÂ‹«Œõ‚ÍŒÅ’è’l
				return diffuse;
			}
 /*
			struct Input {
				float2 uv_MainTex;
			};

			void surf (Input IN, inout SurfaceOutput  o) {
				o.Albedo = fixed4(1,1,1,1);
			}

			half4 LightingSimpleLambert(SurfaceOutput s, half3 lightDir, half atten)
			{
				 half NdotL = max(0, dot(s.Normal, lightDir));
				 half4 c;
				 c.rgb = s.Albedo * _LightColor0.rgb * NdotL + fixed4(0.2f, 0.2f, 0.2f, 1);
				 c.a = s.Alpha;
				 return c;
			}
			*/
			ENDCG
		}
	}
}
