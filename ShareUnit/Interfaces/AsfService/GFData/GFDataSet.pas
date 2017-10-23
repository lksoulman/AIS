unit GFDataSet;

////////////////////////////////////////////////////////////////////////////////
//
// Description： Data Set
// Author：      lksoulman
// Date：        2017-9-13
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  DB,
  JSON,
  GFData,
  FMTBcd,
  Windows,
  Classes,
  SysUtils,
  Variants,
  AnsiStrings;

type

  // Data Header
  TGFDataHeader = packed record
    CRC: Integer;
    ResponseCode: Integer;
    Version: Integer;
    FieldCount: Integer;
    FieldLength: Integer;
    DataCount: Integer;
    DataLength: Integer;
    Reserve: Integer;
  end;

  // Field Header
  TGFFieldHeader = packed record
    ColName: string;
    ColType: Integer;
    ColPrecision: Integer;
    ColScale: Integer;
    Scale: string;
  end;

  // Field Header Dynamic Array
  TGFFieldHeaderDynArray = Array Of TGFFieldHeader;

  // Field Row Value Dynamic Array
  TGFFieldRowValueDynArray = Array Of Variant;

  TGFDataSet = class;

  TSortCompare = function(L, R: Integer): integer of object;

  // GF Blob Stream
  TGFBlobStream = class(TStream)
  private
    // Size
    FSize: Cardinal;
    // Blob Data
    FBlobData: Pointer;
    // Data Set
    FDataSet: TGFDataSet;
  protected
    function GetSize: Int64; override;
  public
    // Constructor
    constructor Create(AField : TField); virtual;
    // Destructor
    destructor Destroy; override;
    // Write To Stream
    procedure WriteToStream(AStream: TStream);
    // Read
    function Read(var Buffer; Count: Longint): Longint; override;
    // Seek
    function Seek(Offset: Longint; Origin: Word): Longint; override;
    // Write
    function Write(const Buffer; Count: Longint): Longint; override;
  end;

  // GF Data Set
  TGFDataSet = class(TDataSet)
  private
    type
      PRecInfo = ^TRecInfo;
      TRecInfo = record
        RecNo: Integer;
        Bookmark: Longint;
        BookmarkFlag: TBookmarkFlag;
      end;
  private
    // Is Last
    FIsLast: boolean;
    // Is First
    FIsFirst: boolean;
    // Is Sort
    FIsSort: boolean;
    // Sort List
    FSortList: TList;
    // Is Filter
    FIsFilter: boolean;
    // Filter List
    FFilterList: TList;
    // Is Prepare
    FIsPrepare: Boolean;
    // Record Size
    FRecordSize: Integer;
    // Record Index
    FRecordIndex: Integer;
    // Record Count
    FRecordCount: Integer;
    // Prepare Index
    FPrepareIndex: Integer;

    // Data Header
    FDataHeader: TGFDataHeader;
    // Field Header
    FFieldHeaders: TGFFieldHeaderDynArray;
    // Field Row Value
    FFieldRowValues: TGFFieldRowValueDynArray;

    // Result Data
    FResultDatas: TJSONArray;
    // Parse Json Stream
    FParseJsonObject: TJSONObject;

    // Prepare Record Data
    procedure PrepareRecordData(ARecordIndex: integer);
    // Record Is Null
    function RecordIsNull(AFieldIndex: integer): boolean;
    // Locate Record
    function LocateRecord(const KeyFields: string; const KeyValues: Variant; Options: TLocateOptions; SyncCursor: Boolean): Boolean;
  protected

    // dataset virtual methods

    // Alloc Record Buffer
    function AllocRecordBuffer: TRecordBuffer; override;
    // Free Record Buffer
    procedure FreeRecordBuffer(var Buffer: TRecordBuffer); override;
    // Get Book mark Flag
    function GetBookmarkFlag(Buffer: TRecBuf): TBookmarkFlag; override;
    // Get Book mark Data
    procedure GetBookmarkData(Buffer: TRecBuf; Data: TBookmark); override;
    // Set Book mark Data
    procedure SetBookmarkData(Buffer: TRecordBuffer; Data: Pointer); override;
    // Set Book mark Flag
    procedure SetBookmarkFlag(Buffer: TRecordBuffer; Value: TBookmarkFlag); override;
    // Get Record No
    function GetRecNo: Integer; override;
    // Get Record Size
    function GetRecordSize: Word; override;
    // Get Record Count
    function GetRecordCount: Integer; override;
    // Set Record No
    procedure SetRecNo(Value: Integer); override;
    // Get Record
    function GetRecord(Buffer: TRecordBuffer; GetMode: TGetMode; DoCheck: Boolean): TGetResult; override;

    // Internal Open
    procedure InternalOpen; override;
    // Internal Post
    procedure InternalPost; override;
    // Internal Last
    procedure InternalLast; override;
    // Internal First
    procedure InternalFirst; override;
    // Internal Close
    procedure InternalClose; override;
    // Internal Insert
    procedure InternalInsert; override;
    // Internal Delete
    procedure InternalDelete; override;
    // Internal Is Filtering
    function InternalIsFiltering: Boolean;
    // Internal Init FieldDefs
    procedure InternalInitFieldDefs; override;
    // Internal Handle Exception
    procedure InternalHandleException; override;
    // Internal Goto Book mark
    procedure InternalGotoBookmark(Bookmark: Pointer); override;
    // Internal Init Record
    procedure InternalInitRecord(Buffer: TRecordBuffer); override;
    // Internal Set Record
    procedure InternalSetToRecord(Buffer: TRecordBuffer); override;
    // Internal Add Record
    procedure InternalAddRecord(Buffer: Pointer; Append: Boolean); override;

    // Set Filter
    procedure SetFiltered(Value: Boolean); override;
    // Set Field Data
    procedure SetFieldData(Field: TField; Buffer: Pointer); override;
    // Set On Filter Record
    procedure SetOnFilterRecord(const Value: TFilterRecordEvent); override;
    // Update Filter
    procedure UpdateFilters;

    // Get Record Index
    function GetRecordIndex: integer;
    // Default Fields
    function DefaultFieldsEx: boolean;
    // Is Cursor Open
    function IsCursorOpen: Boolean; override;
    // Get Can Modify
    function GetCanModify: Boolean; override;

     // Parse Data
    procedure DoParseJsonData(AStream: TStream);
  public
    // Constructor
    constructor Create(AGFData: IGFData); reintroduce;
    // Destructor
    destructor Destroy; override;
    // Empty Sort
    procedure EmptySort;
    // Absolute RecNo
    function AbsoluteRecNo: integer;
    // Field To String
    function FieldHeadToString: string;
    // Alpha Sort
    procedure AlphaSort(SortCompare: TSortCompare);
    // Compare Book mark
    function CompareBookmarks(Bookmark1, Bookmark2: TBookmark): Integer; override;
    // Get Field Data
    function GetFieldData(Field: TField; var Buffer: TValueBuffer): Boolean; override;
    // Create Blob Stream
    function CreateBlobStream(Field: TField; Mode: TBlobStreamMode): TStream; override;
    // Locate
    function Locate(const KeyFields: string; const KeyValues: Variant; Options: TLocateOptions): Boolean; override;
  published
    published
    property Active;
    property BeforeOpen;
    property AfterOpen;
    property BeforeClose;
    property AfterClose;
    property BeforeInsert;
    property AfterInsert;
    property BeforeEdit;
    property AfterEdit;
    property BeforePost;
    property AfterPost;
    property BeforeCancel;
    property AfterCancel;
    property BeforeDelete;
    property AfterDelete;
    property BeforeScroll;
    property AfterScroll;
    property OnCalcFields;
    property OnDeleteError;
    property OnEditError;
    property OnFilterRecord;
    property OnNewRecord;
    property OnPostError;
  end;


