{
  Copyright (c) 2016, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit ooDAO.EntityScript.Intf;

interface

uses
  ooFilter,
  ooEntity.Intf;

type
  IDAOEntityScript<T: IEntity> = interface
    ['{20D97EEE-95EB-4BC8-9A15-13C138B6D7F4}']
    function Select(const Entity: T; const Filter: IFilter): String;
    function SelectList(const Filter: IFilter): String;
    function Insert(const Entity: T): String;
    function Update(const Entity: T): String;
    function Delete(const Entity: T): String;
  end;

implementation

end.
