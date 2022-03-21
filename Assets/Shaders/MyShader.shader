Shader "tsune2ne/MyShader"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
		_Diffuse ("Diffuse Color", Color) = (0.3,0.3,1,1) // 拡散反射の色
		_Kd ("Kd", Range (0.01, 1)) = 0.8 // 拡散反射の反射率
		_Specular ("Spec Color", Color) = (1,1,1,1) // 鏡面反射の色
        _Ks ("Ks", Range (0.01, 1)) = 1.0 // 鏡面反射の反射率
		_Shininess ("Shininess", Range (0, 100)) = 10 // ハイライトの鋭さ
		_Ka ("Ka", Range (0.01, 1)) = 0.5 // 環境光の反射率
        _RimPower("RimPower", Range(0.0, 10.0)) = 0.3
        [PowerSlider(0.1)] _F0 ("F0", Range(0.0, 1.0)) = 0.02 // フレネル効果の強さ
		_Fresnel ("Fresnel Color", Color) = (0.3,0.3,1,1) // フレネル効果の色
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

			#define PI 3.141592

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
				float3 view   : TEXCOORD2;
			};


			sampler2D _MainTex;
			float4 _Color;
			float4 _MainTex_ST;
			float4 _Diffuse;
			float _Kd;
			float4 _Specular;
			float _Ks;
			float _Shininess;
			float _Ka;
            half _RimPower;
			float _F0;
			float4 _Fresnel;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normal = UnityObjectToWorldNormal(v.normal);
				o.view = normalize(ObjSpaceViewDir(v.vertex));
				return o;
			}

			float3 frag(v2f i) : SV_Target
			{
				float4 col = tex2D(_MainTex, i.uv) * _Color;

				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				float3 NdotL = max(0, dot(i.normal, lightDir));

				// 反射ベクトル
				float3 reflect = normalize(- lightDir + 2.0 * i.normal * NdotL);

				// 拡散反射
				float3 diffuse = _Kd * col.xyz * NdotL * _Diffuse;

				// 鏡面反射
				float3 spec = _Ks * pow(max(0, dot(reflect, i.view)), _Shininess) * _Specular;

				// 環境光
				half4 refColor = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflect, 0);
                half rim = pow(1.0 - abs(dot(i.view, i.normal)), 2);
				float3 ambient = col.xyz * _Ka * float3(1,1,1) + refColor * rim * _RimPower;

				// フレネル効果
                half vdotn = dot(i.view, i.normal.xyz);
                half3 fresnel = (_F0 + (1.0h - _F0) * pow(1.0h - vdotn, 5)) * _Fresnel;

				half4 c;
				c.rgb = diffuse + spec + ambient + fresnel;
				return c;
			}
			ENDCG
		}
	}
}
