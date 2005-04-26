object Form_Melodia: TForm_Melodia
  Left = 250
  Top = 205
  Width = 555
  Height = 330
  Caption = 'Curva Melódica'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClick = FormClick
  OnPaint = FormPaint
  PixelsPerInch = 96
  TextHeight = 13
  object Panel_Curva_Melodia: TPanel
    Left = 80
    Top = 24
    Width = 400
    Height = 200
    TabOrder = 0
    Visible = False
  end
  object Radio_Aniade_Puntos: TRadioButton
    Left = 136
    Top = 232
    Width = 97
    Height = 25
    Caption = 'Añadir Puntos'
    Checked = True
    TabOrder = 1
    TabStop = True
  end
  object Radio_Mover_Puntos: TRadioButton
    Left = 240
    Top = 232
    Width = 113
    Height = 25
    Caption = 'Mover Puntos'
    TabOrder = 2
  end
  object Button1: TButton
    Left = 224
    Top = 272
    Width = 105
    Height = 25
    Caption = 'Guardar Curva'
    TabOrder = 3
  end
  object Radio_Eliminar_Puntos: TRadioButton
    Left = 352
    Top = 232
    Width = 89
    Height = 25
    Caption = 'Borrar Puntos'
    TabOrder = 4
  end
end
