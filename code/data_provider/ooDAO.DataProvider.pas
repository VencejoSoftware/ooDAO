{
  Copyright (c) 2016, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit ooDAO.DataProvider;

interface

uses
  SysUtils, DB,
  Generics.Collections,
  ooFilter,
  ooEntity.Intf,
  ooDAO.EntityScript.Intf,
  ooDAO.Connection.Intf,
  ooDataInput.Intf, ooDataOutput.Intf,
  ooDataset.DataInput, ooDataset.DataOutput;

type
  IDAODataProvider<T: IEntity> = interface
    ['{6CFB08FA-FB8F-4B9F-950B-C34EF93EBAF2}']
    function Insert(const Entity: T): Integer;
    function Update(const Entity: T): Boolean;
    function Delete(const Entity: T): Boolean;
    function InsertList(const List: TList<T>): Boolean;
    function Select(const Entity: T; const Filter: IFilter): Boolean;
    function SelectList(const List: TList<T>; const Filter: IFilter): Boolean;
    function NewEntity: T;
  end;

  EDAODataProvider = class sealed(Exception)
  end;

  TDAODataProvider<T: IEntity> = class(TInterfacedObject, IDAODataProvider<T>)
  strict private
    _Connection: IDAOConnection;
    _EntityScript: IDAOEntityScript<T>;
  private
    procedure DataSetToList(const DataInput: IDataInput; const List: TList<T>);
  protected
    function NewEntity: T; virtual; abstract;
  public
    function Insert(const Entity: T): Integer;
    function Update(const Entity: T): Boolean;
    function Delete(const Entity: T): Boolean;
    function InsertList(const List: TList<T>): Boolean; virtual;
    function Select(const Entity: T; const Filter: IFilter): Boolean;
    function SelectList(const List: TList<T>; const Filter: IFilter): Boolean;
    constructor Create(const Connection: IDAOConnection; const EntityScript: IDAOEntityScript<T>);
  end;

implementation

function TDAODataProvider<T>.Insert(const Entity: T): Integer;
var
  Script: String;
begin
  _Connection.BeginTransaction;
  try
    Script := _EntityScript.Insert(Entity);
    _Connection.ExecuteSQL(Script, Result);
    _Connection.CommitTransaction;
  except
    _Connection.RollbackTransaction;
    raise ;
  end;
end;

function TDAODataProvider<T>.Update(const Entity: T): Boolean;
var
  Script: String;
  RowsAffected: Integer;
begin
  _Connection.BeginTransaction;
  try
    Script := _EntityScript.Update(Entity);
    _Connection.ExecuteSQL(Script, RowsAffected);
    Result := RowsAffected > 0;
    _Connection.CommitTransaction;
  except
    _Connection.RollbackTransaction;
    raise ;
  end;
end;

function TDAODataProvider<T>.Delete(const Entity: T): Boolean;
var
  Script: String;
  RowsAffected: Integer;
begin
  _Connection.BeginTransaction;
  try
    Script := _EntityScript.Delete(Entity);
    _Connection.ExecuteSQL(Script, RowsAffected);
    Result := RowsAffected > 0;
    _Connection.CommitTransaction;
  except
    _Connection.RollbackTransaction;
    raise ;
  end;
end;

function TDAODataProvider<T>.InsertList(const List: TList<T>): Boolean;
var
  Entity: T;
  RowsAffected: Integer;
  Script: String;
begin
  Result := False;
  Script := EmptyStr;
  for Entity in List do
    Script := Script + _EntityScript.Insert(Entity) + sLineBreak;
  _Connection.ExecuteScript(Script, RowsAffected, False);
  Result := RowsAffected = List.Count;
end;

function TDAODataProvider<T>.Select(const Entity: T; const Filter: IFilter): Boolean;
var
  Script: String;
  DataSet: TDataSet;
  DataInput: IDataInput;
begin
  Result := False;
  Script := _EntityScript.Select(Entity, Filter);
  if _Connection.BuildDataset(DataSet, Script, []) then
  begin
    try
      if DataSet.RecordCount > 1 then
        raise EDAODataProvider.Create('Multiples rows in dataset');
      Result := DataSet.RecordCount = 1;
      if Result then
      begin
        DataInput := TDatasetDataInput.New(DataSet);
        Entity.Unmarshal(DataInput);
      end;
    finally
      DataSet.Free;
    end;
  end;
end;

procedure TDAODataProvider<T>.DataSetToList(const DataInput: IDataInput; const List: TList<T>);
var
  Entity: T;
begin
  Entity := NewEntity;
  Entity.Unmarshal(DataInput);
  List.Add(Entity);
end;

function TDAODataProvider<T>.SelectList(const List: TList<T>; const Filter: IFilter): Boolean;
var
  Script: String;
  DataSet: TDataSet;
  DataInput: IDataInput;
begin
  Result := False;
  List.Clear;
  Script := _EntityScript.SelectList(Filter);
  if _Connection.BuildDataset(DataSet, Script, []) then
  begin
    Result := DataSet.RecordCount > 0;
    if Result then
    begin
      DataInput := TDatasetDataInput.New(DataSet);
      try
        DataSet.DisableControls;
        while not DataSet.Eof do
        begin
          DataSetToList(DataInput, List);
          DataSet.Next;
        end;
      finally
        DataSet.EnableControls;
        DataSet.Free;
      end;
    end;
  end;
end;

constructor TDAODataProvider<T>.Create(const Connection: IDAOConnection; const EntityScript: IDAOEntityScript<T>);
begin
  _Connection := Connection;
  _EntityScript := EntityScript;
end;

end.
