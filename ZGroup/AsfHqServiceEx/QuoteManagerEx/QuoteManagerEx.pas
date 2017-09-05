unit QuoteManagerEx;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-27
// Comments：
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

  // 服务器类型数组
  TServerTypeEnumDynArray = Array of ServerTypeEnum;

  // 行情接口
  IQuoteManagerEx = interface
    ['{61F0BC22-EE1F-4BA3-B79A-260ACC0F7F5D}']
    // 获取是不是激活
    function GetActive: WordBool; safecall;
    // 获取
    function GetTypeLib: ITypeLib; safecall;
    // 获取是不是港股实时
    function GetIsHKReal: Boolean; safecall;
    // 获取是不是 Level2
    function GetIsLevel2(AInnerCode: Integer): Boolean; safecall;
    // 连接消息客户端
    procedure ConnectMessage(const QuoteMessage: IQuoteMessage); safecall;
    // 取消消息客户端的连接
    procedure DisconnectMessage(const QuoteMessage: IQuoteMessage); safecall;
    // 获取行情服务器类型对应的名称
    function GetServerTypeName(AServerType: ServerTypeEnum): WideString; safecall;
    // 获取行情服务器连接状态
    function GetServerTypeConnected(AServerTypes: TServerTypeEnumDynArray): WordBool; safecall;
    // 获取 InnerCode 对应的 CodeInfo
    function GetCodeInfoByInnerCode(AInnerCode: Int64; ACodeInfo: Int64): Boolean; safecall;
    // 获取 InnerCodes 对应的 CodeInfos
    function GetCodeInfosByInnerCodes(AInnerCodes: Int64; ACount: Integer): IQuoteCodeInfosEx; safecall;
    // CodeInfo 转 InnerCode
    procedure CodeInfo2InnerCode(ACodeInfos: Int64; Count: Integer; AInnerCodes: Int64); safecall;
    // 获取行情数据
    function QueryData(QuoteType: QuoteTypeEnum; pCodeInfo: Int64): IUnknown; safecall;
    // 订阅数据
    function Subscribe(QuoteType: QuoteTypeEnum; pCodeInfos: Int64; Count: Integer; Cookie: Integer; Value: OleVariant): WordBool; safecall;
  end;

implementation

end.
