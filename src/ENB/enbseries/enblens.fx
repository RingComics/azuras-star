//++++++++++++++++++++++++++++++++++++++++++++
// ENBSeries effect file
// visit http://enbdev.com for updates
// Copyright (c) 2007-2013 Boris Vorontsov
//++++++++++++++++++++++++++++++++++++++++++++
// 
// edited by kingeric1992
//+++++++++++++++++++++++++++++
//internal parameters, can be modified
//+++++++++++++++++++++++++++++

//Lens : controls lens reflection
float LensX < string UIName="Lens Reflect Position X"; string UIWidget="Spinner"; float UIMin=-1; float UIMax=1;> = {0};
float LensY < string UIName="Lens Reflect Position Y"; string UIWidget="Spinner"; float UIMin=-1; float UIMax=1;> = {0};

float LensSize < string UIName="Lens Reflect Size";	string UIWidget="Spinner"; float UIMin=0.1;	float UIMax=10.0;> = {1};
float LensIntensity < string UIName="Lens Reflect Intensity"; string UIWidget="Spinner"; float UIMin=0.0; float UIMax=1000.0;> = {1};



//Flare : controls lens flare
float FlareIntensity1N < string UIName="Flare IntensityL-N"; string UIWidget="Spinner"; float UIMin=0.0; float UIMax=1000.0;> = {2};
float FlareIntensity2N < string UIName="Flare IntensityH-N"; string UIWidget="Spinner"; float UIMin=0.0; float UIMax=1000.0;> = {1};
float FlareIntensity1D < string UIName="Flare IntensityL-D"; string UIWidget="Spinner"; float UIMin=0.0; float UIMax=1000.0;> = {2};
float FlareIntensity2D < string UIName="Flare IntensityH-D"; string UIWidget="Spinner"; float UIMin=0.0; float UIMax=1000.0;> = {1};
float FlareIntensity1I < string UIName="Flare IntensityL-I"; string UIWidget="Spinner"; float UIMin=0.0; float UIMax=1000.0;> = {2};
float FlareIntensity2I < string UIName="Flare IntensityH-I"; string UIWidget="Spinner"; float UIMin=0.0; float UIMax=1000.0;> = {1};

float FlareThreshold1N < string UIName="Flare Lighting ThresholdL-N"; string UIWidget="Spinner"; float UIMin=0.0; float UIMax=100.0;> = {0.7};
float FlareThreshold2N < string UIName="Flare Lighting ThresholdH-N"; string UIWidget="Spinner"; float UIMin=0.0; float UIMax=100.0;> = {0.9};
float FlareThreshold1D < string UIName="Flare Lighting ThresholdL-D"; string UIWidget="Spinner"; float UIMin=0.0; float UIMax=100.0;> = {0.7};
float FlareThreshold2D < string UIName="Flare Lighting ThresholdH-D"; string UIWidget="Spinner"; float UIMin=0.0; float UIMax=100.0;> = {0.9};
float FlareThreshold1I < string UIName="Flare Lighting ThresholdL-I"; string UIWidget="Spinner"; float UIMin=0.0; float UIMax=100.0;> = {0.7};
float FlareThreshold2I < string UIName="Flare Lighting ThresholdH-I"; string UIWidget="Spinner"; float UIMin=0.0; float UIMax=100.0;> = {0.9};

float FlareCurve1 <	string UIName="Flare Curve1"; string UIWidget="Spinner"; float UIMin=1; float UIMax=100;> =	{6};
float FlareCurve2 <	string UIName="Flare Curve2"; string UIWidget="Spinner"; float UIMin=1; float UIMax=100;> =	{6};

float3 FlareTint1 <	string UIName="Flare Tint1"; string UIWidget="color";> = {0.137, 0.216, 1};
float3 FlareTint2 <	string UIName="Flare Tint2"; string UIWidget="color";> = {0.137, 0.216, 1};

