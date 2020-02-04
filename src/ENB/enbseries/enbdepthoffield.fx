//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// ENBSeries effect file
// visit http://enbdev.com for updates
// Copyright © 2007-2011 Boris Vorontsov
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// 0915v2
// edited by gp65cj04
// GUI & tweaks by ericking1992
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


//+++++++++++++++++++++++++++++
//internal parameters, can be modified
//+++++++++++++++++++++++++++++

//#define NOT_BLURRING_SKY_MODE

#define DEPTH_OF_FIELD_QULITY 3
#define MIX_FOCUS
#define TILT_SHIFT
#define POLYGONAL_BOKEH


int POLYGON <
	string UIName="Bokeh Shape";
	string UIWidget="spinner";
	int UIMax=4;
	int UIMin=0;
> = {1};

float BOKEH_ANGLE <
	string UIName="Bokeh Shape Angle";
	string UIWidget="spinner";
	float UIMax=360;
	float UIMin=0;
	float UIStep=1;
> = {0};




bool MF_MODE <
	string UIName="MF mode";
> = {false};

extern int AF;
extern int MF;


float FPx <
	string UIName="AF pos X ";
	string UIWidget="Slider";
	string help="Left end of screen = 0";
	float UIMin=0.00;
	float UIMax=1.00;
	float UIStep=0.001;
> = {0.5};
float FPy <
	string UIName="AF pos Y ";
	string UIWidget="Slider";
	string help="Upper end of screen = 0";
	float UIMin=0.00;
	float UIMax=1.00;
	float UIStep=0.001;
> = {0.5};


float FocusSampleRange <
	string UIName="AF Sample Range";
	string UIWidget="Slider";
	float UIMin=0.00;
	float UIMax=10.00;
> = {1.00};

float NearBlurCurve <
	string UIName="AF Near Blur Curve";
	string UIWidget="Slider";
	float UIMin=0.00;
	float UIMax=1000.00;
> = {12.00};

float FarBlurCurve <
	string UIName="AF Far Blur Curve";
	string UIWidget="Slider";
	float UIMin=0.00;
	float UIMax=1000.00;
> = {2.00};

float DepthClip=12000.0;

// for static dof
float FocalPlaneDepth <
	string UIName="MF Focal Plane";
	string UIWidget="Slider";
	float UIMin=0.00;
	float UIMax=1000.00;
> = {0.00};

float FarBlurDepth <
	string UIName="MF Far Blur Plane";
	string UIWidget="Slider";
	float UIMin=0.00;
	float UIMax=1000.00;
> = {170.00};

float BlurStrength <
	string UIName="Blur Strength";
	string UIWidget="Spinner";
	float UIMin=1.0;
	float UIMax=100;
> = {1};

// for tilt shift
float TiltShiftAngle <
	string UIName="Tilt Shift Angle";
	string UIWidget="Slider";
	float UIMin=0.00;
	float UIMax=1000.00;
> = {32.00};

// common
float BokehBias <
	string UIName="Bokeh Bias";
	string UIWidget="Slider";
	float UIMin=0.00;
	float UIMax=1000.00;
> = {0.0012};

float BokehBiasCurve <
	string UIName="Bokeh Bias Curve";
	string UIWidget="Slider";
	float UIMin=0.00;
	float UIMax=1000.00;
> = {0.75};
float BokehBrightnessThreshold <
	string UIName="Bokeh Brifhtness Threshold";
	string UIWidget="Slider";
	float UIMin=0.00;
	float UIMax=1000.00;
> = {1.00};
float BokehBrightnessMultipiler <
	string UIName="Bokeh Brightness Multipiler";
	string UIWidget="Slider";
	float UIMin=0.00;
	float UIMax=1000.00;
> = {0.00};

float RadiusSacleMultipiler <
	string UIName="Bokeh Radius";
	string UIWidget="Slider";
	float UIMin=0.00;
	float UIMax=1000.00;
> = {2.50};

float ChromaticAberrationAmount <
	string UIName="Bokeh Chromatic Aberration";
	string UIWidget="Slider";
	float UIMin=0.00;
	float UIMax=1000.00;
> = {0.25};

// noise grain
float NoiseAmount <
	string UIName="Noise Amount";
	string UIWidget="Slider";
	float UIMin=0.00;
	float UIMax=100.00;
> = {0.079};

float NoiseCurve <
	string UIName="Noise Curve";
	string UIWidget="Slider";
	float UIMin=0.00;
	float UIMax=1.00;
> = {0.999};




//+++++++++++++++++++++++++++++
//external parameters, do not modify
//+++++++++++++++++++++++++++++
//keyboard controlled temporary variables (in some versions exists in the config file). Press and hold key 1,2,3...8 together with PageUp or PageDown to modify. By default all set to 1.0
float4 tempF1; //0,1,2,3
float4 tempF2; //5,6,7,8
float4 tempF3; //9,0
//x=Width, y=1/Width, z=ScreenScaleY, w=1/ScreenScaleY
float4 ScreenSize;
//x=generic timer in range 0..1, period of 16777216 ms (4.6 hours), w=frame time elapsed (in seconds)
float4 Timer;
//adaptation delta time for focusing
float FadeFactor;



