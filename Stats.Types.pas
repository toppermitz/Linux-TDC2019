unit Stats.Types;

interface

uses
  System.SysUtils, System.Classes;

type
  TLinuxDistro = (ldCentOS6, ldCentOS7,ldUbuntu);
  TStatsEncoding = (seUTF8,seANSI);



  TStasEncodingHelper = record helper for TStatsEncoding
  public
    function ToEncoding : TEncoding;
  end;

implementation

{ TStasEncodingHelper }

function TStasEncodingHelper.ToEncoding: TEncoding;
begin
  case Self of
    seUTF8: Result := TEncoding.UTF8;
    seANSI: Result := TEncoding.ANSI;
  else
    Result := TEncoding.Default;
  end;
end;

end.
