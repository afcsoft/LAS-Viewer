#include "Common.h"


Log* logger = nullptr;
void* TViewPort = nullptr;

/// <summary>
/// Sends log message to main app.
/// </summary>
/// <param name="logKind">Alert Level</param>
/// <param name="message">Message to be sent</param>
void dlllog(LogKind logKind, const char* message)
{
    if (logger && TViewPort)
        (*logger)(TViewPort, logKind, message);
}
/// <summary>
/// Reads Shader File
/// </summary>
/// <param name="Path"> Path to compiled shader </param>
/// <param name="bytes"> Pointer to shader in memory (Allocated in function) </param>
/// <returns> Returns number of bytes read. </returns>
long ReadShader(const char* Path, char*& bytes)
{
	FILE* fl;
	fopen_s(&fl, Path, "rb");
	if (!fl) return 0;
	fseek(fl, 0, SEEK_END);
	long len = ftell(fl);
	bytes = (char*)malloc(len);
	fseek(fl, 0, SEEK_SET);
	fread(bytes, 1, len, fl);
	fclose(fl);
	return len;
}
