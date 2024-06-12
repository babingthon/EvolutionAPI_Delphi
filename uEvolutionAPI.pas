unit uEvolutionAPI;

interface

uses
  System.Classes, IdHTTP, IdSSL, System.JSON, System.SysUtils,
  System.NetEncoding, IdSSLOpenSSL, IdCoderMIME, Vcl.StdCtrls,
  System.Net.HttpClientComponent, System.Net.HttpClient, Clipbrd,
  uEvolutionAPI.Emoticons, Vcl.Forms, Vcl.Controls, System.Net.URLClient;

type
  TInstanceStatus = record
    InstanceName: string;
    State: string;
  end;

type
  TServerStatus = record
    Status: string;
    Version: string;
    Msg: string;
  end;

type
  TInstanceDetail = record
    InstanceName: string;
    Status: string;
    ServerUrl: string;
    ApiKey: string;
    owner: string;
    profileName: string;
    profilePictureUrl: string;
  end;

type
  TContactDetail = record
    Id: string;
    Owner: string;
    ProfilePictureUrl: string;
    PushName: string;
  end;

  TInstances = array of TInstanceDetail;

  TContacts = array of TContactDetail;

  TBelTZap = class(TComponent)
  private
    FGlobalAPI: string;
    FServidorURL: string;
    FChaveApi: string;
    FNomeInstancia: string;
    FCodigoPais: string;
    FDDDPadrao: string;
    FForm: TForm;
    FEmojiScrollBox: TScrollBox;
    FEmojiComponent: TComponent;
    procedure DecodeBase64Stream(Input, Output: TStream);
    function DetectFileType(const filePath: string): string;
    function FormatPhoneNumber(const Numero: string): string;
    function FileToBase64(const FileName: string): string;
    procedure ClickEmoji(Sender: TObject);
  public
    function ObterInstancias: TInstances;
    function EnviarMensagemDeMidia(NumeroTelefone, Mensagem, MediaCaption, CaminhoArquivo: string): Boolean;
    function EnviarMensagemDeTexto(NumeroTelefone, Mensagem: string): Boolean;
    function CriarInstancia: Boolean;
    function DeletarInstancia: Boolean;
    function StatusInstancia: TInstanceStatus;
    function StatusServidor: TServerStatus;
    function LogoutInstancia: Boolean;
    function ObterQrCode: string;
    function ListaEmojis: Boolean;
    function ObterContatos: TContacts;
    constructor Create(AOwner: TComponent);
    function SaveImageFromURLToDisk(const ImageURL, NumeroContato: string): string;
  published
    property CodigoPais: string read FCodigoPais write FCodigoPais;
    property DDDPadrao: string read FdddPadrao write FdddPadrao;
    property ChaveApi: string read FChaveApi write FChaveApi;
    property NomeInstancia: string read FNomeInstancia write FNomeInstancia;
    property GlobalAPI: string read FGlobalAPI write FGlobalAPI;
    property ServidorURL: string read FServidorURL write FServidorURL;
    property EmojiScrollBox: TScrollBox read FEmojiScrollBox write FEmojiScrollBox;
    property Form: TForm read FForm write FForm;
    property EmojiComponent: TComponent read FEmojiComponent write FEmojiComponent;
  end;

implementation

procedure TBelTZap.ClickEmoji(Sender: TObject);
begin
  if FEmojiComponent is TEdit then
    TEdit(FEmojiComponent).Text := TEdit(FEmojiComponent).Text + TLabel(Sender).Caption;

  if FEmojiComponent is TMemo then
    TMemo(FEmojiComponent).Lines.Text := TMemo(FEmojiComponent).Lines.Text + TLabel(Sender).Caption;
end;
//

function TBelTZap.ObterInstancias: TInstances;
var
  HTTP: TIdHTTP;
  SSL: TIdSSLIOHandlerSocketOpenSSL;
  ResponseStr: string;
  JSONArray: TJSONArray;
  Instances: TInstances;
  JSONInstance: TJSONObject;
  Aux: string;
