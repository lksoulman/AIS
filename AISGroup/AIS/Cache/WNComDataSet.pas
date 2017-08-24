unit WNComDataSet;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-6
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses Classes, DB, SysUtils, WnDataSetInf;

type

  TWNComField = class(TInterfacedObject, IWNField)
  private
    FFieldName: WideString;
    FFieldType: FieldTypeEnum;
    FField: TField;
  protected
    { IWNField }
    function Get_FieldName: WideString; safecall;
    function Get_FieldType: FieldTypeEnum; safecall;
    function Get_FieldSize: Integer; safecall;
    function Get_DataSize: Integer; safecall;
    function Get_AsFloat: Double; safecall;
    function Get_AsBoolean: WordBool; safecall;
    function Get_AsDateTime: Double; safecall;
    function Get_AsString: WideString; safecall;
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
  public
    constructor Create(Field: TField);
    property FieldName: WideString read Get_FieldName write FFieldName;
    property FieldType: FieldTypeEnum read Get_FieldType write FFieldType;
  end;

  TWNComDataSet = class(TInterfacedObject, IWNDataSet)
  private
    FDataSet: TDataSet;
    FReversValue: OleVariant;
    FFields: TInterfaceList;
    FReversInterface: IUnknown;
    FFreeDataSet: boolean;
    // FRecordCount: Integer;
  protected
    { ICDDataSet }
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
    function Get_ReversValue: OleVariant; safecall;
    procedure Set_ReversValue(Value: OleVariant); safecall;
    function Get_ReversInterface: IUnknown; safecall;
    procedure Set_ReversInterface(const Value: IUnknown); safecall;
    function Get_Filter: WideString; safecall;
    procedure Set_Filter(const Value: WideString); safecall;
    procedure CreateComField(Field: TField);
    procedure FilterByBitMapString(const FieldName: WideString; const BitMapString: WideString; IsIn: WordBool); safecall;
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
    procedure AddField(Type_: FieldTypeEnum; Length: Integer; Scale: Integer; const Name: WideString;
      const Descript: WideString); safecall;
    function CloneDataSet: IWNDataSet; safecall;
    function FindField(const FieldName: WideString): IWNField; safecall;
    procedure LoadFromMemory(pMemory: Integer; Length: Integer; SourceOfFieldName: SourceOfFieldAliaEnum); safecall;
    procedure CreateWNDataSet; safecall;
    procedure ReplaceAliaWithDesc; safecall;
    procedure EmptyDataSet; safecall;
    function SaveToBuffer(DataAddres: Integer; BufferLength: Integer): Integer; safecall;
    function Get_MaxDataLength: Integer; safecall;
    procedure SetDataFromAdoRecordSet(const inRecordSet: IDispatch; RecordCount: Integer); safecall;
    function SaveToFile(const FileName: WideString): Integer; safecall;
    function LoadFromFile(const FileName: WideString; SourceOfFieldName: SourceOfFieldAliaEnum): Integer; safecall;

  public
    constructor Create(DataSet: TDataSet; FreeDataSet: boolean);
    destructor Destroy; override;

    property DataSet: TDataSet read FDataSet;
  end;

implementation

uses
  Math, Uni;

{ TWNComField }

constructor TWNComField.Create(Field: TField);
begin
  FField := Field;
end;

function TWNComField.Get_AsBoolean: WordBool;
begin
  Result := FField.AsBoolean;
end;

function TWNComField.Get_AsDateTime: Double;
begin
  Result := FField.AsDateTime;
end;

function TWNComField.Get_AsFloat: Double;
begin
  Result := FField.AsFloat;
end;

function TWNComField.Get_AsInteger: Integer;
begin
  Result := FField.AsInteger;
end;

function TWNComField.Get_AsString: WideString;
begin
  Result := FField.AsString;
end;

function TWNComField.Get_AsValue: OleVariant;
begin
  Result := FField.AsVariant;
end;

function TWNComField.Get_FieldName: WideString;
begin
  Result := FFieldName;
end;

function TWNComField.Get_FieldType: FieldTypeEnum;
begin
  Result := FFieldType;
end;

function TWNComField.Get_AsInt64: Int64;
begin
  // Result := TLargeintField(FField).AsLargeInt;
  Result := StrToInt64Def(FField.AsString, 0);
end;

function TWNComField.Get_DataSize: Integer;
begin
  Result := FField.DataSize;
end;

function TWNComField.Get_FieldDesc: WideString;
begin
  Result := FField.FieldName;
end;

function TWNComField.Get_FieldSize: Integer;
begin
  Result := FField.Size;
end;

function TWNComField.Get_AsStream: IUnknown;
begin
  Result := nil;
end;

function TWNComField.Get_IsNull: WordBool;
begin
  Result := FField.IsNull;
end;

procedure TWNComField.Set_AsBoolean(Value: WordBool);
begin

