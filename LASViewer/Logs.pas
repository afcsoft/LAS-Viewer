unit Logs;
{
  Copyright(c) Abdülkadir Çakýr all rights reserved.
}
interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.ImageList, Vcl.ImgList, Vcl.Menus,
  Vcl.ExtCtrls,System.Generics.Collections;

type TLogKind = (lgMessage = 0,lgInfo = 1,lgWarning = 2,lgError = 3);

const LogKindText:array [0..3] of string = ('MSG','INFO','WARN','ERR');

type TLogElement = packed record
  LogKind:TLogKind;
  LogMessage:String;
  Epoch:TDateTime;
  function ToString:String;
end;

type TLogEvent = procedure (Sender:TObject;LogElement:TLogElement);

type TLogger = class
  private
    _fileHandle:TextFile;
    _logPath:string;
    _logs:TList<TLogElement>;
    _onlog:TLogEvent;
  public
    property OnLogAdded:TLogEvent read _onlog write _onlog;
    procedure Log(LogKind:TLogKind; logmessage:String; Sender:TObject=nil);
    constructor Create(logPath:String);
    destructor  Free;
end;

implementation
function TLogElement.ToString:String;
begin
  Exit(format('[%s][%s]: %s',[DateTimeToStr(Epoch),LogKindText[Integer(LogKind)],LogMessage]))
end;
procedure TLogger.Log(LogKind: TLogKind; logmessage: string; Sender:TObject=nil);
var
temp:^TLogElement;
begin
    new(temp);

    temp.LogKind := LogKind;
    temp.LogMessage := logmessage;
    temp.Epoch := Now;

    _logs.Add(temp^);
    if Assigned(_onlog) then
      _onlog(Self,temp^);
    if Sender <> nil then
      Write(_fileHandle,format('[%s]',[Sender.ClassName]));
    Writeln(_fileHandle,temp.ToString);

    Flush(_fileHandle);
end;

constructor TLogger.Create(logPath: string);
begin
{$IFDEF NOLOGOVERWRITE }
  if FileExists(logPath) then
    raise Exception.Create('Log file already exists!');
{$ENDIF}

  _logPath:=logPath;
  _logs:=TList<TLogElement>.Create;
  AssignFile(_fileHandle,_logPath);
  Rewrite(_fileHandle);
  Log(lgMessage,'Logger Init',Self);

end;

destructor TLogger.Free;
begin
_logs.Free;
if TTextRec(_fileHandle).Mode<>fmClosed then
  CloseFile(_fileHandle);
end;

end.
