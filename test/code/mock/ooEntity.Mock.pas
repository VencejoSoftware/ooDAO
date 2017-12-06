{
  Copyright (c) 2016, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit ooEntity.Mock;

interface

uses
  SysUtils,
  Generics.Collections,
  ooTextKey,
  ooDataInput.Intf, ooDataOutput.Intf,
  ooEntity.Intf;

type
  IEntityMock = interface(IEntity)
    ['{BAF94D3C-1CD5-4B86-BD46-FC261CFD3835}']
    function ID: Integer;
    function Value: String;
  end;

  TEntityMock = class sealed(TInterfacedObject, IEntityMock, IEntity)
  strict private
    _ID: Integer;
    _Value: string;
  public
    function ID: Integer;
    function Value: String;
    function Marshal(const DataOutput: IDataOutput): Boolean;
    function Unmarshal(const DataInput: IDataInput): Boolean;
    constructor Create(const ID: Integer; const Value: String);
    class function New(const ID: Integer; const Value: String): IEntityMock;
  end;

  TEntityMockList = TList<IEntityMock>;

implementation

function TEntityMock.ID: Integer;
begin
  Result := _ID;
end;

function TEntityMock.Value: String;
begin
  Result := _Value;
end;

constructor TEntityMock.Create(const ID: Integer; const Value: String);
begin
  _ID := ID;
  _Value := Value;
end;

function TEntityMock.Unmarshal(const DataInput: IDataInput): Boolean;
begin
  _ID := DataInput.ReadInteger(TTextKey.New('ID'));
  _Value := DataInput.ReadString(TTextKey.New('FIELD1'));
  Result := True;
end;

function TEntityMock.Marshal(const DataOutput: IDataOutput): Boolean;
begin
  DataOutput.WriteInteger(TTextKey.New('ID'), _ID);
  DataOutput.WriteString(TTextKey.New('FIELD1'), _Value);
  Result := True;
end;

class function TEntityMock.New(const ID: Integer; const Value: String): IEntityMock;
begin
  Result := TEntityMock.Create(ID, Value);
end;

end.
