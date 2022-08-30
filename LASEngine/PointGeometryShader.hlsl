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


struct GOut
{
	float4 pos  : SV_POSITION;
	float4 color:COLOR;
	float2 uv:TEXCOORD;
};



[maxvertexcount(6)]
void main(point VOut input[1], inout TriangleStream<GOut> OutputStream)
{
	
	GOut P1;
	P1.pos = float4(input[0].position.x - size / 2, input[0].position.y - size / 2, input[0].position.z, 1);
	P1.color = input[0].color;
	P1.pos = mul(world, P1.pos);
	P1.uv = float2(-1, -1);
	OutputStream.Append(P1);

	GOut P2;
	P2.pos = float4(input[0].position.x - size / 2, input[0].position.y + size / 2, input[0].position.z, 1);
	P2.color = input[0].color;
	P2.pos = mul(world, P2.pos);
	P2.uv = float2(-1, 1);
	OutputStream.Append(P2);

	GOut P3;
	P3.pos = float4(input[0].position.x + size / 2, input[0].position.y - size / 2, input[0].position.z, 1);
	P3.color = input[0].color;
	P3.pos = mul(world, P3.pos);
	P3.uv = float2(1, -1);
	OutputStream.Append(P3);

	GOut P4;
	P4.pos = float4(input[0].position.x + size / 2, input[0].position.y + size / 2, input[0].position.z, 1);
	P4.color = input[0].color;
	P4.pos = mul(world, P4.pos);
	P4.uv = float2(1, 1);
	OutputStream.Append(P4);

	GOut P5;
	P5.pos = float4(input[0].position.x + size / 2, input[0].position.y - size / 2, input[0].position.z, 1);
	P5.color = input[0].color;
	P5.pos = mul(world, P5.pos);
	P5.uv = float2(1, -1);
	OutputStream.Append(P5);

	GOut P6;
	P6.pos = float4(input[0].position.x - size / 2, input[0].position.y - size / 2, input[0].position.z, 1);
	P6.color = input[0].color;
	P6.pos = mul(world, P6.pos);
	P6.uv = float2(-1, -1);
	OutputStream.Append(P6);
}