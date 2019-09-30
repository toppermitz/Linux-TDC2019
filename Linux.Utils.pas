unit Linux.Utils;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Character,
  Posix.Base,
  Posix.Fcntl,
  System.IOUtils;

type
  TStreamHandle = pointer;

  TLogType = (ltInfo, ltWarn, ltError, ltAlert, ltCrit, ltNotice, ltDebug);

  TLinuxUtils = class

  const
    cLogPath = '/log';
  class var FAppDirectory : String;
  private
    class procedure Log(const ATipoLog: tLogType;const AMessage: String);
  public
    class function RunCommandLine(const ACommand : string) : TStringList;overload;
    class function RunCommandLine(const Acommand : string; Return : TProc<String>) : boolean; overload;
    class procedure RunCommand(const ACommand : string;var Result : String);overload;
    class procedure RunCommand(const ACommand : string;var Result : Integer);overload;
    class procedure RunCommand(const ACommand : string;var Result : Double);overload;
    class function findParameter(const AParameter : string) : boolean;
    class function OnlyNumber(AValue : string) : Integer;
    class function FormatMacro(const Text, MacroName,MacroValue: String): String; static;
    class procedure LogInfo(const AMessage: String);
    class procedure LogWarn(const AMessage: String);
    class procedure LogError(const AMessage: String);
    class procedure LogDebug(const AMessage: String);
    class function GetApplicationPath : String;
  end;



  function popen(const command: MarshaledAString; const _type: MarshaledAString): TStreamHandle; cdecl; external libc name _PU + 'popen';
  function pclose(filehandle: TStreamHandle): int32; cdecl; external libc name _PU + 'pclose';
  function fgets(buffer: pointer; size: int32; Stream: TStreamHAndle): pointer; cdecl; external libc name _PU + 'fgets';


implementation

class function TLinuxUtils.RunCommandLine(const ACommand : string) : TStringList;
var
  Handle: TStreamHandle;
  Data: array[0..511] of uint8;
  M : TMarshaller;

begin
  Result := TStringList.Create;
  try
    Handle := popen(M.AsAnsi(PWideChar(ACommand)).ToPointer,'r');
    try
      while fgets(@data[0],Sizeof(Data),Handle)<>nil do begin
        Result.Add(Copy(UTF8ToString(@Data[0]),1,UTF8ToString(@Data[0]).Length -1));//,sizeof(Data)));
      end;
    finally
      pclose(Handle);
    end;
  except
    on E: Exception do
      Result.Add(E.ClassName + ': ' + E.Message);
  end;
end;

class function TLinuxUtils.OnlyNumber(AValue: string): Integer;
var
  I : Integer;
  str : String;
begin
  for I := 0 to Pred(AValue.Length) do
    if AValue[I].IsNumber then
      str := str + AValue[i];

  Result := StrToIntDef(str,0);
end;


class procedure TLinuxUtils.RunCommand(const ACommand: string; var Result: String);
var
  CmdResult : TStringList;
begin
  CmdResult := TLinuxUtils.RunCommandLine(ACommand);
  try
    Result := CmdResult.Text.Trim;
  finally
    CmdResult.Free;
  end;
end;

class procedure TLinuxUtils.RunCommand(const ACommand: string; var Result: Integer);
var
  CommandResult : string;
begin
  RunCommand(ACommand,CommandResult);
  Result := OnlyNumber(CommandResult);
end;

class procedure TLinuxUtils.RunCommand(const ACommand: string; var Result: Double);
var
  CommandResult : string;
begin
  RunCommand(ACommand,CommandResult);
  Result := StrToFloatDef(CommandResult,0);
end;

class function TLinuxUtils.RunCommandLine(const Acommand : string; Return : TProc<string>) : boolean;
var
  Handle: TStreamHandle;
  Data: array[0..511] of uint8;
  M : TMarshaller;

begin
  Result := false;
  try
    Handle := popen(M.AsAnsi(PWideChar(ACommand)).ToPointer,'r');
    try
      while fgets(@data[0],Sizeof(Data),Handle)<>nil do begin
        Return(Copy(UTF8ToString(@Data[0]),1,UTF8ToString(@Data[0]).Length -1));
      end;
    finally
      pclose(Handle);
    end;
  except
    on E: Exception do
      Return(E.ClassName + ': ' + E.Message);
  end;
end;

class function TLinuxUtils.findParameter(const AParameter : string) : boolean;
var
  I : Integer;
begin
  Result := false;
  for I := 0 to Pred(ParamCount) do
  begin
    Result := AParameter.ToUpper = ParamStr(i).ToUpper;
    if Result then
      Break;
  end;
end;

class function TLinuxUtils.FormatMacro(const Text, MacroName, MacroValue: String): String;
begin
  Result := StringReplace(Text,MacroName,MacroValue,[rfReplaceALL,rfIgnoreCase]);
end;

class function TLinuxUtils.GetApplicationPath: String;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
end;

class procedure TLinuxUtils.Log(const ATipoLog: tLogType;const AMessage: String);
var
  Log : TStringList;
  FileName : string;
begin
  if FAppDirectory = '' then
    FAppDirectory := TLinuxUtils.RunCommandLine('pwd').Text.Trim;

  case ATipoLog of
    ltInfo,
    ltWarn: FileName := '/messages';

    ltCrit,
    ltAlert: FileName := '/alerts';
    
    ltNotice, 
    ltDebug : FileName := '/debug';
    
    ltError: FileName := '/errors' ;
  end;

  FileName := FAppDirectory + cLogPath + FileName;

  if not TDirectory.Exists(FAppDirectory + cLogPath) then
    TDirectory.CreateDirectory(FAppDirectory + cLogPath);

  Log := TStringList.Create;
  try
    if TFile.Exists(FileName) then
     Log.Text := TFile.ReadAllText(FileName, TEncoding.UTF8);

    Log.Add(FormatDateTime('dd/mm/yy hh:mm:ss',Now) + ' - ' + AMessage);
    Log.SaveToFile(FileName);
  finally
    Log.Free;
  end;
end;

class procedure TLinuxUtils.LogDebug(const AMessage: String);
begin
  TLinuxUtils.Log(ltDebug, AMessage);
end;

class procedure TLinuxUtils.LogError(const AMessage: String);
begin
  TLinuxUtils.Log(ltError, AMessage);
end;

class procedure TLinuxUtils.LogInfo(const AMessage: String);
begin
  TLinuxUtils.Log(ltInfo, AMessage);
end;

class procedure TLinuxUtils.LogWarn(const AMessage: String);
begin
  TLinuxUtils.Log(ltWarn, AMessage);
end;

end.
