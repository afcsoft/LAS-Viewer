object SettingsForm: TSettingsForm
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = 'Settings'
  ClientHeight = 271
  ClientWidth = 394
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 0
    Top = 0
    Width = 394
    Height = 129
    Align = alTop
    Caption = 'Points'
    Padding.Left = 3
    Padding.Top = 3
    Padding.Right = 3
    Padding.Bottom = 3
    TabOrder = 0
    ExplicitTop = -6
    object Label1: TLabel
      Left = 5
      Top = 18
      Width = 384
      Height = 13
      Hint = 'Defines size in world units.'
      Align = alTop
      Caption = 'Size:'
      ExplicitLeft = 6
      ExplicitTop = 12
    end
    object Label2: TLabel
      Left = 5
      Top = 52
      Width = 384
      Height = 13
      Hint = 'Set point color if not defined in LAS file'
      Align = alTop
      Caption = 'Point Color:'
      ExplicitTop = 53
      ExplicitWidth = 56
    end
    object ColorBox1: TColorBox
      Left = 5
      Top = 65
      Width = 384
      Height = 22
      Align = alTop
      Selected = clPurple
      Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbCustomColor, cbPrettyNames]
      TabOrder = 0
      ExplicitLeft = 4
      ExplicitTop = 58
    end
    object Edit1: TEdit
      Left = 5
      Top = 31
      Width = 384
      Height = 21
      Align = alTop
      TabOrder = 1
      Text = '1'
      ExplicitLeft = 4
      ExplicitTop = 45
    end
  end
  object GroupBox2: TGroupBox
    Left = 0
    Top = 129
    Width = 394
    Height = 105
    Align = alTop
    Caption = 'General'
    Padding.Left = 3
    Padding.Top = 3
    Padding.Right = 3
    Padding.Bottom = 3
    TabOrder = 1
    ExplicitLeft = 144
    ExplicitTop = 88
    ExplicitWidth = 185
    object Label3: TLabel
      Left = 5
      Top = 18
      Width = 384
      Height = 13
      Hint = 'Set point color if not defined in LAS file'
      Align = alTop
      Caption = 'Background Color'
      ExplicitLeft = 2
      ExplicitTop = 15
      ExplicitWidth = 84
    end
    object ColorBox2: TColorBox
      Left = 5
      Top = 31
      Width = 384
      Height = 22
      Align = alTop
      Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbCustomColor, cbPrettyNames]
      TabOrder = 0
      ExplicitLeft = 3
      ExplicitTop = 34
      ExplicitWidth = 390
    end
    object CheckBox1: TCheckBox
      Left = 5
      Top = 53
      Width = 384
      Height = 17
      Hint = 'Experimental'
      Align = alTop
      Caption = 'Restrict Memory Use (Experimental)'
      TabOrder = 1
      ExplicitLeft = 4
      ExplicitTop = 59
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 234
    Width = 394
    Height = 37
    Align = alClient
    BevelOuter = bvNone
    Padding.Top = 3
    Padding.Right = 10
    Padding.Bottom = 3
    TabOrder = 2
    ExplicitTop = 240
    object BitBtn1: TBitBtn
      Left = 309
      Top = 3
      Width = 75
      Height = 31
      Align = alRight
      Kind = bkOK
      NumGlyphs = 2
      TabOrder = 0
      OnClick = BitBtn1Click
      ExplicitLeft = 315
      ExplicitTop = 6
    end
    object BitBtn2: TBitBtn
      Left = 234
      Top = 3
      Width = 75
      Height = 31
      Align = alRight
      Kind = bkCancel
      NumGlyphs = 2
      TabOrder = 1
      ExplicitTop = 6
    end
  end
end
