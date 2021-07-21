Shader "ClassicShader/Gouraud"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        [Header(Ambient)]
        _AmbientIntensity("Intensity", Range(0.0, 1.0)) = 0.1
        _AmbientColor("Color", Color) = (1.0, 1.0, 1.0, 1.0)

        [Header(Diffuse)]
        _DiffuseIntensity("Intensity", Range(0.0, 1.0)) = 1.0
        _DiffuseColor("Color", Color) = (1.0, 1.0, 1.0, 1.0)

        [Header(Specular)]
        _Shininess("Shininess", Range(0.0, 200.0)) = 1.0
        _SpecularColor("Color", Color) = (1.0, 1.0, 1.0, 1.0)
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
                float4 color  : COLOR;
                float2 uv     : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv     : TEXCOORD0;
                float4 color  : COLOR;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            fixed  _AmbientIntensity;
            fixed4 _AmbientColor;

            fixed  _DiffuseIntensity;
            fixed4 _DiffuseColor;

            fixed  _Shininess;
            fixed4 _SpecularColor;

            fixed4 _LightColor0;

            v2f vert (appdata v)
            {
                v2f o;

                // World position
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                // Clip position
                o.vertex = mul(UNITY_MATRIX_VP, float4(worldPos, 1.0));

                // Normal in WorldSpace
                float3 N = normalize(mul(v.normal, (float3x3)unity_WorldToObject));

                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                // Light direction
                float3 L = normalize(_WorldSpaceLightPos0.xyz);

                // Camera direction
                float3 V = normalize(_WorldSpaceCameraPos.xyz - worldPos.xyz);


                // Compute ambient lighting
                float4 amb = _AmbientIntensity * _AmbientColor;
                amb *= _LightColor0;

                // Compute the diffuse lighting
                float4 NdotL = max(0.0, dot(N, L));
                float4 dif = NdotL * _DiffuseIntensity * _DiffuseColor;
                dif *= _LightColor0;
                
                // Compute the specular lighting
                float3 refl = normalize(reflect(-L, N));
                float RdotV = max(0.0, dot(refl, V));
                float4 spec = pow(RdotV, _Shininess) * _SpecularColor;
                spec *= _LightColor0;

                float4 light = spec + dif + amb;

                o.color = v.color * light;

                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 c = tex2D(_MainTex, i.uv);
                
                c.rgb *= i.color.rgb;
                
                return c;
            }
            ENDCG
        }
    }
}
