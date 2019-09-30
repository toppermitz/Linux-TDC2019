unit Stats.Memory;

interface

uses
  System.Classes, System.SysUtils, Linux.Utils, System.JSON.Serializers, System.Math;

type
  TSizeType = (stKB, stMB, stGB);
  TMemoryInfo = class(TObject)
  private
    [JsonName('Total')]
    FTotal: Double;
    [JsonName('Used')]
    FUsed: Double;
   [JsonName('Free')]
    FFree: Double;
    [JsonIgnore]
    FSizeType : TSizeType;
    procedure GetMemoryData;
  public
    property Total : Double read FTotal;
    property MemFree : Double read FFree;
    property Used : Double read FUsed;
    constructor Create(ASizeType : TSizeType);
  end;



implementation

{ TMemoryInfo }

constructor TMemoryInfo.Create(ASizeType : TSizeType);
begin
  inherited Create;
  FSizeType := ASizeType;
  GetMemoryData;
end;

procedure TMemoryInfo.GetMemoryData;
var
  Cmd : String;
  SizeArgument : string;
  Buffers, Cached : Double;

begin
  try
    case FSizeType of
      stKB: SizeArgument := 'k';
      stMB: SizeArgument := 'm';
      stGB: SizeArgument := 'm';
    end;

    //Memory in buffers + cached is actually available, so we count it
    //as free. See http://www.linuxatemyram.com/ for details
    Cmd := 'cat /proc/meminfo | grep "^MemFree:" | awk ''{print $2}''';
    TLinuxUtils.RunCommand(Cmd,FFree);

    Cmd := 'cat /proc/meminfo | grep "^Buffers:" | awk ''{print $2}''';
    TLinuxUtils.RunCommand(Cmd,Buffers);

    Cmd := 'cat /proc/meminfo | grep "^Cached:" | awk ''{print $2}''';
    TLinuxUtils.RunCommand(Cmd,Cached);

    FFree := FFree + Buffers + Cached;

    //Pegando dados de memória total
    Cmd := 'cat /proc/meminfo | grep "^MemTotal:" | awk ''{print $2}''';
    TLinuxUtils.RunCommand(Cmd,FTotal);


    if not (FSizeType = stKB) then
      FTotal := FTotal / 1024;

    if not (FSizeType = stKB) then
      FFree := FFree / 1024;


    if FSizeType = stGB then
    begin
      FTotal := FTotal / 1024;
      FFree := FFree / 1024;
    end;

    FTotal := Round(FTotal);
    FFree := Round(FFree);
    FUsed := FTotal - FFree;

  except
    on E:Exception do
    begin
    {$IFDEF DEBUG}
      TLinuxUtils.LogError('TMemoryInfo.GetMemoryData - ' + E.Message);
    {$ENDIF}
    end;
  end;



end;

end.
