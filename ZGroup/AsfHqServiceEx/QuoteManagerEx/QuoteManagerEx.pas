unit QuoteManagerEx;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-27
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  ActiveX,
  Windows,
  Classes,
  SysUtils,
  QuoteMngr_TLB,
  QuoteCodeInfosEx;

type

  // ��������������
  TServerTypeEnumDynArray = Array of ServerTypeEnum;

  // ����ӿ�
  IQuoteManagerEx = interface
    ['{61F0BC22-EE1F-4BA3-B79A-260ACC0F7F5D}']
    // ��ȡ�ǲ��Ǽ���
    function GetActive: WordBool; safecall;
    // ��ȡ
    function GetTypeLib: ITypeLib; safecall;
    // ��ȡ�ǲ��Ǹ۹�ʵʱ
    function GetIsHKReal: Boolean; safecall;
    // ��ȡ�ǲ��� Level2
    function GetIsLevel2(AInnerCode: Integer): Boolean; safecall;
    // ������Ϣ�ͻ���
    procedure ConnectMessage(const QuoteMessage: IQuoteMessage); safecall;
    // ȡ����Ϣ�ͻ��˵�����
    procedure DisconnectMessage(const QuoteMessage: IQuoteMessage); safecall;
    // ��ȡ������������Ͷ�Ӧ������
    function GetServerTypeName(AServerType: ServerTypeEnum): WideString; safecall;
    // ��ȡ�������������״̬
    function GetServerTypeConnected(AServerTypes: TServerTypeEnumDynArray): WordBool; safecall;
    // ��ȡ InnerCode ��Ӧ�� CodeInfo
    function GetCodeInfoByInnerCode(AInnerCode: Int64; ACodeInfo: Int64): Boolean; safecall;
    // ��ȡ InnerCodes ��Ӧ�� CodeInfos
    function GetCodeInfosByInnerCodes(AInnerCodes: Int64; ACount: Integer): IQuoteCodeInfosEx; safecall;
    // CodeInfo ת InnerCode
    procedure CodeInfo2InnerCode(ACodeInfos: Int64; Count: Integer; AInnerCodes: Int64); safecall;
    // ��ȡ��������
    function QueryData(QuoteType: QuoteTypeEnum; pCodeInfo: Int64): IUnknown; safecall;
    // ��������
    function Subscribe(QuoteType: QuoteTypeEnum; pCodeInfos: Int64; Count: Integer; Cookie: Integer; Value: OleVariant): WordBool; safecall;
  end;

implementation

end.
