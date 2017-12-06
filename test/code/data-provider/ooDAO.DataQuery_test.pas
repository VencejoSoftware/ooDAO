{
  Copyright (c) 2016, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit ooDAO.DataQuery_test;

interface

uses
  Windows,
  SysUtils, Forms, DB,
  ooFS.Archive, ooFS.Archive.Delete,
  ooFilter,
  ooSQL.Filter.JoinNone, ooSQL.Filter.JoinAnd, ooSQL.Filter.JoinWhere,
  ooSQL.Filter.JoinAndNot,
  ooSQL.Filter.Greater,
  ooSQL.Filter.SimpleFormatter,
  ooSQL.Parameter.Text, ooSQL.Parameter.Int,
  ooDAO.DataQuery,
  ooDAO.Connection.Settings, ooDAO.Connection.SQLite.Settings,
  ooDAO.Connection.Intf, ooDAO.Connection.SQLite,
{$IFDEF FPC}
  fpcunit, testregistry
{$ELSE}
  TestFramework
{$ENDIF};

type
  TDAODataQueryTest = class(TTestCase)
  const
    DB_PASS = '';
    SCRIPT =                                  //
      'BEGIN TRANSACTION;' + sLineBreak +     //
      'DROP TABLE TEST_TABLE;' + sLineBreak + //
      'CREATE TABLE TEST_TABLE(TEST_FIELD VARCHAR(8), ID INTEGER, FIELD3 VARCHAR(10));' + sLineBreak + //
      'COMMIT;' + sLineBreak + //
      'INSERT INTO TEST_TABLE (TEST_FIELD, ID, FIELD3) VALUES (''TestVal1'', 10, ''1'');' + sLineBreak + //
      'INSERT INTO TEST_TABLE (TEST_FIELD, ID, FIELD3) VALUES (''TestVal2'', 11, ''11'');';
    TEST_SQL = 'SELECT TEST_FIELD FROM TEST_TABLE WHERE TEST_FIELD = :TEST_FIELD AND ID = :ID;';
  private
    function DBPath: String;
    function ConnectionSettings: IConnectionSQLiteSettings;
    procedure CreateDB(const Settings: IConnectionSQLiteSettings);
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure SQLIsSelect;
    procedure SQLIsSelectFiltered;
    procedure SQLIsError;
    procedure ExecuteWithFilterAndDynamicParam;
    procedure ParameterTwoIsID;
    procedure ParameterCountIsTwo;
    procedure CleanAllParameters;
  end;

implementation

procedure TDAODataQueryTest.ExecuteWithFilterAndDynamicParam;
var
  DAODataQuery: IDAODataQuery;
  Dataset: TDataSet;
  Filter: IFilter;
begin
  DAODataQuery := TDAODataQuery.New(TDAOConnectionSQLite.New(ConnectionSettings), 'SELECT * FROM TEST_TABLE');
  try
    Filter := TFilter.New(TSQLJoinWhere.New);
    Filter.AddElement(TSQLConditionGreater.New('ID', ':ID'));
    DAODataQuery.ChangeFilter(Filter, TSQLFilterSimpleFormatter.New);
    DAODataQuery.AddParameter(TSQLParameterInt.New('ID', 0));
    DAODataQuery.Execute(Dataset);
    while not Dataset.Eof do
    begin
      Dataset.Next;
    end;
  finally
    Dataset.Free;
  end;
end;

procedure TDAODataQueryTest.ParameterTwoIsID;
var
  DAODataQuery: IDAODataQuery;
begin
  DAODataQuery := TDAODataQuery.New(TDAOConnectionSQLite.New(ConnectionSettings), TEST_SQL);
  DAODataQuery.AddParameter(TSQLParameterText.New('TEST_FIELD', 'test'));
  DAODataQuery.AddParameter(TSQLParameterInt.New('ID', 99));
  CheckEquals(':ID', DAODataQuery.Parameter(1).NameParsed);
  CheckEquals('99', DAODataQuery.Parameter(1).ValueParsed);
end;

procedure TDAODataQueryTest.SQLIsError;
var
  DAODataQuery: IDAODataQuery;
  ErrorFound: Boolean;
begin
  DAODataQuery := TDAODataQuery.New(TDAOConnectionSQLite.New(ConnectionSettings), EmptyStr);
  ErrorFound := False;
  try
    CheckEquals(EmptyStr, DAODataQuery.SQL);
  except
    on E: EDAODataQuery do
      ErrorFound := True;
  end;
  CheckTrue(ErrorFound);
end;

procedure TDAODataQueryTest.SQLIsSelect;
var
  DAODataQuery: IDAODataQuery;
begin
  DAODataQuery := TDAODataQuery.New(TDAOConnectionSQLite.New(ConnectionSettings), TEST_SQL);
  CheckEquals(TEST_SQL, DAODataQuery.SQL);
end;

procedure TDAODataQueryTest.SQLIsSelectFiltered;
var
  DAODataQuery: IDAODataQuery;
  Filter: IFilter;
begin
  DAODataQuery := TDAODataQuery.New(TDAOConnectionSQLite.New(ConnectionSettings), TEST_SQL);
  Filter := TFilter.New(TSQLJoinAnd.New);
  Filter.AddElement(TSQLConditionGreater.New('ID', '4'));
  DAODataQuery.ChangeFilter(Filter, TSQLFilterSimpleFormatter.New);
  CheckEquals(Copy(TEST_SQL, 1, Pred(Length(TEST_SQL))) + ' AND (ID > 4)', DAODataQuery.SQL);
end;

procedure TDAODataQueryTest.CleanAllParameters;
var
  DAODataQuery: IDAODataQuery;
begin
  DAODataQuery := TDAODataQuery.New(TDAOConnectionSQLite.New(ConnectionSettings), TEST_SQL);
  DAODataQuery.AddParameter(TSQLParameterText.New('TEST_FIELD', 'test'));
  DAODataQuery.AddParameter(TSQLParameterInt.New('ID', 99));
  CheckEquals(2, DAODataQuery.ParameterCount);
  DAODataQuery.CleanParameters;
  CheckEquals(0, DAODataQuery.ParameterCount);
end;

procedure TDAODataQueryTest.ParameterCountIsTwo;
var
  DAODataQuery: IDAODataQuery;
begin
  DAODataQuery := TDAODataQuery.New(TDAOConnectionSQLite.New(ConnectionSettings), TEST_SQL);
  CheckEquals(0, DAODataQuery.ParameterCount);
  DAODataQuery.AddParameter(TSQLParameterText.New('TEST_FIELD', 'test'));
  DAODataQuery.AddParameter(TSQLParameterInt.New('ID', 99));
  CheckEquals(2, DAODataQuery.ParameterCount);
end;

function TDAODataQueryTest.DBPath: String;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + 'db_sqlite.db3';
end;

function TDAODataQueryTest.ConnectionSettings: IConnectionSQLiteSettings;
begin
  Result := TConnectionSQLiteSettings.New(TConnectionSettings.New(EmptyStr, EmptyStr, DBPath, 'sqlite3.dll'));
end;

procedure TDAODataQueryTest.CreateDB(const Settings: IConnectionSQLiteSettings);
var
  Connection: IDAOConnectionSQLite;
  RowsAffected: Integer;
begin
  Connection := TDAOConnectionSQLite.New(ConnectionSettings);
  Connection.CreateDatabase;
  CheckTrue(Connection.ExecuteScript(SCRIPT, RowsAffected, True));
end;

procedure TDAODataQueryTest.SetUp;
begin
  inherited;
  CreateDB(ConnectionSettings);
end;

procedure TDAODataQueryTest.TearDown;
begin
  inherited;
  TFSArchiveDelete.New(TFSArchive.New(nil, ConnectionSettings.DataBasePath)).Execute;
end;

initialization

RegisterTest(TDAODataQueryTest {$IFNDEF FPC}.Suite {$ENDIF});

end.
