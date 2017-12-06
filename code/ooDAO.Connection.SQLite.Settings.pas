{
  Copyright (c) 2016, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit ooDAO.Connection.SQLite.Settings;

interface

uses
  ooDAO.Connection.Settings;

type
  IConnectionSQLiteSettings = interface(IConnectionSettings)
    ['{DAD02332-1B8D-42C4-8AE5-2A305BCB7BEC}']
    function CharSet: String;
  end;

  TConnectionSQLiteSettings = class sealed(TInterfacedObject, IConnectionSQLiteSettings)
  strict private
    _ConnectionSettings: IConnectionSettings;
    _CharSet: String;
  public
    function User: String;
    function Password: String;
    function DataBasePath: String;
    function LibraryPath: String;
    function CharSet: String;

    constructor Create(const ConnectionSettings: IConnectionSettings; const CharSet: String);
    class function New(const ConnectionSettings: IConnectionSettings; const CharSet: String = 'UTF16')
      : IConnectionSQLiteSettings;
  end;

implementation

function TConnectionSQLiteSettings.User: String;
begin
  Result := _ConnectionSettings.User;
end;

function TConnectionSQLiteSettings.Password: String;
begin
  Result := _ConnectionSettings.Password;
end;

function TConnectionSQLiteSettings.DataBasePath: String;
begin
  Result := _ConnectionSettings.DataBasePath;
end;

function TConnectionSQLiteSettings.LibraryPath: String;
begin
  Result := _ConnectionSettings.LibraryPath;
end;

function TConnectionSQLiteSettings.CharSet: String;
begin
  Result := _CharSet;
end;

constructor TConnectionSQLiteSettings.Create(const ConnectionSettings: IConnectionSettings; const CharSet: String);
begin
  _ConnectionSettings := ConnectionSettings;
  _CharSet := CharSet;
end;

class function TConnectionSQLiteSettings.New(const ConnectionSettings: IConnectionSettings;
  const CharSet: String): IConnectionSQLiteSettings;
begin
  Result := TConnectionSQLiteSettings.Create(ConnectionSettings, CharSet);
end;

end.
