unit AppContext;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-10
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  LoginMgr,
  CipherMgr,
  CacheType,
  FastLogLevel,
  WNDataSetInf,
  PermissionMgr,
  GFDataMngr_TLB;

type

  // GF ������������
  TGFType = (gtBaseData,       // ��������
             gtAssetData       // �ʲ�����
             );

  IAppContext = Interface(IInterface)
    ['{919A20C7-3242-4DBB-81F7-18EF05813380}']
    // �˳�Ӧ�ó���
    procedure ExitApp; safecall;
    // ����Ӧ�ó���
    procedure ReStartApp; safecall;
    // ��ȡ���ýӿ�
    function GetConfig: IInterface; safecall;
    // ��ȡ��¼�ӿ�
    function GetLoginMgr: IInterface; safecall;
    // ��ȡ���ܽ��ܽӿ�
    function GetCipherMgr: IInterface; safecall;
    // ��ȡϵͳ��Ϣ����ӿ�
    function GetMsgServices: IInterface; safecall;
    // ��ȡ��������
    function GetServiceBase: IInterface; safecall;
    // ��ȡ�ʲ�����
    function GetServiceAsset: IInterface; safecall;
    // ��ȡȨ�޹���ӿ�
    function GetPermissionMgr: IInterface; safecall;
    // ע��ӿ�
    procedure RegisterInterface(AGUID: TGUID; const AObj: IUnknown); safecall;
    // ж�ؽӿ�
    procedure UnRegisterInterface(AGUID: TGUID); safecall;
    // ��ѯ�ӿ�
    function QueryInterface(AGUID: TGUID): IUnknown; safecall;
    // ����û���Ϊ����
    procedure AddBehavior(ABehavior: WideString); safecall;
    // ������־���
    procedure HQLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
    // ��ҳ��־���
    procedure WebLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
    // Ӧ��ϵͳ��־���
    procedure AppLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
    // ָ����־���
    procedure IndicatorLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
    // Cache���ݻ�ȡ�ӿ�
    function SyncCacheQueryData(ACacheType: TCacheType; ASql: WideString): IWNDataSet; safecall;
    // GF �첽���ݲ�ѯ����
    function GFASyncQueryData(AGFType: TGFType; ASql: WideString; ADataArrive: Int64; ATag: Int64): IGFData; safecall;
    // GF ͬ�����ݲ�ѯ����
    function GFSyncQueryData(AGFType: TGFType; ASQL: WideString; ATag: Int64; AWaitTime: DWORD): IWNDataSet; safecall;
    // GF ͬ�������ȼ����ݲ�ѯ����
    function GFSyncQueryHighData(AGFType: TGFType; ASQL: WideString; ATag: Int64; AWaitTime: DWORD): IWNDataSet; safecall;
  end;

implementation

end.
