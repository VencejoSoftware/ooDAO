{
  Copyright (c) 2016, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit ooDAO.DataProvider.List.Intf;

interface

uses
  SysUtils,
  ooDAO.DataProvider.Intf;

type
  EDAODataProviderList = class(Exception)
  end;

  IDAODataProviderList = interface
    ['{78E6648C-448E-4B18-A7B5-F3855DC855E8}']
    function Add(const Item: IDAODataProviderAbstract): Integer;
    function Find(const EntityClass: TClass): IDAODataProviderAbstract;
  end;

implementation

end.
