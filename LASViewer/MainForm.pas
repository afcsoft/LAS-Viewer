unit MainForm;

{
  Copyright(c) Abdülkadir Çakýr all rights reserved.
}
interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.ImageList, Vcl.ImgList, Vcl.Menus, LASEngine,
  Vcl.ExtCtrls, Logs, ASPRSLAS, Vcl.ComCtrls, Settings;

type
  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    loadMenuItem: TMenuItem;
    ImageList1: TImageList;
    viewPanel: TPanel;
    exitMenuItem: TMenuItem;
    OpenDialog1: TOpenDialog;
    StatusBar1: TStatusBar;
    Settings1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure exitMenuItemClick(Sender: TObject);
    procedure loadMenuItemClick(Sender: TObject);
    procedure Settings1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    _firstShow: Boolean;

  public
    { Public declarations }
    _viewPort: TLASView;
    Logger: TLogger;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

/// <summary>
/// TLasReader Event Logger
/// </summary>
procedure OnReaderLog(Sender: TObject; LogKind: TLogKind; LogMessage: string);
begin
  Form1.Logger.Log(LogKind, LogMessage, Sender);
end;

procedure TForm1.exitMenuItemClick(Sender: TObject);
begin
  Form1.Close;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  _viewPort.Free;
  Logger.Free;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin

  _firstShow := False;

  // Create Logger
  Logger := TLogger.Create('log.txt');
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  if not _firstShow then
  begin
    Logger.Log(lgMessage, 'Main form show', Self);
    _firstShow := True;
    _viewPort := TLASView.Create(viewPanel, Logger);
    _viewPort.SetBackgroundColor(0, 0, 0);
  end;
end;

procedure TForm1.loadMenuItemClick(Sender: TObject);
var
  LasReader: TLasReader;
  RGB: LongInt;
begin
  if OpenDialog1.Execute() then
  begin

    // Get Default Point Color from Settings Window
    RGB := ColorToRGB(SettingsForm.ColorBox1.Selected);

    // Create Reader with default point color values to be used if las file does not contain colored records.
    LasReader := TLasReader.Create(GetRValue(RGB) / 255.0, GetGValue(RGB) / 255.0, GetBValue(RGB) / 255.0, SettingsForm.CheckBox1.Checked);
    LasReader.OnReaderLog := OnReaderLog;

    // Load Points to Memory
    LasReader.LoadFromFile(OpenDialog1.FileName, StatusBar1.Panels[0]);

    // Clear Existing Points
    _viewPort.ClearPoints;

    // Copy Points to Vertex Buffer
    _viewPort.LoadPoints(LasReader.Points, LasReader.PointCount);

    // Move Scene to first point in LAS file.
    // (Many LAS files contain invalid extent. )
    _viewPort.MoveTo(LasReader.Points.Position.Y, LasReader.Points.Position.X, 1);

    // Free
    LasReader.Free;

  end;
end;

procedure TForm1.Settings1Click(Sender: TObject);
begin
  SettingsForm.ShowModal;
end;

end.