float FlareAngle1 <	string UIName="Flare Angle 1"; string UIWidget="Spinner"; float UIMin=0.01; float UIMax=180;> = {180};
float FlareAngle2 <	string UIName="Flare Angle 2"; string UIWidget="Spinner"; float UIMin=0.01; float UIMax=180;> = {90};

float radii < string UIName="blur radii"; string UIWidget="Spinner"; float UIMin=0;	float UIMax=1000;> = {16};

//+++++++++++++++++++++++++++++
//external parameters, do not modify
//+++++++++++++++++++++++++++++
//keyboard controlled temporary variables (in some versions exists in the config file). Press and hold key 1,2,3...8 together with PageUp or PageDown to modify. By default all set to 1.0
float4	tempF1; //0,1,2,3
float4	tempF2; //5,6,7,8
float4	tempF3; //9,0
//x=Width, y=1/Width, z=ScreenScaleY, w=1/ScreenScaleY
float4	ScreenSize;
//changes in range 0..1, 0 means that night time, 1 - day time
float	ENightDayFactor;
//changes 0 or 1. 0 means that exterior, 1 - interior
float	EInteriorFactor;
//x=generic timer in range 0..1, period of 16777216 ms (4.6 hours), w=frame time elapsed (in seconds)
float4	Timer;
//additional info for computations
float4	TempParameters; 
//x=reflection intensity, y=reflection power, z=dirt intensity, w=dirt power
float4	LensParameters;
//fov in degrees
float	FieldOfView;



texture2D texColor;
texture2D texMask;//enblensmask texture
texture2D texBloom1;
texture2D texBloom2;
texture2D texBloom3;
texture2D texBloom4;
texture2D texBloom5;
texture2D texBloom6;
texture2D texBloom7;
texture2D texBloom8;

sampler2D SamplerColor = sampler_state
{
	Texture   = <texColor>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = NONE;
	AddressU  = Clamp;
	AddressV  = Clamp;
	SRGBTexture=FALSE;
	MaxMipLevel=0;
	MipMapLodBias=0;
};

sampler2D SamplerMask = sampler_state
{
	Texture   = <texMask>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = NONE;
	AddressU  = Clamp;
	AddressV  = Clamp;
	SRGBTexture=FALSE;
	MaxMipLevel=0;
	MipMapLodBias=0;
};

