unit BizPacket2Impl;

interface

uses
  dialogs, windows, SysUtils, Classes, Variants, BizPacket, WinSock;

const
  /// 结果集名最大长度
  MaxDatasetName = 32;
  /// 字段名最大长度
  MaxFieldName = 64;
  /// 每个结果集可能长度   结果集名+结果集头+字段信息
  MinDatasetSize = 512;
  /// 当前版本
  CurrentVersion = $21;
  /// 整数最大长度
  MaxIntWidth = 20;
  /// 浮点数最大长度
  MaxFloatWidth = 24;
  /// 每次内存扩大的最小长度
  MinMemoryIncrement = 1024;
  /// 每次扩大字段数的最小个数
  MinFieldIncrement = 32;

  /// 分隔符号
  SOH = #0;
  /// 列数的长度
  ColCountLength = 4; // 10;
  /// 行数的长度
  RowCountLength = 8;
  /// 结果集头长度
  DatasetHeadLength = (ColCountLength + 1 + RowCountLength + 1);

  /// 一个业务数据包中最多结果集个数
  MAX_DATASET = 32;

type

  /// 业务包头部
  PBizPackHead = ^TBizPackHead;

  TBizPackHead = record
    /// 版本，目前为0x21
    Version: Byte;
    /// 结果集数量，>=1
    DatasetCount: Byte;
    /// 业务包头长度
    HeadSize: Byte;
  end;

  /// 结果集头部(不包括前面变长的结果集名称)
  PDatasetHead = ^TDatasetHead;

  TDatasetHead = record
    /// 列数
    ColCount: Integer;
    /// 行数
    RowCount: Integer;
    /// 结果集长度（不包括本头部）
    DatasetLength: Integer;
    /// 返回值，一般非0表示错误
    ReturnCode: Integer;
  end;

  /// 列描述（不包括前面变长的列名称）
  PFieldInfo = ^TFieldInfo;

  TFieldInfo = packed record
    /// I整数，F浮点，C字符，S字符串，R任意二进制数据
    FieldType: AnsiChar;
    /// 最大长度
    Width: Integer;
    /// F时小数点位数
    Scale: Byte;
  end;

  TBiz2FieldImpl = class(TBizField)
  private
    FFieldName: AnsiString;
    FFieldNo: Integer;
    FFieldType: AnsiChar;
    FWidth: Integer;
    FScale: Byte;
    FValue: OleVariant;
  public
    procedure InternalSet(const FieldName: AnsiString; FieldNo: Integer; FieldType: AnsiChar; Width: Integer;
      Scale: Byte);
    procedure InternalSetValue(const Ptr: PAnsiChar);
    procedure ClearValue;

  protected
    function GetFieldName: AnsiString; override;
    function GetFieldNo: Integer; override;
    function GetFieldType: AnsiChar; override;
    function GetWidth: Integer; override;
    function GetScale: Byte; override;
    function GetValue: OleVariant; override;
    procedure SetValue(Value: OleVariant); override;
  end;

  TBiz2DatasetImpl = class(TBizDataset)
  private
    FDatasetName: AnsiString;
    FDatasetNo: Integer;
    FDatasetLen: Integer; // liangyong 080625
    FColCount: Integer;
    FRowCount: Integer;
    FReturnCode: Integer;
    FNullField: TBiz2FieldImpl;
    FFields: array of TBiz2FieldImpl;
    FFieldNames: TStringList;
    FBOF: Boolean;
    FEOF: Boolean;
    FRowNo: Integer;
    FPtrArray: array of Pointer;
    procedure InternalInit(const DatasetName: AnsiString; DatasetNo, ColCount, RowCount, ReturnCode, SetLen: Integer);
    procedure SetField(Index: Integer; const FieldName: AnsiString; FieldType: AnsiChar; Width: Integer; Scale: Byte);
    procedure SetValue(Index: Integer; const val: Pointer);
    procedure SetFieldsValue;
    function IndexOf(const FieldName: AnsiString): Integer;
  protected
    function GetDatasetName: AnsiString; override;
    function GetDatasetNo: Integer; override;
    function GetColCount: Integer; override;
    function GetRowCount: Integer; override;
    function GetReturnCode: Integer; override;
    function GetField(varField: OleVariant): TBizField; override;
    function GetBOF: Boolean; override;
    function GetEOF: Boolean; override;
    function GetRowNo: Integer; override;
    function GetExist(const FieldName: AnsiString): Boolean; override;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Move(Rows: Integer); override;
    procedure Go(Row: Integer); override;
    procedure MoveFirst; override;
    procedure MoveLast; override;
    procedure MoveNext; override;
    procedure MovePrev; override;
  end;

  TBiz2Packer = class(TBizPacker)
  private
    FBuffer: PAnsiChar;
    FSize: Integer;
    FLength: Integer;
    FPackHead: PBizPackHead;
    FCurHead: PDatasetHead;
    FFields: array of TBiz2FieldImpl;
    FFieldsCapacity: Integer;
    FDatasetCount: Integer;
    FDatasetHeadOffset: Integer;
    procedure ExtendBuffer(ExpectSize: Integer);
    procedure EndDataset;
  protected

    function GetField(varIndex: OleVariant): TBizField; override;
  public
    constructor Create;
    destructor Destroy; override;
    function GetData: Pointer; override;
    function GetDataLength: Integer; override;
    procedure BeginPack; override;
    procedure NewDataset(const DatasetName: AnsiString; ReturnCode: Integer = 0); override;
    procedure SetReturnCode(ReturnCode: Integer); override;
    procedure AddField(const FieldName: AnsiString; FieldType: AnsiChar; Width: Integer; Scale: Byte); override;
    procedure AddIntField(const FieldName: AnsiString); override;
    procedure AddFloatField(const FieldName: AnsiString; Scale: Byte = 3); override;
    procedure AddStringField(const FieldName: AnsiString; Width: Integer); override;
    procedure AddRawField(const FieldName: AnsiString; Width: Integer); override;
    procedure NewLine; override;
    procedure EndPack; override;
    // 20081224 caozh add 根据解包器对象打包 ,解包器中如果有多条记录只解第一条记录，这个BizUnpacker 必须完成过Open,使用这个函数时先BeginPack,调完后，EndPack
    procedure CreateRequestPaker(BizUnpacker: TObject); override;
  end;

  // 版本2的解包器
  TBiz2Unpacker = class(TBizUnpacker)
  private
    FBuffer: PAnsiChar;
    FSize: Integer;
    FLength: Integer;
    FDatasets: array of TBiz2DatasetImpl;
    FDatasetCount: Integer;
    FCurrentDataset: TBizDataset;
  protected
    procedure ParseDataSet(var Data: PAnsiChar; DataLength: Integer);
    function GetFieldName(iCount: Integer): AnsiString; override;
    function GetVersion: Byte; override;
    function GetDatasetCount: Integer; override;
    function GetDataset(varDataset: OleVariant): TBizDataset; override;
    function GetDatasetName: AnsiString; override;
    function GetColCount: Integer; override;
    function GetRowCount: Integer; override;
    function GetReturnCode: Integer; override;
    function GetField(varField: OleVariant): TBizField; override;
    function GetBOF: Boolean; override;
    function GetEOF: Boolean; override;
    function GetRowNo: Integer; override;
    function GetExist(const FieldName: AnsiString): Boolean; override;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Open(const Data: Pointer; DataLength: Integer); override;
    procedure SetCurrentDataset(varDataset: OleVariant); override;
    procedure Move(Rows: Integer); override;
    procedure Go(Row: Integer); override;
    procedure MoveFirst; override;
    procedure MoveLast; override;
    procedure MoveNext; override;
    procedure MovePrev; override;
  end;

