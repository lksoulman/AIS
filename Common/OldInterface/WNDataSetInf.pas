unit WNDataSetInf;

interface
type
  Largeuint = Int64;

  FieldTypeEnum = (
  fteInteger,
  fteInteger64,
  fteFloat,
  fteDatetime,
  fteChar,
  fteVarchar,
  fteImage,
  fteBool,
  fteBcd,
  fteblob);

  WNDSStatusEnum =(
  edsNORMAL,
  edsAPPEND,
  edsEDIT);

  SourceOfFieldAliaEnum =(
  sfnINTERNALFIELDNAME,
  sfnFIELDDESCRIPT);


  WNGBCD = packed record
    Sign: Shortint;
    Scale: Shortint;
    LoVal: Largeuint;
    HiVal: Largeuint;
  end;

  WNMyBCD = packed record
    Scale: Shortint;
    Val: Int64;
  end;
  MyB = WideString;

  IWNField = interface(IUnknown)
   ['{8986B94D-30BB-41B6-9725-FCA0E90F44C2}']
    function Get_FieldName: WideString; safecall;
    function Get_FieldType: FieldTypeEnum; safecall;
    function Get_FieldSize: Integer; safecall;
    function Get_DataSize: Integer; safecall;
    function Get_AsFloat: Double; safecall;
    function Get_AsBoolean: WordBool; safecall;
    function Get_AsDateTime: Double; safecall;
    function Get_AsString: MyB; safecall;
    function Get_AsInt64: Int64; safecall;
    function Get_AsInteger: Integer; safecall;
    function Get_AsValue: OleVariant; safecall;
    function Get_FieldDesc: WideString; safecall;
    function Get_AsStream: IUnknown; safecall;
    procedure Set_AsFloat(Value: Double); safecall;
    procedure Set_AsBoolean(Value: WordBool); safecall;
    procedure Set_AsDateTime(Value: Double); safecall;
    procedure Set_AsString(const Value: MyB); safecall;
    procedure Set_AsInt64(Value: Int64); safecall;
    procedure Set_AsInteger(Value: Integer); safecall;
    procedure Set_AsValue(Value: OleVariant); safecall;
    procedure Set_AsStream(const Value: IUnknown); safecall;
    function Get_IsNull: WordBool; safecall;
    procedure Clear; safecall;
    function ReadToBuffer(pBuffer: Integer): Integer; safecall;
    procedure WriteFromBuffer(pBuffer: Integer; DataLen: Integer); safecall;
    function Get_AsMyBCD: WNMyBCD; safecall;
    procedure Set_AsMyBCD(Value: WNMyBCD); safecall;
    function Get_NumberScale: Integer; safecall;
    function Get_FieldOriginalName: WideString; safecall;
    function Get_AsGBCD: WNGBCD; safecall;
    procedure Set_AsGBCD(Value: WNGBCD); safecall;
    property FieldName: WideString read Get_FieldName;
    property FieldType: FieldTypeEnum read Get_FieldType;
    property FieldSize: Integer read Get_FieldSize;
    property DataSize: Integer read Get_DataSize;
    property AsFloat: Double read Get_AsFloat write Set_AsFloat;
    property AsBoolean: WordBool read Get_AsBoolean write Set_AsBoolean;
    property AsDateTime: Double read Get_AsDateTime write Set_AsDateTime;
    property AsString: MyB read Get_AsString write Set_AsString;
    property AsInt64: Int64 read Get_AsInt64 write Set_AsInt64;
    property AsInteger: Integer read Get_AsInteger write Set_AsInteger;
    property AsValue: OleVariant read Get_AsValue write Set_AsValue;
    property FieldDesc: WideString read Get_FieldDesc;
    property AsStream: IUnknown read Get_AsStream write Set_AsStream;
    property IsNull: WordBool read Get_IsNull;
    property AsMyBCD: WNMyBCD read Get_AsMyBCD write Set_AsMyBCD;
    property NumberScale: Integer read Get_NumberScale;
    property FieldOriginalName: WideString read Get_FieldOriginalName;
    property AsGBCD: WNGBCD read Get_AsGBCD write Set_AsGBCD;
  end;

  IWNDataSet = interface(IUnknown)
    ['{67C77CE5-FDA5-404A-87E2-13A57F143EFA}']
    procedure First; safecall;
    procedure Last; safecall;
    procedure Prior; safecall;
    procedure Next; safecall;
    function Get_RecordCount: Integer; safecall;
    function Get_IndexNames: WideString; safecall;
    procedure Set_IndexNames(const Value: WideString); safecall;
    function Get_FieldCount: Integer; safecall;
    function Get_RecNo: Integer; safecall;
    procedure Set_RecNo(Value: Integer); safecall;
    function Get_Bof: WordBool; safecall;
    function Get_Eof: WordBool; safecall;
    function Fields(Index: Integer): IWNField; safecall;
    function FieldByName(const FieldName: WideString): IWNField; safecall;
    function Get_ReversInterface: IUnknown; safecall;
    procedure Set_ReversInterface(const Value: IUnknown); safecall;
    function Get_ReversValue: OleVariant; safecall;
    procedure Set_ReversValue(Value: OleVariant); safecall;
    procedure FilterByBitMapString(const FieldName: WideString; const BitMapString: WideString;
                                   IsIn: WordBool); safecall;
    function Get_Filter: WideString; safecall;
    procedure Set_Filter(const Value: WideString); safecall;
    function Locate(const FieldName: WideString; const FieldValue: WideString): WordBool; safecall;
    function Get_SortFieldsName: WideString; safecall;
    procedure Set_SortFieldsName(const Value: WideString); safecall;
    function Get_DataAsStream: IUnknown; safecall;
    function Get_Status: WNDSStatusEnum; safecall;
    procedure Append; safecall;
    procedure Edit; safecall;
    procedure Delete; safecall;
    procedure Post; safecall;
    procedure Cancel; safecall;
    function SaveToStream: IUnknown; safecall;
    procedure LoadFromStream(const InStream: IUnknown; SourceOfFieldName: SourceOfFieldAliaEnum); safecall;
    function CloneStruct: IWNDataSet; safecall;
    procedure AddField(Type_: FieldTypeEnum; Length: Integer; Scale: Integer;
                       const Name: WideString; const Descript: WideString); safecall;
    function CloneDataSet: IWNDataSet; safecall;
    function FindField(const FieldName: WideString): IWNField; safecall;
    procedure LoadFromMemory(pMemory: Integer; Length: Integer;
                             SourceOfFieldName: SourceOfFieldAliaEnum); safecall;
    procedure CreateWNDataSet; safecall;
    procedure ReplaceAliaWithDesc; safecall;
    procedure EmptyDataSet; safecall;
    function SaveToBuffer(DataAddres: Integer; BufferLength: Integer): Integer; safecall;
    function Get_MaxDataLength: Integer; safecall;
    procedure SetDataFromAdoRecordSet(const inRecordSet: IDispatch; RecordCount: Integer); safecall;
    function SaveToFile(const FileName: WideString): Integer; safecall;
    function LoadFromFile(const FileName: WideString; SourceOfFieldName: SourceOfFieldAliaEnum): Integer; safecall;
    property RecordCount: Integer read Get_RecordCount;
    property IndexNames: WideString read Get_IndexNames write Set_IndexNames;
    property FieldCount: Integer read Get_FieldCount;
    property RecNo: Integer read Get_RecNo write Set_RecNo;
    property Bof: WordBool read Get_Bof;
    property Eof: WordBool read Get_Eof;
    property ReversInterface: IUnknown read Get_ReversInterface write Set_ReversInterface;
    property ReversValue: OleVariant read Get_ReversValue write Set_ReversValue;
    property Filter: WideString read Get_Filter write Set_Filter;
    property SortFieldsName: WideString read Get_SortFieldsName write Set_SortFieldsName;
    property DataAsStream: IUnknown read Get_DataAsStream;
    property Status: WNDSStatusEnum read Get_Status;
    property MaxDataLength: Integer read Get_MaxDataLength;
  end;
implementation

end.
