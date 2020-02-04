//++++++++++++++++++++++++++++++++++++++++++++
// ENBSeries effect file
// visit http://enbdev.com for updates
// Copyright (c) 2007-2011 Boris Vorontsov
//++++++++++++++++++++++++++++++++++++++++++++



//+++++++++++++++++++++++++++++
//internal parameters, can be modified
//+++++++++++++++++++++++++++++
//none



//+++++++++++++++++++++++++++++
//external parameters, do not modify
//+++++++++++++++++++++++++++++
//keyboard controlled temporary variables (in some versions exists in the config file). Press and hold key 1,2,3...8 together with PageUp or PageDown to modify. By default all set to 1.0
float4	tempF1; //0,1,2,3
float4	tempF2; //5,6,7,8
float4	tempF3; //9,0
//x=Width, y=1/Width, z=ScreenScaleY, w=1/ScreenScaleY
float4	ScreenSize;
//x=generic timer in range 0..1, period of 16777216 ms (4.6 hours), w=frame time elapsed (in seconds)
float4	Timer;
//additional info for computations
float4	TempParameters; 
//BloomRadius1, BloomRadius2, BloomBlueShiftAmount, BloomContrast
float4	BloomParameters;
//changes in range 0..1, 0 means that night time, 1 - day time
float	ENightDayFactor;
//changes 0 or 1. 0 means that exterior, 1 - interior
float	EInteriorFactor;
//changes in range 0..1, 0 means full quality, 1 lowest dynamic quality (0.33, 0.66 are limits for quality levels)
float	EAdaptiveQualityFactor;
//fov in degrees
float	FieldOfView;


texture2D texBloom1;
texture2D texBloom2;
texture2D texBloom3;
texture2D texBloom4;
texture2D texBloom5;
texture2D texBloom6;
texture2D texBloom7;//additional bloom tex
texture2D texBloom8;//additional bloom tex

sampler2D SamplerBloom1 = sampler_state
{
    Texture   = <texBloom1>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = NONE;//NONE;
	AddressU  = Clamp;
	AddressV  = Clamp;
	SRGBTexture=FALSE;
	MaxMipLevel=0;
	MipMapLodBias=0;
};

sampler2D SamplerBloom2 = sampler_state
{
    Texture   = <texBloom2>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = NONE;//NONE;
	AddressU  = Clamp;
	AddressV  = Clamp;
	SRGBTexture=FALSE;
	MaxMipLevel=0;
	MipMapLodBias=0;
};

sampler2D SamplerBloom3 = sampler_state
{
    Texture   = <texBloom3>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = NONE;//NONE;
	AddressU  = Clamp;
	AddressV  = Clamp;
	SRGBTexture=FALSE;
	MaxMipLevel=0;
	MipMapLodBias=0;
};

sampler2D SamplerBloom4 = sampler_state
{
    Texture   = <texBloom4>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = NONE;//NONE;
	AddressU  = Clamp;
	AddressV  = Clamp;
	SRGBTexture=FALSE;
	MaxMipLevel=0;
	MipMapLodBias=0;
};

sampler2D SamplerBloom5 = sampler_state
{
    Texture   = <texBloom5>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = NONE;//NONE;
	AddressU  = Clamp;
	AddressV  = Clamp;
	SRGBTexture=FALSE;
	MaxMipLevel=0;
	MipMapLodBias=0;
};

sampler2D SamplerBloom6 = sampler_state
{
    Texture   = <texBloom6>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = NONE;//NONE;
	AddressU  = Clamp;
	AddressV  = Clamp;
	SRGBTexture=FALSE;
	MaxMipLevel=0;
	MipMapLodBias=0;
};

sampler2D SamplerBloom7 = sampler_state
{
    Texture   = <texBloom7>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = NONE;//NONE;
	AddressU  = Clamp;
	AddressV  = Clamp;
	SRGBTexture=FALSE;
	MaxMipLevel=0;
	MipMapLodBias=0;
};

sampler2D SamplerBloom8 = sampler_state
{
    Texture   = <texBloom8>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = NONE;//NONE;
	AddressU  = Clamp;
	AddressV  = Clamp;
	SRGBTexture=FALSE;
	MaxMipLevel=0;
	MipMapLodBias=0;
};

struct VS_OUTPUT_POST
{
	float4 vpos  : POSITION;
	float2 txcoord0 : TEXCOORD0;
};
struct VS_INPUT_POST
{
	float3 pos  : POSITION;
	float2 txcoord0 : TEXCOORD0;
};



