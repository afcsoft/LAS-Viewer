unit Settings;
{
  Copyright(c) Abdülkadir Çakýr all rights reserved.
}
interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls;

type
  TSettingsForm = class(TForm)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    ColorBox1: TColorBox;
    Label2: TLabel;
    Edit1: TEdit;
    ColorBox2: TColorBox;
    Label3: TLabel;
    Panel1: TPanel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    CheckBox1: TCheckBox;
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SettingsForm: TSettingsForm;

implementation

{$R *.dfm}
uses MainForm;
procedure TSettingsForm.BitBtn1Click(Sender: TObject);
var
  RGB:LongInt;
  PointSize:Single;
begin
  RGB:=ColorToRGB(ColorBox2.Selected);
  MainForm.Form1._viewPort.SetBackgroundColor(  GetRValue(RGB)/255.0,  GetGValue(RGB)/255.0,  GetBValue(RGB)/255.0);
  if TryStrToFloat(Edit1.Text,PointSize) then
    MainForm.Form1._viewPort.SetPointSize(PointSize)
  else
    ShowMessage('Invalid Point Size Value');


end;

end.
