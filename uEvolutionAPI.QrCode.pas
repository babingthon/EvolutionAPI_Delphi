unit uEvolutionAPI.QrCode;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.StdCtrls, System.IOUtils, Vcl.ComCtrls, RzButton, uEvolutionAPI;

type
  TFrmQrCode = class(TForm)
    ImageQrCode: TImage;
    BtnChecarStatus: TRzButton;
    procedure BtnChecarStatusClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FBelt: TBelTZap;
  public
    vInstancia, vChave, vServidor: string;
    vConectado: Boolean;
  end;

var
  FrmQrCode: TFrmQrCode;

implementation

{$R *.dfm}

procedure TFrmQrCode.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FBelt.Free;
end;

procedure TFrmQrCode.FormCreate(Sender: TObject);
begin
  FBelt := TBelTZap.Create(nil);
end;

procedure TFrmQrCode.BtnChecarStatusClick(Sender: TObject);
var
  Instance: TInstanceStatus;
begin
  FBelt.NomeInstancia := vInstancia;
  FBelt.ChaveApi := vChave;
  FBelt.ServidorURL := vServidor;

  Instance := FBelt.StatusInstancia;

  if Instance.State = 'open' then
  begin
    vConectado := True;
    Close;
  end;
end;

end.