begin
  HTTP := TIdHTTP.Create(nil);
  SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);

  try
    SSL.SSLOptions.SSLVersions := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
    HTTP.IOHandler := SSL;
    HTTP.HTTPOptions := [hoNoProtocolErrorException];
    HTTP.Request.CustomHeaders.AddValue('apikey', FGlobalAPI);
    ResponseStr := HTTP.Get(FServidorURL + '/instance/fetchInstances');

    if HTTP.ResponseCode <> 200 then
      raise Exception.Create('Erro ao Realizar a Requisição: ' + HTTP.ResponseText);

    JSONArray := TJSONObject.ParseJSONValue(ResponseStr) as TJSONArray;

    try
      SetLength(Instances, JSONArray.Count);

      for var i := 0 to JSONArray.Count - 1 do
      begin
        JSONInstance := JSONArray.Items[i].GetValue<TJSONObject>('instance');

        Instances[i].InstanceName := JSONInstance.GetValue<string>('instanceName');
        Instances[i].Status := JSONInstance.GetValue<string>('status');
        Instances[i].ServerUrl := JSONInstance.GetValue<string>('serverUrl');
        Instances[i].ApiKey := JSONInstance.GetValue<string>('apikey');

        Aux := '';

        if JSONInstance.TryGetValue<string>('owner', Aux) then
          Instances[i].owner := JSONInstance.GetValue<string>('owner');

        if JSONInstance.TryGetValue<string>('profileName', Aux) then
          Instances[i].profileName := JSONInstance.GetValue<string>('profileName');

        if JSONInstance.TryGetValue<string>('profilePictureUrl', Aux) then
          Instances[i].profilePictureUrl := JSONInstance.GetValue<string>('profilePictureUrl');
      end;

      Result := Instances;
    finally
      JSONArray.Free;
    end;

  finally
    SSL.Free;
    HTTP.Free;
  end;
end;

procedure TBelTZap.DecodeBase64Stream(Input, Output: TStream);
var
  Decoder: TIdDecoderMIME;
begin
  Decoder := TIdDecoderMIME.Create(nil);
  try
    Decoder.DecodeBegin(Output);
    Decoder.Decode(Input);
    Decoder.DecodeEnd;
  finally
    Decoder.Free;
  end;
end;

function TBelTZap.DeletarInstancia: Boolean;
var
  HTTP: TIdHTTP;
  SSL: TIdSSLIOHandlerSocketOpenSSL;
begin
  HTTP := TIdHTTP.Create(nil);
  SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);

  try
    Result := False;

    SSL.SSLOptions.SSLVersions := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
    HTTP.IOHandler := SSL;
    HTTP.Request.ContentType := 'application/json';
    HTTP.HTTPOptions := [hoNoProtocolErrorException];
    HTTP.Request.CustomHeaders.AddValue('apikey', FChaveApi);

    HTTP.Delete(FServidorURL + '/instance/delete/' + FNomeInstancia);

    if HTTP.ResponseCode <> 200 then
      raise Exception.Create('Erro ao Realizar a Requisição: ' + HTTP.ResponseText);

    Result := True;

  finally
    SSL.Free;
    HTTP.Free;
  end;
end;

function TBelTZap.FormatPhoneNumber(const Numero: string): string;
var
  I: Integer;
  FormattedNumber, DDD, NumeroFinal: string;
  CountryCodeLength, DDDLength, NumeroLength: Integer;
begin
  FormattedNumber := '';
  DDD := FDDDPadrao;
  CountryCodeLength := Length(FCodigoPais);
  DDDLength := Length(FDDDPadrao);

  for I := 1 to Length(Numero) do
  begin
    if CharInSet(Numero[I], ['0'..'9']) then
      FormattedNumber := FormattedNumber + Numero[I];
  end;

  NumeroLength := Length(FormattedNumber);

  case NumeroLength of
    8:
      NumeroFinal := FormattedNumber;
    9:
      begin
        if StrToIntDef(DDD, 0) <= 33 then
          NumeroFinal := FormattedNumber
        else
          NumeroFinal := Copy(FormattedNumber, 2, 8);
      end;
    10:
      begin
        DDD := Copy(FormattedNumber, 1, 2);
        if StrToIntDef(DDD, 0) >= 33 then
          NumeroFinal := Copy(FormattedNumber, 3, 8)
        else
          NumeroFinal := '9' + Copy(FormattedNumber, 3, 8);
      end;
    11:
      begin
        DDD := Copy(FormattedNumber, 1, 2);
        if StrToIntDef(DDD, 0) > 33 then
          NumeroFinal := Copy(FormattedNumber, 4, 8)
        else
          NumeroFinal := Copy(FormattedNumber, 3, 9);
      end;
    13:
      begin
        DDD := Copy(FormattedNumber, 3, 2);
        if StrToIntDef(DDD, 0) >= 33 then
          NumeroFinal := Copy(FormattedNumber, 6, 9)
        else
          NumeroFinal := '9' + Copy(FormattedNumber, 6, 9);
      end;
  end;

  if NumeroFinal <> '' then
    Result := FCodigoPais + DDD + NumeroFinal
  else
    Result := FormattedNumber;