sampler2D SamplerBloom1 = sampler_state
{
	Texture   = <texBloom1>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = NONE;
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
	MipFilter = NONE;
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
	MipFilter = NONE;
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
	MipFilter = NONE;
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
	MipFilter = NONE;
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
	MipFilter = NONE;
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
	MipFilter = NONE;
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
	MipFilter = NONE;
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
VS_OUTPUT_POST VS_Draw(VS_INPUT_POST IN)
{
	VS_OUTPUT_POST OUT;

	OUT.vpos=float4(IN.pos.x,IN.pos.y,IN.pos.z,1.0);

	OUT.txcoord0.xy=IN.txcoord0.xy+TempParameters.xy;//1.0/(bloomtexsize*2.0)

	return OUT;
}



float4	PS_Draw(VS_OUTPUT_POST In) : COLOR
{
	float4	res = 0;

	float2	coord;
	//deepness, curvature, inverse size
	const float3 offset[4]=
	{
		float3(1.6, 4.0, 1.0),
		float3(0.7, 0.25, 2.0),
		float3(0.3, 1.5, 0.5),
		float3(-0.5, 1.0, 1.0)
	};
	//color filter per reflection
	const float3 factors[4]=
	{
		float3(0.3, 0.4, 0.4),
		float3(0.2, 0.4, 0.5),
		float3(0.5, 0.3, 0.7),
		float3(0.1, 0.2, 0.7)
	};

	for (int i=0; i<4; i++)
	{
		float2	distfact=(In.txcoord0.xy-0.5);
		distfact.x += LensX;
		distfact.y += LensY;		
		coord.xy=offset[i].x*distfact;
		coord.xy*=pow(2.0*length(float2(distfact.x*ScreenSize.z/LensSize,distfact.y/ LensSize)), offset[i].y);
		coord.xy*=offset[i].z;
		coord.xy=0.5-coord.xy;//v1
//		coord.xy=In.txcoord0.xy-coord.xy;//v2


		float3	templens=tex2D(SamplerBloom2, coord.xy);
		templens=templens*factors[i];
		distfact=(coord.xy-0.5);
		distfact*=2.0;
		templens*=saturate(1.0-dot(distfact,distfact));//limit by uv 0..1
//		templens=factors[i] * (1.0-dot(distfact,distfact));
		float	maxlens=max(templens.x, max(templens.y, templens.z));
//		float3	tempnor=(templens.xyz/maxlens);
//		tempnor=pow(tempnor, tempF1.z);
//		templens.xyz=tempnor.xyz*maxlens;
		float	tempnor=(maxlens/(1.0+maxlens));
		tempnor=pow(tempnor, LensParameters.y);
		templens.xyz*=tempnor;

		res.xyz+=templens;
	}
	res.xyz*=LensIntensity*LensParameters.x;	
	
	
	
	//add mask
	{
		coord=In.txcoord0.xy;
		coord.y*=ScreenSize.w;//remove stretching of image
		float4	mask=tex2D(SamplerMask, coord);
		float3 templensM=tex2D(SamplerBloom2, In.txcoord0.xy);
		float	maxlens=max(templensM.x, max(templensM.y, templensM.z));
		float	tempnor=(maxlens/(1.0+maxlens));
		tempnor=pow(tempnor, LensParameters.w);
		templensM.xyz*=tempnor * LensParameters.z;
		res.xyz+=mask.xyz * templensM.xyz;
	}

	return res;
}

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++
//for ALF Effect
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++


float3 BrightPass(float2 tex, float BrightPassThreshold)
{
	float3 c = tex2D(SamplerBloom2, tex).rgb;
	float lum = dot(c, float3(0.212, 0.716, 0.072)); // Rec.709 coefficients
	float lum2 = max(lum - BrightPassThreshold, 0.0f);
	return c*= lum2 / lum;
}


/*
float3 BrightPass(float2 tex, float BrightPassThreshold)
{
	float3 c = tex2D(SamplerBloom2, tex).rgb;
	float3 bC = max(c - float3(BrightPassThreshold, BrightPassThreshold, BrightPassThreshold), 0.0);
	return lerp(0.0, c, smoothstep(0.0, 0.5, (bC.x + bC.y + bC.z)));
}		
*/



float4 PS_AnamorphicLensFlare(VS_OUTPUT_POST In, float2 vPos : VPOS) : COLOR
{
	float4 res;
	
	float FlareCurve[2] = {	FlareCurve1, FlareCurve2};	
	float FlareIntensity[2] = 
	{	
		lerp(lerp(FlareIntensity1N, FlareIntensity1D, ENightDayFactor), FlareIntensity1I, EInteriorFactor),
		lerp(lerp(FlareIntensity2N, FlareIntensity2D, ENightDayFactor), FlareIntensity2I, EInteriorFactor)
	};		
	
	float FlareThreshold[2] = 
	{ 
		lerp(lerp(FlareThreshold1N, FlareThreshold1D, ENightDayFactor), FlareThreshold1I, EInteriorFactor),
		lerp(lerp(FlareThreshold2N, FlareThreshold2D, ENightDayFactor), FlareThreshold2I, EInteriorFactor)
	};
	
	float FlareAngle[2] = { (FlareAngle1 - 90), (FlareAngle2 - 90)};
	
for(int i = 0; i < 2; i++)
{
	float3 FlareTint[2] = { FlareTint1, FlareTint2};  
	float3 BaseTint[2] = {	FlareTint[i], float3 (1.0f, 1.0f, 1.0f)};
	float2 startcoord = 0;
	float2 Dvector = 0;	
	sincos( FlareAngle[i]  * 0.017453292, Dvector.y, Dvector.x); //set angle between 0~180

	if ( Dvector.x != 0)//get starting point
	{	
		float slope = Dvector.y / Dvector.x;		//get slope		 
		float yintercept  = ( -In.txcoord0.x * slope ) +  In.txcoord0.y;//get y intercept 
		if( yintercept > 1)                          
			startcoord.xy = float2( (1-In.txcoord0.y)/slope + In.txcoord0.x, 1);
		else if( yintercept < 0)
			startcoord.xy = float2(( -In.txcoord0.y / slope + In.txcoord0.x), 0);
		else
			startcoord.xy = float2( 0, yintercept);
	}
	else //for vertical line
		startcoord.xy = float2( In.txcoord0.x, 0); 
	
	for(int j = 0; j < 2; j++)
	{		
		float2 tex = startcoord;
		float3 ALFtemp =0;
		float2 maxpos=0;
		float3 BrightSample = 0;
		
		for(int i = 0; i < 30; i++)
		{
					ALFtemp = BrightPass(tex, FlareThreshold[j]);
					if(length(ALFtemp) > length(BrightSample))
						maxpos.xy = tex.xy;
					BrightSample.xyz = max(ALFtemp, BrightSample);
					tex.xy += Dvector.xy * 0.05;
					
		}
		res.rgb += BrightSample * pow(0.2, length( In.txcoord0.xy - maxpos) * FlareCurve[j]) * FlareIntensity[j] * BaseTint[j];	
	}
}
	res.a = 1.0;	
	return res;
}



//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++




//blurring may required when quality of blurring is too bad for bilinear filtering on screen
float4	PS_LensPostPass(VS_OUTPUT_POST In) : COLOR
{
	float4	res = 0;

	//blur
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
//	float2 screenfact=TempParameters.y;
//	screenfact.y*=ScreenSize.z;
	float2 screenfact=ScreenSize.y;
	screenfact.y*=ScreenSize.z;
		for (int i=0; i<8; i++)
		{
			float2	coord= radii*offset[i].xy*screenfact.xy+In.txcoord0.xy;
			res.xyz+= tex2D(SamplerColor, coord);
		}
	res.xyz*=0.125;
	res.xyz=min(res.xyz, 32768.0f);
	res.xyz=max(res.xyz, 0.0);
/*
	//no blur
	res=tex2D(SamplerColor, In.txcoord0.xy);
	res.xyz=min(res.xyz, 32768.0);
	res.xyz=max(res.xyz, 0.0);
*/
	return res;

	
}


//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//actual computation, draw all effects to small texture


technique Draw
{	
	pass p0
    {
	VertexShader = compile vs_3_0 VS_Draw();
	PixelShader  = compile ps_3_0 PS_Draw();

	ColorWriteEnable=ALPHA|RED|GREEN|BLUE;
	CullMode=NONE;
	AlphaBlendEnable=FALSE;
	AlphaTestEnable=FALSE;
	SeparateAlphaBlendEnable=FALSE;
	SRGBWriteEnable=FALSE;
	}


	pass p1
	{
	VertexShader = compile vs_3_0 VS_Draw();
	PixelShader  = compile ps_3_0 PS_AnamorphicLensFlare();
    ColorWriteEnable=ALPHA|RED|GREEN|BLUE;
	AlphaBlendEnable = True;
    SrcBlend = One;
    DestBlend = One;
	}

}


//final pass, output to screen with additive blending and no alpha
technique LensPostPass
{
	pass p0
    {
	VertexShader = compile vs_3_0 VS_Draw();
	PixelShader  = compile ps_3_0 PS_LensPostPass();

	AlphaBlendEnable=TRUE;
	SrcBlend=ONE;
	DestBlend=ONE;
	ColorWriteEnable=RED|GREEN|BLUE;//warning, no alpha output!
	CullMode=NONE;
	AlphaTestEnable=FALSE;
	SeparateAlphaBlendEnable=FALSE;
	SRGBWriteEnable=FALSE;
	}	
}	





	


