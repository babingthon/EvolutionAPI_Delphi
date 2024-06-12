program EvolutionAPI;

uses
  Vcl.Forms,
  uEvolutionAPI in 'uEvolutionAPI.pas',
  uEvolutionAPI.Emoticons in 'uEvolutionAPI.Emoticons.pas',
  uEvolutionAPI.QrCode in 'uEvolutionAPI.QrCode.pas' {FrmQrCode},
  uPrincipal in 'uPrincipal.pas' {FrmPrincipal},
  uEvolutionAPI.Token in 'uEvolutionAPI.Token.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmPrincipal, FrmPrincipal);
  Application.Run;
end.

