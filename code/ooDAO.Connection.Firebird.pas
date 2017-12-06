{
  Copyright (c) 2016, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit ooDAO.Connection.Firebird;

interface

uses
  SysUtils, DB,
  ZConnection, ZDbcIntfs,
  ooSQL.Parameter.Intf,
  ooDAO.Connection.Firebird.Settings,
  ooDAO.Connection, ooDAO.Connection.Intf;

type
  IDAOConnectionFirebird = interface(IDAOConnection)
    ['{6C0629AC-2C39-497C-BF40-092D6267184A}']
    function ServerDateTime: TDateTime;
    function CreateDatabase: Boolean;
  end;

  TDAOConnectionFirebird = class sealed(TInterfacedObject, IDAOConnectionFirebird, IDAOConnection)
  strict private
    _Connection: TZConnection;
    _DAOConnection: IDAOConnection;
  private
    procedure SetConnectionSettings(const Connection: TZConnection; const Settings: IConnectionFirebirdSettings);
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

    constructor Create(const Settings: IConnectionFirebirdSettings);
    destructor Destroy; override;

    class function New(const Settings: IConnectionFirebirdSettings): IDAOConnectionFirebird;
  end;

implementation

procedure TDAOConnectionFirebird.BeginTransaction;
begin
  _DAOConnection.BeginTransaction;
end;

procedure TDAOConnectionFirebird.CommitTransaction;
begin
  _DAOConnection.CommitTransaction;
end;

procedure TDAOConnectionFirebird.RollbackTransaction;
begin
  _DAOConnection.RollbackTransaction;
end;

function TDAOConnectionFirebird.InTransaction: Boolean;
begin
  Result := _DAOConnection.InTransaction;
end;

function TDAOConnectionFirebird.ExecuteScript(const SQL: String; var RowsAffected: Integer;
  const IgnoreErrors: Boolean): Boolean;
begin
  Result := _DAOConnection.ExecuteScript(SQL, RowsAffected, IgnoreErrors);
end;

function TDAOConnectionFirebird.ExecuteSQL(const SQL: String; var RowsAffected: Integer): Boolean;
begin
  Result := _DAOConnection.ExecuteSQL(SQL, RowsAffected);
end;

function TDAOConnectionFirebird.BuildDataset(out Dataset: TDataSet; const SQL: String;
  Parameters: array of ISQLParameter): Boolean;
begin
  Result := _DAOConnection.BuildDataset(Dataset, SQL, Parameters);
end;

function TDAOConnectionFirebird.IsConnected: Boolean;
begin
  Result := _DAOConnection.IsConnected;
end;

procedure TDAOConnectionFirebird.Disconnect;
begin
  _DAOConnection.Disconnect;
end;

procedure TDAOConnectionFirebird.Connect;
begin
  _DAOConnection.Connect;
end;
{$HINTS OFF}

function TDAOConnectionFirebird.ServerDateTime: TDateTime;
const
  SQL_TMP = 'SELECT CURRENT_DATE AS SERVER_DATE FROM rdb$database';
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

procedure TDAOConnectionFirebird.SetConnectionSettings(const Connection: TZConnection;
  const Settings: IConnectionFirebirdSettings);
begin
  Connection.HostName := EmptyStr;
  Connection.Database := Settings.DataBasePath;
  Connection.User := Settings.User;
  Connection.Password := Settings.Password;
  Connection.LibraryLocation := Settings.LibraryPath;
  Connection.TransactIsolationLevel := tiReadCommitted;
  Connection.Protocol := Settings.Version;
  Connection.Port := Settings.Port;
  Connection.ClientCodepage := Settings.Collation;
  Connection.Properties.Clear;
  Connection.Properties.Values['dialect'] := IntToStr(Settings.Dialect);
  with Connection.Properties do
  begin
    Add('lc_ctype=' + Settings.Collation);
    Add('Codepage=' + Settings.Collation);
    Add('isc_tpb_concurrency');
    Add('isc_tpb_nowait');
  end;
end;

function TDAOConnectionFirebird.CreateDatabase: Boolean;
var
  SQLCreate: String;
begin
  SQLCreate := Format('CREATE DATABASE %s USER %s PASSWORD %s PAGE_SIZE 8192 DEFAULT CHARACTER SET %s',
    [QuotedStr(_Connection.Database), QuotedStr(_Connection.User), QuotedStr(_Connection.Password),
    _Connection.ClientCodepage]);
  _Connection.Properties.Values['CreateNewDatabase'] := SQLCreate;
  _Connection.Connect;
  Result := True;
end;

constructor TDAOConnectionFirebird.Create(const Settings: IConnectionFirebirdSettings);
begin
  _Connection := TZConnection.Create(nil);
  SetConnectionSettings(_Connection, Settings);
  _DAOConnection := TDAOConnection.New(_Connection);
end;

destructor TDAOConnectionFirebird.Destroy;
begin
  if IsConnected then
    Disconnect;
  _Connection.Free;
  inherited;
end;

class function TDAOConnectionFirebird.New(const Settings: IConnectionFirebirdSettings): IDAOConnectionFirebird;
begin
  Result := TDAOConnectionFirebird.Create(Settings);
end;

end.