implementation

var
   G_FormatSettings: TFormatSettings;

{ TGFBlobStream }

constructor TGFBlobStream.Create(AField: TField);
var
  LFieldIndex: integer;
  LStrValue: AnsiString;
begin
  FDataSet := TGFDataSet(AField.DataSet);
  with FDataSet do begin
    PrepareRecordData(GetRecordIndex - 1);
    LFieldIndex := AField.FieldNo - 1;
    if RecordIsNull(LFieldIndex) then begin
      FSize := 0;
    end else begin
      //7 binary  9 Text
      if FFieldHeaders[LFieldIndex].ColType = 7 then begin
        FSize := 0;
        FBlobData := nil;
      end else if FFieldHeaders[LFieldIndex].ColType = 9 then begin
        LStrValue := AnsiString(FFieldRowValues[LFieldIndex]);
        FSize := Length(LStrValue);
        GetMem(FBlobData, FSize);
        AnsiStrings.StrLCopy(PAnsiChar(FBlobData), PAnsiChar(LStrValue), Length(LStrValue));
      end else begin
        FSize := 0;
      end;
    end;
  end;
end;

destructor TGFBlobStream.Destroy;
begin
  if FBlobData <> nil then begin
    FreeMem(FBlobData);
    FBlobData := nil;
  end;
  inherited;
end;

procedure TGFBlobStream.WriteToStream(AStream: TStream);
begin
  if FSize <> 0 then begin
    AStream.WriteBuffer(FBlobData^, FSize);
  end;
end;

function TGFBlobStream.Read(var Buffer; Count: Integer): Longint;
begin
  if Count > integer(FSize) then begin
    Count := FSize;
  end;

  if (FBlobData <> nil) then begin
    Move(FBlobData^, Buffer, Count);
    Result := count;
  end else begin
    Result := 0;
  end;
end;

function TGFBlobStream.Seek(Offset: Integer; Origin: Word): Longint;
begin
  Result := 0;
end;

function TGFBlobStream.Write(const Buffer; Count: Integer): Longint;
begin
  Result := 0;
end;

function TGFBlobStream.GetSize: Int64;
begin
  Result := FSize;
end;

{ TGFDataSet }

