#include "DXManager.h"

/// <summary>
/// Loads Precompiled shaders. Which will be binded to Context in constructor
/// </summary>
void DXManager::LoadShader()
{
	long Length;
	HRESULT result;

	Length = ReadShader("Engine\\PointPixelShader.cso", PixelBlob);

	if (Length < 1)
	{
		dlllog(lgError, "Cannot load pixel shader");
		return;
	}

	result = Device->CreatePixelShader(PixelBlob, Length, NULL, &PixelShader);
	if (result != S_OK)
	{
		dlllog(lgError, "Cannot create pixel shader");
		return;
	}

	Length = ReadShader("Engine\\PointVertexShader.cso", VertexBlob);
	VertexBufferSize = Length;
	if (Length < 1)
	{
		dlllog(lgError, "Cannot load Vertex shader");
		return;
	}

	result = Device->CreateVertexShader(VertexBlob, Length, NULL, &VertexShader);
	if (result != S_OK)
	{
		dlllog(lgError, "Cannot create pixel shader");
		return;
	}

	Length = ReadShader("Engine\\PointGeometryShader.cso", GeometryBlob);

	if (Length < 1)
	{
		dlllog(lgError, "Cannot load geometry shader");
		return;
	}

	result = Device->CreateGeometryShader(GeometryBlob, Length, NULL, &GeometryShader);
	if (result != S_OK)
	{
		dlllog(lgError, "Cannot create geometry shader");
		return;
	}
}

/// <summary>
/// Updates Constant Buffer, which will be consumed by shaders.
/// </summary>
void DXManager::UpdateCBuffer()
{
	if (g_pConstantBuffer11)
		g_pConstantBuffer11->Release();
	cbuff.world = XMMatrixOrthographicOffCenterLH((float)SceneY - ((float)ViewPortWidth / 2) * (float)SceneZoom, (float)SceneY + ((float)ViewPortWidth / 2) * (float)SceneZoom,
		(float)SceneX - ((float)ViewPortHeight / 2) * (float)SceneZoom, (float)SceneX + ((float)ViewPortHeight / 2) * (float)SceneZoom, -10000.0f, 10000.0f);

	cbuff.scale = SceneZoom;
	cbuff.PointSize = PointSize;
	D3D11_BUFFER_DESC cbDesc = {};
	cbDesc.ByteWidth = sizeof(CBUFFER);
	cbDesc.Usage = D3D11_USAGE_DYNAMIC;
	cbDesc.BindFlags = D3D11_BIND_CONSTANT_BUFFER;
	cbDesc.CPUAccessFlags = D3D11_CPU_ACCESS_WRITE;
	cbDesc.MiscFlags = 0;
	cbDesc.StructureByteStride = 0;


	D3D11_SUBRESOURCE_DATA InitData={};
	ZeroMemory(&ViewPort, sizeof(D3D11_SUBRESOURCE_DATA));
	InitData.pSysMem = &cbuff;
	InitData.SysMemPitch = 0;
	InitData.SysMemSlicePitch = 0;

	Device->CreateBuffer(&cbDesc, &InitData, &g_pConstantBuffer11);

	Context->VSSetConstantBuffers(0, 1, &g_pConstantBuffer11);
	Context->GSSetConstantBuffers(0, 1, &g_pConstantBuffer11);
	Context->PSSetConstantBuffers(0, 1, &g_pConstantBuffer11);
}


/// <summary>
/// Sets point size in world units
/// </summary>
/// <param name="size"></param>
void DXManager::SetPointSize(float size)
{
	PointSize = size;
	UpdateCBuffer();
}


