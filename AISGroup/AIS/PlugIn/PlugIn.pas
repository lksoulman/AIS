unit PlugIn;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-16
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

  IPlugIn = Interface(IInterface)
    ['{F436FEEF-B7E4-4DBE-8615-F4A1CE553B94}']
    // ��ʼ����Ҫ����Դ
    procedure Initialize(AContext: IAppContext); safecall;
    // �ͷŲ���Ҫ����Դ
    procedure UnInitialize; safecall;
    // �ǲ�����Ҫͬ�����ز���
    function IsNeedSync: WordBool; safecall;
    // ͬ��ʵ��
    procedure SyncExecuteOperate; safecall;
    // �첽ʵ�ֲ���
    procedure AsyncExecuteOperate; safecall;
    // ���������
    function PlugInClassName: WideString; safecall;
  end;

implementation

end.

