unit ViewPort;
{
  Copyright(c) Abdülkadir Çakýr all rights reserved.
}
interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.ImageList, Vcl.ImgList, Vcl.Menus,
  Vcl.ExtCtrls,Logs;

  type TScenePoint = record
  X,Y:Single;
  class operator Add(a,b:TScenePoint):TScenePoint;
  class operator Subtract(a,b:TScenePoint):TScenePoint;
  class operator Divide(a:TScenePoint;b:Single):TScenePoint;

end;


  type TPanelMSEvent = class(TPanel);

  type TViewPort = class

    private
      _viewPanel:TPanel;
      _panX,_panY:Integer; // Pan Begin X Y
      _sceneX,_sceneY,_sceneZoom:Single; // Viewport center coordinates and zoom level
       _width,_height:Integer; // Viewport width & height
      _log:TLogger; // Logger object
      ResizeTimer:TTimer; // Timer that pools _Resize(..) calls.

      // Viewport events
      procedure OnMouseMove(Sender:TObject;Shift:TShiftState;X,Y:Integer);
      procedure OnMouseDown(Sender:TObject;Button:TMouseButton;Shift:TShiftState;X,Y:Integer);
      procedure OnMouseUp(Sender:TObject;Button:TMouseButton;Shift:TShiftState;X,Y:Integer);
      procedure OnMouseLeave(Sender:TObject);
      procedure OnResize(Sender:TObject);
      procedure OnResizeTimer(Sender:TObject);
      procedure OnMouseWheeel(Sender: TObject; Shift: TShiftState;WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);

      function Scene2World(PixX,PixY:Integer):TScenePoint; // Convert Screen Coords. to World Coords.

      // Not used yet.
      function World2Scene(X,Y:Single):TScenePoint;

    public
      property SceneX:Single read _sceneX write  _sceneX;
      property SceneY:Single read _sceneY write _sceneY;
      property Zoom:Single read _sceneZoom write _sceneZoom;
      property ViewPortWidth:Integer read _width write _width;
      property ViewPortHeight:Integer read _height write _height;

      procedure Log(kind:TLogKind;LogMessage:string);

      constructor Create(_view:TPanel;_logger:TLogger = nil);

      //Implemented in LasEngine.pas
      procedure Render();virtual;abstract;
      procedure Resize(Width,Height:Integer);virtual;abstract;
      procedure MoveTo(X,Y,SCZoom:Single);virtual;abstract;

  end;

implementation

function TViewPort.Scene2World(PixX: Integer; PixY: Integer): TScenePoint;
begin
  Result.X := SceneX - (PixY-ViewPortHeight/2)*Zoom;
  Result.Y := SceneY + (PixX-ViewPortWidth/2)*Zoom;
end;

function TViewPort.World2Scene(X: Single; Y: Single): TScenePoint;
var
  offsetx,offsety:Single;
begin
  offsetx := SceneX + ((ViewPortHeight/2)/ Zoom);
  offsety := SceneY - ((ViewPortWidth/2)/ Zoom);

  Result.X := (Y-offsety)*Zoom;
  Result.Y := (offsetx-X)*Zoom;
end;

class operator TScenePoint.Add(a: TScenePoint; b: TScenePoint): TScenePoint;
begin
    Result.X := a.X + b.X;
    Result.Y := a.Y + b.Y;
end;

class operator TScenePoint.Subtract(a: TScenePoint; b: TScenePoint): TScenePoint;
begin
    Result.X := a.X - b.X;
    Result.Y := a.Y - b.Y;
end;

class operator TScenePoint.Divide(a: TScenePoint; b: Single): TScenePoint;
begin
    Result.X := a.X / b;
    Result.Y := a.Y / b;
end;

procedure TViewPort.Log(kind:TLogKind;LogMessage:string);
begin
  if _log<>nil then
    _log.Log(kind,LogMessage,Self);
end;

procedure TViewPort.OnMouseWheeel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var
  ZoomFact:Single;
  ROI,KOI:TScenePoint;
  MC:TPoint;
begin

  if WheelDelta=0 then Exit;

  MC:=_viewPanel.ScreenToClient(MousePos);
  ZoomFact := 1.2+(-(abs(WheelDelta) / WheelDelta)-1) * 0.2;

  ROI := Scene2World(MC.X,MC.Y);
  KOI.X := SceneX;
  KOI.Y := SceneY;

  SceneX := ROI.X;
  SceneY := ROI.Y;

  Zoom := Zoom * ZoomFact;

  SceneX := SceneX + (KOI.X - ROI.X) * ZoomFact;
  SceneY := SceneY + (KOI.Y - ROI.Y) * ZoomFact;
  MoveTo(SceneX,SceneY,Zoom);
end;

procedure TViewPort.OnMouseLeave(Sender: TObject);
begin
    _viewPanel.OnMouseMove:=nil;
end;

procedure TViewPort.OnResize(Sender: TObject);
begin
   ResizeTimer.Tag:=60;
  ResizeTimer.Enabled:=True;
end;

procedure TViewPort.OnResizeTimer(Sender: TObject);
begin
  while(ResizeTimer.Tag>0) do
  begin
    ResizeTimer.Tag:=ResizeTimer.Tag-1;
    Application.ProcessMessages;
  end;
  Resize(_viewPanel.Width,_viewPanel.Height);
  Render;
  ResizeTimer.Enabled:=False;
end;

// Pan
procedure TViewPort.OnMouseMove(Sender: TObject; Shift: TShiftState; X: Integer; Y: Integer);
var
  dX,dY:Single;
begin
  dX :=  (Y - _panY) * Zoom;
  dY := -(X - _panX)* Zoom;

  _panX := X;
  _panY := Y;

  SceneX := SceneX + dX;
  SceneY := SceneY + dY;
  MoveTo(SceneX,SceneY,Zoom);
end;


// Pan Begin - (Mouse Middle Button)
procedure TViewPort.OnMouseDown(Sender:TObject;Button:TMouseButton;Shift:TShiftState;X,Y:Integer);
begin
   Render();
   if Button<>TMouseButton.mbMiddle then Exit;
   //Pan Start Point
   _panX:=X;
   _panY:=Y;

   //Watch for mouse move
   _viewPanel.OnMouseMove:=OnMouseMove;
end;

// Pan End
procedure TViewPort.OnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);
begin
   if Button<>TMouseButton.mbMiddle then Exit;
   _viewPanel.OnMouseMove:=nil;
end;


constructor TViewPort.Create(_view:TPanel;_logger:TLogger = nil);
begin
  // Logger
  _log:= _logger;
try
  //Viewport Def.
  _viewPanel:=_view;


  //Events
  _view.OnMouseDown:=OnMouseDown;
  _view.OnMouseUp:=OnMouseUp;
  _view.OnMouseLeave:=OnMouseLeave;
  TPanelMSEvent(_view).OnMouseWheel:=OnMouseWheeel;

  _view.OnResize:=OnResize;

  //Scene Defaults
  _sceneX:=0;
  _sceneY:=0;
  _sceneZoom:=1;

  // ResizeTimer
  ResizeTimer:=TTimer.Create(nil);
  ResizeTimer.Interval:=1;
  ResizeTimer.OnTimer:= OnResizeTimer;

  Log(lgMessage,'View Port Init.');

except
   on e:Exception do
   begin
     Log(lgError,e.Message);
   end;
end;
end;


end.
