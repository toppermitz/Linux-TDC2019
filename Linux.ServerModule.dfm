object ServerModule: TServerModule
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 150
  Width = 215
  object HTTPServer: TIdHTTPServer
    Bindings = <>
    DefaultPort = 9090
    OnCommandOther = HTTPServerCommandOther
    OnCommandGet = HTTPServerCommandGet
    Left = 48
    Top = 56
  end
end
