Shader "ZEPETO/Hair"
{
    Properties
    {
        _MainTex ("Diffuse (RGB) Alpha (A)", 2D) = "white" {}
        _Color ("Main Color", Color) = (1,1,1,1)
        _Cutoff ("Alpha Cutoff", range(0.01, 1)) = 0.5
        _NormalTex ("Normal Map", 2D) = "bump" {}
        _NormalPower ("NormalPower", range(0, 5)) = 0.75
        _SpecularTex ("Specular (R) Spec Shift (G) Spec Mask (B)", 2D) = "gray" {}
        _SpecularMultiplier ("Specular Multiplier", float) = 10.0
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _SpecularColor ("Specular Color", Color) = (1,1,1,1)
        _SpecularMultiplier2 ("Secondary Specular Multiplier", float) = 10.0
        _SpecularColor2 ("Secondary Specular Color", Color) = (1,1,1,1)
        _PrimaryShift ( "Specular Primary Shift", float) = -0.01
        _SecondaryShift ( "Specular Secondary Shift", float) = -0.28
 
        _RimColor ("Rim Color", Color) = (0,0,0,0)
        _RimPower ("Rim Power", Range(1,3)) = 1.292
 
 
        _TintColor ("Tint Color", Color) = (0,0,0)
        _TintPower ("Tint Power", Range(0,1)) = 0.292
 
        [HideInInspector]_LogLut ("_LogLut", 2D)  = "white" {}
 
 
 
    }
 
    SubShader
    {
        Tags { "RenderType" = "Transparent"  "Queue" = "Transparent"  "RequireOption" = "SoftVegetation" }
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite off
        Cull off

        Pass {
		
            ColorMask 0
            ZWrite On
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
 
            #include "UnityCG.cginc"
            struct v2f {
                float4 vertex : SV_POSITION;
                float2 texcoord : TEXCOORD0;
            };
            sampler2D _MainTex;
            fixed _Cutoff;
            v2f vert (appdata_img v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.texcoord = v.texcoord;
                return o;
            }
			
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.texcoord);
				
                clip(col.a - _Cutoff);
                return 0;
            }
            ENDCG
        }

        Pass
        {
            Tags { "RenderType" = "Transparent"  "Queue" = "Transparent"  "RequireOption" = "SoftVegetation" }
			AlphaTest GEqual 0.95
            ZWrite off
            

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"
            struct v2f {
                V2F_SHADOW_CASTER;
                float2 texcoord : TEXCOORD1;
            };
            v2f vert(appdata_base v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                o.texcoord = v.texcoord;
                return o;
            }
 
            sampler2D _MainTex;
            fixed _Cutoff;
            float4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.texcoord);
                clip(col.a - _Cutoff);
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
 
        Pass {
		Tags { "RenderType" = "Transparent"  "Queue" = "Transparent"  "RequireOption" = "SoftVegetation" }
        Blend SrcAlpha OneMinusSrcAlpha
        LOD 200
        ZWrite Off

   
            AlphaTest GEqual 0.95
            SetTexture [_MainTex] { }
        }

 
 
        CGPROGRAM
        #pragma surface surf Hair keepalpha alpha:fade decal:blend finalcolor:tonemapping vertex:vert
		#pragma shader_feature _USEMETALLICMAP_ON
        #pragma target 3.0
		

        #include "/Hair.cginc"
 
	
        void surf (Input IN, inout SurfaceOutputHair o)
        {
 
        fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Alpha = saturate(c.a / _Cutoff);
			
            surf_base(IN, o);
	
        }
		
	
 
        ENDCG
 
 
    }
    FallBack "Mobile/VertexLit"
}