implementation

// TBiz2FieldImpl

procedure TBiz2FieldImpl.InternalSet(const FieldName: AnsiString; FieldNo: Integer; FieldType: AnsiChar; Width: Integer;
  Scale: Byte);
begin
  FFieldName := FieldName;
  FFieldType := FieldType;
  FWidth := Width;
  FScale := Scale;
  FFieldNo := FieldNo;
  VarClear(FValue);
end;

procedure TBiz2FieldImpl.InternalSetValue(const Ptr: PAnsiChar);
var
  i: Integer;
  P: PAnsiChar;
  pv: Pointer;
begin
  if FFieldType = 'I' then
    FValue := StrToIntDef(Ptr, 0)
  else if FFieldType = 'F' then
    try
      FValue := StrToFloat(Ptr);
    except
      FValue := 0.0;
    end
  else if FFieldType = 'C' then
    FValue := Ptr^
  else if FFieldType = 'R' then
  begin
    P := Ptr;
    i := WinSock.ntohl(PInteger(Ptr)^);
    FValue := Null;
    if i > 0 then
    begin
      Inc(P, sizeof(Integer));
      FValue := VarArrayCreate([0, i - 1], varByte);
      pv := VarArrayLock(FValue);
      Move(P^, pv^, i);
      VarArrayUnlock(FValue);
    end;
  end
  else
    FValue := AnsiString(Ptr);
end;

procedure TBiz2FieldImpl.ClearValue;
begin
  VarClear(FValue);
end;

function TBiz2FieldImpl.GetFieldName: AnsiString;
begin
  Result := FFieldName;
end;

function TBiz2FieldImpl.GetFieldNo: Integer;
begin
  Result := FFieldNo;
end;

function TBiz2FieldImpl.GetFieldType: AnsiChar;
begin
  Result := FFieldType;