end;

function TBelTZap.ListaEmojis: Boolean;
var
  EmojiLabel: TLabel;
  emj: TEmojis;
begin
  emj := TEmojis.Create;

  for var I := 0 to Length(emj.EmojiList) - 1 do
  begin
    EmojiLabel := TLabel.Create(Self);
    EmojiLabel.Parent := FEmojiScrollBox; // assuming Panel1 is the name of your TPanel
    EmojiLabel.AutoSize := true;
    EmojiLabel.Font.Name := 'Segoe UI Emoji';
    EmojiLabel.Font.Size := 16;
    EmojiLabel.Caption := emj.EmojiList[I];
    EmojiLabel.Left := 10 + (I mod 11) * 40;
    EmojiLabel.Top := 20 + (I div 11) * 30;
    EmojiLabel.OnClick := ClickEmoji;
    FEmojiScrollBox.Cursor := crHandPoint;
  end;
  FreeAndNil(emj);
end;

function TBelTZap.LogoutInstancia: Boolean;
var
  HTTP: TIdHTTP;
  SSL: TIdSSLIOHandlerSocketOpenSSL;
  ResponseStr: string;
  ResponseJSON: TJSONObject;
  Status: string;
begin
  HTTP := TIdHTTP.Create(nil);
  SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);

  try

    Result := False;

    SSL.SSLOptions.SSLVersions := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
    HTTP.IOHandler := SSL;
    HTTP.HTTPOptions := [hoNoProtocolErrorException];
    HTTP.Request.CustomHeaders.AddValue('apikey', FChaveApi);
    ResponseStr := HTTP.Delete(FServidorURL + '/instance/logout/' + FNomeInstancia);
    ResponseJSON := TJSONObject.ParseJSONValue(ResponseStr) as TJSONObject;

    try

      if HTTP.ResponseCode <> 200 then
        raise Exception.Create('Erro ao Realizar a Requisição: ' + HTTP.ResponseText);

      if HTTP.ResponseCode = 200 then
      begin
        Status := ResponseJSON.GetValue<string>('status');

        if Status = 'SUCCESS' then
          Result := True;
      end;

    finally
      ResponseJSON.Free;
    end;

  finally
    SSL.Free;
    HTTP.Free;
  end;

end;

function TBelTZap.SaveImageFromURLToDisk(const ImageURL, NumeroContato: string): string;
var
  HttpClient: TNetHTTPClient;
  ImageStream: TMemoryStream;
  HttpResponse: IHTTPResponse;
  DirPath, FilePath: string;
begin
  Result := '';

  HttpClient := TNetHTTPClient.Create(nil);
  try
    ImageStream := TMemoryStream.Create;
    try
      HttpResponse := HttpClient.Get(ImageURL, ImageStream);
      if HttpResponse.StatusCode = 200 then
      begin
        ImageStream.Position := 0;

        DirPath := ExtractFilePath(ParamStr(0)) + 'foto_perfil\';
        FilePath := DirPath + NumeroContato + '.jpg';

        if not DirectoryExists(DirPath) then
          ForceDirectories(DirPath);

        ImageStream.SaveToFile(FilePath);

        Result := FilePath;
      end
      else
        raise Exception.Create('Erro ao baixar a imagem. HTTP Status: ' + HttpResponse.StatusCode.ToString);
    finally
      ImageStream.Free;
    end;
  finally
    HttpClient.Free;
  end;
end;

function TBelTZap.ObterContatos: TContacts;
var
  HTTP: TIdHTTP;
  SSL: TIdSSLIOHandlerSocketOpenSSL;
  ResponseStr: string;
  JSONArray: TJSONArray;
  Contacts: TContacts;
  JSONContact: TJSONObject;