//textures
texture2D texColor;
texture2D texDepth;
texture2D texNoise;
texture2D texPalette;
texture2D texFocus; //computed focusing depth
texture2D texCurr; //4*4 texture for focusing
texture2D texPrev; //4*4 texture for focusing

sampler2D SamplerColor = sampler_state
{
Texture = <texColor>;
MinFilter = LINEAR;
MagFilter = LINEAR;
MipFilter = NONE;//NONE;
AddressU = Clamp;
AddressV = Clamp;
SRGBTexture=FALSE;
MaxMipLevel=0;
MipMapLodBias=0;
};

sampler2D SamplerDepth = sampler_state
{
Texture = <texDepth>;
MinFilter = POINT;
MagFilter = POINT;
MipFilter = NONE;
AddressU = Clamp;
AddressV = Clamp;
SRGBTexture=FALSE;
MaxMipLevel=0;
MipMapLodBias=0;
};

sampler2D SamplerNoise = sampler_state
{
Texture = <texNoise>;
MinFilter = POINT;
MagFilter = POINT;
MipFilter = NONE;//NONE;
AddressU = Wrap;
AddressV = Wrap;
SRGBTexture=FALSE;
MaxMipLevel=0;
MipMapLodBias=0;
};

sampler2D SamplerPalette = sampler_state
{
Texture = <texPalette>;
MinFilter = LINEAR;
MagFilter = LINEAR;
MipFilter = NONE;//NONE;
AddressU = Clamp;
AddressV = Clamp;
SRGBTexture=FALSE;
MaxMipLevel=0;
MipMapLodBias=0;
};

//for focus computation
sampler2D SamplerCurr = sampler_state
{
Texture = <texCurr>;
MinFilter = LINEAR;
MagFilter = LINEAR;
MipFilter = LINEAR;//NONE;
AddressU = Clamp;
AddressV = Clamp;
SRGBTexture=FALSE;
MaxMipLevel=0;
MipMapLodBias=0;
};

//for focus computation
sampler2D SamplerPrev = sampler_state
{
Texture = <texPrev>;
MinFilter = LINEAR;
MagFilter = LINEAR;
MipFilter = NONE;
AddressU = Clamp;
AddressV = Clamp;
SRGBTexture=FALSE;
MaxMipLevel=0;
MipMapLodBias=0;
};
//for dof only in PostProcess techniques
sampler2D SamplerFocus = sampler_state
{
Texture = <texFocus>;
MinFilter = LINEAR;
MagFilter = LINEAR;
MipFilter = NONE;
AddressU = Clamp;
AddressV = Clamp;
SRGBTexture=FALSE;
MaxMipLevel=0;
MipMapLodBias=0;
};

struct VS_OUTPUT_POST
{
float4 vpos : POSITION;
float2 txcoord : TEXCOORD0;
};

struct VS_INPUT_POST
{
float3 pos : POSITION;
float2 txcoord : TEXCOORD0;
};



////////////////////////////////////////////////////////////////////
//begin focusing code
////////////////////////////////////////////////////////////////////
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
VS_OUTPUT_POST VS_Focus(VS_INPUT_POST IN)
{
VS_OUTPUT_POST OUT;

float4 pos=float4(IN.pos.x,IN.pos.y,IN.pos.z,1.0);

OUT.vpos=pos;
OUT.txcoord.xy=IN.txcoord.xy;

return OUT;
}


float linearlizeDepth(float nonlinearDepth)
{
float2 dofProj=float2(0.0509804, 3098.0392);
float2 dofDist=float2(0.0, 0.0509804);

float4 depth=nonlinearDepth;


depth.y=-dofProj.x + dofProj.y;
depth.y=1.0/depth.y;
depth.z=depth.y * dofProj.y;
depth.z=depth.z * -dofProj.x;
depth.x=dofProj.y * -depth.y + depth.x;
depth.x=1.0/depth.x;

depth.y=depth.z * depth.x;

depth.x=depth.z * depth.x - dofDist.y;
depth.x+=dofDist.x * -0.5;

depth.x=max(depth.x, 0.0);

return depth.x;
}


//SRCpass1X=ScreenWidth;
//SRCpass1Y=ScreenHeight;
//DESTpass2X=4;
//DESTpass2Y=4;
float4 PS_ReadFocus(VS_OUTPUT_POST IN) : COLOR
{

float2 uvsrc;
uvsrc.x = FPx;
uvsrc.y = FPy;

float2 pixelSize=ScreenSize.y;
pixelSize.y*=ScreenSize.z;

const float2 offset[4]=
{
float2(0.0, 1.0),
float2(0.0, -1.0),
float2(1.0, 0.0),
float2(-1.0, 0.0)
};

float res=linearlizeDepth(tex2D(SamplerDepth, uvsrc.xy).x);
for (int i=0; i<4; i++)
{
uvsrc.xy=uvsrc.xy;
uvsrc.xy+=offset[i] * pixelSize.xy * FocusSampleRange;
#ifdef NOT_BLURRING_SKY_MODE
res+=linearlizeDepth(tex2D(SamplerDepth, uvsrc).x);
#else
res+=min(linearlizeDepth(tex2D(SamplerDepth, uvsrc).x), DepthClip);
#endif
}
res*=0.2;




return res;
}



