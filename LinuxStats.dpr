program LinuxStats;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Linux.Utils in 'Linux.Utils.pas',
  Posix.Daemon in 'Posix.Daemon.pas',
  Posix.Syslog in 'Posix.Syslog.pas',
  Stats.Config in 'Stats.Config.pas',
  Stats.Types in 'Stats.Types.pas',
  Stats.SystemInfo in 'Stats.SystemInfo.pas',
  Linux.ServerModule in 'Linux.ServerModule.pas' {ServerModule: TDataModule},
  Stats.Disk in 'Stats.Disk.pas',
  Stats.Memory in 'Stats.Memory.pas',
  Stats.OS in 'Stats.OS.pas',
  Stats.CPU in 'Stats.CPU.pas';

var
  Server : TServerModule;
begin
  try
    FormatSettings.DecimalSeparator := ',';
    FormatSettings.ThousandSeparator := '.';
    FormatSettings.DateSeparator := '/';
    FormatSettings.ShortDateFormat := 'd/M/yyyy';
    FormatSettings.ShortTimeFormat := 'hh:nn:ss';
    Server := TServerModule.Create(nil);
    try
      if FindCmdLineSwitch('DAEMON',['-'],true) then
      begin
        TPosixDaemon.Setup(procedure(ASignal: TPosixSignal)
        begin
          case ASignal of
            TPosixSignal.Termination:
            begin
              Server.Stop;
            end;
            TPosixSignal.Reload:
            begin
              //-1 para forçar a pegar a porta do json de configuração
              Server.ConfigurePort(-1);
            end;
          end;
        end);

        Server.ConfigurePort(-1);
        Server.Start;
      end else begin
        Server.ConfigurePort;
        while true do
        begin
          sleep(1000);
        end;

      end;

      TPosixDaemon.Run(1000);
    finally
      Server.Free;
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
