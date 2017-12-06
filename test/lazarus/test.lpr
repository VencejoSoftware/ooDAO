{
  Copyright (c) 2016, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
program test;

uses
  ooRunTest,
  ooDAO.DataProvider.Mock_test in '..\code\data-provider\ooDAO.DataProvider.Mock_test.pas',
  ooEntity.Mock in '..\code\mock\ooEntity.Mock.pas',
  ooMock.DataInput in '..\code\mock\ooMock.DataInput.pas',
  ooDAO.Connection.Firebird_test in '..\code\ooDAO.Connection.Firebird_test.pas',
  ooDAO.Connection.SQLite_test in '..\code\ooDAO.Connection.SQLite_test.pas',
  ooDAO.EntityScript.Mock in '..\code\mock\ooDAO.EntityScript.Mock.pas',
  ooDAO.DataProvider.Mock in '..\code\mock\ooDAO.DataProvider.Mock.pas',
  ooDAO.EntityScript.Mock_test in '..\code\data-provider\ooDAO.EntityScript.Mock_test.pas',
  ooDAO.DataQuery_test in '..\code\data-provider\ooDAO.DataQuery_test.pas';

{R *.RES}

begin
  Run;

end.
