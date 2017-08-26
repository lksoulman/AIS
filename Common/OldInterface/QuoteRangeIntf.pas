unit QuoteRangeIntf;

interface
uses QuoteLibrary;
type
    SkipTypeEnum = (
  steSkipNone = $00000000,
  steSkipRange = $00000001);

  FetchTypeEnum =(
  ftFetchCurr = $00000000,
  ftFetchNext = $00000001,
  ftFetchPrev = $00000002,
  ftFetchFirst = $00000003);

   HisDataRec = packed record
    WNModule: Int64;
    SubParam: WideString;
    ModuleTitle: WideString;
    SkipType: SkipTypeEnum;
    Data1: OleVariant;
    Data2: OleVariant;
  end;

  IModuleHisMngr = interface(IUnknown)
    ['{095CA419-F225-4A26-A599-680B9866C01D}']
    procedure PushHistory(HisData: HisDataRec; CanBack: WordBool); safecall;
    function PopHisotry: HisDataRec; safecall;
    function Get_NextItem(): WideString; safecall;
    function NextCount: Integer; safecall;
    function Get_PrevItem(): WideString; safecall;
    function PrevCount: Integer; safecall;
    procedure GotoHistory(Index: Integer; GotoNext: WordBool); safecall;
    procedure SkipHistory(WNModule: Integer; SkipType: SkipTypeEnum); safecall;
  end;

  IQuoteRangeCookie = interface(IUnknown)
    ['{9667C8CB-9973-47CA-A720-18458D0C8C3B}']
    function StockFromRange(FetchType: FetchTypeEnum; NBBM: Integer; Count: Integer;
                            out Stock: OleVariant): WordBool; safecall; //�����ð���ȡ֤ȯ��Count > 1 ���ؽ��StockΪ IIntegerList��
    function StockFromBesc(FetchType: FetchTypeEnum; NBBM: Integer; Count: Integer;
                           out Stock: OleVariant): WordBool; safecall;  //��ȫ�г���ȡ֤ȯ  ��Count > 1 ���ؽ��StockΪ IIntegerList��
    function Get_ActiveRangeList: IIntegerList; safecall;               //��ȡ�������List
    function Get_Cookie: Integer; safecall;
    procedure ChangeHQRange(const RangeID: WideString; const RangeList: IIntegerList); safecall; //���ð����֤ȯ
    function Get_ActiveRangeID: WideString; safecall;                  //��ȡ��ǰ����ID
  end;



implementation



end.