//SRCpass1X=4;
//SRCpass1Y=4;
//DESTpass2X=4;
//DESTpass2Y=4;
float4 PS_WriteFocus(VS_OUTPUT_POST IN) : COLOR
{

float2 uvsrc;
uvsrc.x = FPx;
uvsrc.y = FPy;


float res=0.0;
float curr=tex2D(SamplerCurr, uvsrc.xy).x;
float prev=tex2D(SamplerPrev, uvsrc.xy).x;


res=lerp(prev, curr, saturate(FadeFactor));//time elapsed factor

return res;
}



//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


technique ReadFocus
{
pass P0
{
VertexShader = compile vs_3_0 VS_Focus();
PixelShader = compile ps_3_0 PS_ReadFocus();

ZEnable=FALSE;
CullMode=NONE;
ALPHATESTENABLE=FALSE;
SEPARATEALPHABLENDENABLE=FALSE;
AlphaBlendEnable=FALSE;
FogEnable=FALSE;
SRGBWRITEENABLE=FALSE;
}
}



technique WriteFocus
{
pass P0
{
VertexShader = compile vs_3_0 VS_Focus();
PixelShader = compile ps_3_0 PS_WriteFocus();

ZEnable=FALSE;
CullMode=NONE;
ALPHATESTENABLE=FALSE;
SEPARATEALPHABLENDENABLE=FALSE;
AlphaBlendEnable=FALSE;
FogEnable=FALSE;
SRGBWRITEENABLE=FALSE;
}
}


////////////////////////////////////////////////////////////////////
//end focusing code
////////////////////////////////////////////////////////////////////



//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
VS_OUTPUT_POST VS_PostProcess(VS_INPUT_POST IN)
{
VS_OUTPUT_POST OUT;

float4 pos=float4(IN.pos.x,IN.pos.y,IN.pos.z,1.0);

OUT.vpos=pos;
OUT.txcoord.xy=IN.txcoord.xy;

return OUT;
}



float4 PS_ProcessPass1(VS_OUTPUT_POST IN, float2 vPos : VPOS) : COLOR
{
float4 res;
float2 coord=IN.txcoord.xy;

float4 origcolor=tex2D(SamplerColor, coord.xy);
float scenedepth=tex2D(SamplerDepth, IN.txcoord.xy).x;
float scenefocus=tex2D(SamplerFocus, 0.5).x;
res.xyz=origcolor.xyz;

int AF=(MF_MODE == true) ? 0 : 1;
int MF=(MF_MODE == true) ? 1 : 0;

float depth=linearlizeDepth(scenedepth);

#ifdef MIX_FOCUS
float focalPlaneDepth=scenefocus*AF + FocalPlaneDepth*MF;
float farBlurDepth=scenefocus*pow(4.0, FarBlurCurve)*AF + FarBlurDepth*MF;
#endif

#ifdef TILT_SHIFT
float shiftAngle=(frac(TiltShiftAngle / 90.0) == 0) ? 0.0 : TiltShiftAngle;
float depthShift=1.0 + (0.5 - coord.x)*tan(-shiftAngle * 0.017453292);
focalPlaneDepth*=depthShift;
farBlurDepth*=depthShift;
#endif


if(depth < focalPlaneDepth)
res.w=(depth - focalPlaneDepth)/focalPlaneDepth;
else
{
res.w=(depth - focalPlaneDepth)/(farBlurDepth - focalPlaneDepth);
res.w=saturate(res.w);
}

res.w=res.w * 0.5 + 0.5;

#ifdef NOT_BLURRING_SKY_MODE
#define DEPTH_OF_FIELD_QULITY 0
res.w=(depth > 1000.0) ? 0.5 : res.w;
#endif


return res;
}
//////////////////////////////////Bokeh////////////////////////////////////////////////

