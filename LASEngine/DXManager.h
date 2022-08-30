#pragma once
#include <DirectXMath.h>
#include <d3d11.h>
#include "d3dcompiler.h"
#include <dxgi1_3.h>
#include <string>
#include <iostream>
#include <vector>
#include "Common.h"
#pragma comment (lib, "d3d11.lib")
#pragma comment(lib,"d3dcompiler.lib")
#pragma comment(lib, "dxgi")
using namespace std;
using namespace DirectX;

class DXManager
{
	DXGI_SWAP_CHAIN_DESC SwapChainDescriptor = {};
	ID3D11RenderTargetView* BackBuffer = NULL;
	ID3D11Texture2D* PsuedoBackBuffer = NULL;
	ID3D11InputLayout* InputLayout = NULL;
	D3D11_VIEWPORT ViewPort = {};
	D3D11_RASTERIZER_DESC RasterDesc = {};
	ID3D11Buffer* VertexBuffer = NULL;
	D3D11_MAPPED_SUBRESOURCE MappedSubRes = {};
	ID3D11Buffer* g_pConstantBuffer11 = NULL;

	HWND hWnd = 0; // Viewport
	CBUFFER cbuff = {}; // Matrix Scale etc.
	//Default VP
	int ViewPortWidth = 300;
	int ViewPortHeight = 300;
	float color[4] = { 0.0f,0.0f,0.0f,1.0f };
	void LoadShader();
	void UpdateCBuffer();
	// Default Scene Pos
	float SceneX = 0;
	float SceneY = 0;
	float SceneZoom = 1.0f;
	float PointSize = 1.0f;
	char* PixelBlob;
	char* VertexBlob;
	char* GeometryBlob;
	long VertexBufferSize = 0;

	unsigned long long PointCount = 0;
	ID3D11PixelShader* PixelShader = nullptr;
	ID3D11VertexShader* VertexShader = nullptr;
	ID3D11GeometryShader* GeometryShader = nullptr;
	
	vector<ID3D11Buffer*> VertexBuffers;

	ID3D11DepthStencilState* DepthState;
	ID3D11Texture2D* depthtexture;
	ID3D11DepthStencilView* DepthStencilView;
	ID3D11BlendState* blend;

public:
	ID3D11InputLayout* PointInputLayout = nullptr;
	ID3D11Device* Device = NULL;
	IDXGIDevice3* DXGIDevice;
	ID3D11DeviceContext* Context = NULL;
	IDXGISwapChain* SwapChain = NULL;
	void SetPointSize(float size);
	void Resize(int Width, int Height);
	void MoveTo(float X, float Y, float Z);
	void LoadPoints(PointVertex* Points, unsigned long long Count);
	void SetBackgroundColor(float Color[4]);
	void FreePoints();
	void Render();
	DXManager(HWND Handle);
	~DXManager();
};

