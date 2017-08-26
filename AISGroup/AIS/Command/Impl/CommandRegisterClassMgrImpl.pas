unit CommandRegisterClassMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-6
// Comments��
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

  // ����ע�������
  TCommandRegisterClassMgrImpl = class(TAutoInterfacedObject, ICommandRegisterClassMgr)
  private
    // ����ע�����ֵ�
    FCommandRegisterClassDic: TDictionary<Integer, TCommandPerm>;
  protected
    // ���ע����
    procedure DoAddRegisterClass(ACommandID: Integer; ACommandPerm: TCommandPerm);
  public
    // ���캯��
    constructor Create; override;
    // ��������
    destructor Destroy; override;

    { ICommandRegisterClassMgr }

    // ע����������
    function RegisterCommandClasses: Boolean;
    // ��ȡ����ע����
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