//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
VS_OUTPUT_POST VS_Bloom(VS_INPUT_POST IN)
{
	VS_OUTPUT_POST OUT;

	OUT.vpos=float4(IN.pos.x,IN.pos.y,IN.pos.z,1.0);

	OUT.txcoord0.xy=IN.txcoord0.xy+TempParameters.xy;//1.0/(bloomtexsize*2.0)

	return OUT;
}


//zero pass HQ, input texture is fullscreen
//SamplerBloom1 - fullscreen texture
float4 PS_BloomPrePass(VS_OUTPUT_POST In) : COLOR
{
	float4 bloomuv;

	float4 bloom=0.0;//tex2D(SamplerBloom1, In.txcoord0);
	const float2 offset[4]=
	{
		float2(0.25, 0.25),
		float2(0.25, -0.25),
		float2(-0.25, 0.25),
		float2(-0.25, -0.25)
	};
	//TempParameters.w==1 if first pass, ==2 is second pass
	float2 screenfact=TempParameters.z;
	screenfact.y*=ScreenSize.z;
	float4 srcbloom=bloom;
	for (int i=0; i<4; i++)
	{
		bloomuv.xy=offset[i];
		bloomuv.xy=(bloomuv.xy*screenfact.xy)+In.txcoord0.xy;
		float4 tempbloom=tex2D(SamplerBloom1, bloomuv.xy);
		bloom.xyz+=tempbloom.xyz;
	}
	bloom.xyz*=0.25;

	bloom.xyz=min(bloom.xyz, 32768.0);
	bloom.xyz=max(bloom.xyz, 0.0);

	return bloom;
}



//first and second passes draw to every texture
//twice, after computations of these two passes,
//result is set as input to next cycle

//first pass
//SamplerBloom1 is result of prepass or second pass from cycle
float4 PS_BloomTexture1(VS_OUTPUT_POST In) : COLOR
{
	float4 bloomuv;

	float4 bloom=tex2D(SamplerBloom1, In.txcoord0);
	const float2 offset[8]=
	{
		float2(1.0, 1.0),
		float2(1.0, -1.0),
		float2(-1.0, 1.0),
		float2(-1.0, -1.0),
		float2(0.0, 1.0),
		float2(0.0, -1.0),
		float2(1.0, 0.0),
		float2(-1.0, 0.0)
	};
	float2 screenfact=TempParameters.z;
	screenfact.y*=ScreenSize.z;
	float4 srcbloom=bloom;
	//TempParameters.w == (1+passnumber)
	float step=BloomParameters.x;//*pow(2.0, BloomParameters.x * (TempParameters.w-1.0));//*0.5
//	float step=(TempParameters.w-0.25);//
	screenfact.xy*=step;//====================================================

	float4 bloomadd=bloom;

	for (int i=0; i<8; i++)
	{
		bloomuv.xy=offset[i];
		bloomuv.xy=(bloomuv.xy*screenfact.xy)+In.txcoord0.xy;//-(1.0/256.0);//-(1.0/512.0);
		float4 tempbloom=tex2D(SamplerBloom1, bloomuv.xy);
		bloom+=tempbloom;
	}
	bloom*=0.111111;


	//float3 violet=float3(0.78, 0.5, 1.0);
	//float3 violet=float3(0.6, 0.4, 1.0);//v2
	float3 violet=float3(0.6, 0.4, 1.0);//v3
//	float3 violet=float3(0.27, 0.52, 1.0);//v4

	//this applies when white
	//float gray=0.104*dot(srcbloom.xyz, 0.333);//max(srcbloom.x, max(srcbloom.y, srcbloom.z));
	//this applies on dark and when contrast
	float ttt=dot(bloom.xyz, 0.333)-dot(srcbloom.xyz, 0.333);
	ttt=max(ttt, 0.0);
	float gray=BloomParameters.z*ttt*10;//max(srcbloom.x, max(srcbloom.y, srcbloom.z));
	float mixfact=(gray/(1.0+gray));
	mixfact*=1.0-saturate((TempParameters.w-1.0)*0.2);
	violet.xy+=saturate((TempParameters.w-1.0)*0.3);
	violet.xy=saturate(violet.xy);
	bloom.xyz*=lerp(1.0, violet.xyz, mixfact);

	bloom.w=1.0;
	return bloom;
}