end;

procedure TWNComField.Set_AsDateTime(Value: Double);
begin

end;

procedure TWNComField.Set_AsFloat(Value: Double);
begin

end;

procedure TWNComField.Set_AsInt64(Value: Int64);
begin

end;

procedure TWNComField.Set_AsInteger(Value: Integer);
begin

end;

procedure TWNComField.Set_AsStream(const Value: IInterface);
begin

end;

procedure TWNComField.Set_AsString(const Value: MyB);
begin

end;

procedure TWNComField.Set_AsValue(Value: OleVariant);
begin

end;

procedure TWNComField.Clear;
begin

end;

function TWNComField.ReadToBuffer(pBuffer: Integer): Integer;
begin

end;

procedure TWNComField.WriteFromBuffer(pBuffer: Integer; DataLen: Integer);
begin

end;

function TWNComField.Get_AsMyBCD: WNMyBCD;
begin

end;

function TWNComField.Get_NumberScale: Integer;
begin

end;

procedure TWNComField.Set_AsMyBCD(Value: WNMyBCD);
begin

end;

function TWNComField.Get_FieldOriginalName: WideString;
begin

end;

function TWNComField.Get_AsGBCD: WNGBCD;
begin

end;

procedure TWNComField.Set_AsGBCD(Value: WNGBCD);
begin

end;

{ TWNComDataSet }

constructor TWNComDataSet.Create(DataSet: TDataSet; FreeDataSet: boolean);
var
  i: Integer;
begin
  if not Assigned(DataSet) then
    raise Exception.Create('DataSet is Nil!');
  FDataSet := DataSet;
  FFields := TInterfaceList.Create;
  FFreeDataSet := FreeDataSet;
  for i := 0 to FDataSet.FieldCount - 1 do
    CreateComField(FDataSet.Fields[i]);
  // FRecordCount := 0;
end;

destructor TWNComDataSet.Destroy;
begin
  if Assigned(FFields) then
  begin
    FFields.Clear;
    FreeAndNil(FFields);
  end;
  FReversInterface := nil;
  // 是否要释放
  if FFreeDataSet and Assigned(FDataSet) then
  begin
    if FDataSet.Active then
      FDataSet.Close;
    FreeAndNil(FDataSet);
  end;
  inherited Destroy;
end;

function TWNComDataSet.Get_FieldCount: Integer;
begin
  Result := FFields.Count;
end;

function TWNComDataSet.Fields(Index: Integer): IWNField;
begin
  Result := FFields[Index] as IWNField;
end;

procedure TWNComDataSet.First;
begin
  FDataSet.First;
end;

procedure TWNComDataSet.Next;
begin
  FDataSet.Next;
end;

function TWNComDataSet.Get_RecordCount: Integer;
// var
// lc_BookMark: TBookmarkStr;
// lc_AfterScroll: TDataSetNotifyEvent;
begin
  Result := FDataSet.RecordCount;
  // Sqlite默认不返回RecordCount以提高性能，在需要时计算一次
  // if FRecordCount = 0 then
  // begin
  // with FDataSet do
  // begin
  // lc_BookMark := Bookmark;
  // lc_AfterScroll := AfterScroll;
  // DisableControls;
  // try
  // First;
  //
  // while not Eof do
  // begin
  // Inc(FRecordCount);
  //
  // Next;
  // end;
  // finally
  // GotoBookmark(Pointer(lc_BookMark));
  // EnableControls;
  // AfterScroll := lc_AfterScroll;
  // end;
  // end;
  // end;
  //
  // Result := FRecordCount;
end;

function TWNComDataSet.Get_IndexNames: WideString;
begin
  Result := '';
end;

function TWNComDataSet.Get_ReversValue: OleVariant;
begin
  Result := FReversValue;
end;

procedure TWNComDataSet.Set_IndexNames(const Value: WideString);
begin
end;

function TWNComDataSet.Get_Eof: WordBool;
begin
  Result := FDataSet.Eof;
end;

function TWNComDataSet.Get_RecNo: Integer;
begin
  Result := FDataSet.RecNo;
end;

procedure TWNComDataSet.Set_RecNo(Value: Integer);
begin
  FDataSet.RecNo := Value;
end;

function TWNComDataSet.Get_ReversInterface: IUnknown;
begin
  Result := FReversInterface;
end;

procedure TWNComDataSet.Set_ReversInterface(const Value: IUnknown);
begin
  FReversInterface := Value;
end;

function TWNComDataSet.FieldByName(const FieldName: WideString): IWNField;
var
  Field: TField;
  i: Integer;
begin
  Result := nil;
  Field := FDataSet.FindField(FieldName);
  if Assigned(Field) then
  begin
    i := Field.Index;
    Result := Fields(i);
  end;
end;

