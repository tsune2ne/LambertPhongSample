Shader "tsune2ne/CubeMapSample"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
        _RimPower("RimPower", Range(0.0, 10.0)) = 0.0
	}
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

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
                float3 worldPos : TEXCOORD2;
                float3 pos : TEXCOORD4;
            };

			sampler2D _MainTex;
            float4 _MainTex_ST;
			float4 _Color;
            half _RimPower;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				float4 col = tex2D(_MainTex, i.uv) * _Color;

                half3 worldViewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                half3 reflDir = reflect(-worldViewDir, i.normal);
                
                // unity_SpecCube0はUnityで定義されているキューブマップ
                half4 refColor = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflDir, 0);

                // Reflection ProbeがHDR設定だった時に必要な処理
                //refColor.rgb = DecodeHDR(refColor, unity_SpecCube0_HDR);
                //return refColor;

                half rim = 1.0 - abs(dot(worldViewDir, i.normal));
                fixed3 ambient = refColor * rim * _RimPower;


				half4 c;
				c.rgb = col.xyz + ambient;
                return c;
            }
            ENDCG
        }
    }
}
