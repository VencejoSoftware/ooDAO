{
  Copyright (c) 2016, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit ooDAO.Connection.SQLite_test;

interface

uses
  Windows,
  Forms, SysUtils, DB,
  ooFS.Archive, ooFS.Archive.Delete,
  ooDAO.Connection.Settings, ooDAO.Connection.SQLite.Settings,
  ooDAO.Connection.Intf,
  ooDAO.Connection.SQLite,
{$IFDEF FPC}
  fpcunit, testregistry
{$ELSE}
  TestFramework
{$ENDIF};

type
  TDAOConnectionSQLiteTest = class(TTestCase)
  const
    SCRIPT =                                  //
      'BEGIN TRANSACTION;' + sLineBreak +     //
      'DROP TABLE TEST_TABLE;' + sLineBreak + //
      'CREATE TABLE TEST_TABLE(TEST_FIELD VARCHAR(8));' + sLineBreak + //
      'COMMIT;' + sLineBreak + //
      'INSERT INTO TEST_TABLE (TEST_FIELD) VALUES (''TestVal1'');' + sLineBreak + //
      'INSERT INTO TEST_TABLE (TEST_FIELD) VALUES (''TestVal2'');';
  private
    function DBPath: String;
    function ConnectionSettings: IConnectionSQLiteSettings;
    procedure CreateDB(const Settings: IConnectionSQLiteSettings);
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure CreateTestDatabase;
    procedure ConnectToTest;
    procedure ServerDateTimeIsNow;
    procedure SomeTransaction;
    procedure RunScriptToCreateTablesWithError;
    procedure RunScriptToCreateTables;
    procedure BuildDatasetTestTable;
    procedure UpdateWithExecuteSQL;
  end;

implementation

procedure TDAOConnectionSQLiteTest.RunScriptToCreateTablesWithError;
var
  Connection: IDAOConnection;
  RowsAffected: Integer;
  ErrorFound: Boolean;
begin
  Connection := TDAOConnectionSQLite.New(ConnectionSettings);
  Connection.Connect;
  ErrorFound := False;
  try
    try
      CheckTrue(Connection.ExecuteScript(SCRIPT, RowsAffected, False));
    except
      on E: EDAOConnection do
        ErrorFound := True;
    end;
    CheckTrue(ErrorFound);
  finally
    Connection.Disconnect;
  end;
end;

procedure TDAOConnectionSQLiteTest.RunScriptToCreateTables;
var
  Connection: IDAOConnection;
  RowsAffected: Integer;
begin
  Connection := TDAOConnectionSQLite.New(ConnectionSettings);
  Connection.Connect;
  try
    CheckTrue(Connection.ExecuteScript(SCRIPT, RowsAffected, True));
    CheckEquals(2, RowsAffected);
  finally
    Connection.Disconnect;
  end;
end;

procedure TDAOConnectionSQLiteTest.BuildDatasetTestTable;
var
  Connection: IDAOConnection;
  RowsAffected: Integer;
  DataSet: TDataSet;
  i: Integer;
begin
  Connection := TDAOConnectionSQLite.New(ConnectionSettings);
  Connection.Connect;
  try
    Connection.ExecuteScript(SCRIPT, RowsAffected, True);
    Connection.BuildDataset(DataSet, 'SELECT * FROM TEST_TABLE', []);
    try
      i := 1;
      while not DataSet.Eof do
      begin
        CheckEquals('TestVal' + IntToStr(i), DataSet.FieldByName('TEST_FIELD').AsString);
        DataSet.Next;
        inc(i)
      end;
    finally
      DataSet.Free;
    end;
  finally
    Connection.Disconnect;
  end;
end;

procedure TDAOConnectionSQLiteTest.ServerDateTimeIsNow;
var
  Connection: IDAOConnectionSQLite;
begin
  Connection := TDAOConnectionSQLite.New(ConnectionSettings);
  Connection.Connect;
  try
    CheckEquals(Date, Trunc(Connection.ServerDateTime));
  finally
    Connection.Disconnect;
  end;
end;

procedure TDAOConnectionSQLiteTest.SomeTransaction;
var
  Connection: IDAOConnection;
begin
  Connection := TDAOConnectionSQLite.New(ConnectionSettings);
  Connection.Connect;
  try
    CheckFalse(Connection.InTransaction);
    Connection.BeginTransaction;
    CheckTrue(Connection.InTransaction);
    Connection.CommitTransaction;
    CheckFalse(Connection.InTransaction);
    Connection.BeginTransaction;
    CheckTrue(Connection.InTransaction);
    Connection.RollbackTransaction;
    CheckFalse(Connection.InTransaction);
  finally
    Connection.Disconnect;
  end;
end;

procedure TDAOConnectionSQLiteTest.UpdateWithExecuteSQL;
var
  Connection: IDAOConnection;
  RowsAffected: Integer;
begin
  Connection := TDAOConnectionSQLite.New(ConnectionSettings);
  Connection.Connect;
  try
    Connection.ExecuteScript(SCRIPT, RowsAffected, True);
    CheckTrue(Connection.ExecuteSQL('UPDATE TEST_TABLE SET TEST_FIELD = ''a''', RowsAffected));
    CheckEquals(2, RowsAffected);
  finally
    Connection.Disconnect;
  end;
end;

procedure TDAOConnectionSQLiteTest.ConnectToTest;
var
  Connection: IDAOConnection;
begin
  Connection := TDAOConnectionSQLite.New(ConnectionSettings);
  Connection.Connect;
  try
    CheckTrue(Connection.IsConnected);
  finally
    Connection.Disconnect;
  end;
  CheckFalse(Connection.IsConnected);
end;

procedure TDAOConnectionSQLiteTest.CreateTestDatabase;
begin
  CheckTrue(FileExists(DBPath));
end;

function TDAOConnectionSQLiteTest.DBPath: String;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + 'db_sqlite.db3';
end;

function TDAOConnectionSQLiteTest.ConnectionSettings: IConnectionSQLiteSettings;
begin
  Result := TConnectionSQLiteSettings.New(TConnectionSettings.New(EmptyStr, EmptyStr, DBPath, 'sqlite3.dll'));
end;

procedure TDAOConnectionSQLiteTest.CreateDB(const Settings: IConnectionSQLiteSettings);
begin
  TDAOConnectionSQLite.New(Settings).CreateDatabase;
end;

procedure TDAOConnectionSQLiteTest.SetUp;
begin
  inherited;
  CreateDB(ConnectionSettings);
end;

procedure TDAOConnectionSQLiteTest.TearDown;
begin
  inherited;
  TFSArchiveDelete.New(TFSArchive.New(nil, ConnectionSettings.DataBasePath)).Execute;
end;

initialization

RegisterTest(TDAOConnectionSQLiteTest {$IFNDEF FPC}.Suite {$ENDIF});

end.
