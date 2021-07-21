Shader "ClassicShader/Ambient"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        [Header(Ambient)]
        _AmbientIntensity ("Intensity", Range(0.0, 1.0)) = 0.1
        _AmbientColor ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
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
                float2 uv     : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv     : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            fixed4 _AmbientColor;
            fixed  _AmbientIntensity;

            fixed4 _LightColor0;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 c = tex2D(_MainTex, i.uv);
                
                // Compute ambient lighting
                fixed4 amb = _AmbientIntensity * _AmbientColor;
                amb.rgb *= _LightColor0;

                c.rgb *= amb.rgb;
    
                return c;
            }
            ENDCG
        }
    }
}