constructor TGFDataSet.Create(AGFData: IGFData);
begin
  inherited Create(nil);
  FIsSort := False;
  FIsFilter := False;
  FIsPrepare := False;
  FSortList := TList.Create;
  FFilterList := TList.Create;
  if AGFData <> nil then begin
    DoParseJsonData(AGFData.GetDataStream);
  end;
end;

destructor TGFDataSet.Destroy;
begin
  if FParseJsonObject <> nil then begin
    FParseJsonObject.Free;
  end;
  FFilterList.Free;
  FSortList.Free;
  inherited;
end;

procedure TGFDataSet.PrepareRecordData(ARecordIndex: integer);
var
  LBcd: TBcd;
  LIndex: integer;
  LValueStr: string;
  LValue: TJSONValue;
  LRecordObj: TJSONArray;
begin
  if (FParseJsonObject = nil) or (FResultDatas = nil) then Exit;

  if ARecordIndex <> FPrepareIndex then begin
    try
      FPrepareIndex := ARecordIndex;
      LRecordObj := TJSONArray(FResultDatas.Items[ARecordIndex]);
      //记录数据准备
      for LIndex := Low(FFieldHeaders) to High(FFieldHeaders) do begin
        if LIndex  >= LRecordObj.Count then begin
          FFieldRowValues[LIndex] := null;
          Continue;
        end;

        LValue := LRecordObj.Items[LIndex];
        if LValue is TJSONNull then begin
          FFieldRowValues[LIndex] := null;
        end else begin
          case FFieldHeaders[LIndex].ColType of
            1:    // 1 int
              begin
                FFieldRowValues[LIndex] := LValue.GetValue<integer>('', 0);
              end;
            2:    // 2 int64
              begin
                FFieldRowValues[LIndex] := LValue.GetValue<int64>('', 0);
              end;
            3:    // 3 decimal  decimal(18, n)    //18位没问题
              begin
                LValueStr := LValue.GetValue<string>('', '');
                FillMemory(@LBcd, Sizeof(Tbcd), 0);
                LBcd.SignSpecialPlaces := FFieldHeaders[LIndex].ColScale;
                if (LValueStr = '') or (LValueStr = '0') then begin
                  FFieldRowValues[LIndex] := 0
                end else begin
                  TryStrToBcd(LValueStr, LBcd);
                  FFieldRowValues[LIndex] := VarFMTBcdCreate(LBcd);
                end;
              end;
            4:    // 4 float
              begin
                FFieldRowValues[LIndex] := StrToFloatDef(LValue.value, 0);
              end;
            5:    // 5 double
              begin
                FFieldRowValues[LIndex] := StrToFloatDef(LValue.value, 0);
              end;
            6:    // Utf8ToAnsi(FPBInput.readString); //6 string
              begin
                FFieldRowValues[LIndex] := LValue.Value;
              end;
            7:    // 7 binary
              begin
                FFieldRowValues[LIndex] := LValue.GetValue<string>('', '');
              end;
            8:    // 8 datetime
              begin
                FFieldRowValues[LIndex] := StrToDateTimeDef(LValue.GetValue<string>('', ''), DateDelta, G_FormatSettings);
              end;
            9:    // 9 Text
              begin
                FFieldRowValues[LIndex] := LValue.GetValue<string>('', '');
              end;
            10:   //10 decimal  decimal(38, n)
              begin
                 {   v := '';
                    FillChar(HInt, SizeOf(HugeInt), 0);
                    FillChar(HInt2, SizeOf(HugeInt), 0);

                    tag := FPBInput.readRawVarint32;
                    FPBInput.readRawBytes(HInt[16 - tag] , tag);

                    //负数处现
                    if HInt[16 - tag] and $80 > 0 then
                            FillChar(HInt, SizeOf(HugeInt) - tag * SizeOf(Byte) , $FF);

                    for ii := 0 to SizeOf(HugeInt) div 4 - 1  do
                            PInteger(@HInt2[(3 - ii) * 4])^ := H32Tolow(PInteger(@HInt[ii * 4])^);

                    HugeInt2String(HInt2, V);
                    FillMemory(@bcd, Sizeof(Tbcd), 0);
                    bcd.SignSpecialPlaces := FPBInputFields[LIndex].colscale;
                    if (V = '') or (V = '0') then
                            FRowValues[LIndex] := 0
                    else begin
                            BcdDivide(V, FPBInputFields[LIndex].scale, bcd);
                            FRowValues[LIndex] := VarFMTBcdCreate(bcd);
                    end;      }
              end;
          end;
        end;
      end;
    except
      on Ex: exception do begin
        //raise Exception.Create(MsgStr + #13#10 + e.Message + FRowValues[1]);
      end;
    end;
  end;
end;

function TGFDataSet.RecordIsNull(AFieldIndex: integer): boolean;
begin
  Result := FFieldRowValues[AFieldIndex] = null;
end;