float4 PS_ProcessPass2(VS_OUTPUT_POST IN, float2 vPos : VPOS) : COLOR
{
float4 res;

float2 coord=IN.txcoord.xy;
float4 origcolor=tex2D(SamplerColor, coord.xy);
float centerDepth=origcolor.w;
float2 pixelSize=ScreenSize.y;
pixelSize.y*=ScreenSize.z;

int AF=(MF_MODE == true) ? 0 : 1;
int MF=(MF_MODE == true) ? 1 : 0;

float blurAmount=abs(centerDepth * 2.0 - 1.0);
float discRadius=blurAmount * float(DEPTH_OF_FIELD_QULITY) * RadiusSacleMultipiler;


#ifdef MIX_FOCUS
	float discA = discRadius;
	discA *= (centerDepth < 0.5) ? (1.0 / max(NearBlurCurve, 1.0)) : 1.0;
	discRadius = discA * AF + discRadius * MF;
#endif


res.xyz=origcolor.xyz;
res.w=dot(res.xyz, 0.3333);
res.w=max((res.w - BokehBrightnessThreshold) * BokehBrightnessMultipiler, 0.0);
res.xyz*=1.0 + res.w*blurAmount*BlurStrength;

res.w=1.0;

int sampleCycle=0;
int sampleCycleCounter=0;
int sampleCounterInCycle=0;

#ifdef POLYGONAL_BOKEH
	int dofTaps=DEPTH_OF_FIELD_QULITY * (DEPTH_OF_FIELD_QULITY + 1) * 4;
#endif

for(int i=0; i < dofTaps; i++)
{
	if(sampleCounterInCycle % sampleCycle == 0)
	{
		sampleCounterInCycle=0;
		sampleCycleCounter++;

		#ifdef POLYGONAL_BOKEH
			sampleCycle+=8;
		#endif

	}
	sampleCounterInCycle++;

	#ifdef POLYGONAL_BOKEH
		float sampleAngle=0.78539816 / float(sampleCycleCounter) * sampleCounterInCycle;
		float2 sampleOffset;
		sincos(sampleAngle, sampleOffset.y, sampleOffset.x);
	#endif

	sampleOffset*=sampleCycleCounter / float(DEPTH_OF_FIELD_QULITY);
	float2 coordLow=coord.xy + (pixelSize.xy * sampleOffset.xy * discRadius);
	float4 tap=tex2D(SamplerColor, coordLow.xy);

	float weight=(tap.w >= centerDepth) ? 1.0 : abs(tap.w * 2.0 - 1.0);

	float luma=dot(tap.xyz, 0.3333);
	float brightMultipiler=max((luma - BokehBrightnessThreshold) * BokehBrightnessMultipiler, 0.0);
	tap.xyz*=1.0 + brightMultipiler*abs(tap.w*2.0 - 1.0);

	tap.xyz*=1.0 + BokehBias * pow(float(sampleCycleCounter)/float(DEPTH_OF_FIELD_QULITY), BokehBiasCurve);

	res.xyz+=tap.xyz * weight;
	res.w+=weight;
}

res.xyz /= res.w;

res.w=centerDepth;


return res;
}

float4 PS_ProcessPass2P3(VS_OUTPUT_POST IN, float2 vPos : VPOS) : COLOR
{
float4 res;

float2 coord=IN.txcoord.xy;
float4 origcolor=tex2D(SamplerColor, coord.xy);
float centerDepth=origcolor.w;
float2 pixelSize=ScreenSize.y;
pixelSize.y*=ScreenSize.z;

int AF=(MF_MODE == true) ? 0 : 1;
int MF=(MF_MODE == true) ? 1 : 0;


float blurAmount=abs(centerDepth * 2.0 - 1.0);
float discRadius=blurAmount * float(DEPTH_OF_FIELD_QULITY) * RadiusSacleMultipiler;


#ifdef MIX_FOCUS
	float discA = discRadius;
	discA *= (centerDepth < 0.5) ? (1.0 / max(NearBlurCurve, 1.0)) : 1.0;
	discRadius = discA * AF + discRadius * MF;
#endif


res.xyz=origcolor.xyz;
res.w=dot(res.xyz, 0.3333);
res.w=max((res.w - BokehBrightnessThreshold) * BokehBrightnessMultipiler, 0.0);
res.xyz*=1.0 + res.w*blurAmount*BlurStrength;

res.w=1.0;

int sampleCycle=0;
int sampleCycleCounter=0;
int sampleCounterInCycle=0;



#ifdef POLYGONAL_BOKEH
	float basedAngle=360.0 / 3;
	float2 currentVertex;
	float2 nextVertex;
	int dofTaps=DEPTH_OF_FIELD_QULITY * (DEPTH_OF_FIELD_QULITY + 1) * 3 / 2.0;
#endif

for(int i=0; i < dofTaps; i++)
{
	if(sampleCounterInCycle % sampleCycle == 0)
	{
		sampleCounterInCycle=0;
		sampleCycleCounter++;

		#ifdef POLYGONAL_BOKEH
			sampleCycle+=3;
			sincos(BOKEH_ANGLE* 0.017453292, currentVertex.y, currentVertex.x);
			sincos((basedAngle + BOKEH_ANGLE)* 0.017453292, nextVertex.y, nextVertex.x);
		#endif
	}
	sampleCounterInCycle++;

	#ifdef POLYGONAL_BOKEH
		float sampleAngle=basedAngle / float(sampleCycleCounter) * sampleCounterInCycle;
		float remainAngle=frac(sampleAngle / basedAngle) * basedAngle;

		if(remainAngle == 0)
		{
			currentVertex=nextVertex;
			sincos((sampleAngle + basedAngle + BOKEH_ANGLE) * 0.017453292, nextVertex.y, nextVertex.x);
		}
		float2 sampleOffset=lerp(currentVertex.xy, nextVertex.xy, remainAngle / basedAngle);
	#endif

	sampleOffset*=sampleCycleCounter / float(DEPTH_OF_FIELD_QULITY);
	float2 coordLow=coord.xy + (pixelSize.xy * sampleOffset.xy * discRadius);
	float4 tap=tex2D(SamplerColor, coordLow.xy);

	float weight=(tap.w >= centerDepth) ? 1.0 : abs(tap.w * 2.0 - 1.0);

	float luma=dot(tap.xyz, 0.3333);
	float brightMultipiler=max((luma - BokehBrightnessThreshold) * BokehBrightnessMultipiler, 0.0);
	tap.xyz*=1.0 + brightMultipiler*abs(tap.w*2.0 - 1.0);

	tap.xyz*=1.0 + BokehBias * pow(float(sampleCycleCounter)/float(DEPTH_OF_FIELD_QULITY), BokehBiasCurve);

	res.xyz+=tap.xyz * weight;
	res.w+=weight;
}

res.xyz /= res.w;

res.w=centerDepth;


return res;
}



