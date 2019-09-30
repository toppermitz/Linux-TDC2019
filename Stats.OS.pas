unit Stats.OS;

interface

uses
  System.Classes, System.SysUtils, Linux.Utils, System.IOUtils, System.DateUtils, System.JSON.Serializers;

type
  TOSInfo = class
  private
    [JsonName('UpTime')]
    FUptime: string;
    [JsonName('CurrentUsers')]
    FCurrentUsers: Integer;
    [JsonName('CurrentDatetime')]
    FCurrentDateTime: TDateTime;
    [JsonName('Kernel')]
    FKernel: string;
    [JsonName('Hostname')]
    FHostname: string;
    [JsonName('OS')]
    FOS: string;
    procedure GetOSName;
    procedure GetHostname;
    procedure GetKernel;
    procedure GetUptime;
    procedure GetCurrentUsers;
    procedure GetCurrentDateTime;
  public
    property Hostname : string read FHostname;
    property OS : string read FOS;
    property Kernel : string read FKernel;
    property Uptime : string read FUptime;
    property CurrentUsers : Integer read FCurrentUsers;
    property CurrentDateTime : TDateTime read FCurrentDateTime;
    constructor Create;
  end;


implementation

{ TOSInfo }

constructor TOSInfo.Create;
begin
  GetOSName;
  GetHostname;
  GetKernel;
  GetUptime;
//  GetLastBoot;
  GetCurrentUsers;
  GetCurrentDateTime;
end;

procedure TOSInfo.GetCurrentDateTime;
var
  Cmd, CmdResult : string;
begin
  Cmd := 'date ''+%d/%m/%y %T''';
  CmdResult := TLinuxUtils.RunCommandLine(Cmd).Text.Trim;
  
  FCurrentDateTime := StrToDateTimeDef(CmdResult,0); 
end;

procedure TOSInfo.GetCurrentUsers;
var
  Cmd, CmdResult : string;
begin
  Cmd := 'who | wc -l';
  CmdResult := TLinuxUtils.RunCommandLine(Cmd).Text.Trim;

  FCurrentUsers := StrToIntDef(CmdResult,0);
end;

procedure TOSInfo.GetHostname;
var
  Cmd, CmdResult : string;
begin
  Cmd := 'hostname';
  CmdResult := TLinuxUtils.RunCommandLine(Cmd).Text.Trim;
  FHostname := CmdResult;
end;

procedure TOSInfo.GetKernel;
var
  Cmd : String;
  CmdResult : String;
begin
  Cmd := 'uname -r';
  CmdResult := TLinuxUtils.RunCommandLine(Cmd).Text.Trim;

  FKernel := CmdResult;
end;

//procedure TOSInfo.GetLastBoot;
//var
//  Cmd : String;
//  CmdResult : String;
//  Date : TDate;
//  Time : TTime;
//begin
//  Cmd := 'who -b | awk ''{print $3}''';
//  CmdResult := TLinuxUtils.RunCommandLine(Cmd).Text.Trim;
//
//  Date := StrToDateDef(cmdResult,0,TFormatSettings.Create('pt-BR'));
//
//  Cmd := 'who -b | awk ''{print $4}''';
//  CmdResult := TLinuxUtils.RunCommandLine(Cmd).Text.Trim;
//
//  Time := StrToTimeDef(CmdResult,0,TFormatSettings.Create('pt-BR'));
//
//  FLastBoot := Date + Time;
//end;

procedure TOSInfo.GetOSName;
var
  Cmd : String;
  CmdResult : String;
begin
  Cmd := 'uname -s';
  CmdResult := TLinuxUtils.RunCommandLine(Cmd).Text.Trim;

  FOS := CmdResult;

  if TFile.Exists('/usr/bin/lsb_release') then
    Cmd := '/usr/bin/lsb_release -ds'
  else if TFile.Exists('/etc/system-release') then
    Cmd := 'cat /etc/system-release'
  else
    Cmd := 'find /etc/*-release -type f -exec cat {} \; | grep NAME | tail -n 1 | cut -d= -f2 | tr -d ''"''';

  CmdResult := TLinuxUtils.RunCommandLine(Cmd).Text.Trim;

  FOS := FOS + ' ' + CmdResult;

end;

procedure TOSInfo.GetUptime;
var
  Cmd, CmdResult : string;
  TotalSeconds : Int64;
  Days : Integer;
  Hours : Integer;
  Minutes : Integer;

begin
  Cmd := 'cat /proc/uptime | awk ''{print $1}''';
  CmdResult := TLinuxUtils.RunCommandLine(Cmd).Text.Trim;

  TotalSeconds := Trunc(StrToFloatDef(CmdResult.Replace(FormatSettings.ThousandSeparator,FormatSettings.DecimalSeparator),0));
  Minutes := trunc(TotalSeconds/ 60) mod 60;
  Hours := trunc(TotalSeconds / 60 / 60) mod 24;
  Days := trunc(TotalSeconds / 60 / 60 / 24);

  if Days > 0 then
    FUptime := Days.ToString + 'dias';

  if (Days > 0) and (Hours > 0)  then
    FUptime := FUptime + ', ';

  if Hours > 0 then
    FUptime := FUptime + Hours.ToString + ' horas';

  if (Days >0) or (Hours > 0) then
    FUptime := FUptime + ' e ';

  if Minutes > 0 then
    FUptime := FUptime + Minutes.ToString + ' minutos';
end;

end.
