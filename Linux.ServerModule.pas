unit Linux.ServerModule;

interface

uses
  System.SysUtils, System.Classes, IdBaseComponent, IdComponent, IdCustomTCPServer,
  IdCustomHTTPServer, IdHTTPServer, Stats.SystemInfo, System.IOUtils,
  System.JSON.Serializers, Stats.Config, IdContext, Linux.Utils, Stats.Types;

type
  TServerModule = class(TDataModule)
    HTTPServer: TIdHTTPServer;
    procedure HTTPServerCommandGet(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure HTTPServerCommandOther(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    FConfig : TStatsConfig;
    function Auth(var ARequestInfo : TIdHTTPRequestInfo; var AResponseInfo : TIdHttpResponseInfo): Boolean;
    function NeedAuth(AUri : string) : Boolean;
    procedure GetFile(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure OnCommand(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
  public
    procedure ConfigurePort(APort: Integer = -1);
    procedure Start;
    procedure Stop;
    class procedure InstallService(const ADistro : TLinuxDistro; const APath :String);static;
  end;

var
  ServerModule: TServerModule;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

function TServerModule.Auth(var ARequestInfo: TIdHTTPRequestInfo;
  var AResponseInfo: TIdHttpResponseInfo): Boolean;
begin
  Result := ARequestInfo.AuthExists and (ARequestInfo.AuthUsername = 'master') and (ARequestInfo.AuthPassword = 'senha');

  if Result then
  begin
    AResponseInfo.ResponseNo := 200;
  end else begin
    AResponseInfo.AuthRealm := 'Linux Stats Monitor';
  end;
end;

procedure TServerModule.ConfigurePort(APort: Integer = -1);
begin
  Stop;
  if APort = -1 then
  begin
    FConfig.Free;
    FConfig := TStatsConfig.LoadFromJSON(TLinuxUtils.GetApplicationPath + TStatsConfig.ConfigFileName,seUTF8);
    HTTPServer.DefaultPort := FConfig.HTTPPort;
  end else begin
    HTTPServer.DefaultPort := APort;
  end;
  Start;
end;

procedure TServerModule.DataModuleCreate(Sender: TObject);
begin
  FConfig := TStatsConfig.LoadFromJSON(TLinuxUtils.GetApplicationPath + TStatsConfig.ConfigFileName,seUTF8);
end;

procedure TServerModule.DataModuleDestroy(Sender: TObject);
begin
  FConfig.Free;
end;

procedure TServerModule.GetFile(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  FileStream: TFileStream;
  FileName : String;
begin
  FileName := ARequestInfo.URI;

  if Copy(FileName, FileName.Length - 1 , 1) = '/' then
      FileName := FileName + 'index.html';

  if NeedAuth(FileName) and not Auth(ARequestInfo,AResponseInfo) then
    Exit;

  if TFile.Exists(FConfig.WebPath + FileName) then
  begin
    FileStream := TFile.Open(FConfig.WebPath + FileName,TFileMode.fmOpen);
    AResponseInfo.ContentStream := FileStream;
    AResponseInfo.ContentLength := FileStream.Size;
    AResponseInfo.ContentType := AResponseInfo.HTTPServer.MIMETable.GetFileMIMEType(FConfig.WebPath + FileName) + '; charset=UTF-8';
  end
  else
    AResponseInfo.ResponseNo := 404;
end;



procedure TServerModule.HTTPServerCommandGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin
  OnCommand(AContext, ARequestInfo, AResponseInfo);
end;

procedure TServerModule.HTTPServerCommandOther(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin
  OnCommand(AContext, ARequestInfo, AResponseInfo);
end;

class procedure TServerModule.InstallService(const ADistro: TLinuxDistro;const APath: String);
begin

end;

function TServerModule.NeedAuth(AUri: string): Boolean;
begin
  Result := true;
  if AUri.ToLower = '/img/favicon.png' then
    Result := false;
end;

procedure TServerModule.OnCommand(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  SystemInfo : TSystemInfo;
  Serializer : TJsonSerializer;
begin
  if ARequestInfo.URI.ToLower = '/get/server' then
  begin
    SystemInfo := TSystemInfo.Create;
    try
      Serializer := TJsonSerializer.Create;
      try
        AResponseInfo.ContentType := 'application/json';
        AResponseInfo.ContentText := Serializer.Serialize(SystemInfo);
      finally
        if Assigned(Serializer) then
          Serializer.Free;
      end;
    finally
      if Assigned(SystemInfo) then
        SystemInfo.Free;
    end;
  end else begin
    GetFile(ARequestInfo, AResponseInfo);
  end;
end;

procedure TServerModule.Start;
begin
  if HTTPServer <> nil then
    if not HTTPServer.Active then
      HTTPServer.Active := True;
end;

procedure TServerModule.Stop;
begin
  HTTPServer.Active := False;
end;

end.
