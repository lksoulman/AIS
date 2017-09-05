unit KeyFairySinkInf;

interface

uses WNDataSetInf;

type
  PKFSSecuInfo = ^TKFSSecuInfo;

  TKFSSecuInfo = packed record
    InnerCode: Integer;
    // CompanyCode: Integer;
    SecuCode: string;
    CodeSuffix: string; // 后缀
    SecuName: string;
    ChiSpelling: string; // 拼音
    Category: Integer; // 类别
    SecuMarket: Smallint; // 市场
    ListedState: Smallint; // 上市状态
    FormerName: string; // 曾用名
    FormerCode: string; // 曾用名拼音
  end;

  IKeyFairySink = interface
    ['{EA8910C5-5692-4A06-90EA-7369E55DCC8F}']
    function GetSinkID: WideString; safecall;
    function GetMaxCount: Integer; safecall;
    procedure SetMaxCount(Count: Integer); safecall;
    // function KeyFairyQuery(Key:string;Param:string):IWndataset;safecall;
    // 因为AppControllerInf已经引用了本单元,不能引用AppControllerInf,故传递Pointer类型,
    // 其实是StockInfoRec的指针
    procedure KeyFairyEnter(AStock: Pointer); safecall;
    function GetCaption: WideString; safecall;
    procedure SetOrder(Value: Integer); safecall;
    function GetOrder(): Integer; safecall;
    function GetIsSetOrder: WordBool; safecall;
    function GetIsActive: WordBool; safecall;
    procedure SetIsActive(Value: WordBool); safecall;
    function GetIsSecu: WordBool; safecall;

    function GetIsLoaded: WordBool; safecall;
    procedure SetIsLoaded(AIsLoaded: Boolean); safecall;
    procedure Load; safecall;
    procedure Lock; safecall;
    procedure UnLock; safecall;
    Function SecuCount: Integer; safecall;
    function GetSecuInfo(Index: Integer): PKFSSecuInfo; safecall;
    function GetSecuCategory(P: PKFSSecuInfo): WideString; safecall;
  end;

implementation

end.