end;

function TBiz2FieldImpl.GetWidth: Integer;
begin
  Result := FWidth;
end;

function TBiz2FieldImpl.GetScale: Byte;
begin
  Result := FScale;
end;

function TBiz2FieldImpl.GetValue: OleVariant;
begin
  Result := FValue;
end;

procedure TBiz2FieldImpl.SetValue(Value: OleVariant);
begin
  FValue := Value;
end;

// TBiz2DatasetImpl

constructor TBiz2DatasetImpl.Create;
begin
  inherited;
  FNullField := TBiz2FieldImpl.Create;
  FNullField.InternalSet('', -1, 'S', 1, 0);
  FNullField.Value := '';
  FFieldNames := TStringList.Create;
  FFieldNames.CaseSensitive := True;
  // 20090114 zhengsq add
  FFieldNames.Sorted := True; // 让他们自动加入时排序
end;

destructor TBiz2DatasetImpl.Destroy;
var
  i: Integer;
begin
  // SetLength(FItems, 0);
  SetLength(FPtrArray, 0);
  for i := Length(FFields) - 1 downto 0 do
    FFields[i].Free;
  SetLength(FFields, 0);
  FFieldNames.Free;
  FNullField.Free;
  inherited;
end;

procedure TBiz2DatasetImpl.InternalInit(const DatasetName: AnsiString; DatasetNo, ColCount, RowCount, ReturnCode,
  SetLen: Integer);
var
  i: Integer;
begin
  i := Length(FFields);
  if i < ColCount then
  begin
    SetLength(FFields, ColCount);
    while i < ColCount do
    begin
      FFields[i] := TBiz2FieldImpl.Create;
      Inc(i);
    end;
  end;
  FFieldNames.Clear;
  // FFieldNames.Sorted := False;  20090114 caozh mod

  if Length(FPtrArray) < ColCount * RowCount then
    SetLength(FPtrArray, ColCount * RowCount); // yzq FPtrArray
  FColCount := ColCount;
  FDatasetName := DatasetName;
  FDatasetNo := DatasetNo;
  FDatasetLen := SetLen;
  FColCount := ColCount;
  FRowCount := RowCount;
  FReturnCode := ReturnCode;
end;

procedure TBiz2DatasetImpl.SetField(Index: Integer; const FieldName: AnsiString; FieldType: AnsiChar; Width: Integer;
  Scale: Byte);
begin
  FFields[Index].InternalSet(FieldName, Index, FieldType, Width, Scale);
  FFieldNames.AddObject(FieldName, Pointer(Index));
end;

procedure TBiz2DatasetImpl.SetValue(Index: Integer; const val: Pointer);
begin
  FPtrArray[Index] := val;
end;

procedure TBiz2DatasetImpl.SetFieldsValue;
var
  i, Index: Integer;
begin
  Index := FRowNo * FColCount;
  for i := 0 to FColCount - 1 do
  begin
    FFields[i].InternalSetValue(FPtrArray[Index]);
    Inc(Index);
  end;
end;

function TBiz2DatasetImpl.IndexOf(const FieldName: AnsiString): Integer;
begin
  // 20090114 zhengsq del
  { if not FFieldNames.Sorted then
    FFieldNames.Sort; }
  Result := FFieldNames.IndexOf(FieldName);
  if Result >= 0 then
    Result := Integer(FFieldNames.Objects[Result]);
end;

function TBiz2DatasetImpl.GetDatasetName: AnsiString;
begin
  Result := FDatasetName;
end;

function TBiz2DatasetImpl.GetDatasetNo: Integer;
begin
  Result := FDatasetNo;
end;

function TBiz2DatasetImpl.GetColCount: Integer;
begin
  Result := FColCount;
end;

function TBiz2DatasetImpl.GetRowCount: Integer;
begin
  Result := FRowCount;
end;

function TBiz2DatasetImpl.GetReturnCode: Integer;
begin
  Result := FReturnCode;
end;

function TBiz2DatasetImpl.GetField(varField: OleVariant): TBizField;
var
  Index: Integer;
begin
  Result := FNullField;
  if VarIsStr(varField) then
    Index := IndexOf(varField)
  else
    Index := varField;
  if (Index >= 0) and (Index < FColCount) then
    Result := FFields[Index];
end;

function TBiz2DatasetImpl.GetBOF: Boolean;
begin
  Result := FBOF;
end;

function TBiz2DatasetImpl.GetEOF: Boolean;
begin
  Result := FEOF;
end;

function TBiz2DatasetImpl.GetRowNo: Integer;
begin
  Result := FRowNo;
end;

function TBiz2DatasetImpl.GetExist(const FieldName: AnsiString): Boolean;
begin
  Result := IndexOf(FieldName) >= 0;
end;

