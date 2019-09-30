unit Stats.SystemInfo;

interface

uses
  System.Classes, System.SysUtils, System.JSON.Serializers,
  Stats.CPU, Stats.OS, Stats.Disk, Stats.Memory;

type
  TSystemInfo = class
  private
    [JsonName('OS')]
    FOS: TOSInfo;
    [JsonName('Memory')]
    FMemory: TMemoryInfo;
    [JSONName('CPU')]
    FCPU: TCPUInfo;
    [JSONName('Disk')]
    FDisk: TDiskInfo;
  public
    property OS : TOSInfo read FOS;
    property Memory : TMemoryInfo read FMemory;
    property CPU : TCPUInfo read FCPU;
    property Disk: TDiskInfo read FDisk;
    constructor Create;
    destructor Destroy; override;
  end;


implementation

{ TSystemInfo }

constructor TSystemInfo.Create;
begin
  FMemory := TMemoryInfo.Create(stMB);
  FOS := TOSInfo.Create;
  FCPU := TCPUInfo.Create;
  FDisk := TDiskInfo.Create;
end;

destructor TSystemInfo.Destroy;
begin
  FMemory.Free;
  FOS.Free;
  FCPU.Free;
  FDisk.Free;
  inherited;
end;

end.

