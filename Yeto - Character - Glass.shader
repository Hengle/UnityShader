Shader "Yeto/Character/Glass"
{
	Properties
	{
		_MainCol("Main Color", Color) = (1, 1, 1, 1)
		_Opacity("Opacity", Range( 0 , 1)) = 0.085
		_SpecularTex("Specular Texture", 2D) = "white" {}
		_Fresnel("Fresnel", Range( 0 , 10)) = 1.39
		_SpecularPower("Specular Range", Range(0.0, 1000.0)) = 1.0
		_SpecularColor("Specular Color", Color) = (1.0, 1.0, 1.0, 1.0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent" }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Phong keepalpha
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
		};

		uniform float _Fresnel;
		uniform sampler2D _SpecularTex;
		uniform float4 _SpecularTex_ST;
		uniform float _Opacity;

		uniform float4 _MainCol;
		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		half _SpecularPower;
		fixed4 _SpecularColor;

		//�Զ��������ṹ
		struct SurfaceOutputSpecular
		{
			fixed3 Albedo;	//������
			fixed3 Normal;	//����
			fixed3 Emission;//�Է�����ɫֵ
			half Specular;	//���淴���
			fixed Gloss;	//�����
			fixed Alpha;	//͸����

			fixed3 SpecularTex;
			fixed Fresnel;
		};

		inline fixed4 LightingPhong(SurfaceOutputSpecular s, fixed3 lightDir, half3 viewDir, fixed atten)
		{
			float diff = dot(s.Normal, lightDir);								//���㷨������ռн�
			float3 reflection = normalize(2.0 * s.Normal * diff - lightDir);	//�߹��㷨
			float spec = pow(max(0, dot(reflection, viewDir)), _SpecularPower);	//�߹�ǿ��
			float3 finalSpec = _SpecularColor.rgb * spec * s.SpecularTex;		//���յĸ߹���ɫ�� �����˸߹���ͼ
			fixed4 c;
			c.rgb = (s.Albedo * _LightColor0.rgb * s.Fresnel) +  (s.Albedo * _LightColor0.rgb * diff ) + (_LightColor0.rgb * finalSpec) * (atten * 2); //��������ɫ+�߹���ɫ
			c.a = s.Alpha;
			return c;
		}

		void surf( Input i , inout SurfaceOutputSpecular o )
		{
			fixed4 c = _MainCol;
			o.SpecularTex = tex2D(_SpecularTex, i.uv_texcoord);		//�߹���ͼ
			o.Albedo = c.rgb;
			o.Alpha = _Opacity;

			float3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
			o.Fresnel = (0.0 + 1.0*pow(1.0 - dot(i.worldNormal, worldViewDir), _Fresnel));
		}

		ENDCG
	}
}
