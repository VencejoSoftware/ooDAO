unit ooDAO.AutoIncScript_Mock;

interface

uses
  ooText.Beautify.Intf, ooSQL.Filter.SimpleFormatter,
  ooSQL,
  ooFilter,
  ooDAO.AutoIncScript.Intf;

type
  TDAOAutoIncScriptMock = class sealed(TInterfacedObject, IDAOAutoIncScript)
  private
    function Beautify: ITextBeautify;
  public
    function Consume(const Filter: IFilter): String;
    function Select(const Filter: IFilter): String;
    class function New: IDAOAutoIncScript;
  end;

implementation

function TDAOAutoIncScriptMock.Beautify: ITextBeautify;
begin
  Result := TSQLFilterSimpleFormatter.New;
end;

function TDAOAutoIncScriptMock.Consume(const Filter: IFilter): String;
const
  SQL_CONSUME = 'UPDATE {{ENTITY.SEQUENCES}} SET AUTOINC = AUTOINC + 1;';
begin
  Result := TSQL.New(SQL_CONSUME).Parse([], Beautify);
end;

function TDAOAutoIncScriptMock.Select(const Filter: IFilter): String;
const
  SQL_SELECT = 'SELECT AUTOINC FROM {{ENTITY.SEQUENCES}};';
begin
  Result := TSQL.New(SQL_SELECT).Parse([], Beautify);
end;

class function TDAOAutoIncScriptMock.New: IDAOAutoIncScript;
begin
  Result := TDAOAutoIncScriptMock.Create;
end;

end.
