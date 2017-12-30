{
  Copyright (c) 2016, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit ooDAO.AutoIncScript.Intf;

interface

uses
  ooFilter;

type
  IDAOAutoIncScript = interface
    ['{83170874-567D-4BF0-9CB3-106D308C2651}']
    function Consume(const Filter: IFilter): String;
    function Select(const Filter: IFilter): String;
  end;

implementation

end.
