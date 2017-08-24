unit LoginUI;

interface

uses
  Windows,
  Classes,
  SysUtils,
  LoginMainUI;

type

  ILoginUI = Interface(IInterface)
    ['{6174EEEE-AACA-4DC3-B74A-8C8DD2EE0420}']
    // չʾ��¼������
    procedure ShowLoginMainUI; safecall;
    // չʾ�󶨴���
    procedure ShowLoginBindUI; safecall;
    // չʾ��¼��Ϣ
    procedure ShowLoginInfo(AMsg: WideString); safecall;
    // ���õ�¼�ص�����
    procedure SetLoginFunc(ALoginFunc: TCallBackLoginFunc); safecall;
  end;

implementation

end.
