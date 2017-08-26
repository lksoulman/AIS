unit KeyFairySinkInf;

interface

uses WNDataSetInf;

type
  PKFSSecuInfo = ^TKFSSecuInfo;

  TKFSSecuInfo = packed record
    InnerCode: Integer;
    // CompanyCode: Integer;
    SecuCode: string;
    CodeSuffix: string; // ��׺
    SecuName: string;
    ChiSpelling: string; // ƴ��
    Category: Integer; // ���
    SecuMarket: Smallint; // �г�
    ListedState: Smallint; // ����״̬
    FormerName: string; // ������
    FormerCode: string; // ������ƴ��
  end;

  IKeyFairySink = interface
    ['{EA8910C5-5692-4A06-90EA-7369E55DCC8F}']
    function GetSinkID: WideString; safecall;
    function GetMaxCount: Integer; safecall;
    procedure SetMaxCount(Count: Integer); safecall;
    // function KeyFairyQuery(Key:string;Param:string):IWndataset;safecall;
    // ��ΪAppControllerInf�Ѿ������˱���Ԫ,��������AppControllerInf,�ʴ���Pointer����,
    // ��ʵ��StockInfoRec��ָ��
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