function TGFDataSet.LocateRecord(const KeyFields: string; const KeyValues: Variant; Options: TLocateOptions; SyncCursor: Boolean): Boolean;

  function SameValue(V1, V2: Variant; IsString, CaseInsensitive, PartialLength: Boolean): Boolean;
  var
    LVariant: Variant;
  begin
    if not IsString then begin
      Result := VarCompareValue(V1, V2) = vrEqual;
    end else begin
      if PartialLength then begin
        LVariant := Copy(V1, 1, Length(V2))
      end else begin
        LVariant := V1;
      end;
      if CaseInsensitive then begin
        Result := LowerCase(LVariant) = LowerCase(V2)
      end else begin
        Result := LVariant = V2;
      end;
    end;
  end;

  function CheckValues(AFields: TStrings; Values: Variant; CaseInsensitive, PartialLength: Boolean): Boolean;
  var
    LField: TField;
    LJ: Integer;
  begin
    Result := True;
    for LJ := 0 to AFields.Count -1 do begin
      LField := FieldByName(AFields[LJ]);
      if not SameValue(LField.Value, Values[LJ], LField.DataType in [ftString, ftFixedChar], CaseInsensitive, PartialLength) then begin
              Result := False;
              break;
      end;
    end;
  end;

var
  LIndex: Integer;
  LValues, LStartValues: Variant;
  LSaveFields, LFields: TStrings;
  LPartialLength, LCaseInsensitive: Boolean;
begin
  CheckBrowseMode;
  CursorPosChanged;
  LFields := TStringList.Create;
  LSaveFields := TStringList.Create;
  try
    LFields.CommaText := StringReplace(KeyFields, ';', ',', [rfReplaceAll]);
    LPartialLength := loPartialKey in Options;
    LCaseInsensitive := loCaseInsensitive in Options;

    if VarIsArray(KeyValues) then begin
      LValues := KeyValues;
    end else begin
      LValues := VarArrayOf([KeyValues]);
    end;
    { save current record in case we cannot locate KeyValues }
    LStartValues := VarArrayCreate([0, FieldCount], varVariant);
    for LIndex := 0 to FieldCount -1 do begin
      LStartValues[LIndex] := Fields[LIndex].Value;
      LSaveFields.Add(Fields[LIndex].FieldName);
    end;
    First;
    while not EOF do begin
      if CheckValues(LFields, LValues, LCaseInsensitive, LPartialLength) then begin
        break;
      end;
      Next;
    end;
    { if not found, reset cursor to starting position }
    Result := not EOF;
    if EOF then begin
      First;
      while not EOF do begin
        if CheckValues(LSaveFields, LStartValues, False, False) then begin
          break;
        end;
        Next;
      end;
    end;
  finally
    LFields.Free;
    LSaveFields.Free;
  end;
end;

procedure TGFDataSet.EmptySort;
var
  _ControlsDisabled: boolean;
begin
  if not Active then Exit;

  _ControlsDisabled := ControlsDisabled;
  if not _ControlsDisabled then begin
    DisableControls;
  end;
  try
    FSortList.Clear;
    FIsSort := false;
    InternalFirst;
    Resync([]);
  finally
    if not _ControlsDisabled then begin
      EnableControls;
    end;
  end;
end;

function TGFDataSet.AbsoluteRecNo: integer;
var
  SortIndex: integer;
begin
  Result := GetRecNo;
  if FIsSort then begin
    SortIndex := Integer(FSortList[Result - 1]);
    if FIsFilter then begin
      Result := Integer(FFilterList[SortIndex-1])
    end else begin
      Result := SortIndex;
    end;
  end else begin
    if FIsFilter then begin
      Result := Integer(FFilterList[Result - 1])
    end;
  end;
end;

function TGFDataSet.FieldHeadToString: string;
var
  FormatString: string;
  LIndex, LLen: integer;
  function TypeToString(Value: integer): string;
  begin
    case Value of
      1: Result := 'Int      ';
      2: Result := 'Int64    ';
      3: Result := 'Decimal  ';
      4: Result := 'Float    ';
      5: Result := 'Double   ';
      6: Result := 'String   ';
      7: Result := 'Binary   ';
      8: Result := 'DateTime ';
      9: Result := 'Text     ';
      10:Result := 'Deimail_B';
    else
      Result := 'Unkonw   ';
    end;
  end;

begin
  Result := '';
  if Active then begin
    LLen := 10;
    for LIndex := Low(FFieldHeaders) to High(FFieldHeaders) do begin
      if LLen < length(FFieldHeaders[LIndex].ColName) then begin
        LLen := length(FFieldHeaders[LIndex].ColName)
      end;
    end;

    Result := Format('名称%' + inttostr(LLen-4) + 's'#9'类型     '#9'长度     '#9'精度', [' ']);
    FormatString := '%-' + inttostr(LLen) + 's'#9'%9s'#9'%-9d'#9'%-4d';
    for LIndex := Low(FFieldHeaders) to High(FFieldHeaders) do begin
      Result := Result + #13#10 + Format(FormatString,
        [FFieldHeaders[LIndex].ColName,
          TypeToString(FFieldHeaders[LIndex].ColType),
          FFieldHeaders[LIndex].ColPrecision,
          FFieldHeaders[LIndex].colscale]);
    end;
  end;
