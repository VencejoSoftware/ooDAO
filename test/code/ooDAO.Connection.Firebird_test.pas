{
  Copyright (c) 2016, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit ooDAO.Connection.Firebird_test;

interface

uses
  Windows,
  Forms, SysUtils, DB,
  ooFS.Archive, ooFS.Archive.Delete,
  ooDAO.Connection.Settings, ooDAO.Connection.Firebird.Settings,
  ooDAO.Connection.Intf,
  ooDAO.Connection.Firebird,
{$IFDEF FPC}
  fpcunit, testregistry
{$ELSE}
  TestFramework
{$ENDIF};

type
  TDAOConnectionFirebirdTest = class(TTestCase)
  const
    SCRIPT =                                  //
      'DROP TABLE TEST_TABLE;' + sLineBreak + //
      'CREATE TABLE TEST_TABLE(TEST_FIELD VARCHAR(8));' + sLineBreak + //
      'COMMIT WORK;' + sLineBreak + //
      'INSERT INTO TEST_TABLE (TEST_FIELD) VALUES (''TestVal1'');' + sLineBreak + //
      'INSERT INTO TEST_TABLE (TEST_FIELD) VALUES (''TestVal2'');';
  private
    function DBPath: String;
    function ConnectionSettings: IConnectionFirebirdSettings;
    procedure CreateDB(const Settings: IConnectionFirebirdSettings);
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

procedure TDAOConnectionFirebirdTest.RunScriptToCreateTablesWithError;
var
  Connection: IDAOConnection;
  RowsAffected: Integer;
  ErrorFound: Boolean;
begin
  Connection := TDAOConnectionFirebird.New(ConnectionSettings);
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

procedure TDAOConnectionFirebirdTest.RunScriptToCreateTables;
var
  Connection: IDAOConnection;
  RowsAffected: Integer;
begin
  Connection := TDAOConnectionFirebird.New(ConnectionSettings);
  Connection.Connect;
  try
    CheckTrue(Connection.ExecuteScript(SCRIPT, RowsAffected, True));
    CheckEquals(2, RowsAffected);
  finally
    Connection.Disconnect;
  end;
end;

procedure TDAOConnectionFirebirdTest.BuildDatasetTestTable;
var
  Connection: IDAOConnection;
  RowsAffected: Integer;
  DataSet: TDataSet;
  i: Integer;
begin
  Connection := TDAOConnectionFirebird.New(ConnectionSettings);
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

procedure TDAOConnectionFirebirdTest.ServerDateTimeIsNow;
var
  Connection: IDAOConnectionFirebird;
begin
  Connection := TDAOConnectionFirebird.New(ConnectionSettings);
  Connection.Connect;
  try
    CheckEquals(Date, Trunc(Connection.ServerDateTime));
  finally
    Connection.Disconnect;
  end;
end;

procedure TDAOConnectionFirebirdTest.SomeTransaction;
var
  Connection: IDAOConnection;
begin
  Connection := TDAOConnectionFirebird.New(ConnectionSettings);
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

procedure TDAOConnectionFirebirdTest.UpdateWithExecuteSQL;
var
  Connection: IDAOConnection;
  RowsAffected: Integer;
begin
  Connection := TDAOConnectionFirebird.New(ConnectionSettings);
  Connection.Connect;
  try
    Connection.ExecuteScript(SCRIPT, RowsAffected, True);
    CheckTrue(Connection.ExecuteSQL('UPDATE TEST_TABLE SET TEST_FIELD = ''a''', RowsAffected));
    CheckEquals(2, RowsAffected);
  finally
    Connection.Disconnect;
  end;
end;

procedure TDAOConnectionFirebirdTest.ConnectToTest;
var
  Connection: IDAOConnection;
begin
  Connection := TDAOConnectionFirebird.New(ConnectionSettings);
  Connection.Connect;
  try
    CheckTrue(Connection.IsConnected);
  finally
    Connection.Disconnect;
  end;
  CheckFalse(Connection.IsConnected);
end;

procedure TDAOConnectionFirebirdTest.CreateTestDatabase;
begin
  CheckTrue(FileExists(DBPath));
end;

function TDAOConnectionFirebirdTest.DBPath: String;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + 'db_fb.fdb';
end;

function TDAOConnectionFirebirdTest.ConnectionSettings: IConnectionFirebirdSettings;
const
  USER_NAME = 'sysdba';
  USER_PASS = 'masterkey';
begin
  Result := TConnectionFirebirdSettings.New(TConnectionSettings.New(USER_NAME, USER_PASS, DBPath, 'fbclient.dll'));
end;

procedure TDAOConnectionFirebirdTest.CreateDB(const Settings: IConnectionFirebirdSettings);
begin
  TDAOConnectionFirebird.New(Settings).CreateDatabase;
end;

procedure TDAOConnectionFirebirdTest.SetUp;
begin
  inherited;
  CreateDB(ConnectionSettings);
end;

procedure TDAOConnectionFirebirdTest.TearDown;
begin
  inherited;
  TFSArchiveDelete.New(TFSArchive.New(nil, ConnectionSettings.DataBasePath)).Execute;
end;

initialization

RegisterTest(TDAOConnectionFirebirdTest {$IFNDEF FPC}.Suite {$ENDIF});

end.
