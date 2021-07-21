Shader "ClassicShader/Attributes/Reflection"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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

            /*
           // https://developer.download.nvidia.com/cg/reflect.html
           i ... incidence vector（入射ベクトル）
           n ... normal vector（法線ベクトル）
           法線ベクトルは正規化されている必要がある. 正規化を行っていた場合, 反射ベクトルは, 入射ベクトルiと同じ大きさになる.
           float  reflect(float  i, float  n)
           {
               return i - 2.0 * n * dot(n, i);
           }

           float2 reflect(float2 i, float2 n)
           {
               return i - 2.0 * n * dot(n, i);
           }

           float3 reflect(float3 i, float3 n)
           {
               return i - 2.0 * n * dot(n, i);
           }

           float4 reflect(float4 i, float4 n)
           {
               return i - 2.0 * n * dot(n, i);
           }
           */
            
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
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                float3 worldNormal = normalize(i.worldNormal);

                // float3 refl = normalize(reflect(-lightDir, worldNormal));                
                float3 refl = -lightDir - 2.0 * worldNormal * dot(worldNormal, -lightDir);

                c.rgb = refl;

                return c;
            }
            ENDCG
        }
    }
}