end;

procedure TGFDataSet.AlphaSort(SortCompare: TSortCompare);
var
  LIndex: integer;
  _ControlsDisabled: boolean;

  procedure QuickSort(ALeft, ARight: Integer);
  var
    LI, LJ, LMid, Index: Integer;
  begin
    repeat
      LI := ALeft;
      LJ := ARight;
      LMid := (ALeft + ARight) shr 1;
      repeat
        Index := Integer(FSortList[LMid]);

        while SortCompare(Integer(FSortList[LI]), Index) < 0 do begin
          Inc(LI);
        end;
        while SortCompare(Integer(FSortList[LJ]), Index) > 0 do begin
          Dec(LJ);
        end;

        if LI <= LJ then begin
          Index := Integer(FSortList[LI]);
          FSortList[LI] := FSortList[LJ];
          FSortList[LJ] := Pointer(Index);

          if LMid = LI then begin
            LMid := LJ
          end else if LMid = LJ then begin
            LMid := LI;
          end;

          Inc(LI);
          Dec(LJ);
        end;
      until LI > LJ;
      if ALeft < LJ then begin
        QuickSort(ALeft, LJ);
      end;
      ALeft := LI;
    until LI >= ARight;
  end;

begin
  if not Active or (FRecordCount <= 0) then Exit;

  _ControlsDisabled := ControlsDisabled;
  if not _ControlsDisabled then begin
    DisableControls;
  end;
  try
    FIsSort := False;
    //初始化 索引列表
    FSortList.Clear;
    FSortList.Count := FRecordCount;
    for LIndex := 0 to FSortList.Count - 1 do begin
      FSortList[LIndex] := Pointer(LIndex + 1);
    end;
    QuickSort(0, FRecordCount-1);
    //排序标志
    FIsSort := True;
    InternalFirst;
    Resync([]);
  finally
    if not _ControlsDisabled then begin
      EnableControls;
    end;
  end;
end;

function TGFDataSet.CompareBookmarks(Bookmark1, Bookmark2: TBookmark): Integer;
begin
  if Assigned(Bookmark1) and Assigned(Bookmark2) then begin
    if PInteger(BookMark1)^ = PInteger(BookMark2)^ then begin
      result := 0
    end else if PInteger(BookMark1)^ < PInteger(BookMark2)^ then begin
      result := -1
    end else begin
      result := 1;
    end;
  end else if Assigned(Bookmark1) then begin
    result := 1;
  end else if Assigned(Bookmark2) then begin
    result := -1;
  end else begin
    Result := 0;
  end;
end;

function TGFDataSet.GetFieldData(Field: TField; var Buffer: TValueBuffer): Boolean;
var
  LStrValue: Ansistring;
  LRecordIndex, LFieldIndex: integer;

  LBuff: TValueBuffer;
begin
  if IsEmpty then begin
    Result := False;
  end else begin
    LRecordIndex := GetRecordIndex;
    PrepareRecordData(LRecordIndex - 1);
    LFieldIndex := Field.FieldNo - 1;
    Result := not RecordIsNull(LFieldIndex);

    if Result and Assigned(Buffer) then begin
      case FFieldHeaders[LFieldIndex].ColType of
        1:    // 1 int
          begin
            PInteger(Buffer)^ := FFieldRowValues[LFieldIndex];
          end;
        2:    // 2 int64
          begin
            PInt64(Buffer)^ := FFieldRowValues[LFieldIndex];
          end;
        3:    // 3 decimal   decimal(18, n)
          begin
            try
              PBCD(Buffer)^ := VarToBcd(FFieldRowValues[LFieldIndex])
            except
              PBCD(Buffer)^ := StrToBcd(VarToStr(FFieldRowValues[LFieldIndex]));
            end;
          end;
        4, 5: // 4 float  double
          begin
            PDouble(Buffer)^  := FFieldRowValues[LFieldIndex];
          end;
        6:
          begin
            LStrValue := AnsiString(FFieldRowValues[LFieldIndex]);
            AnsiStrings.StrLCopy(PAnsiChar(Buffer), PAnsiChar(LStrValue), Length(LStrValue));
          end;
        7:    // 7	binary
          begin
            Result := true;
          end;
        8:    // 8 datetime
          begin
            SetLength(LBuff, SizeOf(Double));
            TBitConverter.FromDouble(FFieldRowValues[LFieldIndex], LBuff);
            DataConvert(Field, LBuff, Buffer, True);
          end;
        9:
          begin
            Result := true;
          end;
        10:   // 10 decimal   decimal(38, n)
          begin
            try
              PBCD(Buffer)^ := VarToBcd(FFieldRowValues[LFieldIndex])
            except
              PBCD(Buffer)^ := StrToBcd(VarToStr(FFieldRowValues[LFieldIndex]));
            end;
          end;
      end;
    end;
  end;
end;

function TGFDataSet.CreateBlobStream(Field: TField; Mode: TBlobStreamMode): TStream;
begin
  Result := TGFBlobStream.Create(Field);
