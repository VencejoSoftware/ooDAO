{
  Copyright (c) 2016, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit ooDAO.EntityScript.Logged;

interface

uses
  SysUtils,
  ooLogger.Intf, ooLog.Actor,
  ooFilter,
  ooEntity.Intf,
  ooDAO.EntityScript.Intf;

type
  IDAOEntityScriptLogged<T: IEntity> = interface(IDAOEntityScript<T>)
    ['{CCB8190C-FE37-41BA-B984-246C938CDE03}']
    function Select(const Entity: T; const Filter: IFilter): String;
    function SelectList(const Filter: IFilter): String;
    function Insert(const Entity: T): String;
    function Update(const Entity: T): String;
    function Delete(const Entity: T): String;
  end;

  TDAOEntityScriptLogged<T: IEntity> = class sealed(TInterfacedObject, IDAOEntityScriptLogged<T>)
  strict private
    _Script: IDAOEntityScript<T>;
    _LogActor: ILogActor;
    _ScriptClassName: String;
  public
    function Select(const Entity: T; const Filter: IFilter): String;
    function SelectList(const Filter: IFilter): String;
    function Insert(const Entity: T): String;
    function Update(const Entity: T): String;
    function Delete(const Entity: T): String;
    constructor Create(const Logger: ILogger; const Script: IDAOEntityScript<T>); reintroduce;
    class function New(const Logger: ILogger; const Script: IDAOEntityScript<T>): IDAOEntityScriptLogged<T>;
  end;

implementation

function TDAOEntityScriptLogged<T>.Select(const Entity: T; const Filter: IFilter): String;
begin
  Result := _Script.Select(Entity, Filter);
  _LogActor.LogDebug(Format('%s.Select=%s', [_ScriptClassName, Result]));
end;

function TDAOEntityScriptLogged<T>.SelectList(const Filter: IFilter): String;
begin
  Result := _Script.SelectList(Filter);
  _LogActor.LogDebug(Format('%s.SelectList=%s', [_ScriptClassName, Result]));
end;

function TDAOEntityScriptLogged<T>.Insert(const Entity: T): String;
begin
  Result := _Script.Insert(Entity);
  _LogActor.LogDebug(Format('%s.Insert=%s', [_ScriptClassName, Result]));
end;

function TDAOEntityScriptLogged<T>.Delete(const Entity: T): String;
begin
  Result := _Script.Delete(Entity);
  _LogActor.LogDebug(Format('%s.Delete=%s', [_ScriptClassName, Result]));
end;

function TDAOEntityScriptLogged<T>.Update(const Entity: T): String;
begin
  Result := _Script.Update(Entity);
  _LogActor.LogDebug(Format('%s.Update=%s', [_ScriptClassName, Result]));
end;

constructor TDAOEntityScriptLogged<T>.Create(const Logger: ILogger; const Script: IDAOEntityScript<T>);
begin
  _LogActor := TLogActor.New(Logger);
  _Script := Script;
  _ScriptClassName := TInterfacedObject(_Script).ClassName;
end;

class function TDAOEntityScriptLogged<T>.New(const Logger: ILogger; const Script: IDAOEntityScript<T>)
  : IDAOEntityScriptLogged<T>;
begin
  Result := TDAOEntityScriptLogged<T>.Create(Logger, Script);
end;

end.
