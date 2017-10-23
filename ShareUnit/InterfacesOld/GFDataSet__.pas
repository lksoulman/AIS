unit GFDataSet;

interface

uses Windows, Classes, SysUtils, ActiveX, DB, Variants, FMTBcd, System.JSON,
  GFDataMngr_TLB, DateUtils, AnsiStrings;

type

  TGFFiledRec = record
    colname: string ;
    colTypeNumber: integer;
    colpresion: integer;
    colscale: integer;
    scale: string;
  end;

  TGFHeadRec = record
    CRC: integer;
    result: integer;
    Version: integer;
    fieldNumber: integer;
    dataNumber: integer;
    fieldLength: integer;
    dataLength: integer;
    reserve: integer;
  end;

  TSortCompare = function(L, R: Integer): integer of object;
  TOnGFDataArrive = procedure(const GFData: IGFData) of object;
  
  TGFDataSet = class;

  TGFBlobStream = class(TStream)
  private
    FBlobData : Pointer;
    FSize : cardinal;
    FDataSet: TGFDataSet;
  protected
    function GetSize: Int64; override;
  public
    constructor Create(Field : TField);
    destructor Destroy; override;
    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    function Seek(Offset: Longint; Origin: Word): Longint; override;
    procedure SaveToStream(Stream: TStream);
  end;

  TGFDataSet = class(TDataSet)
  private
    FGFData: IGFData;
    FRecordSize: integer;
    FGFInput: TJSONObject;
    FGFDatas: TJSONArray;
    FIsPrepare: boolean;

    FGFInputHead: TGFHeadRec;
    FGFInputFields: array of TGFFiledRec;
    FRowValues: array of Variant;

    FFirst: boolean;
    FLast: boolean;
    FRecordCount: integer;
    FRecordIndex: integer;

    FIsFilter: boolean;
    FFilterList: TList;
    FIsSort: boolean;
    FSortList: TList;
    FPrepareIndex: integer;
    function LocateRecord(const KeyFields: string; const KeyValues: Variant; Options: TLocateOptions; SyncCursor: Boolean): Boolean;
    procedure PrepareDataHead;
    procedure PrepareRecData(RecIndex: integer);
    function RecIsNull(FieldIndex: integer): boolean;
    { Private declarations }
  protected
    // dataset virtual methods
    function AllocRecordBuffer: TRecordBuffer; override;
    procedure FreeRecordBuffer(var Buffer: TRecordBuffer); override;
    procedure InternalInitRecord(Buffer: TRecordBuffer); override;
    procedure GetBookmarkData(Buffer: TRecBuf; Data: TBookmark);  override;
    function GetBookmarkFlag(Buffer: TRecBuf): TBookmarkFlag; override;
    function GetRecord(Buffer: TRecordBuffer; GetMode: TGetMode; DoCheck: Boolean): TGetResult; override;

    function GetRecordSize: Word; override;
    procedure InternalAddRecord(Buffer: Pointer; Append: Boolean); override;
    procedure InternalClose; override;
    procedure InternalDelete; override;
    procedure InternalPost; override;
    procedure InternalInsert; override;

    procedure InternalGotoBookmark(Bookmark: Pointer); override;
    procedure InternalHandleException; override;

    procedure InternalFirst; override;
    procedure InternalLast; override;

    procedure InternalOpen; override;
    procedure InternalSetToRecord(Buffer: TRecordBuffer); override;
    function IsCursorOpen: Boolean; override;
    procedure SetBookmarkFlag(Buffer: TRecordBuffer; Value: TBookmarkFlag); override;
    procedure SetBookmarkData(Buffer: TRecordBuffer; Data: Pointer); override;
    function GetRecordCount: Integer; override;
    procedure SetRecNo(Value: Integer); override;
    function GetRecNo: Integer; override;

    procedure InternalInitFieldDefs; override;
    procedure SetFieldData(Field: TField; Buffer: Pointer); override;
    function GetCanModify: Boolean; override;
    procedure SetFiltered(Value: Boolean); override;
    function InternalIsFiltering: Boolean;
    procedure UpdateFilters;
    procedure SetOnFilterRecord(const Value: TFilterRecordEvent); override;
    function GetRecIndex: integer;

    procedure UpdateDataSet;
    function Get_SortFieldsName: string; safecall;
    procedure Set_SortFieldsName(const Value: string); safecall;
    function _DefaultFields: boolean;
    { Protected declarations }
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetFieldData(Field: TField; var Buffer: TValueBuffer): Boolean; override;

    procedure CreateDataSet(Stream: TStream); overload;
    procedure CreateDataSet(GFData: IGFData);  overload;
    function CompareBookmarks(Bookmark1, Bookmark2: TBookmark): Integer; override;
    function Locate(const KeyFields: string; const KeyValues: Variant; Options: TLocateOptions): Boolean; override;

    function AbsoluteRecNo: integer;

    procedure AlphaSort(SortCompare: TSortCompare);
    procedure EmptySort;


    property GFData: IGFData read FGFData;
    function CreateBlobStream(Field: TField; Mode: TBlobStreamMode): TStream; override;
    function HeadToString: string;
    property SortFieldsName: string Read Get_SortFieldsName write Set_SortFieldsName;
    { Public declarations }
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
    { Published declarations }
  end;

