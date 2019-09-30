unit Stats.CPU;

interface

uses
  System.Classes, System.SysUtils, Linux.Utils, System.JSON.Serializers;

type
  TLoadAVG = record
    [JSONName('Minute')]
    F1minute : Double;
    [JSONName('FiveMinutes')]
    F5minute : Double;
    [JSONName('FiftenMinutes')]
    F15minute: Double;
  end;

  TFrequency = array of Double;

  TCPUInfo = class
  private
    [JSONName('Model')]
    FModel: string;
    [JSONName('Processors')]
    FProcessors: Integer;
    [JSONName('LoadAVG')]
    FLoadAVG: TLoadAVG;
    [JSONName('Frequency')]
    FFrequency: TFrequency;
    [JSONName('CacheSize')]
    FCacheSize: String;
    procedure GetModel;
    procedure GetProcessors;
    procedure GetCacheSize;
    procedure GetFrequency;
    procedure GetLoadAvg;
  public
    property LoadAVG : TLoadAVG read FLoadAVG;
    property Processors : Integer read FProcessors;
    property Model : string read FModel;
    property Frequency : TFrequency read FFrequency;
    property CacheSize : String read FCacheSize;
    constructor Create;
  end;
implementation

{ TCPUInfo }

constructor TCPUInfo.Create;
begin
  GetModel;
  GetProcessors;
  GetCacheSize;
  GetFrequency;
  GetLoadAvg;
end;

procedure TCPUInfo.GetCacheSize;
var
  Cmd : String;
begin
  try
    Cmd := 'cat /proc/cpuinfo | grep -i "^cache size" | awk -F": " ''{print $2}'' | head -1';
    TLinuxUtils.RunCommand(Cmd,FCacheSize);
  except
    on E:Exception do
    begin
    {$IFDEF DEBUG}
      TLinuxUtils.LogError('TCPUInfo.GetCacheSize - ' + E.Message);
    {$ENDIF}
    end;
  end;
end;

procedure TCPUInfo.GetFrequency;
var
  Cmd: String;
  CmdResult : TStringList;
  I: Integer;
begin
  try
    Cmd := 'cat /proc/cpuinfo | grep -i "^cpu MHz" | awk -F": " ''{print $2}''';
    CmdResult := TLinuxUtils.RunCommandLine(Cmd);
    try
      SetLength(FFrequency,CmdResult.Count);

      for I := 0 to Pred(CmdResult.Count) do
      begin
        FFrequency[I] := Round(StrToFloatDef(CmdResult[I].Replace('.',','),0));
      end;
    finally
      CmdResult.Free;
    end;
  except
    on E:Exception do
    begin
    {$IFDEF DEBUG}
      TLinuxUtils.LogError('TCPUInfo.GetFrequency - ' + E.Message);
    {$ENDIF}
    end;
  end;
end;

procedure TCPUInfo.GetLoadAvg;
var
  Cmd, CmdResult:String;
begin
  try
    Cmd := 'cat /proc/loadavg';
    TLinuxUtils.RunCommand(Cmd,CmdResult);
    FLoadAVG.F1minute  := StrToFloatDef(CmdResult.Split([' '])[0].Replace('.',','),0);
    FLoadAVG.F5minute  := StrToFloatDef(CmdResult.Split([' '])[1].Replace('.',','),0);
    FLoadAVG.F15minute := StrToFloatDef(CmdResult.Split([' '])[2].Replace('.',','),0);
  except
    on E:Exception do
    begin
    {$IFDEF DEBUG}
      TLinuxUtils.LogError('TCPUInfo.GetLoadAvg - ' + E.Message);
    {$ENDIF}
    end;
  end;
end;

procedure TCPUInfo.GetModel;
var
  Cmd : String;
begin
  try
    Cmd := 'cat /proc/cpuinfo | grep -i "^model name" | awk -F": " ''{print $2}'' | head -1 | sed ''s/ \+/ /g''';
    TLinuxUtils.RunCommand(Cmd,FModel);
  except
    on E:Exception do
    begin
    {$IFDEF DEBUG}
      TLinuxUtils.LogError('TCPUInfo.GetModel - ' + E.Message);
    {$ENDIF}
    end;
  end;
end;

procedure TCPUInfo.GetProcessors;
begin
  try
    FProcessors := System.CPUCount;
  except
    on E:Exception do
    begin
    {$IFDEF DEBUG}
      TLinuxUtils.LogError('TCPUInfo.GetProcessors - ' + E.Message);
    {$ENDIF}
    end;
  end;
end;

end.