float4 PS_ProcessPass2P4(VS_OUTPUT_POST IN, float2 vPos : VPOS) : COLOR
{
float4 res;

float2 coord=IN.txcoord.xy;
float4 origcolor=tex2D(SamplerColor, coord.xy);
float centerDepth=origcolor.w;
float2 pixelSize=ScreenSize.y;
pixelSize.y*=ScreenSize.z;

int AF=(MF_MODE == true) ? 0 : 1;
int MF=(MF_MODE == true) ? 1 : 0;


float blurAmount=abs(centerDepth * 2.0 - 1.0);
float discRadius=blurAmount * float(DEPTH_OF_FIELD_QULITY) * RadiusSacleMultipiler;


#ifdef MIX_FOCUS
	float discA = discRadius;
	discA *= (centerDepth < 0.5) ? (1.0 / max(NearBlurCurve, 1.0)) : 1.0;
	discRadius = discA * AF + discRadius * MF;
#endif

res.xyz=origcolor.xyz;
res.w=dot(res.xyz, 0.3333);
res.w=max((res.w - BokehBrightnessThreshold) * BokehBrightnessMultipiler, 0.0);
res.xyz*=1.0 + res.w*blurAmount;

res.w=1.0;

int sampleCycle=0;
int sampleCycleCounter=0;
int sampleCounterInCycle=0;



#ifdef POLYGONAL_BOKEH
	float basedAngle=360.0 / 4;
	float2 currentVertex;
	float2 nextVertex;
	int dofTaps=DEPTH_OF_FIELD_QULITY * (DEPTH_OF_FIELD_QULITY + 1) * 4 / 2.0;
#endif

for(int i=0; i < dofTaps; i++)
{
	if(sampleCounterInCycle % sampleCycle == 0)
	{
		sampleCounterInCycle=0;
		sampleCycleCounter++;
		
		#ifdef POLYGONAL_BOKEH
			sampleCycle+=4;
			sincos(BOKEH_ANGLE* 0.017453292, currentVertex.y, currentVertex.x);
			sincos((basedAngle + BOKEH_ANGLE)* 0.017453292, nextVertex.y, nextVertex.x);
		#endif
	}
	sampleCounterInCycle++;
	#ifdef POLYGONAL_BOKEH
		float sampleAngle=basedAngle / float(sampleCycleCounter) * sampleCounterInCycle;
		float remainAngle=frac(sampleAngle / basedAngle) * basedAngle;

		if(remainAngle == 0)
		{
			currentVertex=nextVertex;
			sincos((sampleAngle + basedAngle + BOKEH_ANGLE) * 0.017453292, nextVertex.y, nextVertex.x);
		}

		float2 sampleOffset=lerp(currentVertex.xy, nextVertex.xy, remainAngle / basedAngle);
	#endif

	sampleOffset*=sampleCycleCounter / float(DEPTH_OF_FIELD_QULITY);
	float2 coordLow=coord.xy + (pixelSize.xy * sampleOffset.xy * discRadius);
	float4 tap=tex2D(SamplerColor, coordLow.xy);

	float weight=(tap.w >= centerDepth) ? 1.0 : abs(tap.w * 2.0 - 1.0);

	float luma=dot(tap.xyz, 0.3333);
	float brightMultipiler=max((luma - BokehBrightnessThreshold) * BokehBrightnessMultipiler, 0.0);
	tap.xyz*=1.0 + brightMultipiler*abs(tap.w*2.0 - 1.0);

	tap.xyz*=1.0 + BokehBias * pow(float(sampleCycleCounter)/float(DEPTH_OF_FIELD_QULITY), BokehBiasCurve);

	res.xyz+=tap.xyz * weight;
	res.w+=weight;
}

res.xyz /= res.w;

res.w=centerDepth;


return res;
}

