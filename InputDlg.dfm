object FInputDlg: TFInputDlg
  Left = 463
  Top = 456
  BorderStyle = bsDialog
  ClientHeight = 71
  ClientWidth = 566
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = True
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object OKBtn: TButton
    Left = 205
    Top = 40
    Width = 75
    Height = 25
    Cursor = crHandPoint
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object CancelBtn: TButton
    Left = 285
    Top = 40
    Width = 75
    Height = 25
    Cursor = crHandPoint
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object edtName: TLabeledEdit
    Left = 104
    Top = 8
    Width = 409
    Height = 24
    EditLabel.Width = 40
    EditLabel.Height = 16
    EditLabel.Caption = 'Name:'
    EditLabel.Font.Charset = RUSSIAN_CHARSET
    EditLabel.Font.Color = clWindowText
    EditLabel.Font.Height = -12
    EditLabel.Font.Name = 'Fixedsys'
    EditLabel.Font.Style = []
    EditLabel.ParentFont = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Fixedsys'
    Font.Style = []
    LabelPosition = lpLeft
    ParentFont = False
    TabOrder = 2
    OnEnter = edtNameEnter
  end
end
