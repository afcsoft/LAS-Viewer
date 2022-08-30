program LASViewer;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {Form1},
  ViewPort in 'ViewPort.pas',
  Logs in 'Logs.pas',
  LASEngine in 'LASEngine.pas',
  ASPRSLAS in 'ASPRSLAS.pas',
  Settings in 'Settings.pas' {SettingsForm},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TSettingsForm, SettingsForm);
  Application.Run;
end.
