{
  Copyright (c) 2016, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit ooMock.DataInput;

interface

uses
  SysUtils,
  ooKey.Intf,
  ooDataInput.Intf;

type
  TMockDataInput = class sealed(TInterfacedObject, IDataInput)
  private
    _ID: Integer;
    _Value: String;
  public
    function IsNull(const Key: IKey): Boolean;
    function ReadInteger(const Key: IKey): Integer;
    function ReadBoolean(const Key: IKey): Boolean;
    function ReadFloat(const Key: IKey): Extended;
    function ReadString(const Key: IKey): String;
    function ReadDateTime(const Key: IKey): TDateTime;
    function ReadChar(const Key: IKey): Char;

    constructor Create(const ID: Integer; const Value: String);
    class function New(const ID: Integer; const Value: String): IDataInput;
  end;

implementation

function TMockDataInput.ReadBoolean(const Key: IKey): Boolean;
begin
  Result := (ReadString(Key) = '1');
end;

function TMockDataInput.ReadChar(const Key: IKey): Char;
begin
  Result := ReadString(Key)[1];
end;

function TMockDataInput.ReadDateTime(const Key: IKey): TDateTime;
begin
  Result := StrToDateTime(ReadString(Key));
end;

function TMockDataInput.ReadFloat(const Key: IKey): Extended;
begin
  Result := StrToFloat(ReadString(Key));
end;

function TMockDataInput.ReadInteger(const Key: IKey): Integer;
begin
  Result := StrToInt(ReadString(Key));
end;

function TMockDataInput.ReadString(const Key: IKey): String;
begin
  if Key.AsString = 'ID' then
    Result := IntToStr(_ID)
  else
    Result := _Value
end;

constructor TMockDataInput.Create(const ID: Integer; const Value: String);
begin
  _ID := ID;
  _Value := Value;
end;

function TMockDataInput.IsNull(const Key: IKey): Boolean;
begin
  Result := _ID < 0;
end;

class function TMockDataInput.New(const ID: Integer; const Value: String): IDataInput;
begin
  Result := Create(ID, Value);
end;

end.
