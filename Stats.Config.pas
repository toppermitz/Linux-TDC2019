unit Stats.Config;

interface

uses
  System.SysUtils,System.Classes, System.IOUtils, System.JSON, Stats.Types, System.JSON.Serializers;

type
  TStatsConfig = class
  const
    ConfigFileName = 'LinuxStatsConfig.json';
  private
    [JSONName('HTTPPort')]
    FHTTPPort: Integer;
    [JSONName('DatabaseMountPoint')]
    FDatabaseMountPoint: string;
    [JSONName('WebPath')]
    FWebPath: String;
    procedure LoadDefaultValues;
    procedure SetDatabaseMountPoint(const Value: string);
    procedure SetHTTPPort(const Value: Integer);
    procedure SetWebPath(const Value: String);
  public
    property HTTPPort : Integer read FHTTPPort write SetHTTPPort;
    property DatabaseMountPoint : string read FDatabaseMountPoint write SetDatabaseMountPoint;
    property WebPath : String read FWebPath write SetWebPath;
    class function LoadFromJSON(const AFileName : String;const AEncoding : TStatsEncoding) : TStatsConfig; overload;
    class function LoadFromJSON(const AJSON : String): TStatsConfig;overload;
    function ToJSON : string;
    procedure FromJSON(const AJSON : String);
  end;

implementation

{ TStatsConfig }

procedure TStatsConfig.FromJSON(const AJSON: String);
var
  Serializer : TJsonSerializer;
begin
  Serializer := TJsonSerializer.Create;
  try
    Serializer.Populate<TStatsConfig>(AJSON,Self);
  finally
    Serializer.Free;
  end;
end;

procedure TStatsConfig.LoadDefaultValues;
begin
  Self.HTTPPort := 9090;
  Self.DatabaseMountPoint := '/';
end;

class function TStatsConfig.LoadFromJSON(const AJSON: String): TStatsConfig;
begin
  Result := TStatsConfig.Create;
  try
    Result.FromJSON(AJSON);
  except
    Result.free;
    raise;
  end;
end;

class function TStatsConfig.LoadFromJSON(const AFileName: String;const AEncoding: TStatsEncoding): TStatsConfig;
begin
  Result := TStatsConfig.Create;
  try
    if TFile.Exists(AFileName) then begin
      Result.FromJSON(TFile.ReadAllText(AFileName, AEncoding.ToEncoding));
    end else
      Result.LoadDefaultValues;
  except
    Result.free;
    raise;
  end;
end;

procedure TStatsConfig.SetDatabaseMountPoint(const Value: string);
begin
  FDatabaseMountPoint := Value;
end;

procedure TStatsConfig.SetHTTPPort(const Value: Integer);
begin
  FHTTPPort := Value;
end;

procedure TStatsConfig.SetWebPath(const Value: String);
begin
  FWebPath := Value;
end;

function TStatsConfig.ToJSON: string;
var
  Serializer : TJsonSerializer;
begin
  Serializer := TJsonSerializer.Create;
  try
    Result := Serializer.Serialize<TStatsConfig>(Self);
  finally
    Serializer.Free;
  end;
end;

end.
