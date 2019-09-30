unit Stats.Disk;

interface

uses
  System.Classes, System.SysUtils, Linux.Utils, System.JSON.Serializers,
  Stats.Config, Stats.Types;

type
  TDiskInfo = class
  private
    [JSONName('Name')]
    FName: string;
    [JSONName('MountPoint')]
    FMount: string;
    [JSONName('%Used')]
    FPerUsed: Double;
    [JSONName('TotalSize')]
    FSize: Double;
    [JSONName('Free')]
    FFree: Double;
    procedure GetMount(APath : String);
  public
    property Name : string read FName;
    property Mount: string read FMount;
    property Size : Double read FSize;
    property FreeSpace : Double read FFree;
    property PercUsed : Double read FPerUsed;
    constructor Create;
  end;

implementation

{ TDiskInfo }

constructor TDiskInfo.Create;
var
  Config : TStatsConfig;
begin
  Config := TStatsConfig.Create;
  try
    Config := TStatsConfig.LoadFromJSON(TLinuxUtils.GetApplicationPath + TStatsConfig.ConfigFileName,seUTF8);
    GetMount(Config.DatabaseMountPoint);
  finally
    Config.Free;
  end;
end;

procedure TDiskInfo.GetMount(APath : String);
var
  Cmd: String;
  Usado : Double;
  CmdResult : TStringList;
  teste : String;
begin
  try
    Cmd := 'df -m ' + APath;
    CmdResult := TLinuxUtils.RunCommandLine(Cmd);
    try
      if CmdResult.Count > 2 then
      begin
        if Assigned(CmdResult) then
          CmdResult.Free;

        Cmd := 'df -m ' + APath + ' | sed "1 d" | grep -iv "^Filesystem|Sys."';
        CmdResult := TLinuxUtils.RunCommandLine(Cmd);
        try
          FName := CmdResult[0].Trim;
        finally
          CmdResult.Free;
        end;

        Cmd :='df -m / | sed "1 d" | grep -iv "^Filesystem|Sys." | sort | head -1 | awk ''{print ". "$5" "$1" "$3}''';
        CmdResult := TLinuxUtils.RunCommandLine(Cmd);


      end else begin
        if Assigned(CmdResult) then
          CmdResult.Free;
        Cmd := 'df -m ' + APath + ' | awk END{print} | awk ''{print $1" "$6" "$2" "$4}''';
        CmdResult := TLinuxUtils.RunCommandLine(Cmd);
        FName := CmdResult.Text.Split([' '])[0];
      end;
      teste := CmdResult.Text;
      FMount := CmdResult.Text.Split([' '])[1];
      FSize := StrToFloatDef(CmdResult.Text.Split([' '])[2],0);
      FFree := TLinuxUtils.OnlyNumber(CmdResult.Text.Split([' '])[3]);
      Usado := FSize - FFree;
      FPerUsed :=  Round((Usado / FSize)*100);
    finally
      if Assigned(CmdResult) then
        CmdResult.Free;
    end;
  except
    on E:Exception do
    begin
    {$IFDEF DEBUG}
      TLinuxUtils.LogError('TDiskInfo.GetMount - ' + E.Message);
    {$ENDIF}
    end;
  end;
end;


end.