procedure TBiz2DatasetImpl.Move(Rows: Integer);
begin
  if Rows > 0 then
  begin
    if FRowNo + Rows < FRowCount then
    begin
      Inc(FRowNo, Rows);
      SetFieldsValue;
      FBOF := False;
      FEOF := False;
    end
    else
    begin
      MoveLast;
      FEOF := True;
    end;
  end
  else if Rows < 0 then
  begin
    if FRowNo + Rows >= 0 then
    begin
      Inc(FRowNo, Rows);
      SetFieldsValue;
      FBOF := False;
      FEOF := False;
    end
    else
    begin
      MoveFirst;
      FBOF := True;
    end;
  end;
end;

procedure TBiz2DatasetImpl.Go(Row: Integer);
begin
  Move(Row - FRowNo);
end;

procedure TBiz2DatasetImpl.MoveFirst;
begin
  if FRowCount <> 0 then
  begin
    FRowNo := 0;
    SetFieldsValue;
    FEOF := False;
    FBOF := False;
  end
  else
  begin
    FEOF := True;
    FBOF := True;
  end;
end;

procedure TBiz2DatasetImpl.MoveLast;
begin
  if FRowCount <> 0 then
  begin
    FRowNo := FRowCount - 1;
    SetFieldsValue;
    FEOF := False;
    FBOF := False;
  end
  else
  begin
    FEOF := True;
    FBOF := True;
  end;
end;

procedure TBiz2DatasetImpl.MoveNext;
begin
  if FRowNo + 1 < FRowCount then
  begin
    Inc(FRowNo);
    SetFieldsValue;
    FEOF := False;
    FBOF := False;
  end
  else
  begin
    FEOF := True;
  end;
end;

procedure TBiz2DatasetImpl.MovePrev;
begin
  if FRowNo > 0 then
  begin
    Dec(FRowNo);
    SetFieldsValue;
    FEOF := False;
    FBOF := False;
  end
  else
  begin
    FBOF := True;
  end;
end;

// TBiz1Packer

constructor TBiz2Packer.Create;
begin
  inherited;
  FBuffer := nil;
  FSize := 0;
  FLength := 0;
  FPackHead := nil;
  FCurHead := nil;
  FFieldsCapacity := 0;
end;

destructor TBiz2Packer.Destroy;
var
  i: Integer;
begin
  FreeMem(FBuffer);
  for i := Length(FFields) - 1 downto 0 do
    FFields[i].Free;
  SetLength(FFields, 0);

  inherited;
end;

procedure TBiz2Packer.ExtendBuffer(ExpectSize: Integer);
begin
  // 扩大内存保留余量，以减少可能的扩大次数
  if ExpectSize < FSize + MinMemoryIncrement then
  begin
    if FSize > 8 * MinMemoryIncrement then
      ExpectSize := FSize + FSize div 4
    else
      ExpectSize := FSize + MinMemoryIncrement;
  end;
  ReallocMem(FBuffer, ExpectSize);
  //
  FPackHead := PBizPackHead(FBuffer);
  FCurHead := PDatasetHead(FBuffer + FDatasetHeadOffset);
  FSize := ExpectSize;
end;

procedure TBiz2Packer.EndDataset;
begin
  NewLine;
  if FDatasetHeadOffset <> 0 then
  begin
    // FCurHead := PDatasetHead(FBuffer + FDatasetHeadOffset);
    FCurHead.ColCount := WinSock.htonl(FCurHead.ColCount);
    FCurHead.RowCount := WinSock.htonl(FCurHead.RowCount);
    FCurHead.DatasetLength := WinSock.htonl(FCurHead.DatasetLength);
    FCurHead.ReturnCode := WinSock.htonl(FCurHead.ReturnCode);
  end;
end;

function TBiz2Packer.GetData: Pointer;
begin
  Result := FBuffer;
end;

function TBiz2Packer.GetDataLength: Integer;
begin
  Result := FLength;
end;

function TBiz2Packer.GetField(varIndex: OleVariant): TBizField;
var
  Index: Integer;
  function IndexOf(const FieldName: AnsiString): Integer;
  var
    i: Integer;
  begin
    Result := -1;
    for i := 0 to FCurHead.ColCount - 1 do
    begin
      if FFields[i].FieldName = FieldName then
      begin
        Result := i;
        Break;
      end;
    end
  end;

begin
  Result := nil;
  if VarIsStr(varIndex) then
    Index := IndexOf(varIndex)
  else
    Index := varIndex;
  if (Index >= 0) and (Index < FCurHead.ColCount) then
    Result := FFields[Index];
end;