float4 PS_ProcessPass2P5(VS_OUTPUT_POST IN, float2 vPos : VPOS) : COLOR
{
float4 res;

float2 coord=IN.txcoord.xy;
float4 origcolor=tex2D(SamplerColor, coord.xy);
float centerDepth=origcolor.w;
float2 pixelSize=ScreenSize.y;
pixelSize.y*=ScreenSize.z;

int AF=(MF_MODE == true) ? 0 : 1;
int MF=(MF_MODE == true) ? 1 : 0;

float blurAmount=abs(centerDepth * 2.0 - 1.0);
float discRadius=blurAmount * float(DEPTH_OF_FIELD_QULITY) * RadiusSacleMultipiler;

#ifdef MIX_FOCUS
	float discA = discRadius;
	discA *= (centerDepth < 0.5) ? (1.0 / max(NearBlurCurve, 1.0)) : 1.0;
	discRadius = discA * AF + discRadius * MF;
#endif

res.xyz=origcolor.xyz;
res.w=dot(res.xyz, 0.3333);
res.w=max((res.w - BokehBrightnessThreshold) * BokehBrightnessMultipiler, 0.0);
res.xyz*=1.0 + res.w*blurAmount;

res.w=1.0;

int sampleCycle=0;
int sampleCycleCounter=0;
int sampleCounterInCycle=0;



#ifdef POLYGONAL_BOKEH
	float basedAngle=360.0 / 5;
	float2 currentVertex;
	float2 nextVertex;

	int dofTaps=DEPTH_OF_FIELD_QULITY * (DEPTH_OF_FIELD_QULITY + 1) * 5 / 2.0;
#endif

for(int i=0; i < dofTaps; i++)
{
	if(sampleCounterInCycle % sampleCycle == 0)
	{
		sampleCounterInCycle=0;
		sampleCycleCounter++;

		#ifdef POLYGONAL_BOKEH
			sampleCycle+=5;
			sincos(BOKEH_ANGLE* 0.017453292, currentVertex.y, currentVertex.x);
			sincos((basedAngle + BOKEH_ANGLE)* 0.017453292, nextVertex.y, nextVertex.x);
		#endif
	}
	sampleCounterInCycle++;

	#ifdef POLYGONAL_BOKEH
		float sampleAngle=basedAngle / float(sampleCycleCounter) * sampleCounterInCycle;
		float remainAngle=frac(sampleAngle / basedAngle) * basedAngle;

		if(remainAngle == 0)
		{
			currentVertex=nextVertex;
			sincos((sampleAngle + basedAngle + BOKEH_ANGLE) * 0.017453292, nextVertex.y, nextVertex.x);
		}
		float2 sampleOffset=lerp(currentVertex.xy, nextVertex.xy, remainAngle / basedAngle);
	#endif

	sampleOffset*=sampleCycleCounter / float(DEPTH_OF_FIELD_QULITY);
	float2 coordLow=coord.xy + (pixelSize.xy * sampleOffset.xy * discRadius);
	float4 tap=tex2D(SamplerColor, coordLow.xy);

	float weight=(tap.w >= centerDepth) ? 1.0 : abs(tap.w * 2.0 - 1.0);

	float luma=dot(tap.xyz, 0.3333);
	float brightMultipiler=max((luma - BokehBrightnessThreshold) * BokehBrightnessMultipiler, 0.0);
	tap.xyz*=1.0 + brightMultipiler*abs(tap.w*2.0 - 1.0);

	tap.xyz*=1.0 + BokehBias * pow(float(sampleCycleCounter)/float(DEPTH_OF_FIELD_QULITY), BokehBiasCurve);

	res.xyz+=tap.xyz * weight;
	res.w+=weight;
}

res.xyz /= res.w;

res.w=centerDepth;


return res;
}

