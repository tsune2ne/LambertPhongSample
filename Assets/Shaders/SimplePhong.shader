Shader "tsune2ne/SimplePhong"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
		_Diffuse ("Diffuse Color", Color) = (0.3,0.3,1,1) // �g�U���˂̐F
		_Kd ("Kd", Range (0.01, 1)) = 0.8 // �g�U���˂̔��˗�
		_Specular ("Spec Color", Color) = (1,1,1,1) // ���ʔ��˂̐F
        _Ks ("Ks", Range (0.01, 1)) = 1.0 // ���ʔ��˂̔��˗�
		_Shininess ("Shininess", Range (0, 100)) = 10 // �n�C���C�g�̉s��
		_Ambient ("Ambient Color", Color) = (0.3,0.3,1,1) // �����̐F
		_Ka ("Ka", Range (0.01, 1)) = 0.5 // �����̔��˗�
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
			float4 _Ambient;
			float _Ka;

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

				// ���˃x�N�g��
				float3 reflect = normalize(- lightDir + 2.0 * i.normal * NdotL);

				// �g�U����
				float3 diffuse = _Kd * col.xyz * NdotL * _Diffuse;

				// ���ʔ���
				float3 spec = _Ks * pow(max(0, dot(reflect, i.view)), _Shininess) * _Specular;

				// ����
				float ambient = col.xyz * _Ka * _Ambient;

				half4 c;
				c.rgb = diffuse + spec + ambient;
				return c;
			}
			ENDCG
		}
	}
}
