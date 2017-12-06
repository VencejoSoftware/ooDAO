{
  Copyright (c) 2016, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit ooDAO.Connection.Firebird.Settings;

interface

uses
  ooDAO.Connection.Settings;

type
  IConnectionFirebirdSettings = interface(IConnectionSettings)
    ['{C42828F4-1EBB-49AB-84D9-9DBB2C5570B7}']
    function Port: Integer;
    function Collation: String;
    function Dialect: Byte;
    function Version: String;
  end;

  TConnectionFirebirdSettings = class sealed(TInterfacedObject, IConnectionFirebirdSettings)
  strict private
    _ConnectionSettings: IConnectionSettings;
    _Port: Integer;
    _Collation, _Version: String;
    _Dialect: Byte;
  public
    function User: String;
    function Password: String;
    function DataBasePath: String;
    function LibraryPath: String;
    function Port: Integer;
    function Collation: String;
    function Dialect: Byte;
    function Version: String;

    constructor Create(const ConnectionSettings: IConnectionSettings; const Port: Integer;
      const Collation, Version: String; const Dialect: Byte);
    class function New(const ConnectionSettings: IConnectionSettings; const Port: Integer = 3050;
      const Collation: string = 'ISO8859_1'; const Version: String = 'firebird-2.5';
      const Dialect: Byte = 3): IConnectionFirebirdSettings;
  end;

implementation

function TConnectionFirebirdSettings.User: String;
begin
  Result := _ConnectionSettings.User;
end;

function TConnectionFirebirdSettings.Password: String;
begin
  Result := _ConnectionSettings.Password;
end;

function TConnectionFirebirdSettings.DataBasePath: String;
begin
  Result := _ConnectionSettings.DataBasePath;
end;

function TConnectionFirebirdSettings.LibraryPath: String;
begin
  Result := _ConnectionSettings.LibraryPath;
end;

function TConnectionFirebirdSettings.Collation: String;
begin
  Result := _Collation;
end;

function TConnectionFirebirdSettings.Dialect: Byte;
begin
  Result := _Dialect;
end;

function TConnectionFirebirdSettings.Port: Integer;
begin
  Result := _Port;
end;

function TConnectionFirebirdSettings.Version: String;
begin
  Result := _Version;
end;

constructor TConnectionFirebirdSettings.Create(const ConnectionSettings: IConnectionSettings; const Port: Integer;
  const Collation, Version: String; const Dialect: Byte);
begin
  _ConnectionSettings := ConnectionSettings;
  _Port := Port;
  _Collation := Collation;
  _Version := Version;
  _Dialect := Dialect;
end;

class function TConnectionFirebirdSettings.New(const ConnectionSettings: IConnectionSettings; const Port: Integer;
  const Collation, Version: String; const Dialect: Byte): IConnectionFirebirdSettings;
begin
  Result := TConnectionFirebirdSettings.Create(ConnectionSettings, Port, Collation, Version, Dialect);
end;

end.
