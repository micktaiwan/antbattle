object Form1: TForm1
  Left = 418
  Top = 158
  Width = 850
  Height = 717
  Caption = 'Ant Battle Viewer'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 842
    Height = 694
    ActivePage = TSGUI
    Align = alClient
    Style = tsFlatButtons
    TabIndex = 0
    TabOrder = 0
    object TSGUI: TTabSheet
      Caption = 'GUI'
      object Label1: TLabel
        Left = 8
        Top = 8
        Width = 47
        Height = 13
        Caption = 'Server IP:'
      end
      object Label2: TLabel
        Left = 32
        Top = 32
        Width = 22
        Height = 13
        Caption = 'Port:'
      end
      object Memo1: TMemo
        Left = 0
        Top = 460
        Width = 834
        Height = 203
        Align = alBottom
        ScrollBars = ssBoth
        TabOrder = 0
        WordWrap = False
      end
      object Panel1: TPanel
        Left = 0
        Top = 55
        Width = 834
        Height = 405
        Align = alBottom
        Anchors = [akLeft, akTop, akRight, akBottom]
        BevelInner = bvSpace
        BorderStyle = bsSingle
        Caption = 'Panel1'
        Color = clWhite
        TabOrder = 1
      end
      object Edit2: TEdit
        Left = 64
        Top = 4
        Width = 121
        Height = 21
        TabOrder = 2
        Text = '127.0.0.1'
      end
      object Edit3: TEdit
        Left = 64
        Top = 28
        Width = 121
        Height = 21
        TabOrder = 3
        Text = '5000'
      end
      object BtnConnect: TBitBtn
        Left = 192
        Top = 28
        Width = 75
        Height = 21
        Caption = 'Connect'
        TabOrder = 4
        OnClick = BtnConnectClick
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Options'
      ImageIndex = 1
    end
  end
  object Timer1: TTimer
    Interval = 50
    OnTimer = Timer1Timer
    Left = 140
    Top = 148
  end
end
