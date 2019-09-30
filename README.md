# LinuxStats

Este é o projeto de exemplo sobre serviços em Linux utilizando Delphi


## Como iniciar?
Em background (Utilizado para os serviços)
```bash
./LinuxStats -daemon
```
Normal
```bash
./LinuxStats
```

## Porta HTTP
Porta padrão da configuração é 9090
```
http://ip_linux:9090/get/server
```
## Versões do Delphi testadas
* 10.3.2
* 10.3.1
* 10.2.1

## Versão de Linux testadas
* CentOS 6
* CentOS 7
* Ubuntu 16.04 LTS
* Ubuntu 18.04 LTS

## Units externas utilizadas nessa projeto
* [Posix.Daemons.pas](https://github.com/delphi-blocks/WiRL/blob/28c1cde391bf62061030ebdf7457ea425f6cb9fb/Source/Extensions/WiRL.Console.Posix.Daemon.pas) do [Paolo Rossi](https://github.com/paolo-rossi)
