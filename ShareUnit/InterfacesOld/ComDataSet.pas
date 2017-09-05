unit ComDataSet;

interface

uses Classes, SysUtils, DB, WNDataSetInf;
type

  TWNComField = class(TInterfacedObject, IWNField)
  private
    FFieldName: WideString;
    FFieldType: FieldTypeEnum;
    FField: TField;
  protected
    {IWNField}
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
    function ReadToBuffer(pBuffer: integer): Integer; safecall;
    procedure WriteFromBuffer(pBuffer: integer; DataLen: Integer); safecall;
    function Get_AsMyBCD: WNMyBCD; safecall;
    procedure Set_AsMyBCD(Value: WNMyBCD); safecall;
    function Get_AsGBCD: WNGBCD; safecall;
    procedure Set_AsGBCD(Value: WNGBCD); safecall;
    function Get_NumberScale: Integer; safecall;
    function Get_FieldOriginalName: WideString; safecall;
  public
    constructor Create(Field: TField);
    property FieldName: WideString read Get_FieldName write FFieldName;
    property FieldType: FieldTypeEnum read Get_FieldType write FFieldType;
  end;

  TCustomComDataSet = class(TInterfacedObject, IWNDataSet)
  private
    FDataSet: TDataSet;
    FReversValue: OleVariant;
    FFields: TInterfaceList;
    FReversInterface: IUnknown;
    FFreeDataSet: boolean;
  protected
    {ICDDataSet}
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
    procedure FilterByBitMapString(const FieldName: WideString; const BitMapString: WideString;
                                   IsIn: WordBool); safecall;
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
    procedure LoadFromMemory(pMemory: integer; Length: Integer;
                             SourceOfFieldName: SourceOfFieldAliaEnum); safecall;
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

uses Math;

{ TWNComField }

constructor TWNComField.Create(Field: TField);
begin
        FField := Field;
end;

function TWNComField.Get_AsBoolean: WordBool;
begin
        result := FField.AsBoolean;
end;

function TWNComField.Get_AsDateTime: Double;
begin
        result := FField.AsDateTime;
end;

function TWNComField.Get_AsFloat: Double;
begin
        result := FField.AsFloat;
end;

function TWNComField.Get_AsInteger: Integer;
begin
        result := FField.AsInteger;
end;

function TWNComField.Get_AsString: WideString;
begin
        result := FField.AsString;
end;

function TWNComField.Get_AsValue: OleVariant;
begin
        result := FField.AsVariant;
end;

function TWNComField.Get_FieldName: WideString;
begin
        result := FFieldName;
end;

function TWNComField.Get_FieldType: FieldTypeEnum;
begin
        result := FFieldType;
end;

function TWNComField.Get_AsInt64: Int64;
begin
        result := FField.AsVariant;
end;

function TWNComField.Get_DataSize: Integer;
begin
        result := FField.DataSize;
end;

function TWNComField.Get_FieldDesc: WideString;
begin
        result := FField.FieldName;
end;

function TWNComField.Get_FieldSize: Integer;
begin
        result := FField.Size;
end;

function TWNComField.Get_AsStream: IUnknown;
begin
        result :=  nil;
end;

function TWNComField.Get_IsNull: WordBool;
begin
        result := FField.IsNull;
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

function TWNComField.ReadToBuffer(pBuffer: integer): Integer;
begin

end;

procedure TWNComField.WriteFromBuffer(pBuffer: integer;
  DataLen: Integer);
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

constructor TCustomComDataSet.Create(DataSet: TDataSet; FreeDataSet: boolean);
var
        i: integer;
begin
        if not Assigned(DataSet) then raise Exception.Create('DataSet is Nil!');
        FDataSet := DataSet;
        FFields := TInterfaceList.Create;
        FFreeDataSet := FreeDataSet;
        for i := 0 to FDataSet.FieldCount - 1 do
                CreateComField(FDataSet.Fields[i]);

end;

destructor TCustomComDataSet.Destroy;
begin
        if Assigned(FFields) then begin
                FFields.Clear;
                FreeAndNil(FFields);
        end;
        FReversInterface := nil;
        //ÊÇ·ñÒªÊÍ·Å
        if FFreeDataSet and Assigned(FDataSet) then
                FreeAndNil(FDataSet);
        inherited Destroy;
end;

function TCustomComDataSet.Get_FieldCount: Integer;
begin
        result := FFields.Count;
end;

function TCustomComDataSet.Fields(Index: Integer): IWNField;
begin
        result := FFields[Index] as IWNField;
end;

procedure TCustomComDataSet.First;
begin
        FDataSet.First;
end;

procedure TCustomComDataSet.Next;
begin
        FDataSet.Next;
end;

function TCustomComDataSet.Get_RecordCount: Integer;
begin
        result := FDataSet.RecordCount
end;

function TCustomComDataSet.Get_IndexNames: WideString;
begin
        result := '';
end;

function TCustomComDataSet.Get_ReversValue: OleVariant;
begin
        result := FReversValue;
end;

procedure TCustomComDataSet.Set_IndexNames(const Value: WideString);
begin
end;

function TCustomComDataSet.Get_Eof: WordBool;
begin
        result := FDataSet.Eof
end;

function TCustomComDataSet.Get_RecNO: Integer;
begin
        result := FDataSet.RecNo
end;

procedure TCustomComDataSet.Set_RecNO(Value: Integer);
begin
        FDataSet.RecNo := Value;
