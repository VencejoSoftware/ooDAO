{
  Copyright (c) 2016, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit ooDAO.Connection.ADO;

interface

uses
  Classes, SysUtils, DB,
  ADODB,
  ooSQL.Filter.SimpleFormatter,
  ooSQL.Parameter.Intf, ooSQL,
  ooDAO.Connection.Intf;

type
  IDAOConnectionADO = interface(IDAOConnection)
    ['{24341804-7A29-4D6C-BF15-357F94D3CBBC}']
    function ServerDateTime: TDateTime;
  end;

  TDAOConnectionADO = class sealed(TInterfacedObject, IDAOConnectionADO, IDAOConnection)
  strict private
    _Connection: TADOConnection;
    _SQLServerDateTime: String;
  private
    function PrepareSQL(const SQL: String): String;
    function InternalExecuteSQL(const SQL: String; var RowsAffected: Integer): Boolean;
  public
    function BuildDataset(out Dataset: TDataSet; const SQL: String; Parameters: array of ISQLParameter): Boolean;
    function IsConnected: Boolean;
    function InTransaction: Boolean;
    function ServerDateTime: TDateTime;
    function ADOConnection: TADOConnection;
    function ExecuteScript(const SQL: String; var RowsAffected: Integer; const IgnoreErrors: Boolean): Boolean;
    function ExecuteSQL(const SQL: String; var RowsAffected: Integer): Boolean;

    procedure BeginTransaction;
    procedure CommitTransaction;
    procedure RollbackTransaction;
    procedure Connect;
    procedure Disconnect;

    constructor Create(const Connection: TADOConnection; const SQLServerDateTime: String);

    class function New(const Connection: TADOConnection; const SQLServerDateTime: String): IDAOConnectionADO;
  end;

implementation

function TDAOConnectionADO.ADOConnection: TADOConnection;
begin
  Result := _Connection;
end;

procedure TDAOConnectionADO.BeginTransaction;
begin
  ADOConnection.BeginTrans;
end;

procedure TDAOConnectionADO.CommitTransaction;
begin
  ADOConnection.CommitTrans;
end;

procedure TDAOConnectionADO.RollbackTransaction;
begin
  ADOConnection.RollbackTrans;
end;

function TDAOConnectionADO.ExecuteScript(const SQL: String; var RowsAffected: Integer;
  const IgnoreErrors: Boolean): Boolean;
var
  StringList: TStringList;
  SQLRowsAffected: Integer;
  SQLItem: String;
  i: Integer;
begin
  Result := False;
  StringList := TStringList.Create;
  RowsAffected := 0;
  try
    StringList.Delimiter := ';';
    StringList.StrictDelimiter := True;
    StringList.DelimitedText := SQL;
    for i := 0 to Pred(StringList.Count) do
    begin
      SQLItem := Trim(StringList[i]);
      if Length(SQLItem) > 0 then
      begin
        try
          if InternalExecuteSQL(SQLItem, SQLRowsAffected) then
            RowsAffected := RowsAffected + SQLRowsAffected;
        except
          on E: Exception do
            if not IgnoreErrors then
              raise EDAOConnection.Create('Error in script ' + SQLItem + sLineBreak + E.Message);
        end;
      end;
      Result := True;
    end;
  finally
    StringList.Free;
  end;
end;
{$HINTS OFF}

function TDAOConnectionADO.ServerDateTime: TDateTime;
var
  Dataset: TDataSet;
begin
  if Length(_SQLServerDateTime) < 1 then
    raise EDAOConnection.Create('Server Date Time SQL not setted!');
  try
    BuildDataset(Dataset, _SQLServerDateTime, []);
    Result := Dataset.FieldByName('SERVER_DATE').AsDateTime;
  finally
    Dataset.Free;
  end;
end;
{$HINTS ON}

function TDAOConnectionADO.ExecuteSQL(const SQL: String; var RowsAffected: Integer): Boolean;
begin
  Result := InternalExecuteSQL(SQL, RowsAffected);
end;

function TDAOConnectionADO.BuildDataset(out Dataset: TDataSet; const SQL: String;
  Parameters: array of ISQLParameter): Boolean;
var
  Query: TADOQuery;
  SQLPrepared: String;
begin
  Query := TADOQuery.Create(ADOConnection);
  SQLPrepared := PrepareSQL(TSQL.New(SQL).Parse(Parameters, TSQLFilterSimpleFormatter.New));
  Query.DisableControls;
  Query.SQL.Text := SQLPrepared;
  Query.Connection := ADOConnection;
  Query.CursorType := ctOpenForwardOnly;
  Query.Open;
  Dataset := Query;
  Result := True;
end;

function TDAOConnectionADO.InternalExecuteSQL(const SQL: String; var RowsAffected: Integer): Boolean;
begin
  ADOConnection.Execute(PrepareSQL(SQL), RowsAffected);
  Result := True;
end;

function TDAOConnectionADO.InTransaction: Boolean;
begin
  Result := ADOConnection.InTransaction;
end;

function TDAOConnectionADO.IsConnected: Boolean;
begin
  Result := ADOConnection.Connected;
end;

function TDAOConnectionADO.PrepareSQL(const SQL: String): String;
begin
  Result := SQL;
  Result := StringReplace(Result, SCHEMA_QUOTE_BEGIN, EmptyStr, [rfReplaceAll]);
  Result := StringReplace(Result, SCHEMA_QUOTE_END, EmptyStr, [rfReplaceAll]);
end;

procedure TDAOConnectionADO.Connect;
begin
  ADOConnection.Connected := True;
end;

procedure TDAOConnectionADO.Disconnect;
begin
  ADOConnection.Connected := False;
end;

constructor TDAOConnectionADO.Create(const Connection: TADOConnection; const SQLServerDateTime: String);
begin
  _Connection := Connection;
  _SQLServerDateTime := SQLServerDateTime;
end;

class function TDAOConnectionADO.New(const Connection: TADOConnection;
  const SQLServerDateTime: String): IDAOConnectionADO;
begin
  Result := TDAOConnectionADO.Create(Connection, SQLServerDateTime);
end;

end.
