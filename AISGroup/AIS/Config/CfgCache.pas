unit CfgCache;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-7-23
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

  // ���û���ӿ�
  ICfgCache = Interface(IInterface)
    ['{865B342F-C51B-40FA-82D0-3DEF0D058E73}']
    // ��ʼ����Ҫ����Դ
    procedure Initialize(AContext: IAppContext); safecall;
    // �ͷŲ���Ҫ����Դ
    procedure UnInitialize; safecall;
    // ���滺��
    procedure SaveCache; safecall;
    // �������û�������
    procedure LoadCfgCacheData; safecall;
    // �������û���Ŀ¼
    procedure SetCfgCachePath(APath: WideString); safecall;
    // ��ȡ����
    function GetValue(AKey: WideString): WideString; safecall;
    // ��������
    function SetValue(AKey, AValue: WideString): boolean; safecall;
  end;

implementation

end.
