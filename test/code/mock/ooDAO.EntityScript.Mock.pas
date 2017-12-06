{
  Copyright (c) 2016, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit ooDAO.EntityScript.Mock;

interface

uses
  SysUtils,
  ooText.Beautify.Intf, ooSQL.Filter.SimpleFormatter,
  ooEntity.Intf,
  ooFilter,
  ooSQL, ooSQL.Parameter.Intf, ooSQL.Parameter.Int, ooSQL.Parameter.Str,
  ooEntity.Mock,
  ooDAO.EntityScript.Intf;

type
  IDAOEntityMockScripts = IDAOEntityScript<IEntityMock>;

  TDAOEntityMockScripts = class sealed(TInterfacedObject, IDAOEntityMockScripts)
  private
    function Beautify: ITextBeautify;
  public
    function Select(const Entity: IEntityMock; const Filter: IFilter): String;
    function SelectList(const Filter: IFilter): String;
    function Insert(const Entity: IEntityMock): String;
    function Update(const Entity: IEntityMock): String;
    function Delete(const Entity: IEntityMock): String;

    class function New: IDAOEntityMockScripts;
  end;

implementation

function TDAOEntityMockScripts.Beautify: ITextBeautify;
begin
  Result := TSQLFilterSimpleFormatter.New;
end;

function TDAOEntityMockScripts.Delete(const Entity: IEntityMock): String;
const
  SQL_DELETE = 'DELETE FROM {{ENTITY.MOCK}} WHERE ID = :ID;';
begin
  Result := TSQL.New(SQL_DELETE).Parse([TSQLParameterInt.New('ID', Entity.ID)], Beautify);
end;

function TDAOEntityMockScripts.Insert(const Entity: IEntityMock): String;
const
  SQL_INSERT = 'INSERT INTO {{ENTITY.MOCK}}(ID, FIELD1) VALUES (:ID, :FIELD1);';
begin
  Result := TSQL.New(SQL_INSERT).Parse([TSQLParameterInt.New('ID', Entity.ID),
    TSQLParameterStr.New('FIELD1', Entity.Value)], Beautify);
end;

function TDAOEntityMockScripts.Select(const Entity: IEntityMock; const Filter: IFilter): String;
const
  SQL_SELECT = 'SELECT ID, FIELD1 FROM {{ENTITY.MOCK}} WHERE ID = :ID;';
begin
  Result := TSQL.New(SQL_SELECT).Parse([TSQLParameterInt.New('ID', Entity.ID)], Beautify);
end;

function TDAOEntityMockScripts.SelectList(const Filter: IFilter): String;
begin
  Result := 'SELECT ID, FIELD1 FROM {{ENTITY.MOCK}}';
end;

function TDAOEntityMockScripts.Update(const Entity: IEntityMock): String;
const
  SQL_UPDATE = 'UPDATE {{ENTITY.MOCK}} SET FIELD1 = :FIELD1 WHERE ID = :ID;';
begin
  Result := TSQL.New(SQL_UPDATE).Parse([TSQLParameterStr.New('FIELD1', Entity.Value),
    TSQLParameterInt.New('ID', Entity.ID)], Beautify);
end;

class function TDAOEntityMockScripts.New: IDAOEntityMockScripts;
begin
  Result := TDAOEntityMockScripts.Create;
end;

end.
