{$REGION 'documentation'}
{
  Copyright (c) 2016, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Object to define an auto-incremental value/sequence
  @created(12/10/2016)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit ooDAO.AutoInc;

interface

uses
  SysUtils, DB,
  ooDAO.AutoIncScript.Intf,
  ooDAO.Connection.Intf,
  ooFilter;

type
{$REGION 'documentation'}
{
  @abstract(Object to define an auto-incremental value/sequence)
  @member(
    CurrentValue Return the current sequence value
    @param(@link(Filter Object to add filter into the get command))
  )
  @member(
    NewValue Consume a sequence value
    @param(@link(Filter Object to add filter into the consume command))
  )
}
{$ENDREGION}
  IDAOAutoInc = interface
    ['{0ECAABA4-9F69-4F9E-9CC3-6FF0B770E4AC}']
    function CurrentValue(const Filter: IFilter): Cardinal;
    function NewValue(const Filter: IFilter): Cardinal;
  end;

{$REGION 'documentation'}
{
  @abstract(Error class for exceptions in code)
}
{$ENDREGION}

  EDAOAutoInc = class sealed(Exception)
  end;

{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IDAOAutoInc))
  @member(CurrentValue @seealso(IDAOAutoInc.CurrentValue))
  @member(NewValue @seealso(IDAOAutoInc.NewValue))
  @member(
    Create Object constructor
    @param(Connection @link(IDAOConnection Connection object))
    @param(AutoIncScript @link(IDAOAutoIncScript Object to build script commands))
  )
}
{$ENDREGION}

  TDAOAutoInc = class(TInterfacedObject, IDAOAutoInc)
  strict private
    _Connection: IDAOConnection;
    _AutoIncScript: IDAOAutoIncScript;
  public
    function CurrentValue(const Filter: IFilter): Cardinal;
    function NewValue(const Filter: IFilter): Cardinal;
    constructor Create(const Connection: IDAOConnection; const AutoIncScript: IDAOAutoIncScript);
  end;

implementation

function TDAOAutoInc.CurrentValue(const Filter: IFilter): Cardinal;
var
  Script: String;
  DataSet: TDataSet;
begin
  Result := 0;
  Script := _AutoIncScript.Select(Filter);
  if _Connection.BuildDataset(DataSet, Script, []) then
  begin
    try
      if DataSet.RecordCount > 1 then
        raise EDAOAutoInc.Create('Multiples rows in dataset');
      Result := DataSet.Fields[0].AsInteger;
    finally
      DataSet.Free;
    end;
  end;
end;

function TDAOAutoInc.NewValue(const Filter: IFilter): Cardinal;
var
  Script: String;
  RowsAffected: Integer;
begin
  _Connection.BeginTransaction;
  try
    Script := _AutoIncScript.Consume(Filter);
    _Connection.ExecuteSQL(Script, RowsAffected);
    if RowsAffected < 0 then
      raise EDAOAutoInc.Create('Can not consume a new auto-incremental value');
    _Connection.CommitTransaction;
  except
    _Connection.RollbackTransaction;
    raise;
  end;
  Result := CurrentValue(Filter);
end;

constructor TDAOAutoInc.Create(const Connection: IDAOConnection; const AutoIncScript: IDAOAutoIncScript);
begin
  _Connection := Connection;
  _AutoIncScript := AutoIncScript;
end;

end.
