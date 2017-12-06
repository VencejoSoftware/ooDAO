{
  Copyright (c) 2016, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit ooDAO.DataProvider.Mock;

interface

uses
  ooDAO.Connection.Intf,
  ooDAO.DataProvider,
  ooDAO.EntityScript.Mock,
  ooEntity.Mock;

type
  IDAODataProviderMock = IDAODataProvider<IEntityMock>;

  TDAODataProviderMock = class(TDAODataProvider<IEntityMock>, IDAODataProviderMock)
  protected
    function NewEntity: IEntityMock; override;
  public
    class function New(const Connection: IDAOConnection): IDAODataProviderMock;
  end;

implementation

function TDAODataProviderMock.NewEntity: IEntityMock;
begin
  Result := TEntityMock.New(0, '');
end;

class function TDAODataProviderMock.New(const Connection: IDAOConnection): IDAODataProviderMock;
begin
  Result := TDAODataProviderMock.Create(Connection, TDAOEntityMockScripts.New);
end;

end.