end;

function TGFDataSet.Locate(const KeyFields: string; const KeyValues: Variant; Options: TLocateOptions): Boolean;
var
  BM: TBookMark;
  LControlsDisabled: boolean;
begin
  result := false;
  if not Active then exit;
  if IsEmpty then exit;

  LControlsDisabled := ControlsDisabled;
  if not LControlsDisabled then begin
    DisableControls;
  end;
  BM := GetBookmark;
  try
    Result := LocateRecord(KeyFields, KeyValues, Options, True);
    FRecordIndex := RecNO;
    if Result then begin
      Resync([rmExact, rmCenter])
    end else begin
      GotoBookmark(BM);
    end;
  finally
    FreeBookmark(BM);
    if not LControlsDisabled then begin
      EnableControls;
    end;
  end;
end;

procedure TGFDataSet.DoParseJsonData(AStream: TStream);
var
  LIndex: Integer;
  LBuffer: TBytes;
  LFields: TJSONArray;
  LJsonValue: TJSONValue;
  LFieldObject: TJSONObject;
begin
  if Active then begin
    Close;
  end;
  FIsPrepare := False;

  if AStream = nil then Exit;

  try
    AStream.Position := 0;
    SetLength(LBuffer, AStream.Size);
    AStream.Read(LBuffer, AStream.Size);
    FParseJsonObject := TJSONObject.ParseJSONValue(LBuffer, 0, True) as TJSONObject;
    if FParseJsonObject <> nil then begin
      FPrepareIndex := -1;
      LJsonValue := FParseJsonObject.GetValue('respCode');
      if LJsonValue <> nil then begin
        FDataHeader.ResponseCode := StrToIntDef(LJsonValue.Value, -1);
      end else begin
        FDataHeader.ResponseCode := -1;
      end;

      LJsonValue := FParseJsonObject.GetValue('fields');
      if LJsonValue <> nil then begin
        LFields := TJSONArray(LJsonValue);
        FDataHeader.FieldCount := LFields.Count;
        SetLength(FFieldHeaders, FDataHeader.FieldCount);
        if LFields <> nil then begin
          for LIndex := 0 to FDataHeader.FieldCount - 1 do begin

            LFieldObject := TJSONObject(LFields.Items[LIndex]);
            LJsonValue := LFieldObject.Values['colname'];
            if (LJsonValue <> nil)
              and not (LJsonValue is TJSONNull) then begin
              FFieldHeaders[LIndex].ColName := LJsonValue.GetValue<string>;
            end;

            LJsonValue := LFieldObject.Values['colType'];
            if (LJsonValue <> nil)
              and not (LJsonValue is TJSONNull) then begin
              FFieldHeaders[LIndex].ColType := LJsonValue.GetValue<Integer>;
            end;

            LJsonValue := LFieldObject.Values['colpresion'];
            if (LJsonValue <> nil)
              and not (LJsonValue is TJSONNull) then begin
              FFieldHeaders[LIndex].ColPrecision := LJsonValue.GetValue<Integer>;
            end;

            LJsonValue := LFieldObject.Values['colscale'];
            if (LJsonValue <> nil)
              and not (LJsonValue is TJSONNull) then begin
              FFieldHeaders[LIndex].ColScale := LJsonValue.GetValue<Integer>;
            end;

            // 处理 decimal 小数点 = 0
            if (FFieldHeaders[LIndex].ColType = 3)
              and (FFieldHeaders[LIndex].ColScale = 0) then begin
              // decimal 小数点 = 0  时 长度不超过 18 直接用 //2 int64
              FFieldHeaders[LIndex].ColType := 2;
            end;

            if FFieldHeaders[LIndex].ColType in [3, 10] then begin
              FFieldHeaders[LIndex].Scale := '1' + StringOfChar('0', self.FFieldHeaders[LIndex].ColScale);
            end;
          end;
        end;
      end else begin
        FDataHeader.FieldCount := 0;
      end;

      LJsonValue := FParseJsonObject.GetValue('result');
      if LJsonValue <> nil then begin
        FResultDatas := TJSONArray(LJsonValue);
        FDataHeader.DataCount := FResultDatas.Count;
      end else begin
        FDataHeader.DataCount := 0;
      end;

      // Data
      SetLength(FFieldRowValues, FDataHeader.FieldCount);
      FIsPrepare := True;

      FRecordCount := FDataHeader.DataCount;
      Open;
    end;
  except

  end;
end;

function TGFDataSet.AllocRecordBuffer: TRecordBuffer;
begin
  Result := AllocMem(FRecordSize);
end;

procedure TGFDataSet.FreeRecordBuffer(var Buffer: TRecordBuffer);
begin
  FreeMem(Buffer);
end;

function TGFDataSet.GetBookmarkFlag(Buffer: TRecBuf): TBookmarkFlag;
begin
  Result := PRecInfo(Buffer).BookmarkFlag;
end;

procedure TGFDataSet.GetBookmarkData(Buffer: TRecBuf; Data: TBookmark);
begin
  PInteger(Data)^ := PRecInfo(Buffer).Bookmark;
