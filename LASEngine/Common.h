#ifndef COMMON
#define COMMON
#include <DirectXMath.h>
#include <windows.h>

#include <stdio.h>
	struct CBUFFER {
		DirectX::XMMATRIX world;
		float scale;
		float PointSize;
	};

	struct PointVertex
	{
		float Position[3];
		float Color[4];
	};

	enum LogKind
	{
		lgMessage = 0, lgInfo = 1, lgWarning = 2, lgError = 3
	};

	typedef void __fastcall Log(void* Self, LogKind logKind, const char* message);

	extern Log* logger ;
	extern void* TViewPort ;

	void dlllog(LogKind logKind, const char* message);

	long ReadShader(const char* Path, char*& bytes);


#endif