function TWNComDataSet.Get_Bof: WordBool;
begin
  Result := FDataSet.Bof;
end;

procedure TWNComDataSet.Last;
begin
  FDataSet.Last;
end;

procedure TWNComDataSet.Prior;
begin
  FDataSet.Prior;
end;

procedure TWNComDataSet.CreateComField(Field: TField);
var
  WNComField: TWNComField;
begin
  WNComField := TWNComField.Create(Field);
  WNComField.FieldName := Field.FieldName;
  case Field.DataType of
    ftString, ftWideString, ftMemo:
      WNComField.FieldType := fteChar;
    ftLargeint:
      WNComField.FieldType := fteInteger64;
    ftInteger, ftWord, ftBytes, ftSmallInt:
      WNComField.FieldType := fteInteger;
    ftBoolean:
      WNComField.FieldType := fteBool;
    ftFloat, ftCurrency, ftBCD:
      WNComField.FieldType := fteFloat;
    ftDate, ftTime, ftDateTime:
      WNComField.FieldType := fteDatetime;
  else
    WNComField.FieldType := fteChar;
  end;
  FFields.Add(WNComField as IWNField);
end;

function TWNComDataSet.Get_Filter: WideString;
begin
  Result := FDataSet.Filter;
end;

procedure TWNComDataSet.Set_Filter(const Value: WideString);
begin
  FDataSet.DisableControls;
  try
    if FDataSet.Filtered then
      FDataSet.Filtered := False;
    FDataSet.Filter := Value;
    if FDataSet.Filter <> '' then
      FDataSet.Filtered := True;
  finally
    FDataSet.EnableControls;
  end;
end;

procedure TWNComDataSet.Set_ReversValue(Value: OleVariant);
begin
  FReversValue := Value;
end;

procedure TWNComDataSet.FilterByBitMapString(const FieldName, BitMapString: WideString; IsIn: WordBool);
begin
end;

function TWNComDataSet.Locate(const FieldName, FieldValue: WideString): WordBool;
begin
  Result := FDataSet.Locate(FieldName, FieldValue, []);
end;

function TWNComDataSet.Get_SortFieldsName: WideString;
var
  lc_UniQuery: TUniQuery;
begin
  Result := '';
  if FDataSet is TUniQuery then
  begin
    lc_UniQuery := FDataSet as TUniQuery;
    Result := lc_UniQuery.IndexFieldNames;
  end;
end;

procedure TWNComDataSet.Set_SortFieldsName(const Value: WideString);
var
  lc_UniQuery: TUniQuery;
begin
  if FDataSet is TUniQuery then
  begin
    lc_UniQuery := FDataSet as TUniQuery;
    lc_UniQuery.IndexFieldNames := Value;
  end;
end;

function TWNComDataSet.Get_DataAsStream: IUnknown;
begin
  Result := nil;
end;

procedure TWNComDataSet.AddField(Type_: FieldTypeEnum; Length, Scale: Integer; const Name, Descript: WideString);
begin

end;

procedure TWNComDataSet.Append;
begin

end;

procedure TWNComDataSet.Cancel;
begin

end;

function TWNComDataSet.CloneStruct: IWNDataSet;
begin

end;

procedure TWNComDataSet.Delete;
begin

end;

procedure TWNComDataSet.Edit;
begin

end;

function TWNComDataSet.FindField(const FieldName: WideString): IWNField;
begin

end;

function TWNComDataSet.Get_Status: WNDSStatusEnum;
begin

end;

procedure TWNComDataSet.LoadFromStream(const InStream: IInterface; SourceOfFieldName: SourceOfFieldAliaEnum);
begin

end;

procedure TWNComDataSet.Post;
begin

end;

function TWNComDataSet.SaveToStream: IUnknown;
begin

end;

function TWNComDataSet.CloneDataSet: IWNDataSet;
begin

end;

procedure TWNComDataSet.LoadFromMemory(pMemory: Integer; Length: Integer; SourceOfFieldName: SourceOfFieldAliaEnum);
begin

end;

procedure TWNComDataSet.CreateWNDataSet;
begin

end;

procedure TWNComDataSet.ReplaceAliaWithDesc;
begin

end;

procedure TWNComDataSet.EmptyDataSet;
begin

end;

function TWNComDataSet.Get_MaxDataLength: Integer;
begin

end;

function TWNComDataSet.SaveToBuffer(DataAddres: Integer; BufferLength: Integer): Integer;
begin

end;

procedure TWNComDataSet.SetDataFromAdoRecordSet(const inRecordSet: IDispatch; RecordCount: Integer);
begin

end;

function TWNComDataSet.LoadFromFile(const FileName: WideString; SourceOfFieldName: SourceOfFieldAliaEnum): Integer;
begin

end;

function TWNComDataSet.SaveToFile(const FileName: WideString): Integer;
begin

end;

end.
