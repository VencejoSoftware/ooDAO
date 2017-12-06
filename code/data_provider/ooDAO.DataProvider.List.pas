{
  Copyright (c) 2016, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit ooDAO.DataProvider.List;

interface

uses
  Classes, SysUtils,
  Generics.Collections,
  ooDAO.DataProvider.Intf,
  ooDAO.DataProvider.List.Intf;

type
  TDAODataProviderList = class sealed(TInterfaceList, IDAODataProviderList)
  strict private
  type
    _TDataProviderList = TList<IDAODataProviderAbstract>;
  strict private
    _List: _TDataProviderList;
  public
    function Add(const Item: IDAODataProviderAbstract): Integer;
    function Find(const EntityClass: TClass): IDAODataProviderAbstract;

    constructor Create;
    destructor Destroy; override;

    class function New: IDAODataProviderList;
  end;

implementation

function TDAODataProviderList.Add(const Item: IDAODataProviderAbstract): Integer;
begin
  if _List.IndexOf(Item) > - 1 then
    raise EDAODataProviderList.Create(Format('DataProvider for "%s" already exists!', [Item.EntityClass.ClassName]))
  else
    Result := _List.Add(Item);
end;

function TDAODataProviderList.Find(const EntityClass: TClass): IDAODataProviderAbstract;
var
  DAODataProviderAbstract: IDAODataProviderAbstract;
begin
  Result := nil;
  for DAODataProviderAbstract in _List do
  begin
    if CompareText(DAODataProviderAbstract.EntityClass.ClassName, EntityClass.ClassName) = 0 then
    begin
      Result := DAODataProviderAbstract;
      Break;
    end;
  end;
end;

constructor TDAODataProviderList.Create;
begin
  _List := _TDataProviderList.Create;
end;

destructor TDAODataProviderList.Destroy;
begin
  _List.Free;
  inherited;
end;

class function TDAODataProviderList.New: IDAODataProviderList;
begin
  Result := Create;
end;

end.
