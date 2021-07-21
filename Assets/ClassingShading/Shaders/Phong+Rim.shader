Shader "ClassicShader/Phong+Rim"
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

        [Header(Rim)]
        _RimColor("Rim Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _RimPower("Rim Power", Range(0.01, 10.0)) = 3.0

        [Header(Emission)]
        _EmissionTex("Emission Texture", 2D) = "gray" {}
        _EmissionIntensity("Intensity", float) = 0.0
        [HDR]_EmissionColor("Color", Color) = (1.0, 1.0, 1.0, 1.0)
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

            float  _AmbientIntensity;
            float4 _AmbientColor;

            float  _DiffuseIntensity;
            float4 _DiffuseColor;

            float  _Shininess;
            float4 _SpecularColor;

            float  _RimPower;
            float4 _RimColor;

            sampler2D _EmissionTex;
            float4 _EmissionColor;
            float  _EmissionIntensity;

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

            float4 frag (v2f i) : SV_Target
            {
                float4 c = tex2D(_MainTex, i.uv);
                
                // Light direction
                float3 L = normalize(_WorldSpaceLightPos0.xyz);

                // Camera direction
                float3 V = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);

                float3 N = normalize(i.worldNormal);

                // Compute ambient lighting
                float4 amb = _AmbientIntensity * _AmbientColor;
                amb *= _LightColor0;

                // Compute the diffuse lighting
                float4 NdotL = max(0.0, dot(N, L));
                float4 dif = NdotL * _DiffuseIntensity * _DiffuseColor;
                dif *= _LightColor0;

                // Compute the specular lighting
                float3 R = normalize(reflect(-L, N));
                float RdotV = max(0.0, dot(R, V));
                float4 spec = pow(RdotV, _Shininess) * _SpecularColor;
                spec *= _LightColor0;

                // Compute Rim lighting
                float3 rimPow = pow(1.0 - saturate(dot(V, N)), _RimPower);
                float4 rim = float4(dot(N, L) * rimPow * _RimColor, 1.0);

                float4 light = spec + dif + amb + rim;
                
                c.rgb *= light;

                // Compute emission
                float4 emi = tex2D(_EmissionTex, i.uv);
                emi *= _EmissionColor * _EmissionIntensity;

                c.rgb += emi.rgb;
                
                return c;
            }
            ENDCG
        }
    }
}