/// <summary>
/// Resizes Viewport
/// </summary>
/// <param name="Width">new width</param>
/// <param name="Height">new heigth</param>
void DXManager::Resize(int Width, int Height)
{
	if (Context == NULL) return;
	ViewPortWidth = Width;
	ViewPortHeight = Height;
	Context->OMSetRenderTargets(0, 0, 0);
	BackBuffer->Release();
	HRESULT result;



	// Preserve the existing buffer count and format.
	// Automatically choose the width and height to match the client rect for HWNDs.
	result = SwapChain->ResizeBuffers(0, 0, 0, DXGI_FORMAT_UNKNOWN, 0);

	dlllog(result == S_OK ? lgMessage : lgError, result == S_OK ? "Resize Buffer" : "Cannot Resize Buffer");


	result = SwapChain->GetBuffer(0, __uuidof(ID3D11Texture2D), (LPVOID*)&PsuedoBackBuffer);
	dlllog(result == S_OK ? lgMessage : lgError, result == S_OK ? "Get Buffer" : "Cannot Get Buffer");

	if (PsuedoBackBuffer == NULL)
		return;

	Device->CreateRenderTargetView(PsuedoBackBuffer, NULL, &BackBuffer);



	PsuedoBackBuffer->Release();
	Context->OMSetRenderTargets(1, &BackBuffer, NULL);

	ZeroMemory(&ViewPort, sizeof(D3D11_VIEWPORT));

	ViewPort.TopLeftX = 0;
	ViewPort.TopLeftY = 0;
	ViewPort.Width = ((float)ViewPortWidth);
	ViewPort.Height = ((float)ViewPortHeight);
	ViewPort.MinDepth = 0.0f;
	ViewPort.MaxDepth = 1.0f;

	Context->RSSetViewports(1, &ViewPort);

	UpdateCBuffer();

}

/// <summary>
/// Moves camera, updates constant buffer and renders.
/// </summary>
/// <see cref="DXManager::UpdateCBuffer"/>
/// <see cref="DXManager::Render"/>
/// <param name="X">Scene Axis Vertical </param>
/// <param name="Y">Scene Axis Horizontal</param>
/// <param name="Z">Scene Zoom</param>
void DXManager::MoveTo(float X, float Y, float Z)
{
	SceneX = X;
	SceneY = Y;
	SceneZoom = Z;
	UpdateCBuffer();
	Render();
}

/// <summary>
///		Copies Points in memory to vertex buffer
/// </summary>
/// <param name="Points"> Pointer to point verticies</param>
/// <param name="Count"> Number of points</param>
void DXManager::LoadPoints(PointVertex* Points, unsigned long long Count)
{
	
	if (VertexBuffer)
		VertexBuffer->Release();

	D3D11_BUFFER_DESC bd;
	ZeroMemory(&bd, sizeof(bd));
	bd.Usage = D3D11_USAGE_DEFAULT;
	bd.ByteWidth = sizeof(PointVertex) * Count;
	bd.BindFlags = D3D11_BIND_VERTEX_BUFFER;
	bd.CPUAccessFlags = NULL;

	D3D11_SUBRESOURCE_DATA vertexData = {};
	vertexData.pSysMem = Points;
	vertexData.SysMemPitch = 0;
	vertexData.SysMemSlicePitch = 0;


	HRESULT result = Device->CreateBuffer(&bd, &vertexData, &VertexBuffer);
	Context->IASetInputLayout(PointInputLayout);
	Context->IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_POINTLIST);

	UINT stride = sizeof(PointVertex);
	UINT offset = 0;

	Context->IASetVertexBuffers(0, 1, &VertexBuffer, &stride, &offset);
	PointCount = Count;
}

/// <summary>
/// Sets Background color
/// </summary>
/// <param name="Color">Red Green Blue Alpha unsigned normalized values (0.0f..1.0f)</param>
void DXManager::SetBackgroundColor(float Color[4])
{
	color[0] = Color[0];
	color[1] = Color[1];
	color[2] = Color[2];
	color[3] = Color[3];
}

/// <summary>
/// Frees allocated GPU memory that previously used
/// </summary>
/// <see cref="DXManager::LoadPoints"/>
void DXManager::FreePoints()
{	
	ID3D11Buffer* buffers[] = { nullptr };
	UINT strides[] = { 0 };
	UINT offsets[] = { 0 };
	Context->IASetVertexBuffers(0, 1, buffers, strides, offsets);

	if (VertexBuffer)
	{		
		auto val =VertexBuffer->Release();	
	}
	VertexBuffer = NULL;
	Context->Flush();
	DXGIDevice->Trim();
}


