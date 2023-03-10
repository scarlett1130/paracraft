// Spot light

float ViewAspect;
float TanHalfFOV;
float2 screenParam;
float2 viewportOffset;
float2 viewportScale;

float4x4 matWorld;
float4x4 matView;
float4x4 matProj;


float4 light_diffuse;
float4 light_specular;
float4 light_ambient;

float3 light_position;
float3 light_direction;

float light_range;
float light_falloff;

float light_attenuation0;
float light_attenuation1;
float light_attenuation2;

float light_theta;
float light_phi;


texture sourceTexture0;
sampler diffuseSampler : register(s0) = sampler_state
{
    Texture = <sourceTexture0>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = None;
    AddressU = clamp;
    AddressV = clamp;
};

// TODO: specular texture surface 1

texture sourceTexture2;
sampler depthSampler : register(s2) = sampler_state
{
    Texture = <sourceTexture2>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = None;
    AddressU = clamp;
    AddressV = clamp;
};

texture sourceTexture3;
sampler normalSampler : register(s3) = sampler_state
{
    Texture = <sourceTexture3>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = None;
    AddressU = clamp;
    AddressV = clamp;
};


struct VSInput
{
    float4 pos : POSITION;
};

struct VSOut
{
    float4 pos : POSITION;
    float2 texCoord : TEXCOORD0;
    float3 cameraEye : TEXCOORD1;
};

struct PSOut
{
    float4 color : COLOR0;
};

VSOut MainVS(VSInput input)
{
    VSOut output;

    float4 local_pos = input.pos;
    float4x4 matWorldViewProj = mul(mul(matWorld, matView), matProj);
    float4 proj_pos = mul(local_pos, matWorldViewProj);

    output.pos = proj_pos;

    float4 norm_proj_pos = proj_pos / proj_pos.w;
    output.cameraEye = float3(norm_proj_pos.x * TanHalfFOV * ViewAspect, norm_proj_pos.y * TanHalfFOV, 1);

    
    // -0.5, because the tex coord and proj screen coord are opposite
    // 0.5 / screenParam
    // ref https://docs.microsoft.com/en-us/windows/desktop/direct3d10/d3d10-graphics-programming-guide-resources-coordinates
    // and https://docs.microsoft.com/en-us/windows/desktop/direct3d9/directly-mapping-texels-to-pixels

    float2 texCoord = (proj_pos.xy * float2(0.5, -0.5) + float2(0.5, 0.5) * proj_pos.w) / proj_pos.w + 0.5 / screenParam;
    // ????????????????????????/????????????????????????????????? viewport ????????? sample ??????????????????
    output.texCoord = texCoord * viewportScale;

    return output;
}

float dist_factor(float3 object_pos)
{
    float4 light_pos = mul(float4(light_position, 1), matView);
    float dist = distance(object_pos, light_pos.xyz / light_pos.w);

    float dist_att;
    if (dist > light_range)
    {
        dist_att = 0;
    }
    else
    {
        dist_att = 1 / (light_attenuation0 + light_attenuation1 * dist + light_attenuation2 * dist * dist);
    }

    return dist_att;
}

/*
 * diffuse: object material diffuse color
 * normal: object normal vector in camera space
 * position: object position in camera space
 */
