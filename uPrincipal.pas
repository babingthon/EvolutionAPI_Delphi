unit uPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uEvolutionAPI,
  uEvolutionAPI.Emoticons, Vcl.StdCtrls, Vcl.ExtCtrls, RzPanel, RzButton,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error,
  FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, Vcl.Grids, Vcl.DBGrids, RzDBGrid,
  System.ImageList, Vcl.ImgList, RzTabs, Vcl.ComCtrls, RzEdit, Vcl.Mask,
  Soap.EncdDecd, Vcl.DBCtrls, Datasnap.DBClient, Vcl.DBCGrids,
  System.Net.HttpClient, Vcl.Imaging.pngimage, RzLabel, RzDBLbl, Jpeg,
  uEvolutionAPI.Token, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,
  IdHTTP, Generics.Collections;

type
  TFrmPrincipal = class(TForm)
    FDMemInstancias: TFDMemTable;
    DsInstancias: TDataSource;
    FDMemInstanciasApiKey: TStringField;
    FDMemInstanciasInstanceName: TStringField;
    FDMemInstanciasServerURL: TStringField;
    FDMemInstanciasStatus: TStringField;
    ImageList1: TImageList;
    PgPrincipal: TRzPageControl;
    TS_Eventos: TRzTabSheet;
    TS_Configuracoes: TRzTabSheet;
    GbConfiguracoes: TRzGroupBox;
    Label1: TLabel;
    EdServidor: TLabeledEdit;
    EdApiKey: TLabeledEdit;
    RzGroupBox1: TRzGroupBox;
    DbGridInstancias: TRzDBGrid;
    ScrollBox1: TScrollBox;
    btnTextoSimples: TButton;
    btnArquivo: TButton;
    FileOpenDialog1: TFileOpenDialog;
    RzPanel1: TRzPanel;
    Label2: TLabel;
    DBEdit1: TDBEdit;
    Label3: TLabel;
    DBEdit2: TDBEdit;
    TabSheet1: TRzTabSheet;
    RzGroupBox2: TRzGroupBox;
    Panel1: TPanel;
    Label4: TLabel;
    EditNumeroContato: TEdit;
    ScrollBoxEmoticons: TScrollBox;
    RzButton1: TRzButton;
    MemoTxt: TMemo;
    DBCtrlGrid1: TDBCtrlGrid;
    DBText1: TDBText;
    DBText2: TDBText;
    DBImage1: TDBImage;
    cdscontato: TClientDataSet;
    cdscontatoCONTATO: TStringField;
    cdscontatoFOTO: TBlobField;
    cdscontatoTEL: TStringField;
    dsContato: TDataSource;
    RzPanel2: TRzPanel;
    RzButton2: TRzButton;
    RzDBLabel1: TRzDBLabel;
    RzDBLabel2: TRzDBLabel;
    FDMemInstanciasprofileName: TStringField;
    FDMemInstanciasowner: TStringField;
    FDMemInstanciasprofilePhoto: TBlobField;
    ImgProfile: TImage;
    RzPanel3: TRzPanel;
    BtnLogout: TRzButton;
    BtnQrCode: TRzButton;
    BtnObterInstancias: TRzButton;
    RzButton4: TRzButton;
    EdtInstancia: TRzEdit;
    RzButton5: TRzButton;
    RzButton3: TRzButton;
    procedure Label1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Label1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnObterInstanciasClick(Sender: TObject);
    procedure FDMemInstanciasAfterScroll(DataSet: TDataSet);
    procedure btnTextoSimplesClick(Sender: TObject);
    procedure btnArquivoClick(Sender: TObject);
    procedure RzButton1Click(Sender: TObject);
    procedure ScrollBoxEmoticonsMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure RzButton2Click(Sender: TObject);
    procedure BtnLogoutClick(Sender: TObject);
    procedure BtnQrCodeClick(Sender: TObject);
    procedure EdtInstanciaKeyPress(Sender: TObject; var Key: Char);
    procedure RzButton4Click(Sender: TObject);
    procedure RzButton5Click(Sender: TObject);
    procedure RzButton3Click(Sender: TObject);
  private
    FBeltZap: TBelTZap;
    FToken: TBeltToken;
    FItensTexto: array of string;
    procedure LoadImageFromURL(const AURL: string; out ABlobStream: TMemoryStream);
    procedure LoadBase64ToImage(const Base64: string; Image: TImage);
    procedure CarregarFotoPerfil;
    procedure NovaMensagem;
        { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

uses
  uEvolutionAPI.QrCode;

{$R *.dfm}

procedure TFrmPrincipal.btnArquivoClick(Sender: TObject);
begin
  FileOpenDialog1.Execute;
  if FileOpenDialog1.FileName <> '' then
    if FBeltZap.EnviarMensagemDeMidia(EditNumeroContato.Text, '', '', FileOpenDialog1.FileName) then
    begin
      MessageDlg('Mensagem Enviada Com Sucesso.', mtConfirmation, [mbOK], 0);
      NovaMensagem;
    end;
end;

procedure TFrmPrincipal.BtnObterInstanciasClick(Sender: TObject);
var
  ImageStream: TMemoryStream;
  FInstancias: TInstances;
begin

  try
    FInstancias := FBeltZap.ObterInstancias;
    FDMemInstancias.EmptyDataSet;

    for var i := 0 to High(FInstancias) do
    begin

      FDMemInstancias.Append;

      if FInstancias[i].profilePictureUrl <> '' then
      begin
        FBeltZap.SaveImageFromURLToDisk(FInstancias[i].profilePictureUrl, FInstancias[i].InstanceName);
      end;

      FDMemInstanciasInstanceName.AsString := FInstancias[i].InstanceName;
      FDMemInstanciasApiKey.AsString := FInstancias[i].ApiKey;
      FDMemInstanciasStatus.AsString := FInstancias[i].Status;
      FDMemInstanciasowner.AsString := FInstancias[i].owner;
      FDMemInstanciasprofileName.AsString := FInstancias[i].profileName;

      FDMemInstancias.Post;
    end;

    FDMemInstancias.First;
  except
    on E: Exception do
    begin
      MessageDlg(E.Message, mtError, [mbOK], 0);
      Abort;
    end;
  end;

end;

procedure TFrmPrincipal.BtnQrCodeClick(Sender: TObject);
var
  Base64QRCode: string;
begin
  Base64QRCode := FBeltZap.ObterQrCode;

  Application.CreateForm(TFrmQrCode, FrmQrCode);
  FrmQrCode.vConectado := False;
  FrmQrCode.vInstancia := FDMemInstanciasInstanceName.AsString;
  FrmQrCode.vChave := FDMemInstanciasApiKey.AsString;
  FrmQrCode.vServidor := EdServidor.Text;
  LoadBase64ToImage(Base64QRCode, FrmQrCode.ImageQrCode);
  FrmQrCode.ShowModal;

  if FrmQrCode.vConectado then
    BtnObterInstancias.Click
  else
    BtnLogout.Click;

  FreeAndNil(FrmQrCode);
end;

procedure TFrmPrincipal.btnTextoSimplesClick(Sender: TObject);
begin
  if FBeltZap.EnviarMensagemDeTexto(EditNumeroContato.Text, MemoTxt.Text) then
  begin
    MessageDlg('Mensagem Enviada Com Sucesso.', mtConfirmation, [mbOK], 0);
    NovaMensagem;
  end;
end;

procedure TFrmPrincipal.CarregarFotoPerfil;
var
  DirPath, FilePath: string;
begin

  ImgProfile.Picture := nil;
  DirPath := ExtractFilePath(ParamStr(0)) + 'foto_perfil\';
  FilePath := DirPath + FDMemInstanciasInstanceName.AsString + '.jpg';

  if FileExists(FilePath) then
  begin
    ImgProfile.Picture.LoadFromFile(FilePath);
  end;

end;

procedure TFrmPrincipal.EdtInstanciaKeyPress(Sender: TObject; var Key: Char);
begin
  if ((Key in ['0'..'9'] = false) and (word(Key) <> vk_back)) then
    Key := #0;
end;

procedure TFrmPrincipal.FDMemInstanciasAfterScroll(DataSet: TDataSet);
begin
  FBeltZap.ChaveApi := FDMemInstanciasApiKey.AsString;
  FBeltZap.NomeInstancia := FDMemInstanciasInstanceName.AsString;

  CarregarFotoPerfil;

  if FDMemInstanciasStatus.AsString = 'close' then
  begin
    BtnQrCode.Visible := True;
  end
  else
  begin
    BtnQrCode.Visible := False;
  end;

end;

procedure TFrmPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FToken.Free;
  FBeltZap.Free;
end;

procedure TFrmPrincipal.FormCreate(Sender: TObject);
begin
  FBeltZap := TBelTZap.Create(nil);
  FBeltZap.GlobalAPI := EdApiKey.Text;
  FBeltZap.ServidorURL := EdServidor.Text;
  FBeltZap.Form := Self;
  FBeltZap.EmojiScrollBox := ScrollBoxEmoticons;
  FBeltZap.EmojiComponent := MemoTxt;
  FDMemInstancias.CreateDataSet;
end;

procedure TFrmPrincipal.Label1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  EdApiKey.PasswordChar := #0
end;

procedure TFrmPrincipal.Label1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  EdApiKey.PasswordChar := '*';
end;

procedure TFrmPrincipal.LoadBase64ToImage(const Base64: string; Image: TImage);
var
  CleanedBase64: string;
  Input: TStringStream;
  Output: TMemoryStream;
  Img: TPNGImage;  // Para PNG
begin
  // Remover o prefixo da string Base64
  CleanedBase64 := Base64.Replace('data:image/png;base64,', '', [rfIgnoreCase]);

  Input := TStringStream.Create(CleanedBase64, TEncoding.ASCII);
  try
    Output := TMemoryStream.Create;
    try
      DecodeStream(Input, Output);
      Output.Position := 0;

      Img := TPNGImage.Create;  // Para PNG
      try
        Img.LoadFromStream(Output);
        Image.Picture.Assign(Img);
      finally
        Img.Free;
      end;

    finally
      Output.Free;
    end;
  finally
    Input.Free;
  end;
end;

procedure TFrmPrincipal.LoadImageFromURL(const AURL: string; out ABlobStream: TMemoryStream);
var
  HttpClient: THttpClient;
  Response: IHTTPResponse;
begin
  HttpClient := THttpClient.Create;
  ABlobStream := TMemoryStream.Create;
  try
    try
      Response := HttpClient.Get(AURL, ABlobStream);
      ABlobStream.Position := 0;
    except
      // Trate qualquer exceção aqui
    end;
  finally
    HttpClient.Free;
  end;
end;

procedure TFrmPrincipal.NovaMensagem;
begin
  MemoTxt.Lines.Clear;
  EditNumeroContato.Text := EmptyStr;
end;

procedure TFrmPrincipal.RzButton1Click(Sender: TObject);
begin
  FBeltZap.ListaEmojis;
end;

procedure TFrmPrincipal.RzButton2Click(Sender: TObject);
var
  FContatos: TContacts;
  ImageStream: TMemoryStream;
begin

  FContatos := FBeltZap.ObterContatos;

  if cdscontato.Active then
    cdscontato.EmptyDataSet
  else
    cdscontato.CreateDataSet;

  for var i := 0 to High(FContatos) do
  begin
    LoadImageFromURL(FContatos[i].profilePictureUrl, ImageStream);

    cdscontato.Append;
    TBlobField(cdscontatoFOTO).LoadFromStream(ImageStream);
    cdscontatoCONTATO.AsString := FContatos[i].pushName;
    cdscontatoTEL.AsString := FContatos[i].id;
    cdscontato.Post;
  end;
end;

procedure TFrmPrincipal.RzButton3Click(Sender: TObject);
var
  StatusServidor: TServerStatus;
begin

  FBeltZap.GlobalAPI := EdApiKey.Text;
  FBeltZap.ServidorURL := EdServidor.Text;

  StatusServidor := FBeltZap.StatusServidor;

  if StatusServidor.Status = '200' then
    MessageDlg('Servidor OK.' + sLineBreak + StatusServidor.Version, mtConfirmation, [mbOK], 0);

end;

procedure TFrmPrincipal.BtnLogoutClick(Sender: TObject);
begin
  if FBeltZap.LogoutInstancia then
    BtnObterInstancias.Click;
end;

procedure TFrmPrincipal.RzButton4Click(Sender: TObject);
begin

  try
    FBeltZap.NomeInstancia := EdtInstancia.Text;
    FToken := TBeltToken.Create;
    FBeltZap.ChaveApi := FToken.GerarToken(EdtInstancia.Text);

    if FBeltZap.CriarInstancia then
    begin
      MessageDlg('Instancia Criada com Sucesso.', mtConfirmation, [mbOK], 0);
      BtnObterInstancias.Click;
      EdtInstancia.Text := EmptyStr;
    end;

  except
    on E: Exception do
    begin
      MessageDlg('Instancia já Existe.', mtWarning, [mbOK], 0);
      Abort;
    end;
  end;
end;

procedure TFrmPrincipal.RzButton5Click(Sender: TObject);
begin

  if MessageDlg('Deseja deletar a instância?', mtWarning, [mbYes, mbNo], 0) <> IDYES then
    Abort;

  try

    if FBeltZap.DeletarInstancia then
    begin
      MessageDlg('Instancia Deletada com Sucesso.', mtConfirmation, [mbOK], 0);
    end;

  except
    on E: Exception do
    begin
      MessageDlg('Instancia não Existe.', mtWarning, [mbOK], 0);
      Abort;
    end;
  end;
end;

procedure TFrmPrincipal.ScrollBoxEmoticonsMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  ScrollBox1.VertScrollBar.Position := ScrollBox1.VertScrollBar.Position - WheelDelta;
  Handled := True;
end;

end.

