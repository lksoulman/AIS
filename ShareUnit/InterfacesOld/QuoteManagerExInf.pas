unit QuoteManagerExInf;

interface

uses
  QuoteMngr_Tlb, Winapi.ActiveX;

type
  IQuoteCodeInfosEx = Interface
    ['{A7EE98C5-CFD6-4D54-BC8E-94508567DAD4}']
    function Count: Integer; safecall;
    function GetCodeInfo(Index: Integer): Int64; safecall;
    function GetInnerCode(Index: Integer): Integer; safecall;
  End;

  IQuoteManagerEx = interface
    ['{61F0BC22-EE1F-4BA3-B79A-260ACC0F7F5D}']
    function Get_Active: WordBool; safecall;
    procedure ConnectMessage(const QuoteMessage: IQuoteMessage); safecall;
    procedure DisconnectMessage(const QuoteMessage: IQuoteMessage); safecall;
    function Subscribe(QuoteType: QuoteTypeEnum; pCodeInfos: Int64; Count: Integer; Cookie: Integer; Value: OleVariant)
      : WordBool; safecall;
    function QueryData(QuoteType: QuoteTypeEnum; pCodeInfo: Int64): IUnknown; safecall;
    procedure ConnectServerInfo(ServerType: ServerTypeEnum; var IP: WideString; var Port: Word); safecall;
    function Get_Connected(ServerType: ServerTypeEnum): WordBool; safecall;
    Function Get_QuoteTypeCount(): Integer; safecall;
    procedure Get_AllQuoteType(QuoteTypes: Int64; Count: Integer); safecall;
    Function Get_QuoteTypeName(ServerType: ServerTypeEnum): WideString; safecall;
    Function IsLevel2(InnerCode: Integer): Boolean; safecall;
    Function IsHKReal(): Boolean; safecall;
    Function GetTypeLib(): ITypeLib; safecall;
    Function GetCodeInfoByInnerCodes(InnerCodes: Int64; Count: Integer): IQuoteCodeInfosEx; safecall;
    Function GetCodeInfoByInnerCode(InnerCode: Int64; CodeInfo: Int64): Boolean; safecall;
    // Function GetCodeInfoBySecuCode(SecuCode:WideString;CodeInfo:Int64):Boolean;safecall;
    procedure CodeInfo2InnerCode(CodeInfos: Int64; Count: Integer; InnerCodes: Int64); safecall;
    procedure SetNeedInitCodeInfo(ANeedInit: Boolean); safecall;
    procedure UpdateConnectingToDisconnect; safecall;
  end;

implementation

end.
