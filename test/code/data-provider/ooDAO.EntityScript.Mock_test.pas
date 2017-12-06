{
  Copyright (c) 2016, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit ooDAO.EntityScript.Mock_test;

interface

uses
  SysUtils, Forms,
  ooEntity.Mock, ooDAO.EntityScript.Mock,
{$IFDEF FPC}
  fpcunit, testregistry
{$ELSE}
  TestFramework
{$ENDIF};

type
  TDAOEntityScriptTest = class(TTestCase)
  published
    procedure SelectOfEntityMock;
    procedure SelectListOfEntityMock;
    procedure InsertOfEntityMock;
    procedure UpdateOfEntityMock;
    procedure DeleteOfEntityMock;
  end;

implementation

procedure TDAOEntityScriptTest.DeleteOfEntityMock;
var
  Script: String;
begin
  Script := TDAOEntityMockScripts.New.Delete(TEntityMock(TEntityMock.New(99, 'value test')));
  CheckEquals('DELETE FROM {{ENTITY.MOCK}} WHERE ID = 99;', Script);
end;

procedure TDAOEntityScriptTest.InsertOfEntityMock;
var
  Script: String;
begin
  Script := TDAOEntityMockScripts.New.Insert(TEntityMock(TEntityMock.New(99, 'value test')));
  CheckEquals('INSERT INTO {{ENTITY.MOCK}}(ID, FIELD1) VALUES (99, ''value test'');', Script);
end;

procedure TDAOEntityScriptTest.SelectListOfEntityMock;
var
  Script: String;
begin
  Script := TDAOEntityMockScripts.New.SelectList(nil);
  CheckEquals('SELECT ID, FIELD1 FROM {{ENTITY.MOCK}}', Script);
end;

procedure TDAOEntityScriptTest.SelectOfEntityMock;
var
  Script: String;
begin
  Script := TDAOEntityMockScripts.New.Select(TEntityMock(TEntityMock.New(99, 'value test')), nil);
  CheckEquals('SELECT ID, FIELD1 FROM {{ENTITY.MOCK}} WHERE ID = 99;', Script);
end;

procedure TDAOEntityScriptTest.UpdateOfEntityMock;
var
  Script: String;
begin
  Script := TDAOEntityMockScripts.New.Update(TEntityMock(TEntityMock.New(99, 'value test')));
  CheckEquals('UPDATE {{ENTITY.MOCK}} SET FIELD1 = ''value test'' WHERE ID = 99;', Script);
end;

initialization

RegisterTest(TDAOEntityScriptTest {$IFNDEF FPC}.Suite {$ENDIF});

end.
