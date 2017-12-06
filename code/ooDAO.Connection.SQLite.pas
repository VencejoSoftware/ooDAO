{
  Copyright (c) 2016, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit ooDAO.Connection.SQLite;

interface

uses
  SysUtils, DB,
  ZConnection, ZDbcIntfs,
  ooSQL.Parameter.Intf,
  ooDAO.Connection.SQLite.Settings,
  ooDAO.Connection, ooDAO.Connection.Intf;

type
  IDAOConnectionSQLite = interface(IDAOConnection)
    ['{4816112F-8476-44A3-9985-2885C00B9365}']
    function ServerDateTime: TDateTime;
    function CreateDatabase: Boolean;
  end;

  TDAOConnectionSQLite = class sealed(TInterfacedObject, IDAOConnectionSQLite, IDAOConnection)
  strict private
    _Connection: TZConnection;
    _DAOConnection: IDAOConnection;
  private
    procedure SetConnectionSettings(const Connection: TZConnection; const Settings: IConnectionSQLiteSettings);
  public
    function BuildDataset(out Dataset: TDataSet; const SQL: String; Parameters: array of ISQLParameter): Boolean;
    function IsConnected: Boolean;
    function InTransaction: Boolean;
    function ServerDateTime: TDateTime;
    function ExecuteScript(const SQL: String; var RowsAffected: Integer; const IgnoreErrors: Boolean): Boolean;
    function ExecuteSQL(const SQL: String; var RowsAffected: Integer): Boolean;
    function CreateDatabase: Boolean;

    procedure BeginTransaction;
    procedure CommitTransaction;
    procedure RollbackTransaction;
    procedure Connect;
    procedure Disconnect;

    constructor Create(const Settings: IConnectionSQLiteSettings);
    destructor Destroy; override;

    class function New(const Settings: IConnectionSQLiteSettings): IDAOConnectionSQLite;
  end;

implementation

procedure TDAOConnectionSQLite.BeginTransaction;
begin
  _DAOConnection.BeginTransaction;
end;

procedure TDAOConnectionSQLite.CommitTransaction;
begin
  _DAOConnection.CommitTransaction;
end;

procedure TDAOConnectionSQLite.RollbackTransaction;
begin
  _DAOConnection.RollbackTransaction;
end;

function TDAOConnectionSQLite.InTransaction: Boolean;
begin
  Result := _DAOConnection.InTransaction;
end;

function TDAOConnectionSQLite.ExecuteScript(const SQL: String; var RowsAffected: Integer;
  const IgnoreErrors: Boolean): Boolean;
begin
  Result := _DAOConnection.ExecuteScript(SQL, RowsAffected, IgnoreErrors);
end;

function TDAOConnectionSQLite.ExecuteSQL(const SQL: String; var RowsAffected: Integer): Boolean;
begin
  Result := _DAOConnection.ExecuteSQL(SQL, RowsAffected);
end;

function TDAOConnectionSQLite.BuildDataset(out Dataset: TDataSet; const SQL: String;
  Parameters: array of ISQLParameter): Boolean;
begin
  Result := _DAOConnection.BuildDataset(Dataset, SQL, Parameters);
end;

function TDAOConnectionSQLite.IsConnected: Boolean;
begin
  Result := _DAOConnection.IsConnected;
end;

procedure TDAOConnectionSQLite.Disconnect;
begin
  _DAOConnection.Disconnect;
end;

procedure TDAOConnectionSQLite.Connect;
begin
  _DAOConnection.Connect;
end;
{$HINTS OFF}

function TDAOConnectionSQLite.ServerDateTime: TDateTime;
const
  SQL_TMP = 'SELECT strftime(''%d/%m/%Y %H:%M:%S'', CURRENT_TIMESTAMP) AS SERVER_DATE';
var
  Dataset: TDataSet;
begin
  try
    BuildDataset(Dataset, SQL_TMP, []);
    Result := Dataset.FieldByName('SERVER_DATE').AsDateTime;
  finally
    Dataset.Free;
  end;
end;
{$HINTS ON}

procedure TDAOConnectionSQLite.SetConnectionSettings(const Connection: TZConnection;
  const Settings: IConnectionSQLiteSettings);
begin
  Connection.HostName := EmptyStr;
  Connection.Database := Settings.DataBasePath;
  Connection.User := Settings.User;
  Connection.Password := Settings.Password;
  Connection.LibraryLocation := Settings.LibraryPath;
  Connection.TransactIsolationLevel := tiReadCommitted;
  Connection.Protocol := 'sqlite-3';
  Connection.ClientCodepage := Settings.CharSet;
end;

function TDAOConnectionSQLite.CreateDatabase: Boolean;
begin
  _Connection.Connect;
  Result := True;
end;

constructor TDAOConnectionSQLite.Create(const Settings: IConnectionSQLiteSettings);
begin
  _Connection := TZConnection.Create(nil);
  SetConnectionSettings(_Connection, Settings);
  _DAOConnection := TDAOConnection.New(_Connection);
end;

destructor TDAOConnectionSQLite.Destroy;
begin
  if IsConnected then
    Disconnect;
  _Connection.Free;
  inherited;
end;

class function TDAOConnectionSQLite.New(const Settings: IConnectionSQLiteSettings): IDAOConnectionSQLite;
begin
  Result := TDAOConnectionSQLite.Create(Settings);
end;

end.
