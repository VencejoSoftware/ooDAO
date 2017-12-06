{
  Copyright (c) 2016, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit ooDAO.Connection.ADO_test;

interface

uses
  Windows,
  Forms, SysUtils, DB,
  ADODB,
  ooFS.Archive, ooFS.Archive.Delete,
  ooDAO.Connection.Intf,
  ooDAO.Connection.Settings, ooDAO.Connection.SQLite.Settings,
  ooDAO.Connection.SQLite,
  ooDAO.Connection.ADO,
{$IFDEF FPC}
  fpcunit, testregistry
{$ELSE}
  TestFramework
{$ENDIF};

type
  TDAOConnectionADOTest = class(TTestCase)
  const
    SCRIPT =                                  //
      'DROP TABLE TEST_TABLE;' + sLineBreak + //
      'CREATE TABLE TEST_TABLE(TEST_FIELD VARCHAR(8));' + sLineBreak + //
      'INSERT INTO TEST_TABLE (TEST_FIELD) VALUES (''TestVal1'');' + sLineBreak + //
      'INSERT INTO TEST_TABLE (TEST_FIELD) VALUES (''TestVal2'');';
  private
    ADOConnection: TADOConnection;
    function DBPath: String;
    function ConnectionSettings: IConnectionSQLiteSettings;
    procedure CreateDB(const Settings: IConnectionSQLiteSettings);
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure ConnectToTest;
    procedure ServerDateTimeIsNow;
    procedure ServerDateTimeIsNowWithOutSQL;
    procedure SomeTransaction;
    procedure RunScriptToCreateTablesWithError;
    procedure RunScriptToCreateTables;
    procedure BuildDatasetTestTable;
    procedure UpdateWithExecuteSQL;
  end;

implementation

procedure TDAOConnectionADOTest.RunScriptToCreateTablesWithError;
var
  Connection: IDAOConnection;
  RowsAffected: Integer;
  ErrorFound: Boolean;
begin
  Connection := TDAOConnectionADO.New(ADOConnection, EmptyStr);
  Connection.Connect;
  try
    ErrorFound := False;
    try
      CheckTrue(Connection.ExecuteScript(SCRIPT + 'error line', RowsAffected, False));
    except
      on E: EDAOConnection do
        ErrorFound := True;
    end;
    CheckTrue(ErrorFound);
  finally
    Connection.Disconnect;
  end;
end;

procedure TDAOConnectionADOTest.RunScriptToCreateTables;
var
  Connection: IDAOConnection;
  RowsAffected: Integer;
begin
  Connection := TDAOConnectionADO.New(ADOConnection, EmptyStr);
  Connection.Connect;
  try
    CheckTrue(Connection.ExecuteScript(SCRIPT, RowsAffected, True));
    CheckEquals(2, RowsAffected);
  finally
    Connection.Disconnect;
  end;
end;

procedure TDAOConnectionADOTest.BuildDatasetTestTable;
var
  Connection: IDAOConnection;
  RowsAffected: Integer;
  DataSet: TDataSet;
  i: Integer;
begin
  Connection := TDAOConnectionADO.New(ADOConnection, EmptyStr);
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

procedure TDAOConnectionADOTest.ServerDateTimeIsNow;
const
  SQL_SERVER_DATETIME = 'SELECT strftime(''%d/%m/%Y %H:%M:%S'', CURRENT_TIMESTAMP) AS SERVER_DATE';
begin
  CheckEquals(Date, Trunc(TDAOConnectionADO.New(ADOConnection, SQL_SERVER_DATETIME).ServerDateTime));
end;

procedure TDAOConnectionADOTest.ServerDateTimeIsNowWithOutSQL;
var
  ErrorFound: Boolean;
begin
  ErrorFound := False;
  try
    CheckEquals(Date, Trunc(TDAOConnectionADO.New(ADOConnection, EmptyStr).ServerDateTime));
  except
    on E: EDAOConnection do
      ErrorFound := True;
  end;
  CheckTrue(ErrorFound);
end;

procedure TDAOConnectionADOTest.SomeTransaction;
var
  Connection: IDAOConnection;
begin
  Connection := TDAOConnectionADO.New(ADOConnection, EmptyStr);
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

procedure TDAOConnectionADOTest.UpdateWithExecuteSQL;
var
  Connection: IDAOConnection;
  RowsAffected: Integer;
begin
  Connection := TDAOConnectionADO.New(ADOConnection, EmptyStr);
  Connection.Connect;
  try
    Connection.ExecuteScript(SCRIPT, RowsAffected, True);
    CheckTrue(Connection.ExecuteSQL('UPDATE TEST_TABLE SET TEST_FIELD = ''a''', RowsAffected));
    CheckEquals(2, RowsAffected);
  finally
    Connection.Disconnect;
  end;
end;

procedure TDAOConnectionADOTest.ConnectToTest;
var
  Connection: IDAOConnection;
begin
  Connection := TDAOConnectionADO.New(ADOConnection, EmptyStr);
  Connection.Connect;
  try
    CheckTrue(Connection.IsConnected);
  finally
    Connection.Disconnect;
  end;
end;

function TDAOConnectionADOTest.DBPath: String;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + 'db_ado.db3';
end;

function TDAOConnectionADOTest.ConnectionSettings: IConnectionSQLiteSettings;
begin
  Result := TConnectionSQLiteSettings.New(TConnectionSettings.New(EmptyStr, EmptyStr, DBPath, 'sqlite3.dll'));
end;

procedure TDAOConnectionADOTest.CreateDB(const Settings: IConnectionSQLiteSettings);
begin
  TDAOConnectionSQLite.New(Settings).CreateDatabase;
end;

procedure TDAOConnectionADOTest.SetUp;
begin
  inherited;
  CreateDB(ConnectionSettings);
  ADOConnection := TADOConnection.Create(Application);
  ADOConnection.ConnectionString :=                   //
    'DRIVER=SQLite3 ODBC Driver;Database=' + DBPath + //
    ';LongNames=0;Timeout=1000;NoTXN=0;SyncPragma=NORMAL;StepAPI=0;';
  ADOConnection.Open('', '');
end;

procedure TDAOConnectionADOTest.TearDown;
begin
  inherited;
  ADOConnection.Free;
  TFSArchiveDelete.New(TFSArchive.New(nil, ConnectionSettings.DataBasePath)).Execute;
end;

initialization

RegisterTest(TDAOConnectionADOTest {$IFNDEF FPC}.Suite {$ENDIF});

end.