float4 PS_ProcessPass2P6(VS_OUTPUT_POST IN, float2 vPos : VPOS) : COLOR
{
float4 res;

float2 coord=IN.txcoord.xy;
float4 origcolor=tex2D(SamplerColor, coord.xy);
float centerDepth=origcolor.w;
float2 pixelSize=ScreenSize.y;
pixelSize.y*=ScreenSize.z;

int AF=(MF_MODE == true) ? 0 : 1;
int MF=(MF_MODE == true) ? 1 : 0;

float blurAmount=abs(centerDepth * 2.0 - 1.0);
float discRadius=blurAmount * float(DEPTH_OF_FIELD_QULITY) * RadiusSacleMultipiler;

#ifdef MIX_FOCUS
	float discA = discRadius;
	discA *= (centerDepth < 0.5) ? (1.0 / max(NearBlurCurve, 1.0)) : 1.0;
	discRadius = discA * AF + discRadius * MF;
#endif

res.xyz=origcolor.xyz;
res.w=dot(res.xyz, 0.3333);
res.w=max((res.w - BokehBrightnessThreshold) * BokehBrightnessMultipiler, 0.0);
res.xyz*=1.0 + res.w*blurAmount;

res.w=1.0;

int sampleCycle=0;
int sampleCycleCounter=0;
int sampleCounterInCycle=0;

#ifdef POLYGONAL_BOKEH
	float basedAngle=360.0 / 6;
	float2 currentVertex;
	float2 nextVertex;

	int dofTaps=DEPTH_OF_FIELD_QULITY * (DEPTH_OF_FIELD_QULITY + 1) * 6 / 2.0;
#endif

for(int i=0; i < dofTaps; i++)
{
	if(sampleCounterInCycle % sampleCycle == 0)
	{
		sampleCounterInCycle=0;
		sampleCycleCounter++;

		#ifdef POLYGONAL_BOKEH
			sampleCycle+=6;
			sincos(BOKEH_ANGLE* 0.017453292, currentVertex.y, currentVertex.x);
			sincos((basedAngle + BOKEH_ANGLE)* 0.017453292, nextVertex.y, nextVertex.x);
		#endif

	}
	sampleCounterInCycle++;

	#ifdef POLYGONAL_BOKEH
		float sampleAngle=basedAngle / float(sampleCycleCounter) * sampleCounterInCycle;
		float remainAngle=frac(sampleAngle / basedAngle) * basedAngle;

		if(remainAngle == 0)
		{
			currentVertex=nextVertex;
			sincos((sampleAngle + basedAngle + BOKEH_ANGLE) * 0.017453292, nextVertex.y, nextVertex.x);
		}

		float2 sampleOffset=lerp(currentVertex.xy, nextVertex.xy, remainAngle / basedAngle);
	#endif

	sampleOffset*=sampleCycleCounter / float(DEPTH_OF_FIELD_QULITY);
	float2 coordLow=coord.xy + (pixelSize.xy * sampleOffset.xy * discRadius);
	float4 tap=tex2D(SamplerColor, coordLow.xy);

	float weight=(tap.w >= centerDepth) ? 1.0 : abs(tap.w * 2.0 - 1.0);

	float luma=dot(tap.xyz, 0.3333);
	float brightMultipiler=max((luma - BokehBrightnessThreshold) * BokehBrightnessMultipiler, 0.0);
	tap.xyz*=1.0 + brightMultipiler*abs(tap.w*2.0 - 1.0);

	tap.xyz*=1.0 + BokehBias * pow(float(sampleCycleCounter)/float(DEPTH_OF_FIELD_QULITY), BokehBiasCurve);

	res.xyz+=tap.xyz * weight;
	res.w+=weight;
}

res.xyz /= res.w;

res.w=centerDepth;


return res;
}



float4 PS_ProcessPass3(VS_OUTPUT_POST IN, float2 vPos : VPOS) : COLOR
{
float2 coord=IN.txcoord.xy;

float2 pixelSize=ScreenSize.y;
pixelSize.y*=ScreenSize.z;

float4 origcolor=tex2D(SamplerColor, coord.xy);
float depth=origcolor.w;
float blurAmount=abs(depth * 2.0 - 1.0);
float discRadius=blurAmount * float(DEPTH_OF_FIELD_QULITY) * RadiusSacleMultipiler;

int AF=(MF_MODE == true) ? 0 : 1;
int MF=(MF_MODE == true) ? 1 : 0;


#ifdef MIX_FOCUS
float discA = discRadius;
discA*=(depth < 0.5) ? (1.0 / max(NearBlurCurve, 1.0)) : 1.0;
discRadius = discA* AF + discRadius*MF;
#endif

float4 res=origcolor;

float3 distortion=float3(-1.0, 0.0, 1.0);
distortion*=ChromaticAberrationAmount*discRadius;

origcolor=tex2D(SamplerColor, coord.xy + pixelSize.xy*distortion.x);
origcolor.w=smoothstep(0.0, depth, origcolor.w);
res.x=lerp(res.x, origcolor.x, origcolor.w);

origcolor=tex2D(SamplerColor, coord.xy + pixelSize.xy*distortion.z);
origcolor.w=smoothstep(0.0, depth, origcolor.w);
res.z=lerp(res.z, origcolor.z, origcolor.w);

return res;
}

float4 PS_ProcessPass4(VS_OUTPUT_POST IN, float2 vPos : VPOS) : COLOR
{
float2 coord=IN.txcoord.xy;

float2 pixelSize=ScreenSize.y;
pixelSize.y*=ScreenSize.z;

float4 origcolor=tex2D(SamplerColor, coord.xy);
float depth=origcolor.w;
float blurAmount=abs(depth*2.0 - 1.0);

int AF=(MF_MODE == true) ? 0 : 1;
int MF=(MF_MODE == true) ? 1 : 0;


#if (DEPTH_OF_FIELD_QULITY > 0)
#ifdef MIX_FOCUS
float BA = blurAmount;
BA*=(depth < 0.5) ? (1.0 / max(NearBlurCurve, 1.0)) : 1.0;
blurAmount = BA*AF + blurAmount*MF;
#endif

blurAmount=smoothstep(0.15, 1.0, blurAmount);
#endif

float weight[5] = {0.2270270270, 0.1945945946, 0.1216216216, 0.0540540541,
0.0162162162};

float4 res=origcolor * weight[0];

for(int i=1; i < 5; i++)
{
res+=tex2D(SamplerColor, coord.xy + float2(i*pixelSize.x*blurAmount*BlurStrength, 0)) * weight[i];
res+=tex2D(SamplerColor, coord.xy - float2(i*pixelSize.x*blurAmount*BlurStrength, 0)) * weight[i];
}


res.w=depth;

return res;
}

