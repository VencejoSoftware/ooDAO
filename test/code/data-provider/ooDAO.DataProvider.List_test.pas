unit ooDAO.DataProvider.List_test;

interface

uses
  SysUtils, Forms,
  ooFS.Archive, ooFS.Archive.Delete,
  ooDataInput.Intf, ooMock.DataInput,
  ooDAO.Connection.Intf, ooDAO.Connection.Firebird,
  ooDAO.Connection.Settings, ooDAO.Connection.Firebird.Settings,
  ooEntity.Mock,
  ooDAO.DataProvider.Mock, ooDAO.DataProvider.List,
{$IFDEF FPC}
  fpcunit, testregistry
{$ELSE}
  TestFramework
{$ENDIF};

type
  TDAODataProviderListTest = class(TTestCase)
  published
    procedure Test1;
  end;

implementation

procedure TDAODataProviderListTest.Test1;
var
  p: TDAODataProviderList;
  DAODataProvider: IDAODataProviderMock;
begin
  p := TDAODataProviderList.Create;
  DAODataProvider := TDAODataProviderMock.New(nil);
  try
    p.Add<IDAODataProviderMock>(DAODataProvider);
  finally
    p.Free;
  end;
end;

initialization

RegisterTest(TDAODataProviderListTest {$IFNDEF FPC}.Suite {$ENDIF});

end.
