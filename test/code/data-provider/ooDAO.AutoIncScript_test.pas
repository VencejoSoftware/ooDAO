{
  Copyright (c) 2016, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit ooDAO.AutoIncScript_test;

interface

uses
  SysUtils, Forms,
  ooDAO.AutoIncScript.Intf, ooDAO.AutoIncScript_Mock,
{$IFDEF FPC}
  fpcunit, testregistry
{$ELSE}
  TestFramework
{$ENDIF};

type
  TDAOAutoIncScriptTest = class(TTestCase)
  published
    procedure ConsumeIsSQL;
    procedure SelectIsSQL;
  end;

implementation

procedure TDAOAutoIncScriptTest.ConsumeIsSQL;
var
  Script: String;
begin
  Script := TDAOAutoIncScriptMock.New.Consume(nil);
  CheckEquals('UPDATE {{ENTITY.SEQUENCES}} SET AUTOINC = AUTOINC + 1;', Script);
end;

procedure TDAOAutoIncScriptTest.SelectIsSQL;
var
  Script: String;
begin
  Script := TDAOAutoIncScriptMock.New.Select(nil);
  CheckEquals('SELECT AUTOINC FROM {{ENTITY.SEQUENCES}};', Script);
end;

initialization

RegisterTest(TDAOAutoIncScriptTest {$IFNDEF FPC}.Suite {$ENDIF});

end.