procedure TBiz2Packer.BeginPack;
begin
  // 判断空间是否足够，不够则扩大，应该只发生在第一次被调用
  if FSize < MinDatasetSize then
    ExtendBuffer(MinDatasetSize);

  // 设置包头
  FPackHead := PBizPackHead(FBuffer);
  FPackHead.Version := CurrentVersion;
  FPackHead.HeadSize := sizeof(TBizPackHead);
  FPackHead.DatasetCount := 0;

  FLength := sizeof(TBizPackHead);

  // 设置第一个结果集头 无结果集名
  (FBuffer + FLength)^ := #0;
  Inc(FLength);
  FDatasetHeadOffset := FLength;
  FCurHead := PDatasetHead(FBuffer + FDatasetHeadOffset);
  FCurHead.ColCount := 0;
  FCurHead.RowCount := 0;
  FCurHead.DatasetLength := 0;
  FCurHead.ReturnCode := 0;

  Inc(FLength, sizeof(TDatasetHead));
  FDatasetCount := 1;
end;

procedure TBiz2Packer.NewDataset(const DatasetName: AnsiString; ReturnCode: Integer);
var
  SetNameLen, n: Integer;
begin
  if FDatasetCount < MAX_DATASET then
  begin
    // 新增
    if (FSize - FLength) < MinDatasetSize then
      ExtendBuffer(FLength + MinDatasetSize);
    EndDataset;

    SetNameLen := Length(DatasetName);
    // 设置结果集名
    if SetNameLen > MaxDatasetName then
      SetNameLen := MaxDatasetName;

    n := SetNameLen + sizeof(TDatasetHead) + 1;
    if (FSize - FLength) < n then
      ExtendBuffer(FLength + n);

    Move(PAnsiChar(DatasetName)^, (FBuffer + FLength)^, SetNameLen);
    Inc(FLength, SetNameLen);

    (FBuffer + FLength)^ := #0;
    Inc(FLength);
    FDatasetHeadOffset := FLength;
    FCurHead := PDatasetHead(FBuffer + FDatasetHeadOffset);
    FCurHead.ColCount := 0;
    FCurHead.RowCount := 0;
    FCurHead.DatasetLength := 0;
    FCurHead.ReturnCode := 0;

    Inc(FDatasetCount);
    Inc(FLength, sizeof(TDatasetHead));
    // FCurHead.ColCount := 0;
    // FCurHead.RowCount := 0;
  end;
end;

procedure TBiz2Packer.SetReturnCode(ReturnCode: Integer);
begin
  if FDatasetHeadOffset > 0 then
  begin
    // FCurHead := PDatasetHead(FBuffer + FDatasetHeadOffset);
    FCurHead.ReturnCode := ReturnCode;
  end;
end;

procedure TBiz2Packer.AddField(const FieldName: AnsiString; FieldType: AnsiChar; Width: Integer; Scale: Byte);
var
  i, len, n: Integer;
  FieldInfo: PFieldInfo;
begin
  if (FieldType <> 'I') and (FieldType <> 'S') and (FieldType <> 'F') and (FieldType <> 'R') then
    raise Exception.CreateFmt('Not support field type "%s".', [FieldType]);
  if FFieldsCapacity <= FCurHead.ColCount then
  begin
    SetLength(FFields, FFieldsCapacity + MinFieldIncrement);
    for i := FFieldsCapacity to FFieldsCapacity + MinFieldIncrement - 1 do
      FFields[i] := TBiz2FieldImpl.Create;
    Inc(FFieldsCapacity, MinFieldIncrement);
  end;
  len := Length(FieldName);
  if len > MaxFieldName then
    len := MaxFieldName;
  n := len + 1 + sizeof(TFieldInfo);
  if (FSize - FLength) < n then
    ExtendBuffer(FLength + n);
  StrPLCopy(FBuffer + FLength, FieldName, len);
  Inc(FLength, len);

  (FBuffer + FLength)^ := SOH;
  Inc(FLength);

  FieldInfo := PFieldInfo(FBuffer + FLength);
  FieldInfo^.FieldType := FieldType;
  FieldInfo^.Width := WinSock.htonl(Width);
  FieldInfo^.Scale := Scale;
  Inc(FLength, sizeof(TFieldInfo));

  FFields[FCurHead.ColCount].InternalSet(FieldName, FCurHead.ColCount, FieldType, Width, Scale);
  Inc(FCurHead.ColCount);
  Inc(FCurHead.DatasetLength, len + 1 + sizeof(TFieldInfo));
end;

procedure TBiz2Packer.AddIntField(const FieldName: AnsiString);
begin
  AddField(FieldName, 'I', MaxIntWidth, 0);
end;

procedure TBiz2Packer.AddFloatField(const FieldName: AnsiString; Scale: Byte);
begin
  AddField(FieldName, 'F', MaxFloatWidth, Scale);
end;

procedure TBiz2Packer.AddStringField(const FieldName: AnsiString; Width: Integer);
begin
  AddField(FieldName, 'S', Width, 4);
