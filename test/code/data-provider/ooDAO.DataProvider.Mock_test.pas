{
  Copyright (c) 2016, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit ooDAO.DataProvider.Mock_test;

interface

uses
  SysUtils, Forms,
  ooFS.Archive, ooFS.Archive.Delete,
  ooDataInput.Intf, ooMock.DataInput,
  ooDAO.Connection.Intf, ooDAO.Connection.Firebird,
  ooDAO.Connection.Settings, ooDAO.Connection.Firebird.Settings,
  ooEntity.Mock, ooDAO.DataProvider.Mock,
{$IFDEF FPC}
  fpcunit, testregistry
{$ELSE}
  TestFramework
{$ENDIF};

type
  TDAODataProviderTest = class(TTestCase)
  private
    _Connection: IDAOConnection;
    procedure CreateDB(const Settings: IConnectionFirebirdSettings);
    function DBPath: String;
    function ConnectionSettings: IConnectionFirebirdSettings;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
    procedure PrepareAmbient;
  published
    procedure BuildNewEntity;
    procedure SaveMock;
    procedure ModifyMock;
    procedure DeleteMock;
    procedure LoadMockList;
    procedure InsertListOnFiveItems;
  end;

implementation

procedure TDAODataProviderTest.BuildNewEntity;
var
  DAODataProvider: IDAODataProviderMock;
  Entity: IEntityMock;
begin
  DAODataProvider := TDAODataProviderMock.New(_Connection);
  Entity := DAODataProvider.NewEntity;
  CheckTrue(Assigned(Entity));
end;

procedure TDAODataProviderTest.CreateDB(const Settings: IConnectionFirebirdSettings);
begin
  TDAOConnectionFirebird.New(Settings).CreateDatabase;
end;

function TDAODataProviderTest.DBPath: String;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + 'db_dao_fb.fdb';
end;

procedure TDAODataProviderTest.SaveMock;
var
  MockList: TEntityMockList;
  DAODataProvider: IDAODataProviderMock;
  DataInput: IDataInput;
  Entity: IEntityMock;
begin
  MockList := TEntityMockList.Create;
  try
    DAODataProvider := TDAODataProviderMock.New(_Connection);
    DAODataProvider.SelectList(MockList, nil);
    CheckTrue(MockList.Count = 0);
    DataInput := TMockDataInput.New(99, 'test 99');
    Entity := TEntityMock.New(0, EmptyStr);
    Entity.Unmarshal(DataInput);
    DAODataProvider.Insert(Entity);
    DAODataProvider.SelectList(MockList, nil);
    CheckEquals(1, MockList.Count);
    CheckEquals('test 99', MockList[0].Value);
  finally
    MockList.Free;
  end;
end;

procedure TDAODataProviderTest.LoadMockList;
var
  i: Integer;
  MockList: TEntityMockList;
  DataInput: IDataInput;
  EntityMock: IEntityMock;
begin
  for i := 0 to 9 do
  begin
    DataInput := TMockDataInput.New(i, Format('test%d', [i]));
    EntityMock := TEntityMock.New(0, EmptyStr);
    EntityMock.Unmarshal(DataInput);
    TDAODataProviderMock.New(_Connection).Insert(EntityMock);
  end;
  MockList := TEntityMockList.Create;
  try
    TDAODataProviderMock.New(_Connection).SelectList(MockList, nil);
    CheckEquals(9, Pred(MockList.Count));
    CheckEquals('test9', MockList[9].Value);
  finally
    MockList.Free;
  end;
end;

procedure TDAODataProviderTest.ModifyMock;
var
  MockList: TEntityMockList;
  DAODataProvider: IDAODataProviderMock;
  DataInput: IDataInput;
  EntityMock: IEntityMock;
begin
  MockList := TEntityMockList.Create;
  try
    DAODataProvider := TDAODataProviderMock.New(_Connection);
    DataInput := TMockDataInput.New(1000, 'test 1000');
    EntityMock := TEntityMock.New(0, EmptyStr);
    EntityMock.Unmarshal(DataInput);
    DAODataProvider.Insert(EntityMock);
    DAODataProvider.SelectList(MockList, nil);
    CheckEquals('test 1000', MockList[0].Value);
    DataInput := TMockDataInput.New(1000, 'test modify');
    EntityMock := TEntityMock.New(0, EmptyStr);
    EntityMock.Unmarshal(DataInput);
    DAODataProvider.Update(EntityMock);
    DAODataProvider.SelectList(MockList, nil);
    CheckEquals('test modify', MockList[0].Value);
  finally
    MockList.Free;
  end;
end;

procedure TDAODataProviderTest.DeleteMock;
var
  MockList: TEntityMockList;
  DAODataProvider: IDAODataProviderMock;
  DataInput: IDataInput;
  EntityMock: IEntityMock;
begin
  MockList := TEntityMockList.Create;
  try
    DAODataProvider := TDAODataProviderMock.New(_Connection);
    DataInput := TMockDataInput.New(2000, 'test delete');
    EntityMock := TEntityMock.New(0, EmptyStr);
    EntityMock.Unmarshal(DataInput);
    DAODataProvider.Insert(EntityMock);
    DAODataProvider.SelectList(MockList, nil);
    CheckEquals('test delete', MockList[0].Value);
    DAODataProvider.Delete(MockList[0]);
    DAODataProvider.SelectList(MockList, nil);
    CheckEquals(0, MockList.Count);
  finally
    MockList.Free;
  end;
end;

procedure TDAODataProviderTest.InsertListOnFiveItems;
var
  MockList: TEntityMockList;
  DAODataProvider: IDAODataProviderMock;
begin
  MockList := TEntityMockList.Create;
  try
    MockList.Add(TEntityMock.Create(1, 'one'));
    MockList.Add(TEntityMock.Create(2, 'two'));
    MockList.Add(TEntityMock.Create(3, 'three'));
    MockList.Add(TEntityMock.Create(4, 'four'));
    MockList.Add(TEntityMock.Create(5, 'five'));
    DAODataProvider := TDAODataProviderMock.New(_Connection);
    DAODataProvider.InsertList(MockList);
    MockList.Clear;
    DAODataProvider.SelectList(MockList, nil);
    CheckEquals(5, MockList.Count);
  finally
    MockList.Free;
  end;
end;

function TDAODataProviderTest.ConnectionSettings: IConnectionFirebirdSettings;
const
  USER_NAME = 'sysdba';
  USER_PASS = 'masterkey';
begin
  Result := TConnectionFirebirdSettings.New(TConnectionSettings.New(USER_NAME, USER_PASS, DBPath, 'fbclient.dll'));
end;

procedure TDAODataProviderTest.PrepareAmbient;
var
  RowAffected: Integer;
begin
  _Connection.BeginTransaction;
  try
    _Connection.ExecuteSQL('DROP TABLE {{ENTITY.MOCK}};', RowAffected);
    _Connection.CommitTransaction;
  except
    _Connection.RollbackTransaction;
  end;
  _Connection.BeginTransaction;
  _Connection.ExecuteSQL('CREATE TABLE {{ENTITY.MOCK}}(ID INTEGER, FIELD1 VARCHAR(100));', RowAffected);
  _Connection.CommitTransaction;
  _Connection.BeginTransaction;
  _Connection.ExecuteSQL('DELETE FROM {{ENTITY.MOCK}};', RowAffected);
  _Connection.CommitTransaction;
end;

procedure TDAODataProviderTest.SetUp;
begin
  CreateDB(ConnectionSettings);
  _Connection := TDAOConnectionFirebird.New(ConnectionSettings);
  _Connection.Connect;
  PrepareAmbient;
  inherited;
end;

procedure TDAODataProviderTest.TearDown;
begin
  inherited;
  _Connection.Disconnect;
  TFSArchiveDelete.New(TFSArchive.New(nil, ConnectionSettings.DataBasePath)).Execute;
end;

initialization

RegisterTest(TDAODataProviderTest {$IFNDEF FPC}.Suite {$ENDIF});

end.
