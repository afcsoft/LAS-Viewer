cbuffer ConstantBuffer {
    matrix world;
    float scale;
    float size;
};
struct VOut
{
    float4 position : SV_POSITION;
    float4 color : COLOR; 
};

VOut main(float3 position : POSITION, float4 color : COLOR)
{
    VOut output;
    output.position = float4(position, 1);
    output.color = color;
    return output;
}