end;

procedure TBiz2Packer.AddRawField(const FieldName: AnsiString; Width: Integer);
begin
  AddField(FieldName, 'R', Width, 0);
end;

procedure TBiz2Packer.NewLine;
var
  i, n: Integer;
  Field: TBiz2FieldImpl;
  Str: AnsiString;
  ValueLen: Integer;
  v: Variant;
  pv: Pointer;

  uBound, lBound: LongWord;
  RawBuf: Pointer;
begin
  if FCurHead.ColCount <= 0 then
    Exit;
  for i := 0 to FCurHead.ColCount - 1 do
  begin
    Field := FFields[i];

    // 往 FBuffer 加值
    case Field.FieldType of
      'I':
        try
          Str := VarAsType(Field.Value, varInteger);
        except
          Str := '0';
        end;
      'S':
        Str := VarToStrDef(Field.Value, '');
      'F':
        try
          Str := Format('%.*f', [Field.Scale, Double(VarAsType(Field.Value, varDouble))]);
        except
          Str := Format('%.*f', [Field.Scale, 0.0]);
        end;
      'C':
        begin
          Str := VarToStrDef(Field.Value, '');
          if Str <> '' then
            Str := Str[1] + SOH
          else
            Str := #0 + SOH;
        end;
      'R':
        v := Field.Value;
    else
      Str := '';
    end;
    if Field.FFieldType <> 'R' then
    begin
      ValueLen := Length(Str) + 1; // 包括#0一起复制
      if FSize - FLength <= ValueLen then
        ExtendBuffer(FLength + ValueLen + 1);
      Move(PAnsiChar(Str)^, (FBuffer + FLength)^, ValueLen);
      Inc(FLength, ValueLen);
      Inc(FCurHead.DatasetLength, ValueLen);
    end
    else
    begin
      if VarIsType(v, varByte or varArray) or (VarArrayDimCount(v) <> 1) then
      begin
        // ValueLen := 0;
        // liangyong 20081226 修改
        lBound := VarArrayLowBound(v, 1);
        uBound := VarArrayHighBound(v, 1);
        ValueLen := uBound - lBound + 1;
        // liangyong 20081226 caozh mod 20081227
        n := sizeof(LongWord) + 1 + ValueLen;
        if FSize - FLength < n then
          ExtendBuffer(FLength + n);
        PLongWord(FBuffer + FLength)^ := WinSock.htonl(ValueLen);
        Inc(FLength, sizeof(LongWord));
        // liangyong 20081226 修改
        RawBuf := VarArrayLock(v);
        // Move(PAnsiChar(RawBuf)^, (FBuffer + FLength)^, ValueLen);
        windows.CopyMemory(PAnsiChar(FBuffer + FLength), RawBuf, ValueLen);
        VarArrayUnlock(v);
        Inc(FLength, ValueLen);
        // liangyong 20081226
        (FBuffer + FLength)^ := SOH;
        Inc(FLength);
        Inc(FCurHead.DatasetLength, sizeof(LongWord) + ValueLen + 1);
      end
      else
      begin
        ValueLen := VarArrayHighBound(v, 1) - VarArrayLowBound(v, 1) + 1;
        n := ValueLen + sizeof(LongWord) + 1;
        if FSize - FLength < n then
          ExtendBuffer(FLength + n);
        PLongWord(FBuffer + FLength)^ := WinSock.htonl(ValueLen);
        Inc(FLength, sizeof(LongWord));
        pv := VarArrayLock(v);
        Move(pv^, (FBuffer + FLength)^, ValueLen);
        VarArrayUnlock(v);
        Inc(FLength, ValueLen);
        (FBuffer + FLength)^ := SOH;
        Inc(FLength);
        Inc(FCurHead.DatasetLength, sizeof(LongWord) + ValueLen + 1);
      end;
    end;
    VarClear(Field.FValue);
  end;
  Inc(FCurHead.RowCount);
end;

procedure TBiz2Packer.EndPack;
begin
  EndDataset;
  FPackHead := PBizPackHead(FBuffer);
  FPackHead.DatasetCount := FDatasetCount;
end;


// TBizUnPacker2

constructor TBiz2Unpacker.Create;
begin
  inherited;
  FBuffer := nil;
  FSize := 0;
  FLength := 0;
  FDatasetCount := 0;
  FCurrentDataset := nil;
end;

destructor TBiz2Unpacker.Destroy;
var
  i: Integer;
begin
  FreeMem(FBuffer);
  for i := Length(FDatasets) - 1 downto 0 do
    FDatasets[i].Free;
  SetLength(FDatasets, 0);
  inherited;
end;

function TBiz2Unpacker.GetVersion: Byte;
begin
  Result := $21;
end;

