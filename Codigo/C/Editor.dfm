object Form1: TForm1
  Left = 120
  Top = 113
  BorderStyle = bsSingle
  Caption = 'Form1'
  ClientHeight = 458
  ClientWidth = 790
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClick = FormClick
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 8
    Width = 155
    Height = 24
    Caption = 'Número de Voces'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Button1: TButton
    Left = 192
    Top = 16
    Width = 193
    Height = 41
    Caption = 'Nueva'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Edit1: TEdit
    Left = 64
    Top = 40
    Width = 57
    Height = 32
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    Text = '10'
  end
  object SelectorZoom: TComboBox
    Left = 408
    Top = 24
    Width = 113
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 2
    OnChange = SelectorZoomChange
    Items.Strings = (
      '1'
      '2'
      '4'
      '8'
      '16'
      '32'
      '64'
      '128')
  end
  object Barra: TScrollBar
    Left = 96
    Top = 368
    Width = 633
    Height = 17
    PageSize = 0
    TabOrder = 3
    OnChange = BarraChange
  end
  object Button2: TButton
    Left = 560
    Top = 24
    Width = 169
    Height = 25
    Caption = 'Button2'
    TabOrder = 4
    OnClick = Button2Click
  end
end