float4 PS_ProcessPass5(VS_OUTPUT_POST IN, float2 vPos : VPOS) : COLOR
{
float2 coord=IN.txcoord.xy;

float2 pixelSize=ScreenSize.y;
pixelSize.y*=ScreenSize.z;


float4 origcolor=tex2D(SamplerColor, coord.xy);
float depth=origcolor.w;
float blurAmount=abs(depth*2.0 - 1.0);

int AF=(MF_MODE == true) ? 0 : 1;
int MF=(MF_MODE == true) ? 1 : 0;


#if (DEPTH_OF_FIELD_QULITY > 0)
#ifdef MIX_FOCUS
float BA = blurAmount;
BA*=(depth < 0.5) ? (1.0 / max(NearBlurCurve, 1.0)) : 1.0;
blurAmount = BA*AF + blurAmount*MF;
#endif

blurAmount=smoothstep(0.15, 1.0, blurAmount);
#endif

float weight[5] = {0.2270270270, 0.1945945946, 0.1216216216, 0.0540540541,
0.0162162162};
float4 res=origcolor * weight[0];

for(int i=1; i < 5; i++)
{
res+=tex2D(SamplerColor, coord.xy + float2(0, i*pixelSize.y*blurAmount*BlurStrength)) * weight[i];
res+=tex2D(SamplerColor, coord.xy - float2(0, i*pixelSize.y*blurAmount*BlurStrength)) * weight[i];
}


float origgray=dot(res.xyz, 0.3333);
origgray/=origgray + 1.0;
coord.xy=IN.txcoord.xy*16.0 + origgray;
float4 cnoi=tex2D(SamplerNoise, coord);
float noiseAmount=NoiseAmount*pow(blurAmount, NoiseCurve);
res=lerp(res, (cnoi.x+0.5)*res, noiseAmount*saturate(1.0-origgray*1.8));

res.w=depth;


return res;
}


//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
technique PostProcess
{
pass P0
{

VertexShader = compile vs_3_0 VS_PostProcess();
PixelShader = compile ps_3_0 PS_ProcessPass1();

DitherEnable=FALSE;
ZEnable=FALSE;
CullMode=NONE;
ALPHATESTENABLE=FALSE;
SEPARATEALPHABLENDENABLE=FALSE;
AlphaBlendEnable=FALSE;
StencilEnable=FALSE;
FogEnable=FALSE;
SRGBWRITEENABLE=FALSE;
}
}

PixelShader pixelShaders[5] = 
{
    compile ps_3_0 PS_ProcessPass2(),
	compile ps_3_0 PS_ProcessPass2P3(),
	compile ps_3_0 PS_ProcessPass2P4(),
    compile ps_3_0 PS_ProcessPass2P5(),
	compile ps_3_0 PS_ProcessPass2P6(),
};

technique PostProcess2
{
pass P0
{

VertexShader = compile vs_3_0 VS_PostProcess();
PixelShader = pixelShaders[POLYGON];

DitherEnable=FALSE;
ZEnable=FALSE;
CullMode=NONE;
ALPHATESTENABLE=FALSE;
SEPARATEALPHABLENDENABLE=FALSE;
AlphaBlendEnable=FALSE;
StencilEnable=FALSE;
FogEnable=FALSE;
SRGBWRITEENABLE=FALSE;
}
}


technique PostProcess3
{
pass P0
{

VertexShader = compile vs_3_0 VS_PostProcess();
PixelShader = compile ps_3_0 PS_ProcessPass3();

DitherEnable=FALSE;
ZEnable=FALSE;
CullMode=NONE;
ALPHATESTENABLE=FALSE;
SEPARATEALPHABLENDENABLE=FALSE;
AlphaBlendEnable=FALSE;
StencilEnable=FALSE;
FogEnable=FALSE;
SRGBWRITEENABLE=FALSE;
}
}


technique PostProcess4
{
pass P0
{

VertexShader = compile vs_3_0 VS_PostProcess();
PixelShader = compile ps_3_0 PS_ProcessPass4();

DitherEnable=FALSE;
ZEnable=FALSE;
CullMode=NONE;
ALPHATESTENABLE=FALSE;
SEPARATEALPHABLENDENABLE=FALSE;
AlphaBlendEnable=FALSE;
StencilEnable=FALSE;
FogEnable=FALSE;
SRGBWRITEENABLE=FALSE;
}
}

technique PostProcess5
{
pass P0
{

VertexShader = compile vs_3_0 VS_PostProcess();
PixelShader = compile ps_3_0 PS_ProcessPass5();

DitherEnable=FALSE;
ZEnable=FALSE;
CullMode=NONE;
ALPHATESTENABLE=FALSE;
SEPARATEALPHABLENDENABLE=FALSE;
AlphaBlendEnable=FALSE;
StencilEnable=FALSE;
FogEnable=FALSE;
SRGBWRITEENABLE=FALSE;
}
}