function TBiz2Unpacker.GetDatasetCount: Integer;
begin
  Result := FDatasetCount;
end;

function TBiz2Unpacker.GetDataset(varDataset: OleVariant): TBizDataset;
var
  Index: Integer;
  function IndexOf(const ADatasetName: AnsiString): Integer;
  var
    i: Integer;
  begin
    Result := -1;
    for i := 0 to FDatasetCount - 1 do
    begin
      if FDatasets[i].DatasetName = ADatasetName then
      begin
        Result := i;
        Break;
      end;
    end
  end;

begin
  Result := nil;
  if VarIsStr(varDataset) then
    Index := IndexOf(varDataset)
  else
    Index := varDataset;
  if (Index >= 0) and (Index < FDatasetCount) then
    Result := FDatasets[Index];
end;

function TBiz2Unpacker.GetDatasetName: AnsiString;
begin
  Result := '';
  if FCurrentDataset <> nil then
    Result := FCurrentDataset.DatasetName;
end;

function TBiz2Unpacker.GetColCount: Integer;
begin
  Result := 0;
  if FCurrentDataset <> nil then
    Result := FCurrentDataset.ColCount;
end;

function TBiz2Unpacker.GetRowCount: Integer;
begin
  Result := 0;
  if FCurrentDataset <> nil then
    Result := FCurrentDataset.RowCount;
end;

function TBiz2Unpacker.GetReturnCode: Integer;
begin
  Result := -1;
  if FCurrentDataset <> nil then
    Result := FCurrentDataset.ReturnCode;
end;

function TBiz2Unpacker.GetField(varField: OleVariant): TBizField;
begin
  Result := nil;
  if FCurrentDataset <> nil then
    Result := FCurrentDataset.Field[varField];
end;

function TBiz2Unpacker.GetFieldName(iCount: Integer): AnsiString;
begin
  Result := '';
end;

function TBiz2Unpacker.GetBOF: Boolean;
begin
  Result := True;
  if FCurrentDataset <> nil then
    Result := FCurrentDataset.BOF;
end;

function TBiz2Unpacker.GetEOF: Boolean;
begin
  Result := True;
  if FCurrentDataset <> nil then
    Result := FCurrentDataset.EOF;
end;

function TBiz2Unpacker.GetRowNo: Integer;
begin
  Result := 0;
  if FCurrentDataset <> nil then
    Result := FCurrentDataset.RowNo;
end;

function TBiz2Unpacker.GetExist(const FieldName: AnsiString): Boolean;
begin
  Result := False;
  if FCurrentDataset <> nil then
    Result := FCurrentDataset.Exist[FieldName];
end;

procedure TBiz2Unpacker.ParseDataSet(var Data: PAnsiChar; DataLength: Integer);
var
  Head: PDatasetHead;
  Field: PFieldInfo;
  PackEnd, SetEnd: PAnsiChar;
  SetName, FieldName: PAnsiChar;
  i, J, K: Integer;
  RawLen: Integer;
  ColCount, RowCount, DatasetLen, ReturnCode: Integer;
  IntP: PInteger;
