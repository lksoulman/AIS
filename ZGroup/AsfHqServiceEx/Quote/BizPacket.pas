// 源文件名：BizPacket.pas
// 软件版权：恒生电子股份有限公司
// 系统名称：HSRCP
// 功能说明：业务包打包解包虚基类
// 作    者：何仲君
// 备    注：Tab = 2
// 历    史：
// 20071030 初始版本

unit BizPacket;

interface

uses
  Classes, Windows;

type
  // 字段虚基类
  TBizField = class(TObject)
  protected
    function GetFieldName: AnsiString; virtual; abstract;
    function GetFieldNo: Integer; virtual; abstract;
    function GetFieldType: AnsiChar; virtual; abstract;
    function GetWidth: Integer; virtual; abstract;
    function GetScale: Byte; virtual; abstract;
    function GetValue: OleVariant; virtual; abstract;
    procedure SetValue(Value: OleVariant); virtual; abstract;
  public
    property FieldName: AnsiString read GetFieldName;
    property FieldNo: Integer read GetFieldNo;
    property FieldType: AnsiChar read GetFieldType;
    property Width: Integer read GetWidth;
    property Scale: Byte read GetScale;
    property Value: OleVariant read GetValue write SetValue;
  end;

  // 结果集虚基类
  TBizDataset = class(TObject)
  protected
    function GetDatasetName: AnsiString; virtual; abstract;
    function GetDatasetNo: Integer; virtual; abstract;
    function GetColCount: Integer; virtual; abstract;
    function GetRowCount: Integer; virtual; abstract;
    function GetReturnCode: Integer; virtual; abstract;
    function GetField(varField: OleVariant): TBizField; virtual; abstract;
    function GetBOF: Boolean; virtual; abstract;
    function GetEOF: Boolean; virtual; abstract;
    function GetRowNo: Integer; virtual; abstract;
    function GetExist(const FieldName: AnsiString): Boolean; virtual; abstract;
  public
    // 相对移动记录
    procedure Move(nRows: Integer); virtual; abstract;
    // 移动到指定记录
    procedure Go(nRow: Integer); virtual; abstract;
    procedure MoveFirst; virtual; abstract;
    procedure MoveLast; virtual; abstract;
    procedure MoveNext; virtual; abstract;
    procedure MovePrev; virtual; abstract;
    property DatasetName: AnsiString read GetDatasetName;
    property DatasetNo: Integer read GetDatasetNo;
    property ColCount: Integer read GetColCount;
    property RowCount: Integer read GetRowCount;
    property ReturnCode: Integer read GetReturnCode;
    property Field[varField: OleVariant]: TBizField read GetField;
    property BOF: Boolean read GetBOF;
    property EOF: Boolean read GetEOF;
    property RowNo: Integer read GetRowNo;
    property Exist[const FieldName: AnsiString]: Boolean read GetExist;
  end;

  // 打包器虚基类
  TBizPacker = class(TObject)
  protected
    function GetData: Pointer; virtual; abstract;
    function GetDataLength: Integer; virtual; abstract;
    function GetField(varField: OleVariant): TBizField; virtual; abstract;
  public
    procedure BeginPack; virtual; abstract;
    procedure NewDataset(const DatasetName: AnsiString; ReturnCode: Integer = 0); virtual; abstract;
    procedure SetReturnCode(ReturnCode: Integer); virtual; abstract;
    procedure AddField(const FieldName: AnsiString; FieldType: AnsiChar; Width: Integer; Scale: Byte); virtual; abstract;
    /// 增加一个整数列信息
    (* *
      *@param  const FieldName: AnsiString		[in]列名称
      *@return int							该列的编号，-1表示错误
    *)
    procedure AddIntField(const FieldName: AnsiString); virtual; abstract;
    procedure AddFloatField(const FieldName: AnsiString; Scale: Byte = 3); virtual; abstract;
    procedure AddStringField(const FieldName: AnsiString; Width: Integer = 256); virtual; abstract;
    procedure AddRawField(const FieldName: AnsiString; Width: Integer); virtual; abstract;
    procedure EndPack; virtual; abstract;
    procedure NewLine; virtual; abstract;
    // 20081224 caozh add 根据解包器对象打包 ,解包器中如果有多条记录只解第一条记录，这个BizUnpacker 必须完成过Open,使用这个函数时先BeginPack,调完后，EndPack
    procedure CreateRequestPaker(BizUnpacker: TObject); virtual; abstract;
    property Data: Pointer read GetData;
    property DataLength: Integer read GetDataLength;
    property Field[varField: OleVariant]: TBizField read GetField;
  end;

  // 解包器虚基类
  TBizUnpacker = class(TObject)
  protected
    function GetVersion: Byte; virtual; abstract;
    function GetDatasetCount: Integer; virtual; abstract;
    function GetDataset(varDataset: OleVariant): TBizDataset; virtual; abstract;
    function GetDatasetName: AnsiString; virtual; abstract;
    function GetColCount: Integer; virtual; abstract;
    function GetRowCount: Integer; virtual; abstract;
    function GetReturnCode: Integer; virtual; abstract;
    function GetField(varField: OleVariant): TBizField; virtual; abstract;
    function GetBOF: Boolean; virtual; abstract;
    function GetEOF: Boolean; virtual; abstract;
    function GetRowNo: Integer; virtual; abstract;
    function GetExist(const FieldName: AnsiString): Boolean; virtual; abstract;
    // 20080617 caozh add
    function GetFieldName(iCount: Integer): AnsiString; virtual; abstract;
  public
    procedure Open(const Data: Pointer; DataLength: Integer); virtual; abstract;
    procedure SetCurrentDataset(varDataset: OleVariant); virtual; abstract;
    procedure Move(Rows: Integer); virtual; abstract;
    procedure Go(Row: Integer); virtual; abstract;
    procedure MoveFirst; virtual; abstract;
    procedure MoveLast; virtual; abstract;
    procedure MoveNext; virtual; abstract;
    procedure MovePrev; virtual; abstract;
    property Version: Byte read GetVersion;
    property DatasetCount: Integer read GetDatasetCount;
    property Dataset[varDataset: OleVariant]: TBizDataset read GetDataset;
    property DatasetName: AnsiString read GetDatasetName;
    property ColCount: Integer read GetColCount;
    property RowCount: Integer read GetRowCount;
    property ReturnCode: Integer read GetReturnCode;
    property Field[varField: OleVariant]: TBizField read GetField;
    property BOF: Boolean read GetBOF;
    property EOF: Boolean read GetEOF;
    property RowNo: Integer read GetRowNo;
    property Exist[const FieldName: AnsiString]: Boolean read GetExist;
  end;

implementation

end.
