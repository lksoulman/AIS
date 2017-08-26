unit CommandRegisterClassMgr;

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
  CommandPerm;

type

  ICommandRegisterClassMgr = Interface(IInterface)
    ['{9D8F5D50-FA9D-4FE6-AB74-1CD9FEDCD57B}']
    // ע����������
    function RegisterCommandClasses: Boolean;
    // ��ȡ����ע����
    function GetCommandClassByID(AID: Integer; var ACommandPerm: TCommandPerm): boolean;
  end;

  var
    // ȫ������ע��������
    G_CommandRegisterClassMgr: ICommandRegisterClassMgr;

implementation

uses
  CommandRegisterClassMgrImpl;

initialization

  if G_CommandRegisterClassMgr = nil then begin
    G_CommandRegisterClassMgr := TCommandRegisterClassMgrImpl.Create as ICommandRegisterClassMgr;
    G_CommandRegisterClassMgr.RegisterCommandClasses;
  end;

finalization

  if G_CommandRegisterClassMgr <> nil then begin
    G_CommandRegisterClassMgr := nil;
  end;

end.