end;

procedure TGFDataSet.SetBookmarkData(Buffer: TRecordBuffer; Data: Pointer);
begin
  PRecInfo(Buffer).Bookmark := PInteger(Data)^;
end;

procedure TGFDataSet.SetBookmarkFlag(Buffer: TRecordBuffer; Value: TBookmarkFlag);
begin
  PRecInfo(Buffer).BookmarkFlag := Value;
end;

function TGFDataSet.GetRecNo: Integer;
begin
  if ActiveBuffer <> 0 then begin
    Result := PRecInfo(ActiveBuffer)^.RecNo;
  end else begin
    Result := 1;
  end;
end;

function TGFDataSet.GetRecordSize: Word;
begin
  Result := FRecordSize;
end;

function TGFDataSet.GetRecordCount: Integer;
begin
  Result := FRecordCount;
end;

procedure TGFDataSet.SetRecNo(Value: Integer);
begin
  if (Value < 1) or (Value > FRecordCount) then begin
    DatabaseError('RecNo Out Of Range!', Self);
  end;
  DoBeforeScroll;
  FRecordIndex := Value;
  Resync([rmCenter]);
  DoAfterScroll;
end;

function TGFDataSet.GetRecord(Buffer: TRecordBuffer; GetMode: TGetMode; DoCheck: Boolean): TGetResult;
begin
  Result := grOK; // default

  case GetMode of
    gmPrior:
      begin
        if FIsLast then begin
          FIsLast := False;
        end else if FRecordIndex >= 1 then begin
          Dec(FRecordIndex);
        end;
        if (FRecordIndex < 1) then begin
          Result := grBOF;
        end;
      end;
    gmNext:
      begin
        if FIsFirst then begin
          FIsFirst := False;
        end else if FRecordIndex <= FRecordCount then begin
          Inc(FRecordIndex);
        end;
        if (FRecordIndex > FRecordCount) then begin
          Result := grEOF;
        end;
      end;
    gmCurrent:
      begin
        if (FRecordIndex < 1) or FIsLast then begin
          Result := grBOF;
        end;
        if (FRecordIndex > FRecordCount) or FIsFirst then begin
          Result := grEOF;
        end;
      end;
  end;

  // read the data
  if Result = grOK then with PRecInfo(Buffer)^ do begin
    RecNo := FRecordIndex ;
    BookmarkFlag := bfCurrent;
    Bookmark := RecNo;
  end;
end;

procedure TGFDataSet.InternalOpen;
begin
  if not FIsPrepare then begin
    DatabaseError('Input is Null!', Self);
  end;

  InternalInitFieldDefs;

  if DefaultFieldsEx then begin
    CreateFields;
  end;

  BindFields(True);

  FRecordSize := SizeOf(TRecInfo);
  BookmarkSize := SizeOf(Integer);

  InternalFirst;

  UpdateFilters;
end;

procedure TGFDataSet.InternalPost;
begin

end;

procedure TGFDataSet.InternalLast;
begin
  FIsLast := True;
  FRecordIndex := FRecordCount;
end;

procedure TGFDataSet.InternalFirst;
begin
  FIsFirst := True;
  FRecordIndex := 1;
end;

procedure TGFDataSet.InternalClose;
begin
  // disconnet and destroy field objects
  FIsPrepare := False;

  Filtered := False;
  BindFields(False);

  if DefaultFieldsEx then begin
    DestroyFields;
  end;

  FieldDefs.Clear;

  if Assigned(FFilterList) then begin
    FFilterList.Clear;
  end;
  FIsFilter := False;

  if Assigned(FSortList) then begin
    FSortList.Clear;
  end;
  FIsSort := False;

  DataEvent(deDataSetChange, 0);
end;

procedure TGFDataSet.InternalInsert;
begin

end;

procedure TGFDataSet.InternalDelete;
begin

end;

function TGFDataSet.InternalIsFiltering: Boolean;
begin
  Result := Assigned(OnFilterRecord) and Filtered;
end;

procedure TGFDataSet.InternalInitFieldDefs;
var
  LColName: string;
  LIndex, LIncr: integer;
