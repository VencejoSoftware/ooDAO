{
  Copyright (c) 2016, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit ooDAO.DataQuery;

interface

uses
  SysUtils, DB,
  ooFilter,
  ooText.Beautify.Intf,
  ooSQL.Intf, ooSQL,
  ooSQL.Parameter.Intf,
  ooDAO.Connection.Intf;

type
  EDAODataQuery = class(Exception)
  end;

  IDAODataQuery = interface
    ['{B0B0DCCE-F8DD-4336-8C1C-8DB954C2528C}']
    function Filter: IFilter;
    function AddParameter(const Parameter: ISQLParameter): Integer;
    function ParameterCount: Integer;
    function Parameter(const Index: Integer): ISQLParameter;
    function SQL: String;
    function Execute(out Dataset: TDataSet): Boolean;

    procedure ChangeFilter(const Filter: IFilter; const Beautify: ITextBeautify);
    procedure CleanParameters;
  end;

  TDAODataQuery = class sealed(TInterfacedObject, IDAODataQuery)
  strict private
    _Connection: IDAOConnection;
    _Parameters: TSQLParameterArray;
    _Filter: IFilter;
    _Beautify: ITextBeautify;
    _SQL: String;
  private
    function ApplyFilter(const SQL: String; const Beautify: ITextBeautify): String;
  public
    function Filter: IFilter;
    function SQL: String; virtual;
    function Execute(out Dataset: TDataSet): Boolean;
    function AddParameter(const Parameter: ISQLParameter): Integer;
    function ParameterCount: Integer;
    function Parameter(const Index: Integer): ISQLParameter;

    procedure ChangeFilter(const Filter: IFilter; const Beautify: ITextBeautify);
    procedure CleanParameters;

    constructor Create(const Connection: IDAOConnection; const SQL: String); virtual;

    class function New(const Connection: IDAOConnection; const SQL: String = ''): IDAODataQuery;
  end;

implementation

function TDAODataQuery.AddParameter(const Parameter: ISQLParameter): Integer;
begin
  SetLength(_Parameters, Succ(Length(_Parameters)));
  Result := High(_Parameters);
  _Parameters[Result] := Parameter;
end;

function TDAODataQuery.Parameter(const Index: Integer): ISQLParameter;
begin
  Result := _Parameters[Index];
end;

function TDAODataQuery.ParameterCount: Integer;
begin
  Result := Length(_Parameters);
end;

procedure TDAODataQuery.CleanParameters;
begin
  SetLength(_Parameters, 0);
end;

function TDAODataQuery.Filter: IFilter;
begin
  Result := _Filter;
end;

function TDAODataQuery.ApplyFilter(const SQL: String; const Beautify: ITextBeautify): String;
begin
  Result := SQL;
  if not Assigned(_Filter) then
    Exit;
  Result := _Beautify.Apply([Result, Filter.Parse(_Beautify)]);
end;

function TDAODataQuery.SQL: String;
begin
  if Length(_SQL) = 0 then
    raise EDAODataQuery.Create('SQL not setted in the query object')
  else
    Result := ApplyFilter(_SQL, _Beautify);
end;

procedure TDAODataQuery.ChangeFilter(const Filter: IFilter; const Beautify: ITextBeautify);
begin
  _Filter := Filter;
  _Beautify := Beautify;
end;

function TDAODataQuery.Execute(out Dataset: TDataSet): Boolean;
begin
  Result := _Connection.BuildDataset(Dataset, SQL, _Parameters);
  if Result then
    Dataset.First;
end;

constructor TDAODataQuery.Create(const Connection: IDAOConnection; const SQL: String);
begin
  _Connection := Connection;
  _Parameters := nil;
  _SQL := SQL;
end;

class function TDAODataQuery.New(const Connection: IDAOConnection; const SQL: String = ''): IDAODataQuery;
begin
  Result := TDAODataQuery.Create(Connection, SQL);
end;

end.
