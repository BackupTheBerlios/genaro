object Form1: TForm1
  Left = 191
  Top = 98
  Width = 800
  Height = 600
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 8
    Top = 168
    Width = 769
    Height = 289
    TabOrder = 0
  end
  object ScrollBar1: TScrollBar
    Left = 80
    Top = 464
    Width = 697
    Height = 17
    PageSize = 0
    TabOrder = 1
  end
  object ScrollBar2: TScrollBar
    Left = 176
    Top = 496
    Width = 545
    Height = 17
    PageSize = 0
    TabOrder = 2
  end
  object Button2: TButton
    Left = 16
    Top = 492
    Width = 33
    Height = 25
    Caption = '[_]'
    TabOrder = 3
  end
  object Button3: TButton
    Left = 48
    Top = 492
    Width = 33
    Height = 25
    Caption = '|>'
    TabOrder = 4
  end
  object Button5: TButton
    Left = 80
    Top = 492
    Width = 33
    Height = 25
    Caption = '| |'
    TabOrder = 5
  end
  object Button1: TButton
    Left = 16
    Top = 56
    Width = 73
    Height = 25
    Caption = 'Exportar Midi'
    TabOrder = 6
  end
  object Button4: TButton
    Left = 16
    Top = 80
    Width = 73
    Height = 25
    Caption = 'Exportar Wav'
    TabOrder = 7
  end
  object Button6: TButton
    Left = 16
    Top = 104
    Width = 73
    Height = 25
    Caption = 'Exportar PDF'
    TabOrder = 8
  end
  object EditFicheroProlog: TEdit
    Left = 256
    Top = 24
    Width = 153
    Height = 21
    TabOrder = 9
    Text = 'generador_acordes.pl'
  end
  object EditRelacionProlog: TEdit
    Left = 480
    Top = 24
    Width = 153
    Height = 21
    TabOrder = 10
    Text = 'genera_acordes(5,5,paralelo)'
  end
  object MainMenu1: TMainMenu
    Left = 8
    Top = 136
    object Archivo1: TMenuItem
      Caption = '&Archivo'
      object Salir1: TMenuItem
        Caption = '&Salir'
      end
    end
    object Edicin1: TMenuItem
      Caption = '&Edición'
    end
    object Insertar1: TMenuItem
      Caption = '&Insertar'
    end
  end
end
