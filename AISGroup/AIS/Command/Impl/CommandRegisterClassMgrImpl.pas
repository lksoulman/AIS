unit CommandRegisterClassMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-6
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  CommandImpl,
  CommandPerm,
  CommonRefCounter,
  Generics.Collections,
  CommandRegisterClassMgr;

type

  // 命令注册类管理
  TCommandRegisterClassMgrImpl = class(TAutoInterfacedObject, ICommandRegisterClassMgr)
  private
    // 命令注册类字典
    FCommandRegisterClassDic: TDictionary<Integer, TCommandPerm>;
  protected
    // 添加注册类
    procedure DoAddRegisterClass(ACommandID: Integer; ACommandPerm: TCommandPerm);
  public
    // 构造函数
    constructor Create; override;
    // 析构函数
    destructor Destroy; override;

    { ICommandRegisterClassMgr }

    // 注册所有命令
    function RegisterCommandClasses: Boolean;
    // 获取命令注册类
    function GetCommandClassByID(AID: Integer; var ACommandPerm: TCommandPerm): boolean;
  end;

implementation

{ TCommandRegisterClassMgrImpl }

constructor TCommandRegisterClassMgrImpl.Create;
begin
  inherited;
  FCommandRegisterClassDic := TDictionary<Integer, TCommandPerm>.Create(100);
end;

destructor TCommandRegisterClassMgrImpl.Destroy;
begin
  FCommandRegisterClassDic.Free;
  inherited;
end;

procedure TCommandRegisterClassMgrImpl.DoAddRegisterClass(ACommandID: Integer; ACommandPerm: TCommandPerm);
begin
  if not FCommandRegisterClassDic.ContainsKey(ACommandID) then begin
    FCommandRegisterClassDic.AddOrSetValue(ACommandID, ACommandPerm);
  end else begin

  end;
end;

function TCommandRegisterClassMgrImpl.RegisterCommandClasses: Boolean;
begin

end;

function TCommandRegisterClassMgrImpl.GetCommandClassByID(AID: Integer; var ACommandPerm: TCommandPerm): boolean;
begin
  if FCommandRegisterClassDic.TryGetValue(AID, ACommandPerm)
    and (ACommandPerm <> nil) then begin
    Result := True;
  end else begin
    Result := False;
  end;
end;

end.