begin
  HTTP := TIdHTTP.Create(nil);
  SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);

  try
    SSL.SSLOptions.SSLVersions := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
    HTTP.IOHandler := SSL;
    HTTP.Request.CustomHeaders.AddValue('apikey', FChaveApi);

    ResponseStr := HTTP.Get(FServidorURL + '/chat/findcontacts/' + FNomeInstancia);
    JSONArray := TJSONObject.ParseJSONValue(ResponseStr) as TJSONArray;

    SetLength(Contacts, JSONArray.Count);

    for var I := 0 to JSONArray.Count - 1 do
    begin
      Contacts[I].Id := JSONContact.GetValue<string>('id');
      Contacts[I].PushName := JSONContact.GetValue<string>('pushName');
      Contacts[I].Owner := JSONContact.GetValue<string>('owner');
      Contacts[I].ProfilePictureUrl := JSONContact.GetValue<string>('profilePictureUrl');
    end;

    Result := Contacts;

  finally
    SSL.Free;
    HTTP.Free;
  end;
end;

constructor TBelTZap.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCodigoPais := '55';
  FDDDPadrao := '99';
end;

function TBelTZap.CriarInstancia: Boolean;
var
  HTTP: TIdHTTP;
  SSL: TIdSSLIOHandlerSocketOpenSSL;
  JSONToSend, ResponseJSON: TJSONObject;
  ResponseStr: string;
  PostDataStream: TStringStream;
begin
  Result := False;

  HTTP := TIdHTTP.Create(nil);
  SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);

  try
    SSL.SSLOptions.SSLVersions := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
    HTTP.IOHandler := SSL;
    HTTP.Request.ContentType := 'application/json';
    HTTP.HTTPOptions := [hoNoProtocolErrorException];
    HTTP.Request.CustomHeaders.AddValue('apikey', FGlobalAPI);
    JSONToSend := TJSONObject.Create;

    try
      JSONToSend.AddPair('instanceName', FNomeInstancia);
      JSONToSend.AddPair('token', FChaveApi);

      PostDataStream := TStringStream.Create(JSONToSend.ToString, TEncoding.UTF8);
      ResponseStr := HTTP.Post(FServidorURL + '/instance/create', PostDataStream);

      ResponseJSON := TJSONObject.ParseJSONValue(ResponseStr) as TJSONObject;

      if not HTTP.ResponseCode in [200, 201] then
        raise Exception.Create('Erro ao Realizar a Requisição: ' + HTTP.ResponseText);

      Result := True;
    finally
      ResponseJSON.Free;
      PostDataStream.Free;
      JSONToSend.Free;
    end;
  finally
    SSL.Free;
    HTTP.Free;
  end;
end;

function TBelTZap.DetectFileType(const filePath: string): string;
var
  fileExt: string;
begin

  fileExt := LowerCase(ExtractFileExt(filePath));

  if (fileExt = '.pdf') or (fileExt = '.doc') or (fileExt = '.docx') or (fileExt = '.txt') then
    Result := 'document'
  else if (fileExt = '.jpg') or (fileExt = '.jpeg') or (fileExt = '.png') or (fileExt = '.gif') then
    Result := 'image'
  else if (fileExt = '.mp3') or (fileExt = '.wav') or (fileExt = '.ogg') then
    Result := 'audio'
  else if (fileExt = '.zip') or (fileExt = '.rar') then
    Result := 'document'
  else if (fileExt = '.xml') then
    Result := 'document'
  else
    Result := 'unknown';
end;

function CleanInvalidBase64Chars(const Base64Str: string): string;
var
  I: Integer;
begin
  Result := '';
  for I := 1 to Length(Base64Str) do
  begin
    if Base64Str[I] in ['A'..'Z', 'a'..'z', '0'..'9', '+', '/', '='] then
      Result := Result + Base64Str[I];
  end;
end;

function TBelTZap.EnviarMensagemDeMidia(NumeroTelefone, Mensagem, MediaCaption, CaminhoArquivo: string): Boolean;
var
  HTTP: TIdHTTP;
  SSL: TIdSSLIOHandlerSocketOpenSSL;
  JSONToSend: TJSONObject;
  TextMessageJSON, OptionsJSON, MediaMessageJSON: TJSONObject;
  PostDataStream: TStringStream;
  Response: string;
  url: string;
  Base64Str, FileName, tipoArquivo: string;
