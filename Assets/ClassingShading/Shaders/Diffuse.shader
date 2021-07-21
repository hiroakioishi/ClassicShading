Shader "ClassicShader/Diffuse"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        [Header(Diffuse)]
        _DiffuseIntensity("Intensity", Range(0.0, 1.0)) = 1.0
        _DiffuseColor ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" "LightMode"="ForwardBase"}

        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex   vert
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
                float2 uv          : TEXCOORD0;
                float4 vertex      : SV_POSITION;
                float3 worldPos    : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            fixed  _DiffuseIntensity;
            fixed4 _DiffuseColor;

            fixed4 _LightColor0;

            v2f vert (appdata v)
            {
                v2f o;

                // World position
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);

                // Clip position
                o.vertex = mul(UNITY_MATRIX_VP, float4(o.worldPos, 1.0));

                // Normal in WorldSpace
                o.worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));

                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 c = tex2D(_MainTex, i.uv);
                
                // Light direction
                float3 L = normalize(_WorldSpaceLightPos0.xyz);

                // Camera direction
                float3 V = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);

                float3 N = normalize(i.worldNormal);

                // Compute the diffuse lighting
                fixed4 NdotL = max(0.0, dot(N, L));
                fixed4 dif = NdotL * _DiffuseIntensity * _DiffuseColor;
                dif *= _LightColor0;

                fixed4 light = dif;
                
                c.rgb *= light;
                
                return c;
            }
            ENDCG
        }
    }
}
