{
  Copyright (c) 2016, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit ooDAO.Connection.Settings;

interface

type
  IConnectionSettings = interface
    ['{4C0F6BDE-CB21-4611-B2B2-4B7CE5B30820}']
    function User: String;
    function Password: String;
    function DataBasePath: String;
    function LibraryPath: String;
  end;

  TConnectionSettings = class sealed(TInterfacedObject, IConnectionSettings)
  strict private
    _User, _Password, _DataBasePath, _LibraryPath: String;
  public
    function User: String;
    function Password: String;
    function DataBasePath: String;
    function LibraryPath: String;
    constructor Create(const User, Password, DataBasePath, LibraryPath: String);
    class function New(const User, Password, DataBasePath, LibraryPath: String): IConnectionSettings;
  end;

implementation

function TConnectionSettings.DataBasePath: String;
begin
  Result := _DataBasePath;
end;

function TConnectionSettings.LibraryPath: String;
begin
  Result := _LibraryPath;
end;

function TConnectionSettings.Password: String;
begin
  Result := _Password;
end;

function TConnectionSettings.User: String;
begin
  Result := _User;
end;

constructor TConnectionSettings.Create(const User, Password, DataBasePath, LibraryPath: String);
begin
  _User := User;
  _Password := Password;
  _DataBasePath := DataBasePath;
  _LibraryPath := LibraryPath;
end;

class function TConnectionSettings.New(const User, Password, DataBasePath, LibraryPath: String): IConnectionSettings;
begin
  Result := TConnectionSettings.Create(User, Password, DataBasePath, LibraryPath);
end;

end.
