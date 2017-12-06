{
  Copyright (c) 2016, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit ooDAO.Connection;

interface

uses
  Classes, SysUtils, DB,
  ZConnection, ZDataset, ZDbcIntfs,
  ooSQL.Parameter.Intf, ooSQL,
  ooDAO.Connection.Intf;

type
  TDAOConnection = class sealed(TInterfacedObject, IDAOConnection)
  strict private
    _Connection: TZConnection;
  private
    function PrepareSQL(const SQL: String): String;
    function InternalExecuteSQL(const SQL: String; var RowsAffected: Integer): Boolean;
    function ProcessCommitSQL(const SQL: String): Boolean;
    function ProcessRollbackSQL(const SQL: String): Boolean;
    function ProcessSQL(const SQL: String; const IgnoreErrors: Boolean): Integer;
    function ProcessBeginTransactionSQL(const SQL: String): Boolean;
  public
    function BuildDataset(out Dataset: TDataSet; const SQL: String; Parameters: array of ISQLParameter): Boolean;
    function IsConnected: Boolean;
    function InTransaction: Boolean;
    function ExecuteScript(const SQL: String; var RowsAffected: Integer; const IgnoreErrors: Boolean): Boolean;
    function ExecuteSQL(const SQL: String; var RowsAffected: Integer): Boolean;

    procedure BeginTransaction;
    procedure CommitTransaction;
    procedure RollbackTransaction;
    procedure Connect;
    procedure Disconnect;

    constructor Create(const Connection: TZConnection);

    class function New(const Connection: TZConnection): IDAOConnection;
  end;

implementation

procedure TDAOConnection.BeginTransaction;
begin
  _Connection.StartTransaction;
end;

procedure TDAOConnection.CommitTransaction;
begin
  _Connection.Commit;
end;

procedure TDAOConnection.RollbackTransaction;
begin
  _Connection.Rollback;
end;

function TDAOConnection.InTransaction: Boolean;
begin
  Result := _Connection.InTransaction
end;

function TDAOConnection.ProcessCommitSQL(const SQL: String): Boolean;
begin
  Result := Pos('COMMIT', SQL) > 0;
  if Result then
    CommitTransaction;
end;

function TDAOConnection.ProcessRollbackSQL(const SQL: String): Boolean;
begin
  Result := Pos('ROLLBACK', SQL) > 0;
  if Result then
    RollbackTransaction;
end;

function TDAOConnection.ProcessBeginTransactionSQL(const SQL: String): Boolean;
begin
  Result := Pos('BEGIN TRANSACTION', SQL) > 0;
  if Result and not InTransaction then
    BeginTransaction;
end;

function TDAOConnection.ProcessSQL(const SQL: String; const IgnoreErrors: Boolean): Integer;
begin
  Result := 0;
  try
    if not ProcessCommitSQL(SQL) and not ProcessRollbackSQL(SQL) and not ProcessBeginTransactionSQL(SQL) then
      InternalExecuteSQL(SQL, Result);
  except
    on E: Exception do
      if not IgnoreErrors then
        raise EDAOConnection.Create('Error in script ' + SQL + sLineBreak + E.Message);
  end;
end;

function TDAOConnection.ExecuteScript(const SQL: String; var RowsAffected: Integer;
  const IgnoreErrors: Boolean): Boolean;
var
  StringList: TStringList;
  SQLRowsAffected: Integer;
  SQLItem: String;
  i: Integer;
begin
  RowsAffected := 0;
  StringList := TStringList.Create;
  try
    StringList.Delimiter := ';';
    StringList.StrictDelimiter := True;
    StringList.DelimitedText := SQL;
    try
      for i := 0 to Pred(StringList.Count) do
      begin
        SQLItem := Trim(StringList[i]);
        if Length(SQLItem) > 0 then
        begin
          SQLRowsAffected := ProcessSQL(SQLItem, IgnoreErrors);
          if SQLRowsAffected > 0 then
            RowsAffected := RowsAffected + SQLRowsAffected;
        end;
      end;
      if InTransaction then
        CommitTransaction;
      Result := True;
    except
      if InTransaction then
        RollbackTransaction;
      raise ;
    end;
  finally
    StringList.Free;
  end;
end;

function TDAOConnection.InternalExecuteSQL(const SQL: String; var RowsAffected: Integer): Boolean;
begin
  if not InTransaction then
    BeginTransaction;
  Result := _Connection.ExecuteDirect(PrepareSQL(SQL), RowsAffected);
end;

function TDAOConnection.ExecuteSQL(const SQL: String; var RowsAffected: Integer): Boolean;
begin
  Result := InternalExecuteSQL(SQL, RowsAffected);
end;

function TDAOConnection.BuildDataset(out Dataset: TDataSet; const SQL: String;
  Parameters: array of ISQLParameter): Boolean;
var
  FBDataset: TZquery;
  SQLPrepared: String;
begin
  FBDataset := TZquery.Create(_Connection);
  SQLPrepared := PrepareSQL(SQL);
  FBDataset.SQL.Text := SQLPrepared;
  FBDataset.Connection := _Connection;
  FBDataset.Open;
  Dataset := FBDataset;
  Result := True;
end;

function TDAOConnection.IsConnected: Boolean;
begin
  Result := _Connection.Connected;
end;

function TDAOConnection.PrepareSQL(const SQL: String): String;
begin
  Result := SQL;
  Result := StringReplace(Result, SCHEMA_QUOTE_BEGIN, '"', [rfReplaceAll]);
  Result := StringReplace(Result, SCHEMA_QUOTE_END, '"', [rfReplaceAll]);
end;

procedure TDAOConnection.Disconnect;
begin
  _Connection.Connected := False;
end;

procedure TDAOConnection.Connect;
begin
  _Connection.Connected := True;
end;

constructor TDAOConnection.Create(const Connection: TZConnection);
begin
  _Connection := Connection;
end;

class function TDAOConnection.New(const Connection: TZConnection): IDAOConnection;
begin
  Result := TDAOConnection.Create(Connection);
end;

end.
