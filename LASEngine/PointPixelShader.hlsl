struct GOut
{
    float4 pos  : SV_POSITION;
    float4 color:COLOR;
    float2 UV:TEXCOORD;
};

float4 main(GOut psin) : SV_TARGET
{

   if (psin.UV.x * psin.UV.x + psin.UV.y * psin.UV.y < 1)
    return psin.color;
    return float4(0, 0, 0, 0);
}