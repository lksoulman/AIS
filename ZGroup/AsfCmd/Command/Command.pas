unit Command;

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
  AppContext;

type

  // ����ӿ�
  ICommand = Interface(IInterface)
    ['{64B65307-CF3E-40E6-9E46-935D0C56922F}']
    // ��ʼ����Ҫ����Դ
    procedure Initialize(AContext: IAppContext); safecall;
    // �ͷŲ���Ҫ����Դ
    procedure UnInitialize; safecall;
    // ���ü���
    procedure SetActive; safecall;
    // ���÷Ǽ���
    procedure SetNoActive; safecall;
    // ����ִ�з���
    procedure ExecCommand(APermMask: Integer; AParams: WideString); safecall;
  end;

implementation

end.
