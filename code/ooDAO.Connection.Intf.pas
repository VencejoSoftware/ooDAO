{
  Copyright (c) 2016, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit ooDAO.Connection.Intf;

interface

uses
  SysUtils,
  DB,
  ooSQL.Parameter.Intf;

const
  SCHEMA_QUOTE_BEGIN = '{{';
  SCHEMA_QUOTE_END = '}}';

type
  EDAOConnection = class(Exception)
  end;

  IDAOConnection = interface
    ['{18E0D472-0BE6-4094-9270-413C0AA1CF1A}']
    function BuildDataset(out Dataset: TDataSet; const SQL: String; Parameters: array of ISQLParameter): Boolean;
    function IsConnected: Boolean;
    function InTransaction: Boolean;
    function ExecuteSQL(const SQL: String; var RowsAffected: Integer): Boolean;
    function ExecuteScript(const SQL: String; var RowsAffected: Integer; const IgnoreErrors: Boolean): Boolean;

    procedure BeginTransaction;
    procedure CommitTransaction;
    procedure RollbackTransaction;
    procedure Connect;
    procedure Disconnect;
  end;

implementation

end.
