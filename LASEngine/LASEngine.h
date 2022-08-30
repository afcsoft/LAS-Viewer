#pragma once

#include <stdio.h>
#include <iostream>
#include "DXManager.h"
#include "Common.h"

using namespace std;
#define dlexp __declspec(dllexport)
extern "C"
{
	dlexp void* Init(void* Viewport,void* LogFunction);
	dlexp DXManager* CreateDX(HWND Handle);
	
	dlexp void Resize(DXManager* manager,int Width,int Height);
	dlexp void MoveTo(DXManager* manager, float X, float Y, float Z);
	dlexp void SetPointSize(DXManager* manager, float size);
	dlexp void SetBackgroundColor(DXManager* manager, float color[4]);
	dlexp void LoadPoints(DXManager* manager, PointVertex* Points,unsigned long long Count);
	dlexp void FreePoints(DXManager* manager);
	dlexp void Render(DXManager* manager);
	dlexp void FreeDX(DXManager* manager);

}

