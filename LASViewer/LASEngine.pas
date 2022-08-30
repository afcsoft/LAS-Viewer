unit LASEngine;
{
  Copyright(c) Abdülkadir Çakýr all rights reserved.
}
interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.ImageList, Vcl.ImgList,
  Vcl.Menus,
  Vcl.ExtCtrls, Logs, ViewPort, ASPRSLAS;


// LASEngine.dll Wrapper

type
  TLASInit = procedure(_view: TViewPort; LogFunction: Pointer);

type
  TCreateDX = function(Handle: HWND): Pointer;

type
  TResize = procedure(Manager: Pointer; Width, Height: Integer);

type
  TMoveTo = procedure(Manager: Pointer; X, Y, Z: Single);

type
  TSetPointSize = procedure(Manager: Pointer; Size: Single);

type
  TSetBackgroundColor = procedure(Manager: Pointer; Color: TFloatColor);

type
  TLoadPoints = procedure(Manager: Pointer; Points: PPointVertex;
    Count: UInt64);

type
  TCommonProc = procedure(Manager: Pointer);

type
  TLASView = class(TViewPort)
  private
    // Dyn. Load DLL Vars.
    _FDLL: HMODULE;
    _Init: TLASInit;
    _CreateDX: TCreateDX;
    _Resize: TResize;
    _MoveTo: TMoveTo;
    _SetPointSize: TSetPointSize;
    _SetBackgroundColor: TSetBackgroundColor;
    _LoadPoints: TLoadPoints;
    _FreePoints: TCommonProc;
    _Render: TCommonProc;
    _FreeDX: TCommonProc;

    DXManager: Pointer;
    function LoadProc(ProcName: AnsiString): Pointer;
  public
    constructor Create(_view: TPanel; _logger: TLogger = nil);
    destructor Free();
    // Render Points to ViewPort
    procedure Render(); override;

    // Resize DirectX ViewPort
    procedure Resize(Width, Height: Integer); override;

    // Move Scene to X,Y and set zoom to SCZoom
    procedure MoveTo(X, Y, SCZoom: Single); override;

    // Load Points to Vertex Buffer (C++ LASEngine.dll DXManager::LoadPoints)
    procedure LoadPoints(Points: PPointVertex; Count: UInt64);

    // Set Background Color (unsigned normalized Red Green Blue)
    procedure SetBackgroundColor(R, G, B: Single);

    // Set Point Size in World Units (Not fixed pixel size {TODO})
    procedure SetPointSize(Size: Single);

    procedure ClearPoints();
  end;

implementation

// Function to be called from LASEngine.dll to log events.
procedure dllLog(ViewPort: TViewPort; kind: TLogKind; LogMessage: PAnsiChar);
begin
  ViewPort.Log(kind, String(LogMessage));
end;

procedure TLASView.ClearPoints;
begin
  _FreePoints(DXManager);
end;

procedure TLASView.SetPointSize(Size: Single);
begin
  _SetPointSize(DXManager, Size);
end;

procedure TLASView.SetBackgroundColor(R, G, B: Single);
var
  FLColor: TFloatColor;
begin
  FLColor.R := R;
  FLColor.G := G;
  FLColor.B := B;
  FLColor.A := 1;
  _SetBackgroundColor(DXManager, FLColor);
end;

procedure TLASView.LoadPoints(Points: PPointVertex; Count: UInt64);
begin
  _LoadPoints(DXManager, Points, Count);
end;

procedure TLASView.Render;
begin
  _Render(DXManager);
end;

procedure TLASView.MoveTo(X, Y, SCZoom: Single);
begin
  SceneX := X;
  SceneY := Y;
  Zoom := SCZoom;
  _MoveTo(DXManager, X, Y, Zoom);
end;

procedure TLASView.Resize(Width, Height: Integer);
begin
  ViewPortWidth := Width;
  ViewPortHeight := Height;
  _Resize(DXManager, Width, Height);
end;

function TLASView.LoadProc(ProcName: AnsiString): Pointer;
begin
  if _FDLL = 0 then
    raise Exception.Create('Invalid DLL');

  Result := GetProcAddress(_FDLL, PAnsiChar(ProcName));
  if Result = nil then
  begin
    Log(lgError, 'Cannot load ' + String(ProcName));
    raise Exception.Create('Cannot load ' + String(ProcName));
  end;
end;

constructor TLASView.Create(_view: TPanel; _logger: TLogger = nil);
begin

  inherited Create(_view, _logger);
  try

    _FDLL := LoadLibrary('Engine\LASEngine.dll');

    @_Init := LoadProc('Init');
    @_CreateDX := LoadProc('CreateDX');
    @_Resize := LoadProc('Resize');
    @_MoveTo := LoadProc('MoveTo');
    @_SetPointSize := LoadProc('SetPointSize');
    @_SetBackgroundColor := LoadProc('SetBackgroundColor');
    @_LoadPoints := LoadProc('LoadPoints');
    @_Render := LoadProc('Render');
    @_FreeDX := LoadProc('FreeDX');
    @_FreePoints := LoadProc('FreePoints');

    _Init(Self, @dllLog);
    DXManager := _CreateDX(_view.Handle);
  except
    on e: Exception do
      Log(lgError, e.Message);
  end;
end;

destructor TLASView.Free;
begin
  _FreeDX(DXManager);
end;

end.
