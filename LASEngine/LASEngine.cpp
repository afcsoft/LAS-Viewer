
#include "LASEngine.h"
#include "Common.h"

/// <summary>
/// Initializes common function(s)
/// </summary>
/// <param name="Viewport">Pointer to Viewport object in host app (TViewPort).</param>
/// <param name="LogFunction">Pointer to log function in host app.</param>
/// <returns></returns>
void* Init(void* Viewport, void* LogFunction)
{
	TViewPort = Viewport;
	logger = (Log*)LogFunction;
	dlllog(lgMessage, "LASEngine.dll Init");
	return nullptr;
}

/// <summary>
/// Creates DXManager Object
/// </summary>
/// <param name="Handle"> HWND of viewport to be used as viewport.</param>
/// <returns>Pointer to DXManager object</returns>
DXManager* CreateDX(HWND Handle)
{
	return new DXManager(Handle);
}


/// <summary>
/// Resizes viewport.
/// </summary>
/// <param name="manager">Pointer to DXManager object</param>
/// <param name="Width">new width</param>
/// <param name="Height">new height</param>
void Resize(DXManager* manager, int Width, int Height)
{
	manager->Resize(Width, Height);
}

/// <summary>
/// Moves Camera 
/// </summary>
void MoveTo(DXManager* manager, float X, float Y, float Z)
{
	manager->MoveTo(X, Y, Z);
}

/// <summary>
/// Sets point size in world units.
/// </summary>
void SetPointSize(DXManager* manager, float size)
{
	manager->SetPointSize(size);

}

/// <summary>
/// Sets background color of viewport.
/// </summary>
/// <param name="manager">Pointer to DXManager object</param>
/// <param name="color">Red Green Blue Alpha in order and unsigned normalized float colors [0..1]</param>
void SetBackgroundColor(DXManager* manager, float color[4])
{
	manager->SetBackgroundColor(color);
}

/// <summary>
///		Copies Points in memory to vertex buffer
/// </summary>
/// <param name="Points"> Pointer to point verticies</param>
/// <param name="Count"> Number of points</param>
void LoadPoints(DXManager* manager, PointVertex* Points, unsigned long long Count)
{
	manager->LoadPoints(Points, Count);
}

/// <summary>
/// Frees allocated GPU memory that previously used
/// </summary>
/// <see cref="DXManager::LoadPoints"/>
void FreePoints(DXManager* manager)
{
	manager->FreePoints();
}

/// <summary>
/// Clears Viewport and Renders Points.
/// </summary>
void Render(DXManager* manager)
{
	manager->Render();
}

/// <summary>
/// Destroys DXManager object
/// </summary>
void FreeDX(DXManager* manager)
{
	manager->~DXManager();
}




