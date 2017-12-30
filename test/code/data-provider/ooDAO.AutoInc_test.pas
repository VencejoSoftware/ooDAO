{
  Copyright (c) 2016, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit ooDAO.AutoInc_test;

interface

uses
  SysUtils, Forms,
  ooFS.Archive, ooFS.Archive.Delete,
  ooDAO.Connection.Settings, ooDAO.Connection.SQLite.Settings,
  ooDAO.Connection.Intf,
  ooDAO.Connection.SQLite,
  ooDAO.AutoInc, ooDAO.AutoIncScript_Mock,
{$IFDEF FPC}
  fpcunit, testregistry
{$ELSE}
  TestFramework
{$ENDIF};

type
  TDAOAutoIncTest = class(TTestCase)
  const
    SCRIPT = //
      'BEGIN TRANSACTION;' + sLineBreak + //
      'DROP TABLE {{ENTITY.SEQUENCES}};' + sLineBreak + //
      'CREATE TABLE {{ENTITY.SEQUENCES}}(AUTOINC INTEGER);' + sLineBreak + //
      'COMMIT;' + sLineBreak + //
      'INSERT INTO {{ENTITY.SEQUENCES}} (AUTOINC) VALUES (0);';
  private
    _Connection: IDAOConnection;
    function DBPath: String;
    function ConnectionSettings: IConnectionSQLiteSettings;
    procedure CreateDB(const Settings: IConnectionSQLiteSettings);
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure CurrentValueIs0;
    procedure NewValueReturn1;
    procedure TwoCallsOfNewValueReturn2;
  end;

implementation

procedure TDAOAutoIncTest.CurrentValueIs0;
var
  DAOAutoInc: IDAOAutoInc;
begin
  DAOAutoInc := TDAOAutoInc.Create(_Connection, TDAOAutoIncScriptMock.New);
  CheckEquals(0, DAOAutoInc.CurrentValue(nil));
end;

procedure TDAOAutoIncTest.NewValueReturn1;
var
  DAOAutoInc: IDAOAutoInc;
begin
  DAOAutoInc := TDAOAutoInc.Create(_Connection, TDAOAutoIncScriptMock.New);
  CheckEquals(1, DAOAutoInc.NewValue(nil));
end;

procedure TDAOAutoIncTest.TwoCallsOfNewValueReturn2;
var
  DAOAutoInc: IDAOAutoInc;
begin
  DAOAutoInc := TDAOAutoInc.Create(_Connection, TDAOAutoIncScriptMock.New);
  DAOAutoInc.NewValue(nil);
  DAOAutoInc.NewValue(nil);
  CheckEquals(2, DAOAutoInc.CurrentValue(nil));
end;

function TDAOAutoIncTest.DBPath: String;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + 'db_sqlite.db3';
end;

function TDAOAutoIncTest.ConnectionSettings: IConnectionSQLiteSettings;
begin
  Result := TConnectionSQLiteSettings.New(TConnectionSettings.New(EmptyStr, EmptyStr, DBPath, 'sqlite3.dll'));
end;

procedure TDAOAutoIncTest.CreateDB(const Settings: IConnectionSQLiteSettings);
begin
  TDAOConnectionSQLite.New(Settings).CreateDatabase;
end;

procedure TDAOAutoIncTest.SetUp;
var
  RowsAffected: Integer;
begin
  inherited;
  CreateDB(ConnectionSettings);
  _Connection := TDAOConnectionSQLite.New(ConnectionSettings);
  _Connection.Connect;
  _Connection.ExecuteScript(SCRIPT, RowsAffected, True);
end;

procedure TDAOAutoIncTest.TearDown;
begin
  inherited;
  _Connection.Disconnect;
  TFSArchiveDelete.New(TFSArchive.New(nil, ConnectionSettings.DataBasePath)).Execute;
end;

initialization

RegisterTest(TDAOAutoIncTest {$IFNDEF FPC}.Suite {$ENDIF});

end.