begin
  PackEnd := Data + DataLength;
  i := 0;
  while Data < PackEnd do
  begin
    // 处理结果集名
    SetName := Data;
    Inc(Data, StrLen(Data) + 1); // 跳过SOH
    if Data + sizeof(TDatasetHead) > PackEnd then
      Exit
    else
    begin
      // 分析结果集头
      Head := PDatasetHead(Data);

      ColCount := WinSock.ntohl(Head.ColCount);
      RowCount := WinSock.ntohl(Head.RowCount);
      ReturnCode := WinSock.ntohl(Head.ReturnCode);
      DatasetLen := WinSock.ntohl(Head.DatasetLength);
      SetEnd := Data + sizeof(TDatasetHead) + DatasetLen;
      if SetEnd > PackEnd then
        Exit;

      FDatasets[i].InternalInit(SetName, i, ColCount, RowCount, ReturnCode, DatasetLen);

      Inc(Data, sizeof(TDatasetHead));

      for J := 0 to ColCount - 1 do
      begin
        // 分析列信息
        FieldName := Data;
        Inc(Data, StrLen(FieldName) + 1);

        Field := PFieldInfo(Data);
        if Data + sizeof(TFieldInfo) > SetEnd then
          Exit;
        FDatasets[i].SetField(J, FieldName, Field.FieldType, WinSock.ntohl(Field.Width), Field.Scale);
        Inc(Data, sizeof(TFieldInfo));
      end;

      // 分析内容
      for J := 0 to RowCount - 1 do
      begin
        for K := 0 to ColCount - 1 do
        begin
          if FDatasets[i].FFields[K].FieldType = 'R' then
          begin
            IntP := PInteger(Data);
            RawLen := WinSock.ntohl(IntP^);
            if (RawLen < 0) or (RawLen > FDatasets[i].FFields[K].Width) then
              Exit;
            FDatasets[i].SetValue(K + J * ColCount, Data);
            Inc(Data, sizeof(LongWord) + RawLen + 1);
          end
          else
          begin
            FDatasets[i].SetValue(K + J * ColCount, Data);
            // 20090212 caozh mod 对VCHAR类型，数据应该是#0#0的方式
            {
              在AS端，如果一个char类字段不存时，其值是返回0(ASCII值，打在包里还是0，对delphi是#0)；
              对于一个整型或浮点字段不存在时其值返回0，打在包里是字符’0’，Ansi为$30；
              对于字符串不存在是，返回的是NULL,打到包里是空串(只有一个字符，#0);
            }
            if (FDatasets[i].FFields[K].FieldType = 'C') and (Data^ = #0) then
              Inc(Data, 2)
            else
              Inc(Data, StrLen(Data) + 1);
          end;

        end;
      end;
      if Data <> SetEnd then
        Exit;
    end;
    Inc(i);
    Inc(FDatasetCount);
  end;
end;

procedure TBiz2Unpacker.Open(const Data: Pointer; DataLength: Integer);
var
  PackHead: PBizPackHead;
  L: Integer;
  P: PAnsiChar;
begin
  FDatasetCount := 0; // 可用来判断open成功与否
  FCurrentDataset := nil;
  if FSize < DataLength then
  begin
    ReallocMem(FBuffer, DataLength);
    FSize := DataLength;
  end;
  CopyMemory(FBuffer, Data, DataLength);
  P := FBuffer;
  PackHead := PBizPackHead(FBuffer);
  if (PackHead.Version >= $21) and (PackHead.Version < $30) then
  begin
    L := Length(FDatasets);
    if L < PackHead.DatasetCount then
      SetLength(FDatasets, PackHead.DatasetCount);
    while L <= PackHead.DatasetCount - 1 do
    begin
      FDatasets[L] := TBiz2DatasetImpl.Create;
      Inc(L);
    end;
    Inc(P, PackHead.HeadSize);
    ParseDataSet(P, DataLength - PackHead.HeadSize);
    if FCurrentDataset = nil then
    begin
      if FDatasetCount > 0 then
      begin
        FCurrentDataset := FDatasets[0];
        FCurrentDataset.MoveFirst;
      end;
    end;
  end;
end;

procedure TBiz2Unpacker.SetCurrentDataset(varDataset: OleVariant);
var
  Dataset: TBizDataset;
begin
  Dataset := GetDataset(varDataset);
  if Dataset <> nil then
  begin
    FCurrentDataset := Dataset;
    Dataset.MoveFirst;
  end;
end;

procedure TBiz2Unpacker.Move(Rows: Integer);
begin
  if FCurrentDataset <> nil then
    FCurrentDataset.Move(Rows);
end;

procedure TBiz2Unpacker.Go(Row: Integer);
begin
  if FCurrentDataset <> nil then
    FCurrentDataset.Go(Row);
end;

procedure TBiz2Unpacker.MoveFirst;
begin
  if FCurrentDataset <> nil then
    FCurrentDataset.MoveFirst;
end;

procedure TBiz2Unpacker.MoveLast;
begin
  if FCurrentDataset <> nil then
    FCurrentDataset.MoveLast;
end;

procedure TBiz2Unpacker.MoveNext;
begin
  if FCurrentDataset <> nil then
    FCurrentDataset.MoveNext;
end;

procedure TBiz2Unpacker.MovePrev;
begin
  if FCurrentDataset <> nil then
    FCurrentDataset.MovePrev;
end;

procedure TBiz2Packer.CreateRequestPaker(BizUnpacker: TObject);
var
  iCount: Integer;
  FieldName: AnsiString;
  FieldType: AnsiChar;
  Width: Integer;
  Scale: Byte;
  BizUnp: TBizUnpacker;
begin
  inherited;
  if BizUnpacker = nil then
    Exit;
  if Not(BizUnpacker is TBizUnpacker) then
    Exit;
  try
    BizUnp := TBizUnpacker(BizUnpacker);
  except
    Exit;
  end;
  if BizUnp.ColCount > 0 then // 分解列
  begin
    for iCount := 0 to BizUnp.ColCount - 1 do // 压字段
    begin
      try
        FieldName := BizUnp.Field[iCount].FieldName;
        FieldType := BizUnp.Field[iCount].FieldType;
        Width := BizUnp.Field[iCount].Width;
        Scale := BizUnp.Field[iCount].Scale;
        AddField(FieldName, FieldType, Width, Scale);
        Field[iCount].Value := BizUnp.Field[iCount].Value
      except
      end;
    end;
    // 压值
  end;
end;

end.