begin
  Result := False;
  NumeroTelefone := FormatPhoneNumber(NumeroTelefone);
  HTTP := TIdHTTP.Create(nil);
  SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  tipoArquivo := DetectFileType(CaminhoArquivo);
  Base64Str := FileToBase64(CaminhoArquivo);
  FileName := ExtractFileName(CaminhoArquivo);

  try
    SSL.SSLOptions.SSLVersions := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
    HTTP.IOHandler := SSL;
    HTTP.Request.ContentType := 'application/json';
    HTTP.HTTPOptions := [hoNoProtocolErrorException];
    HTTP.Request.CustomHeaders.AddValue('apikey', FChaveApi);

    JSONToSend := TJSONObject.Create;

    try
      JSONToSend.AddPair('number', NumeroTelefone);

      OptionsJSON := TJSONObject.Create;
      OptionsJSON.AddPair('delay', TJSONNumber.Create(1200));
      OptionsJSON.AddPair('presence', 'composing');
      JSONToSend.AddPair('options', OptionsJSON);

      MediaMessageJSON := TJSONObject.Create;
      MediaMessageJSON.AddPair('mediatype', tipoArquivo);
      MediaMessageJSON.AddPair('fileName', FileName);
      MediaMessageJSON.AddPair('caption', MediaCaption);
      MediaMessageJSON.AddPair('media', Base64Str);
      JSONToSend.AddPair('mediaMessage', MediaMessageJSON);

      PostDataStream := TStringStream.Create(JSONToSend.ToString, TEncoding.UTF8);

      try
        Response := HTTP.Post(FServidorURL + '/message/sendMedia/' + FNomeInstancia, PostDataStream);

        if not HTTP.ResponseCode in [200, 201] then
          raise Exception.Create('Erro ao Realizar a Requisição: ' + HTTP.ResponseText);

        Result := True;

      finally
        PostDataStream.Free;
      end;

    finally
      JSONToSend.Free;
    end;

  finally
    SSL.Free;
    HTTP.Free;
  end;
end;

function TBelTZap.FileToBase64(const FileName: string): string;
var
  InputStream: TFileStream;
  Bytes: TBytes;
  base64: string;
begin
  Result := '';
  if not FileExists(FileName) then
    Exit;

  InputStream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    SetLength(Bytes, InputStream.Size);
    InputStream.Read(Bytes[0], InputStream.Size);
    base64 := TNetEncoding.Base64.EncodeBytesToString(Bytes);
    base64 := CleanInvalidBase64Chars(base64);
    Result := base64;
  finally
    InputStream.Free;
  end;
end;

function TBelTZap.EnviarMensagemDeTexto(NumeroTelefone, Mensagem: string): Boolean;
var
  HTTP: TIdHTTP;
  SSL: TIdSSLIOHandlerSocketOpenSSL;
  JSONToSend: TJSONObject;
  TextMessageJSON, OptionsJSON: TJSONObject;
  PostDataStream: TStringStream;
  Response: string;
begin
  Result := False;

  HTTP := TIdHTTP.Create(nil);
  SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  NumeroTelefone := FormatPhoneNumber(NumeroTelefone);

  try
    SSL.SSLOptions.SSLVersions := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
    HTTP.IOHandler := SSL;
    HTTP.Request.ContentType := 'application/json';
    HTTP.HTTPOptions := [hoNoProtocolErrorException];
    HTTP.Request.CustomHeaders.AddValue('apikey', FChaveApi);

    JSONToSend := TJSONObject.Create;

    try
      JSONToSend.AddPair('number', NumeroTelefone);

      TextMessageJSON := TJSONObject.Create;
      TextMessageJSON.AddPair('text', Mensagem);
      JSONToSend.AddPair('textMessage', TextMessageJSON);

      OptionsJSON := TJSONObject.Create;
      OptionsJSON.AddPair('delay', TJSONNumber.Create(437));
      OptionsJSON.AddPair('presence', 'composing');
      JSONToSend.AddPair('options', OptionsJSON);

      PostDataStream := TStringStream.Create(JSONToSend.ToString, TEncoding.UTF8);

      try
        Response := HTTP.Post(FServidorURL + '/message/sendText/' + FNomeInstancia, PostDataStream);

        if not HTTP.ResponseCode in [200, 201] then
          raise Exception.Create('Erro ao Realizar a Requisição: ' + HTTP.ResponseText);

        if HTTP.ResponseCode = 201 then
          Result := True;

      finally
        PostDataStream.Free;
      end;

    finally
      JSONToSend.Free;
    end;

  finally
    SSL.Free;
    HTTP.Free;
  end;