float3 lighting(float4 diffuse, float3 normal, float3 position)
{
    float3 I_diff, I_spec, I_total;
    float3 l, v, n, h;
    float att;

    n = normalize(normal);
    v = normalize(-position);

    // FIXME: two test value
    float m_shi = 1;
    float4 m_spec = float4(1, 1, 1, 1);

    att = dist_factor(position);

    // spot light factor reference
    // https://docs.microsoft.com/en-us/windows/desktop/direct3d9/attenuation-and-spotlight-factor#spotlight-factor

    float cos_half_theta = cos(light_theta / 2);
    float cos_half_phi = cos(light_phi / 2);

    // tranform light direction from wolrd into camera space
    float4 light_dir = mul(float4(light_direction, 0), matView);
    float3 norm_light_dir = normalize(light_dir.xyz);

    float4 light_pos = mul(float4(light_position, 1), matView);
    l = normalize(light_pos.xyz / light_pos.w - position);

    // alpha is the angle between light direction vector and light-to-object vector
    float cos_alpha = dot(norm_light_dir, -l);
    float spotlight_factor;

    if (cos_alpha > cos_half_theta)
    {
        spotlight_factor = 1;
    }
    else if (cos_alpha < cos_half_phi)
    {
        spotlight_factor = 0;
    }
    else
    {
        float p = (cos_alpha - cos_half_phi) / (cos_half_theta - cos_half_phi);
        // p is always between 0 and 1, but hlsl compiler doesn't know
        // use abs() here to avoid the hlsl compiler's warning
        spotlight_factor = pow(abs(p), light_falloff);
    }

    att = att * spotlight_factor;

    I_diff = saturate(dot(l, n)) * (diffuse.xyz * light_diffuse.xyz);

    h = normalize(l + v);

    I_spec = saturate(dot(l, n)) * pow(saturate(dot(h, n)), m_shi) * (m_spec.xyz * light_specular.xyz);

    I_total = att * (I_diff + I_spec);
    return I_total;
}

PSOut MainPS(VSOut input)
{
    PSOut output;

    float2 texCoord = input.texCoord;
    float4 color = tex2D(diffuseSampler, texCoord);
    float alpha = color.a;
	
    // if the normal is world space normal value
    float4 norm = tex2D(normalSampler, texCoord);
    float4 normal_in_camera = mul(float4(norm.rgb * 2.0 - 1.0, 0), matView);
    float3 normal = normalize(normal_in_camera.xyz);

	// screen space depth value. 
    float depth = tex2D(depthSampler, texCoord).x;

    // position in camera space
    float4 position = float4(input.cameraEye * depth, 1);

    float3 total_color = color.rgb;
    total_color = total_color + lighting(color, normal.xyz, position.xyz);

    output.color = float4(total_color, alpha);

    return output;
}



struct VS1_IN
{
    float4 pos : POSITION;
};

struct VS1_OUT
{
	float4 pos : POSITION;
};

struct PS1_OUT
{
	float4 Color : COLOR0;
};

VS1_OUT VS1(VS1_IN input)
{
	VS1_OUT output;

    float4 p = input.pos;

    float4x4 matWorldViewProj = mul(mul(matWorld, matView), matProj);
    p = mul(p, matWorldViewProj);

    output.pos = p;

	return output;
}


PS1_OUT PS1(VS1_OUT input)
{
	PS1_OUT output;
    output.Color = float4(1, 0, 0, 1);

	return output;
}

technique LightVolumeMask
{
    pass FrontFace
    {
        VertexShader = compile vs_3_0 VS1();
        PixelShader = compile ps_3_0 PS1();

        ColorWriteEnable = 0;
        //ColorWriteEnable = 0xFFFFFFFF;
        ZWriteEnable = 0;
        ZFunc = LESS;
        StencilEnable = true;
        StencilFunc = ALWAYS;
        StencilZFail = REPLACE;
        StencilPass = KEEP;
        StencilRef = 1;
        StencilMask = 0xFFFFFFFF;
        CullMode = CCW;
    }
    pass BackFace
    {
        VertexShader = compile vs_3_0 MainVS();
        PixelShader = compile ps_3_0 MainPS();

        ColorWriteEnable = 0xFFFFFFFF;
        ZWriteEnable = 0;
        ZFunc = GREATEREQUAL;
        StencilEnable = true;
        StencilFunc = EQUAL;
        StencilPass = KEEP;
        StencilRef = 0;
        StencilMask = 0xFFFFFFFF;
        CullMode = CW;
    }
}
