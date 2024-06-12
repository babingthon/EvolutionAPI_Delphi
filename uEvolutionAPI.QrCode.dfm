object FrmQrCode: TFrmQrCode
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Conectar dispositivo'
  ClientHeight = 308
  ClientWidth = 286
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Verdana'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object ImageQrCode: TImage
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 280
    Height = 275
    Align = alClient
    Center = True
    Proportional = True
    ExplicitHeight = 262
  end
  object BtnChecarStatus: TRzButton
    AlignWithMargins = True
    Left = 3
    Top = 284
    Width = 280
    Height = 21
    Align = alBottom
    Caption = 'Checar Status'
    TabOrder = 0
    OnClick = BtnChecarStatusClick
  end
end