//second pass
//SamplerBloom1 is result of first pass
float4 PS_BloomTexture2(VS_OUTPUT_POST In) : COLOR
{
	float4 bloomuv;

	float4 bloom=tex2D(SamplerBloom1, In.txcoord0);
	const float2 offset[8]=
	{
		float2(1.0, 1.0),
		float2(1.0, -1.0),
		float2(-1.0, 1.0),
		float2(-1.0, -1.0),
		float2(0.0, 1.0),
		float2(0.0, -1.0),
		float2(1.0, 0.0),
		float2(-1.0, 0.0)
	};
	float2 screenfact=TempParameters.z;
	screenfact.y*=ScreenSize.z;
	float4 srcbloom=bloom;

	//TempParameters.w == (1+passnumber)
//	float step=(TempParameters.w-0.25);
	float step=BloomParameters.y;//*pow(2.0, BloomParameters.y * (TempParameters.w-1.0))*2.0;//*0.5
	screenfact.xy*=step;//*0.25====================================================
	float4 rotvec=0.0;
	sincos(0.3927, rotvec.x, rotvec.y);
	for (int i=0; i<8; i++)
	{
		bloomuv.xy=offset[i];
		bloomuv.xy=reflect(bloomuv.xy, rotvec.xy);
		bloomuv.xy=(bloomuv.xy*screenfact.xy)+In.txcoord0.xy;
		float4 tempbloom=tex2D(SamplerBloom1, bloomuv.xy);
		bloom+=tempbloom;
	}
	bloom*=0.111111;

	bloom.w=1.0;
	return bloom;
}



//last pass, mix several bloom textures
//SamplerBloom5 is the result of prepass
//float4 PS_BloomPostPass(float2 vPos : VPOS ) : COLOR
float4 PS_BloomPostPass(VS_OUTPUT_POST In) : COLOR
{
	float4 bloom;

	//v1
	bloom =tex2D(SamplerBloom1, In.txcoord0);
	bloom+=tex2D(SamplerBloom2, In.txcoord0);
	bloom+=tex2D(SamplerBloom3, In.txcoord0);
	bloom+=tex2D(SamplerBloom4, In.txcoord0);
	bloom+=tex2D(SamplerBloom7, In.txcoord0);
	bloom+=tex2D(SamplerBloom8, In.txcoord0);
	bloom+=tex2D(SamplerBloom5, In.txcoord0);
//	bloom+=tex2D(SamplerBloom6, In.txcoord0);
	bloom*=0.142857;

	return bloom;
}



technique BloomPrePass
{
    pass p0
    {
	VertexShader = compile vs_3_0 VS_Bloom();
	PixelShader  = compile ps_3_0 PS_BloomPrePass();

	ColorWriteEnable=ALPHA|RED|GREEN|BLUE;
	CullMode=NONE;
	AlphaBlendEnable=FALSE;
	AlphaTestEnable=FALSE;
	SEPARATEALPHABLENDENABLE=FALSE;
	FogEnable=FALSE;
	SRGBWRITEENABLE=FALSE;
	}
}

technique BloomTexture1
{
    pass p0
    {
	VertexShader = compile vs_3_0 VS_Bloom();
	PixelShader  = compile ps_3_0 PS_BloomTexture1();

	ColorWriteEnable=ALPHA|RED|GREEN|BLUE;
	CullMode=NONE;
	AlphaBlendEnable=FALSE;
	AlphaTestEnable=FALSE;
	SEPARATEALPHABLENDENABLE=FALSE;
	FogEnable=FALSE;
	SRGBWRITEENABLE=FALSE;
	}
}


technique BloomTexture2
{
    pass p0
    {
	VertexShader = compile vs_3_0 VS_Bloom();
	PixelShader  = compile ps_3_0 PS_BloomTexture2();

	ColorWriteEnable=ALPHA|RED|GREEN|BLUE;
	CullMode=NONE;
	AlphaBlendEnable=FALSE;
	AlphaTestEnable=FALSE;
	SEPARATEALPHABLENDENABLE=FALSE;
	FogEnable=FALSE;
	SRGBWRITEENABLE=FALSE;
	}
}

technique BloomPostPass
{
    pass p0
    {
	VertexShader = compile vs_3_0 VS_Bloom();
	PixelShader  = compile ps_3_0 PS_BloomPostPass();

	ColorWriteEnable=ALPHA|RED|GREEN|BLUE;
	CullMode=NONE;
	AlphaBlendEnable=FALSE;
	AlphaTestEnable=FALSE;
	SEPARATEALPHABLENDENABLE=FALSE;
	FogEnable=FALSE;
	SRGBWRITEENABLE=FALSE;
	}
}