end;

function TBelTZap.StatusInstancia: TInstanceStatus;
var
  HTTP: TIdHTTP;
  SSL: TIdSSLIOHandlerSocketOpenSSL;
  ResponseStr: string;
  ResponseJSON, InstanceJSON: TJSONObject;
  StatusData: TInstanceStatus;
begin
  HTTP := TIdHTTP.Create(nil);
  SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);

  try
    SSL.SSLOptions.SSLVersions := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
    HTTP.IOHandler := SSL;
    HTTP.HTTPOptions := [hoNoProtocolErrorException];
    HTTP.Request.CustomHeaders.AddValue('apikey', FChaveApi);
    ResponseStr := HTTP.Get(FServidorURL + '/instance/connectionState/' + FNomeInstancia);

    if HTTP.ResponseCode <> 200 then
      raise Exception.Create('Erro ao Realizar a Requisição: ' + HTTP.ResponseText);

    ResponseJSON := TJSONObject.ParseJSONValue(ResponseStr) as TJSONObject;

    try
      InstanceJSON := ResponseJSON.GetValue<TJSONObject>('instance');
      StatusData.InstanceName := InstanceJSON.GetValue<string>('instanceName');
      StatusData.State := InstanceJSON.GetValue<string>('state');
    finally
      ResponseJSON.Free;
    end;

  finally
    SSL.Free;
    HTTP.Free;
  end;

  Result := StatusData;
end;

function TBelTZap.StatusServidor: TServerStatus;
var
  HTTP: TIdHTTP;
  SSL: TIdSSLIOHandlerSocketOpenSSL;
  ResponseStr: string;
  Server: TServerStatus;
  JSONServer: TJSONObject;
begin
  HTTP := TIdHTTP.Create(nil);
  SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  try
    SSL.SSLOptions.SSLVersions := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
    HTTP.IOHandler := SSL;
    HTTP.HTTPOptions := [hoNoProtocolErrorException];
    HTTP.Request.CustomHeaders.AddValue('apikey', FGlobalAPI);
    ResponseStr := HTTP.Get(FServidorURL);

    if HTTP.ResponseCode <> 200 then
      raise Exception.Create('Erro ao Realizar a Requisição: ' + HTTP.ResponseText);

    JSONServer := TJSONObject.ParseJSONValue(ResponseStr) as TJSONObject;

    Server.Status := JSONServer.GetValue<string>('status');
    Server.Version := JSONServer.GetValue<string>('version');
    Server.Msg := JSONServer.GetValue<string>('message');

    Result := Server;

  finally
    SSL.Free;
    HTTP.Free;
  end;
end;

function TBelTZap.ObterQrCode: string;
var
  HTTP: TIdHTTP;
  SSL: TIdSSLIOHandlerSocketOpenSSL;
  ResponseStr: string;
  ResponseJSON: TJSONObject;
  Base64: string;
begin
  HTTP := TIdHTTP.Create(nil);
  SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);

  try
    SSL.SSLOptions.SSLVersions := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
    HTTP.IOHandler := SSL;
    HTTP.HTTPOptions := [hoNoProtocolErrorException];
    HTTP.Request.CustomHeaders.AddValue('apikey', FChaveApi);
    ResponseStr := HTTP.Get(FServidorURL + '/instance/connect/' + FNomeInstancia);

    if HTTP.ResponseCode <> 200 then
      raise Exception.Create('Erro ao Realizar a Requisição: ' + HTTP.ResponseText);

    ResponseJSON := TJSONObject.ParseJSONValue(ResponseStr) as TJSONObject;
    try
      Base64 := ResponseJSON.GetValue<string>('base64');

      Result := Base64;

    finally
      ResponseJSON.Free;
    end;
  finally
    SSL.Free;
    HTTP.Free;
  end;

end;

end.