begin
  FieldDefs.Clear;

  for LIndex := Low(FFieldHeaders) to High(FFieldHeaders) do begin
    //有重名
    LColName := FFieldHeaders[LIndex].ColName;
    LIncr := 0;
    while (LColName = '') or (FieldDefs.IndexOf(LColName) >= 0) do begin
      Inc(LIncr);
      LColName := Format('COLUMN%d', [LIncr]);
    end;

    //名称为空
    if FFieldHeaders[LIndex].ColName = '' then begin
      FFieldHeaders[LIndex].ColName := LColName;
    end;

    case FFieldHeaders[LIndex].ColType of
      1:      //1 int
        begin
          FieldDefs.Add(LColName, ftInteger);
        end;
      2:      //2 int64
        begin
          FieldDefs.Add(LColName, ftLargeint);
        end;
      3:      //3 decimal      decimal(18, n)
        begin
          FieldDefs.Add(LColName, ftFMTBcd);
        end;
      4, 5:   //4 float       // 5 double
        begin
          FieldDefs.Add(LColName, ftFloat);
        end;
      6:
        begin
          if FFieldHeaders[LIndex].ColPrecision = 0 then begin
            FFieldHeaders[LIndex].ColPrecision := 50;
          end;
          //6 string
          if FFieldHeaders[LIndex].ColPrecision <= 8000 then begin
            FieldDefs.Add(LColName, ftString, FFieldHeaders[LIndex].ColPrecision)
          end else begin
            // 大与 8000 就算memo
            FieldDefs.Add(LColName, ftMemo); //9 Text
            //重新改一下类型
            FFieldHeaders[LIndex].ColType := 9;
          end;
        end;
      7:      //7	binary
        begin
          FieldDefs.Add(LColName, ftBlob);
        end;
      8:      //8 DateTime
        begin
          FieldDefs.Add(LColName, ftDateTime);
        end;
      9:      //9 Text
        begin
          FieldDefs.Add(LColName, ftMemo);
        end;
      10:     //10  decimal    deimail(38, n)
        begin
          FieldDefs.Add(LColName, ftFMTBcd);
        end;
    end;
  end;
end;

procedure TGFDataSet.InternalHandleException;
begin
  ApplicationHandleException(Self);
end;

procedure TGFDataSet.InternalGotoBookmark(Bookmark: Pointer);
begin
  if Assigned(Bookmark) then begin
    FRecordIndex := Integer(Bookmark^);
  end;
end;

procedure TGFDataSet.InternalInitRecord(Buffer: TRecordBuffer);
begin
  FillChar(Buffer^, FRecordSize, #0);
end;

procedure TGFDataSet.InternalSetToRecord(Buffer: TRecordBuffer);
begin
  if PRecInfo(Buffer)^.BookmarkFlag in [bfCurrent, bfInserted] then begin
    InternalGotoBookmark(@PRecInfo(Buffer)^.Bookmark);
  end;
end;

procedure TGFDataSet.InternalAddRecord(Buffer: Pointer; Append: Boolean);
begin

end;

procedure TGFDataSet.UpdateFilters;
var
  LAccepted: boolean;
  LFilterCount: integer;
  LControlsDisabled: boolean;
begin
  if not Active then Exit;

  LControlsDisabled := ControlsDisabled;
  if not LControlsDisabled then begin
    DisableControls;
  end;

  FRecordCount := FDataHeader.DataCount;

  FIsSort := false;
  FIsFilter := false;
  FSortList.Clear;
  FFilterList.Clear;
  if InternalIsFiltering then begin
    First;
    LFilterCount := 1;
    while not EOF do begin
      LAccepted := True;
      OnFilterRecord(self, LAccepted);
      if(LAccepted) then begin
        FFilterList.Add(Pointer(LFilterCount));
      end;
      Next;
      Inc(LFilterCount);
    end;
    FRecordCount := FFilterList.Count;
    FIsFilter := true;
  end;
  InternalFirst;
  Resync([]);
  if not LControlsDisabled then begin
    EnableControls;
  end;
end;

procedure TGFDataSet.SetFiltered(Value: Boolean);
begin
  if Filtered <> Value then begin
    inherited SetFiltered(Value);
    UpdateFilters;
  end;
end;

procedure TGFDataSet.SetFieldData(Field: TField; Buffer: Pointer);
begin

end;

procedure TGFDataSet.SetOnFilterRecord(const Value: TFilterRecordEvent);
begin
  inherited SetOnFilterRecord(Value);
  UpdateFilters;
end;

function TGFDataSet.GetRecordIndex: integer;
var
  LSortIndex: integer;
begin
  if FIsSort then begin
    LSortIndex := Integer(FSortList[PRecInfo(ActiveBuffer)^.RecNo - 1]);
    if FIsFilter then begin
      Result := Integer(FFilterList[LSortIndex - 1]);
    end else begin
      Result := LSortIndex;
    end;
  end else begin
    if FIsFilter then begin
      Result := Integer(FFilterList[PRecInfo(ActiveBuffer)^.RecNo - 1]);
    end else begin
      Result := PRecInfo(ActiveBuffer)^.RecNo;
    end;
  end;
end;

function TGFDataSet.DefaultFieldsEx: boolean;
begin
  Result := (FieldOptions.AutoCreateMode <> acExclusive) or not (lcPersistent in Fields.LifeCycles);
end;

function TGFDataSet.IsCursorOpen: Boolean;
begin
  Result := FIsPrepare;
end;

function TGFDataSet.GetCanModify: Boolean;
begin
  Result := False;
end;


begin
  GetFormatSettings;
  G_FormatSettings := SysUtils.FormatSettings;
  G_FormatSettings.ThousandSeparator:=' ';
  G_FormatSettings.DateSeparator:='-';
  G_FormatSettings.TimeSeparator:=':';
  G_FormatSettings.LongTimeFormat:='YYYY-MM-DD HH:MM:SS';
end.