implementation


var
   FormatSettings: TFormatSettings;
type

  PRecInfo = ^TRecInfo;
  TRecInfo = record
    RecNO: Integer;
    Bookmark: Longint;
    BookmarkFlag: TBookmarkFlag;
  end;

{ TGFDataSet }

function TGFDataSet.AllocRecordBuffer: TRecordBuffer;
begin
        Result := AllocMem(FRecordSize);
end;

procedure TGFDataSet.FreeRecordBuffer(var Buffer: TRecordBuffer);
begin
        FreeMem(Buffer);
end;

procedure TGFDataSet.InternalInitRecord(Buffer: TRecordBuffer);
begin
        FillChar(Buffer^, FRecordSize, #0);
end;

procedure TGFDataSet.GetBookmarkData(Buffer: TRecBuf; Data: TBookmark);
begin
        PInteger(Data)^ := PRecInfo(Buffer).Bookmark;
end;

function TGFDataSet.GetBookmarkFlag(Buffer: TRecBuf): TBookmarkFlag;
begin
        Result := PRecInfo(Buffer).BookmarkFlag;
end;

function TGFDataSet.GetRecNo: Integer;
begin
        if ActiveBuffer <> 0 then
                Result := PRecInfo(ActiveBuffer)^.RecNO
        else Result := 1;
end;

function TGFDataSet.GetRecordCount: Integer;
begin
        Result := FRecordCount;
end;

function TGFDataSet.GetRecordSize: Word;
begin
        result := FRecordSize;
end;

procedure TGFDataSet.InternalFirst;
begin
        FFirst := true;
        FRecordIndex := 1;
end;

procedure TGFDataSet.InternalLast;
begin
        FLast := true;
        FRecordIndex := FRecordCount;
end;

procedure TGFDataSet.InternalGotoBookmark(Bookmark: Pointer);
begin
        if Assigned(Bookmark) then FRecordIndex := Integer(Bookmark^);
end;

procedure TGFDataSet.InternalHandleException;
begin
        ApplicationHandleException(Self);
end;

procedure TGFDataSet.InternalOpen;
begin
        
        if not FIsPrepare then DatabaseError('Input is Null!', Self);

        InternalInitFieldDefs;

        if _DefaultFields then CreateFields;
        BindFields (True);

        FRecordSize := sizeof (TRecInfo);
        BookmarkSize := sizeOf (Integer);
        InternalFirst;
        UpdateFilters;   
end;

procedure TGFDataSet.InternalClose;
begin
        // disconnet and destroy field objects
        FIsPrepare := false;

        Filtered := false;
        BindFields (False);
        if _DefaultFields then DestroyFields;

        FieldDefs.Clear;

        if Assigned(FFilterList) then FFilterList.Clear;
        FIsFilter := false;

        if Assigned(FSortList) then FSortList.Clear;
        FIsSort := false;

        DataEvent(deDataSetChange, 0);
end;

procedure TGFDataSet.InternalSetToRecord(Buffer: TRecordBuffer);
begin
        if PRecInfo(Buffer)^.BookmarkFlag in [bfCurrent, bfInserted] then
                InternalGotoBookmark(@PRecInfo(Buffer)^.Bookmark);
end;

function TGFDataSet.IsCursorOpen: Boolean;
begin
        Result := FIsPrepare;
end;

procedure TGFDataSet.SetBookmarkData(Buffer: TRecordBuffer; Data: Pointer);
begin
        PRecInfo(Buffer).Bookmark := PInteger(Data)^;
end;

procedure TGFDataSet.SetBookmarkFlag(Buffer: TRecordBuffer; Value: TBookmarkFlag);
begin
        PRecInfo(Buffer).BookmarkFlag := Value;
end;

procedure TGFDataSet.SetRecNo(Value: Integer);
begin
        if (Value < 1) or (Value > FRecordCount) then
                DatabaseError('RecNo Out Of Range!', Self);
        DoBeforeScroll;
        FRecordIndex := Value;
        Resync([rmCenter]);
        DoAfterScroll;
end;

function TGFDataSet.GetCanModify: Boolean;
begin
        Result := False; 
end;

procedure TGFDataSet.InternalInitFieldDefs;
var
        i, v: integer;
        FName: string;
begin
        FieldDefs.Clear;

        for i := Low(FGFInputFields) to High(FGFInputFields) do begin
                //有重名

                FName := string(FGFInputFields[i].colname);
                v := 0;
                while (FName = '') or (FieldDefs.IndexOf(FName) >= 0) do begin
                       Inc(v);
                       FName := Format('COLUMN%d', [v])
                end;

                //名称为空
                if FGFInputFields[i].colname = '' then
                        FGFInputFields[i].colname := FName;
                        
                case FGFInputFields[i].colTypeNumber of
                        1: FieldDefs.Add(FName, ftInteger);     //1 int
                        2: FieldDefs.Add(FName, ftLargeint);    //2 int64
                        3: FieldDefs.Add(FName, ftFMTBcd);         //3 decimal      decimal(18, n)
                        4, 5: begin
                                FieldDefs.Add(FName, ftFloat);    //4 float  // 5 double
                        end;
                        6: begin
                                if FGFInputFields[i].colpresion = 0 then
                                        FGFInputFields[i].colpresion := 50;

                                if FGFInputFields[i].colpresion <= 8000 then
                                         FieldDefs.Add(FName, ftString, FGFInputFields[i].colpresion) //6 string
                                else begin
                                        // 大与 8000 就算memo
                                        FieldDefs.Add(FName, ftString,10240); //9 Text
                                        //重新改一下类型 
                                        FGFInputFields[i].colTypeNumber := 9;
                                end;
                        end;
                        7: FieldDefs.Add(FName, ftBlob);        //7	binary
                        8: FieldDefs.Add(FName, ftDateTime);    //8 DateTime
                        9: FieldDefs.Add(FName, ftString,10240);        //9 Text
                        10:FieldDefs.Add(FName, ftFMTBcd);         //10  decimal    deimail(38, n)
                end;
        end;
end;

function TGFDataSet.GetRecord(Buffer: TRecordBuffer; GetMode: TGetMode; DoCheck: Boolean): TGetResult;
begin
        Result := grOK; // default

        case GetMode of
                gmPrior: begin
                        if FLast then FLast := false
                        else if (FRecordIndex >= 1) then Dec(FRecordIndex);
                        if (FRecordIndex < 1) then Result := grBOF;
                end;
                gmNext: begin
                        if FFirst then FFirst := false
                        else if (FRecordIndex <= FRecordCount) then inc(FRecordIndex);
                        if (FRecordIndex > FRecordCount) then Result := grEOF;
                end;
                gmCurrent: begin
                        if (FRecordIndex < 1) or FLast then Result := grBOF;
                        if (FRecordIndex > FRecordCount) or FFirst then Result := grEOF;
                end;
        end;
        
        // read the data
        if Result = grOK then with PRecInfo(Buffer)^ do begin
                RecNO := FRecordIndex ;
                BookmarkFlag := bfCurrent;
                Bookmark := RecNO;
        end;
end;

function TGFDataSet.GetFieldData(Field: TField; var Buffer: TValueBuffer): Boolean;
var
       // DataValue: TDateTime;
        StrValue: Ansistring;
        RecIndex, FieldIndex: integer;

        LBuff: TValueBuffer;
begin
        if IsEmpty then Result := false
        else begin
                RecIndex := GetRecIndex;

                PrepareRecData(RecIndex - 1);
                
                FieldIndex := Field.FieldNo - 1;

                Result := not RecIsNull(FieldIndex);
            //    if not result then OutputDebugString(PChar( '  Rec:'+ inttostr(RecIndex) + '  Field:'+ inttostr(FieldIndex)));

                if Result and Assigned(Buffer) then begin
                        case FGFInputFields[FieldIndex].colTypeNumber of
                                1: PInteger(Buffer)^ := FRowValues[FieldIndex];    //1 int
                                2: PInt64(Buffer)^ := FRowValues[FieldIndex];     //2 int64
                                3: begin  //3 decimal   decimal(18, n)
                                        try
                                                PBCD(Buffer)^ := VarToBcd( FRowValues[FieldIndex])
                                        except

                                                PBCD(Buffer)^ := StrToBcd(VarToStr(FRowValues[FieldIndex]));
                                        end;
                                end;
                                4, 5: PDouble(Buffer)^  := FRowValues[FieldIndex];   //4 float  double
                                6: begin
                                        StrValue := AnsiString(FRowValues[FieldIndex]);
                                        AnsiStrings.StrLCopy(PAnsiChar(Buffer), PAnsiChar(StrValue), Length(StrValue));

                                end;
                                7: begin //7	binary
                                        Result := true;
                                end;
                                8:  begin  //8 datetime

                                        SetLength(LBuff, SizeOf(Double));
                                        TBitConverter.FromDouble(FRowValues[FieldIndex], LBuff);
                                        DataConvert(Field, LBuff, Buffer, True)

                                        //DataValue :=  FRowValues[FieldIndex];
                                       // DataConvert(Field, @DataValue, Buffer, True) ;
                                end;
                                9:  begin  // 9 Text
                                      //Result := true;
                                      StrValue := AnsiString(FRowValues[FieldIndex]);
                                      if Length(Buffer) < length(StrValue) + 1 then
                                        SetLength(Buffer,length(StrValue) + 1);

                                      AnsiStrings.StrLCopy(PAnsiChar(Buffer), PAnsiChar(StrValue), Length(StrValue));
                                end;
                                10: begin  //10   decimal   decimal(38, n)
                                        try
                                                PBCD(Buffer)^ := VarToBcd( FRowValues[FieldIndex])
                                        except
                                                PBCD(Buffer)^ := StrToBcd(VarToStr(FRowValues[FieldIndex]));
                                        end;
                                end;
                        end;
                end;
        end;
end;

procedure TGFDataSet.CreateDataSet(Stream: TStream);
var
        Buffer: TArray<byte>;
        Size: integer;
begin
        if Active then Close;

        if FGFInput <> nil then FGFInput.Free;
        Size := Stream.Size;
        //拷贝数据
        setlength(Buffer, Size);                         //给动态数组定义长度
        Stream.ReadBuffer(Buffer[0], Size);

        FGFInput := TJSONObject.ParseJSONValue(Buffer, 0, true) as TJSONObject;

        PrepareDataHead;

        FRecordCount := FGFInputHead.dataNumber;

        Open;
end;

function TGFDataSet.CompareBookmarks(Bookmark1, Bookmark2: TBookmark): Integer;
begin
        if Assigned(Bookmark1) and Assigned(Bookmark2) then begin
                if PInteger(BookMark1)^ = PInteger(BookMark2)^ then result := 0
                else if PInteger(BookMark1)^ < PInteger(BookMark2)^ then result := -1
                else  result := 1;
        end else if Assigned(Bookmark1) then result := 1
        else if Assigned(Bookmark2) then result := -1
        else Result := 0;
end;

procedure TGFDataSet.InternalPost;
begin
end;

procedure TGFDataSet.SetFieldData(Field: TField; Buffer: Pointer);
begin
end;

procedure TGFDataSet.InternalAddRecord(Buffer: Pointer; Append: Boolean);
begin
end;

procedure TGFDataSet.InternalDelete;
begin
end;

procedure TGFDataSet.InternalInsert;
begin
end;

procedure TGFDataSet.SetFiltered(Value: Boolean);
begin
        if Filtered <> Value then begin
                inherited SetFiltered(Value);
                UpdateFilters;
        end;
end;

function TGFDataSet.InternalIsFiltering: Boolean;
begin
        Result := Assigned(OnFilterRecord) and Filtered;
end;

procedure TGFDataSet.UpdateFilters;
var
        _ControlsDisabled: boolean;
        FilterCount: integer;
        Accepted: boolean;
begin
        if not Active then exit;

        _ControlsDisabled := ControlsDisabled;
        if not _ControlsDisabled then DisableControls;

        FRecordCount := FGFInputHead.dataNumber;

        FIsSort := false;
        FSortList.Clear;

        FIsFilter := false;
        FFilterList.Clear;
        if InternalIsFiltering then begin

                First;
                FilterCount := 1;
                while not EOF do begin
                        Accepted := True;
                        OnFilterRecord(self, Accepted);
                        if(Accepted) then FFilterList.Add(Pointer(FilterCount));
                        Next;
                        Inc(FilterCount);
                end;
                FRecordCount := FFilterList.Count;
                FIsFilter := true;
        end;
        InternalFirst;
        Resync([]);
        if not _ControlsDisabled then EnableControls;
end;

function TGFDataSet._DefaultFields: boolean;
begin
        Result := (FieldOptions.AutoCreateMode <> acExclusive) or not (lcPersistent in Fields.LifeCycles);
end;

procedure TGFDataSet.SetOnFilterRecord(const Value: TFilterRecordEvent);
begin
        inherited SetOnFilterRecord(Value);
        UpdateFilters;
end;

constructor TGFDataSet.Create(AOwner: TComponent);
begin
        inherited Create(AOwner);
        FFilterList := TList.Create;
        FIsFilter := false;

        FSortList := TList.Create;
        FIsSort := false;


end;

destructor TGFDataSet.Destroy;
begin
        if Assigned(FFilterList) then FreeAndNil(FFilterList);
        if Assigned(FSortList) then FreeAndNil(FSortList);
        if Assigned(FGFInput) then FreeAndNil(FGFInput);

        FGFData := nil;
        
        inherited Destroy;
end;

function TGFDataSet.Locate(const KeyFields: string; const KeyValues: Variant; Options: TLocateOptions): Boolean;
var
        BM: TBookMark;
        _ControlsDisabled: boolean;
begin
        result := false;
        if not Active then exit;
        if IsEmpty then exit;

        _ControlsDisabled := ControlsDisabled;
        if not _ControlsDisabled then DisableControls;
        BM := GetBookmark;
        try
                Result := LocateRecord(KeyFields, KeyValues, Options, True);
                FRecordIndex := RecNO;
                if Result then Resync([rmExact, rmCenter])
                else GotoBookmark(BM);
        finally
                FreeBookmark(BM); 
                if not _ControlsDisabled then EnableControls;
        end;
end;

function TGFDataSet.LocateRecord(const KeyFields: string; const KeyValues: Variant; Options: TLocateOptions; SyncCursor: Boolean): Boolean;

        function SameValue(V1, V2: Variant; IsString, CaseInsensitive, PartialLength: Boolean): Boolean;
        var
                V: Variant;
        begin
                if not IsString then
                        Result := VarCompareValue(V1, V2) = vrEqual
                else begin
                        if PartialLength then V := Copy(V1, 1, Length(V2))
                        else V := V1;
                        if CaseInsensitive then Result := LowerCase(V) = LowerCase(V2)
                        else Result := V = V2;
                end;
        end;

        function CheckValues(AFields: TStrings; Values: Variant; CaseInsensitive, PartialLength: Boolean): Boolean;
        var
                J: Integer;
                Field: TField;
        begin
                Result := True;
                for J := 0 to AFields.Count -1 do begin
                        Field := FieldByName(AFields[J]);
                        if not SameValue(Field.Value, Values[J], Field.DataType in [ftString, ftFixedChar], CaseInsensitive, PartialLength) then begin
                                Result := False;
                                break;
                        end;
                end;
        end;
var
        I: Integer;
        SaveFields, AFields: TStrings;
        PartialLength, CaseInsensitive: Boolean;
        Values, StartValues: Variant;
begin
        CheckBrowseMode;
        CursorPosChanged;
        AFields := TStringList.Create;
        SaveFields := TStringList.Create;
        try
                AFields.CommaText := StringReplace(KeyFields, ';', ',', [rfReplaceAll]);
                PartialLength := loPartialKey in Options;
                CaseInsensitive := loCaseInsensitive in Options;
                
                if VarIsArray(KeyValues) then Values := KeyValues
                else Values := VarArrayOf([KeyValues]);
                { save current record in case we cannot locate KeyValues }
                StartValues := VarArrayCreate([0, FieldCount], varVariant);
                for I := 0 to FieldCount -1 do begin
                        StartValues[I] := Fields[I].Value;
                        SaveFields.Add(Fields[I].FieldName);
                end;
                First;
                while not EOF do begin
                        if CheckValues(AFields, Values, CaseInsensitive, PartialLength) then
                                break;
                        Next;
                end;
                { if not found, reset cursor to starting position }
                Result := not EOF;
                if EOF then begin
                        First;
                        while not EOF do begin
                                if CheckValues(SaveFields, StartValues, False, False) then
                                      break;
                                Next;
                        end;
                end;
        finally
                AFields.Free;
                SaveFields.Free;
        end;
end;

function TGFDataSet.AbsoluteRecNo: integer;
var
        SortIndex: integer;
begin
        result := GetRecNo;
        if FIsSort then begin
                SortIndex := Integer(FSortList[result - 1]);

                if FIsFilter then
                        result :=Integer(FFilterList[SortIndex-1])
                else result := SortIndex;

        end else begin
                if FIsFilter then
                        result :=  Integer(FFilterList[result - 1])
                else
                        result := result;
        end;
end;

procedure TGFDataSet.AlphaSort(SortCompare: TSortCompare);

        procedure QuickSort(L, R: Integer);
        var
                I, J, P, Index: Integer;
        begin
                repeat
                        I := L;
                        J := R;
                        P := (L + R) shr 1;
                        repeat
                                Index := Integer(FSortList[P]);

                                while SortCompare(Integer(FSortList[I]), Index) < 0 do Inc(I);
                                while SortCompare(Integer(FSortList[J]), Index) > 0 do Dec(J);

                                if I <= J then begin

                                        Index := Integer(FSortList[I]);
                                        FSortList[I] := FSortList[J];
                                        FSortList[J] := Pointer(Index);

                                        if P = I then P := J
                                        else if P = J then P := I;
                                        Inc(I); Dec(J);
                                end;
                        until I > J;
                        if L < J then QuickSort(L, J);
                        L := I;
                until I >= R;
        end;
var
        i: integer;
        _ControlsDisabled: boolean;
begin
        if not Active or (FRecordCount <= 0) then exit;
        _ControlsDisabled := ControlsDisabled;
        if not _ControlsDisabled then DisableControls;
        try
                FIsSort := false;
                
                //初始化 索引列表
                FSortList.Clear;
                FSortList.Count := FRecordCount;
                for i := 0 to FSortList.Count - 1 do FSortList[i] := Pointer(i + 1);

                QuickSort(0, FRecordCount-1);

                //排序标志
                FIsSort := true;

                InternalFirst;
                Resync([]);
        finally
                if not _ControlsDisabled then EnableControls;
        end;
end;

procedure TGFDataSet.EmptySort;
var
        _ControlsDisabled: boolean; 
begin
        if not Active then exit;

        _ControlsDisabled := ControlsDisabled;
        if not _ControlsDisabled then DisableControls;
        FSortList.Clear;
        FIsSort := false;
        InternalFirst;
        Resync([]);
        
        if not _ControlsDisabled then EnableControls;
end;

procedure TGFDataSet.PrepareDataHead;
var
        i: integer;
        MsgStr: string;
        Fileds: TJSONArray;
        FiledObj: TJSONObject;
        CurrentValue: TJSONValue;
begin
        Fileds := nil;
        if (FGFInput <> nil) then try

                FPrepareIndex := -1;
                CurrentValue := FGFInput.GetValue('respCode');
                if CurrentValue <> nil then
                        FGFInputHead.result := StrToIntDef(CurrentValue.Value, -1)
                else FGFInputHead.result := -1;

                //FGFInputHead.        FGFInput.GetValue('respMsg').Value
                CurrentValue := FGFInput.GetValue('fields');
                if CurrentValue <> nil then begin
                        Fileds := TJSONArray(CurrentValue);
                        FGFInputHead.fieldNumber := Fileds.Count;
                end else FGFInputHead.fieldNumber := 0;


                CurrentValue := FGFInput.GetValue('result');
                if CurrentValue <> nil then begin
                        FGFDatas := TJSONArray(CurrentValue);
                        FGFInputHead.dataNumber := FGFDatas.Count;
                end else FGFInputHead.dataNumber := 0;

                SetLength(FGFInputFields, FGFInputHead.fieldNumber);
                //创建字段
                if Fileds <> nil then for i := 0 to FGFInputHead.fieldNumber - 1 do begin

                        FiledObj := TJSONObject(Fileds.Items[i]);

                        CurrentValue := FiledObj.Values['colname'];
                        if (CurrentValue <> nil) and not (CurrentValue is TJSONNull)  then
                                FGFInputFields[i].colname := CurrentValue.GetValue<string>;


                        CurrentValue := FiledObj.Values['colType'];
                        if (CurrentValue <> nil) and not (CurrentValue is TJSONNull)  then
                                FGFInputFields[i].colTypeNumber := CurrentValue.GetValue<integer>;

                        CurrentValue := FiledObj.Values['colpresion'];
                        if (CurrentValue <> nil)  and not (CurrentValue is TJSONNull)  then
                                FGFInputFields[i].colpresion := CurrentValue.GetValue<integer>;

                        CurrentValue := FiledObj.Values['colscale'];
                        if (CurrentValue <> nil)  and not (CurrentValue is TJSONNull)  then
                                FGFInputFields[i].colscale := CurrentValue.GetValue<integer>;


                        //处理decimal 小数点 = 0
                      if (FGFInputFields[i].colTypeNumber  = 3) and (FGFInputFields[i].colscale = 0) then begin
                                //decimal 小数点 = 0  时 长度不超过 18 直接用 //2 int64
                                FGFInputFields[i].colTypeNumber  := 2;
                        end;

                        //生成小数因子
                        if FGFInputFields[i].colTypeNumber in [3, 10] then
                                FGFInputFields[i].scale := '1' + StringOfChar('0', FGFInputFields[i].colscale);

                end;

                //数据
                SetLength(FRowValues, FGFInputHead.fieldNumber);
                FIsPrepare := true;
        except
                on e: exception do
                        raise Exception.Create(MsgStr + #13#10 + e.Message);
        end;
end;

function JavaToDelphiDateTime(Value: Int64): TDateTime;
begin
            {1900/01/01 - 1899/12/30 }
        //'1900/01/01')以来的豪秒 ;
        Result := (MilliSecondsBetween(StrtoDate('1970-01-01'), 0) + Value )/ MSecsPerDay;
        //Result := (172800000 + Value) / MSecsPerDay;
end;

procedure TGFDataSet.PrepareRecData(RecIndex: integer);
var
        i: integer;
        v: string;

        bcd: TBcd;
        RecObj: TJSONArray;
        Value: TJSONValue;
begin
        if (FGFInput = nil) or (FGFDatas = nil) then exit;
        
        if RecIndex <> FPrepareIndex then try
                
                FPrepareIndex := RecIndex;

                RecObj := TJSONArray(FGFDatas.Items[RecIndex]);
                //记录数据准备
                for i := low(FGFInputFields) to high(FGFInputFields) do begin
                        if i  >= RecObj.Count then begin
                                FRowValues[i] := null;
                                Continue;
                        end;

                        Value := RecObj.Items[i];
                        //MsgStr := 'PrepareRecData RecNO:'  + inttostr(RecIndex) + ' FieldName:' + FPBInputFields[i].colname + ' FieldType:' +  Inttostr(FPBInputFields[i].colTypeNumber);
                        if Value is TJSONNull then
                                FRowValues[i] := null
                      //  if Value.Value = '' then
                        
                        else begin
                                case FGFInputFields[i].colTypeNumber of
                                        1: FRowValues[i] := Value.GetValue<integer>('', 0);    //1 int
                                        2: FRowValues[i] := Value.GetValue<int64>('', 0);   //2 int64
                                        3: begin   //3 decimal  decimal(18, n)    //18位没问题
                                                V := Value.GetValue<string>('', '');
                                                FillMemory(@bcd, Sizeof(Tbcd), 0);

                                                bcd.SignSpecialPlaces := FGFInputFields[i].colscale;
                                                if (V = '') or (V = '0') then
                                                        FRowValues[i] := 0
                                                else begin
                                                        TryStrToBcd(V, bcd);
                                                        FRowValues[i] := VarFMTBcdCreate(bcd);
                                                end;
                                        end;
                                        4: begin

                                                FRowValues[i] := StrToFloatDef(Value.value, 0);     //4 float
                                        end;
                                        5: begin
                                                FRowValues[i] := StrToFloatDef(Value.value, 0);   // 5 double
                                        end;

                                        6: begin
                                               // OutputDebugString(PChar(Value.GetValue<string>('', '')));

                                                FRowValues[i] := Value.Value; //Utf8ToAnsi(FPBInput.readString); //6 string

                                        end;
                                        7: begin //7 binary
                                                FRowValues[i] := Value.GetValue<string>('', '');
                                                
                                        end;     //8 datetime
                                        8:  begin

                                                FRowValues[i] := StrToDateTimeDef(Value.GetValue<string>('', ''), DateDelta, FormatSettings);
                                        end;
                                        9:begin  // 9 Text
                                                FRowValues[i] := Value.GetValue<string>('', '');

                                        end;
                                        10: begin //10 decimal  decimal(38, n)
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
                                                bcd.SignSpecialPlaces := FPBInputFields[i].colscale;
                                                if (V = '') or (V = '0') then
                                                        FRowValues[i] := 0
                                                else begin
                                                        BcdDivide(V, FPBInputFields[i].scale, bcd);
                                                        FRowValues[i] := VarFMTBcdCreate(bcd);
                                                end;      }
                                        end;
                                end;
                        end;
                end;
        except
                on e: exception do begin
                        //raise Exception.Create(MsgStr + #13#10 + e.Message + FRowValues[1]);
                end;
        end;
end;

function TGFDataSet.RecIsNull(FieldIndex: integer): boolean;
begin
       result := FRowValues[FieldIndex] = null;
end;

procedure TGFDataSet.CreateDataSet(GFData: IGFData);
begin
        if Active then Close;

        FIsPrepare := false;

        FGFData := GFData;

        UpdateDataSet;

        FRecordCount := FGFInputHead.dataNumber;

        Open;
end;


{procedure TPBDataSet.WaitEvent;
begin
        //阻塞模式
        if (FPBData <> nil)  then begin
                if (FPBData.WaitMode = wmBlocking) then begin
                        WaitForSingleObject(FPBData.WaitEvent, INFINITE);
                        UpdateDataSet;
                end;
        end;
end;   }

procedure TGFDataSet.UpdateDataSet;
var
        Buffer: TBytes;
begin
        if Active then Close;

        if (FGFData <> nil) and (FGFData.Succeed) then begin

                if FGFInput <> nil then FGFInput.Free;

                //拷贝数据
                setlength(Buffer, FGFData.Size);                         //给动态数组定义长度
                Move((Pointer(FGFData.Data))^, Buffer[0], FGFData.Size);

                FGFInput := TJSONObject.ParseJSONValue(Buffer, 0, true) as TJSONObject;

                PrepareDataHead;

                FRecordCount := FGFInputHead.dataNumber;
                Open;
        end;
end;

function TGFDataSet.CreateBlobStream(Field: TField; Mode: TBlobStreamMode): TStream;
begin
        result := TGFBlobStream.Create(Field);
end;

function TGFDataSet.GetRecIndex: integer;
var
        SortIndex: integer;
begin
        if FIsSort then begin
                SortIndex := Integer(FSortList[PRecInfo(ActiveBuffer)^.RecNO - 1]);

                if FIsFilter then
                        result :=Integer(FFilterList[SortIndex - 1])
                else result := SortIndex;

        end else begin
                if FIsFilter then
                        result :=  Integer(FFilterList[PRecInfo(ActiveBuffer)^.RecNO - 1])
                else result := PRecInfo(ActiveBuffer)^.RecNO;
        end;
end;

function TGFDataSet.HeadToString: string;
var
        i, len: integer;
        f: string;
        function TypeToString(v: integer): string;
        begin
                case v of
                        1: result := 'Int      ';
                        2: result := 'Int64    ';
                        3: result := 'Decimal  ';
                        4: result := 'Float    ';
                        5: result := 'Double   ';
                        6: result := 'String   ';
                        7: result := 'Binary   ';
                        8: result := 'DateTime ';
                        9: result := 'Text     ';
                        10:result := 'Deimail_B';
                        else          
                           result := 'Unkonw   ';
                end;
        end;

begin
        result := '';
        if Active then begin
                len := 10;
                for i := 0 to FGFInputHead.fieldNumber - 1 do begin
                        if Len < length(FGFInputFields[i].colname) then
                                Len := length(FGFInputFields[i].colname)
                end;

                result := format('名称%' + inttostr(len-4) + 's'#9'类型     '#9'长度     '#9'精度', [' ']);
                f := '%-' + inttostr(len) + 's'#9'%9s'#9'%-9d'#9'%-4d';
                for i := 0 to FGFInputHead.fieldNumber - 1 do begin
                        result := result + #13#10 + format(f, [FGFInputFields[i].colname, TypeToString(FGFInputFields[i].colTypeNumber), FGFInputFields[i].colpresion,  FGFInputFields[i].colscale]);
                end;
        end;
end;

function TGFDataSet.Get_SortFieldsName: string;
begin
//        result := FSortFieldsName;
end;

procedure TGFDataSet.Set_SortFieldsName(const Value: string);
begin
     {   if FSortFieldsName <> Value then begin
                FSortFieldsName := Value;

                if FSortFieldsName <> nil then begin

                        //
                end;
        end;   }
end;

{ TGFBlobStream }

constructor TGFBlobStream.Create(Field: TField);
var
        StrValue: AnsiString;
        FieldIndex: integer;
//        RecObj: TJSONArray;
//        Value: TJSONValue;
begin
        FDataSet := TGFDataSet(Field.DataSet);
        with FDataSet do begin
                PrepareRecData(GetRecIndex - 1);

                FieldIndex := Field.FieldNo - 1;
                if RecIsNull(FieldIndex) then FSize := 0
                else begin
                        //7 binary  9 Text
                        if FGFInputFields[FieldIndex].colTypeNumber = 7 then begin

                                FSize := 0;
                                FBlobData := nil;

                        end else if FGFInputFields[FieldIndex].colTypeNumber = 9 then begin
                                StrValue := AnsiString(FRowValues[FieldIndex]);
                                FSize := Length(StrValue);
                                GetMem(FBlobData, FSize);

                                AnsiStrings.StrLCopy(PAnsiChar(FBlobData), PAnsiChar(StrValue), Length(StrValue));


                        end else FSize := 0;
                end;
        end;
end;

destructor TGFBlobStream.Destroy;
begin

        if FBlobData <> nil then begin
                FreeMem(FBlobData);
                FBlobData := nil;
        end;
        inherited Destroy;
end;

function TGFBlobStream.GetSize: Int64;
begin
        result := FSize;
end;

function TGFBlobStream.Read(var Buffer; Count: Integer): Longint;
begin
        if Count > integer(FSize) then Count := FSize;

        if (FBlobData <> nil) then begin
                move(FBlobData^, Buffer, Count);
                result := count;
        end else result := 0;
end;

procedure TGFBlobStream.SaveToStream(Stream: TStream);
begin
        if FSize <> 0 then Stream.WriteBuffer(FBlobData^, FSize);
end;

function TGFBlobStream.Seek(Offset: Integer; Origin: Word): Longint;
begin
        result := 0;
end;

function TGFBlobStream.Write(const Buffer; Count: Integer): Longint;
begin
        result := 0;
end;

begin
   GetFormatSettings;
   FormatSettings :=  SysUtils.FormatSettings;

   FormatSettings.ThousandSeparator:=' ';
   FormatSettings.DateSeparator:='-';
   FormatSettings.TimeSeparator:=':';
   FormatSettings.LongTimeFormat:='YYYY-MM-DD HH:MM:SS';

end.