end;

function TCustomComDataSet.Get_ReversInterface: IUnknown;
begin
        result := FReversInterface;
end;

procedure TCustomComDataSet.Set_ReversInterface(const Value: IUnknown);
begin
        FReversInterface := Value;
end;

function TCustomComDataSet.FieldByName(const FieldName: WideString): IWNField;
var
        Field: TField;
begin
        result := nil;
        Field := FDataSet.FindField(FieldName);
        if Assigned(Field) then result := Fields(Field.Index);
end;

function TCustomComDataSet.Get_Bof: WordBool;
begin
        result := FDataSet.Bof
end;

procedure TCustomComDataSet.Last;
begin
        FDataSet.Last;
end;

procedure TCustomComDataSet.Prior;
begin
        FDataSet.Prior;
end;
{
  1: FieldDefs.Add(FName, ftInteger);     //1 int
  2: FieldDefs.Add(FName, ftLargeint);    //2 int64
  3: FieldDefs.Add(FName, ftFMTBcd);         //3 decimal      decimal(18, n)
  4, 5: begin
    FieldDefs.Add(FName, ftFloat);        //4 float  // 5 double
    end;
  6: ftString
  7: FieldDefs.Add(FName, ftBlob);        //7	binary
  8: FieldDefs.Add(FName, ftDateTime);    //8 DateTime
  9: FieldDefs.Add(FName, ftMemo);        //9 Text
  10:FieldDefs.Add(FName, ftFMTBcd);      //10  decimal    deimail(38, n)
}

procedure TCustomComDataSet.CreateComField(Field: TField);
var
        WNComField: TWNComField;
begin
        WNComField := TWNComField.Create(Field);
        WNComField.FieldName := Field.FieldName;
        case Field.DataType of
                ftString, ftWideString,ftMemo:
                        WNComField.FieldType := fteChar;
                ftLargeint:
                        WNComField.FieldType := fteInteger64;
                ftInteger, ftWord, ftBytes:
                        WNComField.FieldType := fteInteger;
                ftBoolean:
                        WNComField.FieldType := fteBool;
                ftFloat, ftCurrency:
                        WNComField.FieldType := fteFloat;
                ftDate, ftTime, ftDateTime:
                        WNComField.FieldType := fteDatetime;
                ftFMTBcd:
                       WNComField.FieldType := fteBcd;
                ftBlob:
                       WNComField.FieldType := fteblob;

        end;
        FFields.Add(WNComField as IWNField);
end;

function TCustomComDataSet.Get_Filter: WideString;
begin
        //
end;

procedure TCustomComDataSet.Set_Filter(const Value: WideString);
begin
//
end;

procedure TCustomComDataSet.Set_ReversValue(Value: OleVariant);
begin
        FReversValue := Value;
end;

procedure TCustomComDataSet.FilterByBitMapString(const FieldName,
  BitMapString: WideString; IsIn: WordBool);
begin
end;

function TCustomComDataSet.Locate(const FieldName,
  FieldValue: WideString): WordBool;
begin
end;

function TCustomComDataSet.Get_SortFieldsName: WideString;
begin
end;

procedure TCustomComDataSet.Set_SortFieldsName(const Value: WideString);
begin
end;

function TCustomComDataSet.Get_DataAsStream: IUnknown;
begin
        result := nil;
end;

procedure TCustomComDataSet.AddField(Type_: FieldTypeEnum; Length,
  Scale: Integer; const Name, Descript: WideString);
begin

end;

procedure TCustomComDataSet.Append;
begin

end;

procedure TCustomComDataSet.Cancel;
begin

end;

function TCustomComDataSet.CloneStruct: IWNDataSet;
begin

end;

procedure TCustomComDataSet.Delete;
begin

end;

procedure TCustomComDataSet.Edit;
begin

end;

function TCustomComDataSet.FindField(const FieldName: WideString): IWNField;
begin

end;

function TCustomComDataSet.Get_Status: WNDSStatusEnum;
begin

end;

procedure TCustomComDataSet.LoadFromStream(const InStream: IInterface;
  SourceOfFieldName: SourceOfFieldAliaEnum);
begin

end;

procedure TCustomComDataSet.Post;
begin

end;

function TCustomComDataSet.SaveToStream: IUnknown;
begin

end;

function TCustomComDataSet.CloneDataSet: IWNDataSet;
begin

end;

procedure TCustomComDataSet.LoadFromMemory(pMemory: integer;
  Length: Integer; SourceOfFieldName: SourceOfFieldAliaEnum);
begin

end;

procedure TCustomComDataSet.CreateWNDataSet;
begin

end;

procedure TCustomComDataSet.ReplaceAliaWithDesc;
begin

end;

procedure TCustomComDataSet.EmptyDataSet;
begin

end;

function TCustomComDataSet.Get_MaxDataLength: Integer;
begin

end;

function TCustomComDataSet.SaveToBuffer(DataAddres: Integer; BufferLength: Integer): Integer;
begin

end;

procedure TCustomComDataSet.SetDataFromAdoRecordSet(
  const inRecordSet: IDispatch; RecordCount: Integer);
begin

end;

function TCustomComDataSet.LoadFromFile(const FileName: WideString;
  SourceOfFieldName: SourceOfFieldAliaEnum): Integer;
begin

end;

function TCustomComDataSet.SaveToFile(const FileName: WideString): Integer;
begin

end;

end.