/// <summary>
/// Clears Viewport and Renders Points.
/// </summary>
void DXManager::Render()
{

	if (Context == NULL) return;
	Context->ClearRenderTargetView(BackBuffer, color);
	Context->Draw(PointCount, 0);
	HRESULT result = SwapChain->Present(0, 0);

}
/// <summary>
///		Initializes Device,Swapchain,Depth Buffer,Blend State,Shaders,Input Layout etc.
/// </summary>
/// <param name="Handle">Handle of object which will be used as viewport</param>
DXManager::DXManager(HWND Handle)
{
	dlllog(lgMessage, "DXMAN Create");
	hWnd = Handle;
	HRESULT result;
	ZeroMemory(&SwapChainDescriptor, sizeof(SwapChainDescriptor));
	SwapChainDescriptor.BufferCount = 1;
	SwapChainDescriptor.BufferDesc.Format = DXGI_FORMAT_R8G8B8A8_UNORM;
	SwapChainDescriptor.BufferDesc.Width = ViewPortWidth;
	SwapChainDescriptor.BufferDesc.Height = ViewPortHeight;
	SwapChainDescriptor.BufferUsage = DXGI_USAGE_RENDER_TARGET_OUTPUT;
	SwapChainDescriptor.OutputWindow = hWnd;
	SwapChainDescriptor.Windowed = true;
	SwapChainDescriptor.SampleDesc.Count = 1;
	SwapChainDescriptor.SampleDesc.Quality = 0;
	SwapChainDescriptor.SwapEffect = DXGI_SWAP_EFFECT_DISCARD;


	D3D_FEATURE_LEVEL  FeatureLevelsRequested = D3D_FEATURE_LEVEL_11_0;

	D3D_FEATURE_LEVEL FeatureLevel;

	result = D3D11CreateDeviceAndSwapChain(
		NULL,
		D3D_DRIVER_TYPE_HARDWARE,
		NULL,
		D3D11_CREATE_DEVICE_DEBUG,
		&FeatureLevelsRequested,
		1u,
		D3D11_SDK_VERSION,
		&SwapChainDescriptor,
		&SwapChain,
		&Device,
		&FeatureLevel,
		&Context
	);

	dlllog(result == S_OK ? lgMessage : lgError, result == S_OK ? "Create Device and Swapchain" : "Cannot Create Device and Swapchain");

	Device->QueryInterface(__uuidof(IDXGIDevice3), (void**)&DXGIDevice);

	result = SwapChain->GetBuffer(0, __uuidof(ID3D11Texture2D), reinterpret_cast<void**>(&PsuedoBackBuffer));

	dlllog(result == S_OK ? lgMessage : lgError, result == S_OK ? "Get Swapchain Buffer" : "Cannot Get Swapchain Buffer");

	if (PsuedoBackBuffer == NULL)
		return;

	result = Device->CreateRenderTargetView(PsuedoBackBuffer, NULL, &BackBuffer);

	dlllog(result == S_OK ? lgMessage : lgError, result == S_OK ? "Create Render Target View" : "Cannot Create Render Target View");

	PsuedoBackBuffer->Release();

	D3D11_TEXTURE2D_DESC depthBufferDesc;

	// Initialize the description of the depth buffer.
	ZeroMemory(&depthBufferDesc, sizeof(depthBufferDesc));

	// Set up the description of the depth buffer.
	depthBufferDesc.Width = ViewPortWidth;
	depthBufferDesc.Height = ViewPortHeight;
	depthBufferDesc.MipLevels = 1;
	depthBufferDesc.ArraySize = 1;
	depthBufferDesc.Format = DXGI_FORMAT_D24_UNORM_S8_UINT;
	depthBufferDesc.SampleDesc.Count = 1;
	depthBufferDesc.SampleDesc.Quality = 0;
	depthBufferDesc.Usage = D3D11_USAGE_DEFAULT;
	depthBufferDesc.BindFlags = D3D11_BIND_DEPTH_STENCIL;
	depthBufferDesc.CPUAccessFlags = 0;
	depthBufferDesc.MiscFlags = 0;

	

	result = Device->CreateTexture2D(&depthBufferDesc, NULL, &depthtexture);

	dlllog(result == S_OK ? lgMessage : lgError, result == S_OK ? "Create Depth Buffer" : "Cannot Create Depth Buffer");


	D3D11_DEPTH_STENCIL_DESC depthStencilDesc;

	// Initialize the description of the stencil state.
	ZeroMemory(&depthStencilDesc, sizeof(depthStencilDesc));

	// Set up the description of the stencil state.
	depthStencilDesc.DepthEnable = true;
	depthStencilDesc.DepthWriteMask = D3D11_DEPTH_WRITE_MASK_ALL;
	depthStencilDesc.DepthFunc = D3D11_COMPARISON_LESS_EQUAL;

	depthStencilDesc.StencilEnable = true;
	depthStencilDesc.StencilReadMask = 0xFF;
	depthStencilDesc.StencilWriteMask = 0xFF;

	// Stencil operations if pixel is front-facing.
	depthStencilDesc.FrontFace.StencilFailOp = D3D11_STENCIL_OP_KEEP;
	depthStencilDesc.FrontFace.StencilDepthFailOp = D3D11_STENCIL_OP_INCR;
	depthStencilDesc.FrontFace.StencilPassOp = D3D11_STENCIL_OP_KEEP;
	depthStencilDesc.FrontFace.StencilFunc = D3D11_COMPARISON_ALWAYS;

	// Stencil operations if pixel is back-facing.
	depthStencilDesc.BackFace.StencilFailOp = D3D11_STENCIL_OP_KEEP;
	depthStencilDesc.BackFace.StencilDepthFailOp = D3D11_STENCIL_OP_DECR;
	depthStencilDesc.BackFace.StencilPassOp = D3D11_STENCIL_OP_INVERT;
	depthStencilDesc.BackFace.StencilFunc = D3D11_COMPARISON_ALWAYS;

	

	result = Device->CreateDepthStencilState(&depthStencilDesc, &DepthState);
	dlllog(result == S_OK ? lgMessage : lgError, result == S_OK ? "Create Depth Stencil" : "Cannot Create Depth Stencil");

	D3D11_DEPTH_STENCIL_VIEW_DESC depthStencilViewDesc;
	
	// Initailze the depth stencil view.
	ZeroMemory(&depthStencilViewDesc, sizeof(depthStencilViewDesc));

	// Set up the depth stencil view description.
	depthStencilViewDesc.Format = DXGI_FORMAT_D24_UNORM_S8_UINT;
	depthStencilViewDesc.ViewDimension = D3D11_DSV_DIMENSION_TEXTURE2DMS;
	depthStencilViewDesc.Texture2D.MipSlice = 0;

	if (depthtexture == NULL)
		return;

	result = Device->CreateDepthStencilView(depthtexture, &depthStencilViewDesc, &DepthStencilView);
	dlllog(result == S_OK ? lgMessage : lgError, result == S_OK ? "Create Depth Stencil View" : "Cannot Create Depth Stencil View");

	D3D11_BLEND_DESC BlendStateDescription;
	ZeroMemory(&BlendStateDescription, sizeof(D3D11_BLEND_DESC));

	

	BlendStateDescription.RenderTarget[0].BlendEnable = true;
	BlendStateDescription.RenderTarget[0].RenderTargetWriteMask = D3D11_COLOR_WRITE_ENABLE_ALL;
	BlendStateDescription.RenderTarget[0].SrcBlend = D3D11_BLEND_SRC_ALPHA;

	BlendStateDescription.RenderTarget[0].DestBlend = D3D11_BLEND_INV_SRC_ALPHA;
	BlendStateDescription.RenderTarget[0].SrcBlendAlpha = D3D11_BLEND_INV_DEST_ALPHA;
	BlendStateDescription.RenderTarget[0].DestBlendAlpha = D3D11_BLEND_ONE;
	BlendStateDescription.RenderTarget[0].BlendOp = D3D11_BLEND_OP_ADD;
	BlendStateDescription.RenderTarget[0].BlendOpAlpha = D3D11_BLEND_OP_ADD;

	result = Device->CreateBlendState(&BlendStateDescription, &blend);
	dlllog(result == S_OK ? lgMessage : lgError, result == S_OK ? "Create Blend State" : "Cannot Create Blend State");

	float blendFactor[] = { 0, 0, 0, 0 };
	UINT sampleMask = 0xffffffff;

	Context->OMSetBlendState(blend, blendFactor, sampleMask);

	Context->OMSetRenderTargets(1, &BackBuffer, DepthStencilView);


	ZeroMemory(&ViewPort, sizeof(D3D11_VIEWPORT));

	ViewPort.TopLeftX = -ViewPortWidth / 2.0f;
	ViewPort.TopLeftY = -ViewPortHeight / 2.0f;
	ViewPort.Width = ViewPortWidth / 1.0f;
	ViewPort.Height = ViewPortHeight / 1.0f;

	Context->RSSetViewports(1, &ViewPort);

	LoadShader();

	D3D11_INPUT_ELEMENT_DESC PointInputLayoutDesc[] =
	{
			{"POSITION", 0, DXGI_FORMAT_R32G32B32_FLOAT, 0, 0, D3D11_INPUT_PER_VERTEX_DATA, 0},
			{"COLOR", 0, DXGI_FORMAT_R32G32B32A32_FLOAT, 0, 12, D3D11_INPUT_PER_VERTEX_DATA, 0}

	};
	result = Device->CreateInputLayout(PointInputLayoutDesc, 2, VertexBlob, VertexBufferSize, &PointInputLayout);
	dlllog(result == S_OK ? lgMessage : lgError, result == S_OK ? "Create Input Layout" : "Cannot Input Layout");
	RasterDesc = {};
	RasterDesc.FillMode = D3D11_FILL_SOLID;
	RasterDesc.CullMode = D3D11_CULL_NONE;
	RasterDesc.DepthClipEnable = false;
	RasterDesc.MultisampleEnable = true;
	RasterDesc.AntialiasedLineEnable = true;



	ID3D11RasterizerState* WireFrame = NULL;


	result = Device->CreateRasterizerState(&RasterDesc, &WireFrame);

	dlllog(result == S_OK ? lgMessage : lgError, result == S_OK ? "Create Rasterizer State" : "Cannot Create Rasterizer State");

	Context->RSSetState(WireFrame);

	Context->VSSetShader(VertexShader, 0, 0);
	Context->GSSetShader(GeometryShader, 0, 0);
	Context->PSSetShader(PixelShader, 0, 0);


	Context->IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_POINTLIST);
	


	
	UpdateCBuffer();
}

/// <summary>
/// Releases DirectX objects in order.
/// </summary>
DXManager::~DXManager()
{

	if (g_pConstantBuffer11)
		g_pConstantBuffer11->Release();

	if (VertexBuffer)
		VertexBuffer->Release();
	if (VertexBlob)
		delete VertexBlob; 
	if (PixelBlob)
		delete PixelBlob;
	if (GeometryBlob)
		delete GeometryBlob;
	
	if (PointInputLayout)
		PointInputLayout->Release();

	if (VertexShader)
		VertexShader->Release();
	if (GeometryShader)
		GeometryShader->Release();
	if (PixelShader)
		PixelShader->Release();	
	
	if (depthtexture)
		depthtexture->Release();
	if (DepthStencilView)
		DepthStencilView->Release();
	if (blend)
		blend->Release();

	if (BackBuffer)
		BackBuffer->Release();
	if (SwapChain)
		SwapChain->Release();


	if (Context)
		Context->Release();
	if (Device)
		Device->Release();
		
}
