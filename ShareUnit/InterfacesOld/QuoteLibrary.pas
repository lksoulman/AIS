unit QuoteLibrary;

interface

uses windows, Classes, SysUtils,Ansistrings;
{$L zIBCode.obj}

type
  //索引
  TIndexData = array [0..1000000] of Int64;
  PIndexData = ^TIndexData;
  AnsiChar6 = array [0..5] of AnsiChar;

  PPHash64Item = ^PHash64Item;
  PHash64Item = ^THash64Item;
  THash64Item = record
    Next: PHash64Item;
    Key: string;
    Value: Int64;
  end;

  TString64Hash = class
  private
    Buckets: array of PHash64Item;
  protected
    function Find(const Key: string): PPHash64Item;
    function HashOf(const Key: string): Cardinal; virtual;
  public
    constructor Create(Size: Cardinal = 256);
    destructor Destroy; override;
    procedure Add(const Key: string; Value: Int64);
    procedure Clear;
    procedure Remove(const Key: string);
    function Modify(const Key: string; Value: Int64): Boolean;
    function ValueOf(const Key: string): Int64;
  end;

  PPHashItem = ^PHashItem;
  PHashItem = ^THashItem;
  THashItem = record
    Next: PHashItem;
    Key: Int64;
    Value: Int64;
  end;

  TIntegerHash = class
  private
    FSize: integer;
    Buckets: array of PHashItem;
    FEmpty: boolean;
    FTag: Int64;
  protected
    function Find(const Key: Int64): PPHashItem;
  public
    constructor Create(ShlBit: Cardinal = 6);
    destructor Destroy; override;
    procedure Add(const Key: Int64; Value: Int64);
    procedure Clear;
    property IsEmpty: boolean read FEmpty;
    procedure Remove(const Key: Int64);
    function Modify(const Key: Int64; Value: Int64): Boolean;
    function ValueOf(const Key: Int64): Int64; overload;
    function ValueOf(const Key: Int64; var Value: Int64): boolean; overload;
    property Tag: Int64 read FTag write FTag;
  end;

  IIntegerList = Interface
    ['{4232C2A7-D804-4E8B-A709-681604C30458}']
    function GetCount: integer; safecall;
    function GetItems(Index: integer): Int64; safecall;
    function GetIndexList: PIndexData; safecall;
    function IndexOf(Value: Int64): Integer;   safecall;
    function GetTag: Int64; safecall;
    procedure SetCount(const Value: integer);  safecall;
    procedure SetItems(Index: integer; const Value: Int64); safecall;
    procedure SetTag(const Value: Int64); safecall;

    property Items[Index: integer]: Int64 read GetItems write SetItems;
    property Count: integer read GetCount write SetCount;
    property IndexList: PIndexData read GetIndexList;
    property Tag: Int64 read GetTag write SetTag;
  end;

  TIntegerList = class(TInterfacedObject, IIntegerList)
  private
    FTag: integer;
    FIndexList: PIndexData;
    FCapacity: integer; //容量
    FCount: integer;    //个数
    function DeltaCount(Value: integer): integer;
    procedure GrowList; virtual;
    procedure SetCount(const Value: integer);  safecall;
    function GetItems(Index: integer): Int64; safecall;
    procedure SetItems(Index: integer; const Value: Int64);  safecall;
    function GetTag: Int64; safecall;
    function GetCount: integer; safecall;
    function GetIndexList: PIndexData; safecall;
    procedure SetTag(const Value: Int64); safecall;
  public
    constructor Create;
    destructor Destroy; override;
    procedure InitItems;
    function Add(value: Int64): integer;
    procedure Delete(Index: integer);
    procedure Insert(Index: integer; Value: Int64);
    property Items[Index: integer]: Int64 read GetItems write SetItems; default;
    property Count: integer read GetCount write SetCount;
    property IndexList: PIndexData read GetIndexList;
    function IndexOf(Value: Int64): integer;   safecall;
    procedure Clean; virtual;
    property Tag: Int64 read GetTag write SetTag;
  end;


  function FloorSize(V, M: integer): integer;

  procedure StocksBit64Index(var Bit64: Int64; Index: integer);
  function IntToDate(RQ: integer): TDate;
  function DateToInt(RQ: TDate): Integer;

  procedure FreeAndClean(List: TList);
  function MinuteDateToDate(indate: Cardinal): Cardinal;  //取分钟K线中的奇葩日期时间 中的日期 结果 YYYYMMDD格式整数
  function MinuteDateToHQTime(indate: UINT): UINT;  //取分钟K线中的奇葩日期时间 中的时间 结果 HHMMSS格式
  function DateTimeToMinuteDate(Atime: TDatetime): UINT;
  function DateToMinuteDate(indate: integer): integer;
  function MinCountToHHMM(ATime:Integer):Integer; //当日的分钟数转换为 结果 HHMM格式的整数
  function IncHHMMMin(ATime:Integer;ACount:Integer):Integer; //HHMM格式的整数时间增加分钟数 结果HHMM格式的整数

  //function CodeToStr( Code: array of AnsiChar): string;


  {*
  * 如果压缩成功则返回0，返回其他值表示失败；
  * 如果返回-1，表示输入参数错误；
  * 如果返回-2；表示编码后的长度超过6个字节
  * 如果返回-3；表示输入的字符串长度为0或者超过11字节；
  * 如果返回-4；表示输入的字符串中含有特殊字符（非字母数字的类型）
  * *}
  function encodeInterbankBondCode(pCode: PAnsiChar; pOut: AnsiChar6): Integer; cdecl; external;

  {*
  * 如果返回0表示解压成功，否则失败；
  * 如果返回-1，表示输入编码错误；
  * 如果返回-2，表示输入的pCode长度不够；
  * *}
  function decodeInterbankBondCode(pIn: AnsiChar6; pCode: PAnsiChar; iCodeBuffLen: integer): Integer; cdecl; external;

  procedure WriteLogx(const Msg: string);

implementation

procedure WriteLogx(const Msg: string);
//var
//        WinNetLog: string;
begin
{//        try
                WinNetLog := 'f:\QuoteMngr.log';
                AssignFile(F, WinNetLog);
                try
                        if FileExists(WinNetLog) then Append(F)
                        else Rewrite(F);
                        WriteLn(F, FormatDateTime('yyyy"年"mm"月"dd"日 "hh"点"mm"分"ss"秒"', Now));
                        WriteLn(F, Msg);
                        WriteLn(F,'');
                finally CloseFile(F); end;
      //  except end;          }
end;

//function CodeToStr( Code: array of AnsiChar): string;
//begin
//        result := string(copy(code, 0, 6));
//end;

procedure FreeAndClean(List: TList);
var
        i: Integer;
begin
        for i := 0 to List.Count - 1 do
                TObject(List[i]).Free;
        List.Clear;
end;

function MinuteDateToDate(indate: Cardinal): Cardinal;
begin
  indate := indate div 10000;
	if( (indate div 100000) > 0 )  then
  begin //2000年之后      20151009 1220
    indate := indate - 100000;
		indate := indate + 20000000;
  end
  else  //2000年之前                    19901009 1220
    indate := indate + 19000000;

	result := indate;
end;

function MinuteDateToHQTime(indate: UINT): UINT;
begin
	Result := indate mod 10000 * 100; //div 100;
	//AMinute :=indate mod 100;

  //result := DWORD(AHour) * 3600 + DWORD(AMinute) * 60;
end;

function DateToMinuteDate(indate: integer): integer;
begin
  //2000 年以后（2020年之后有BUG）     20151009 1111
	if( (indate div 20000000) > 0 )  then
  begin
		indate := indate - 20000000;
    indate := indate + 100000;
  end else //2000年之前
      indate := indate - 19000000;
	result := indate;
end;

function DateTimeToMinuteDate(Atime: TDatetime): UINT;
var
  Hour,Min,Sec,MSec:Word;
begin
  Result := DateToMinuteDate(DateToInt(Atime));
  DecodeTime(Atime,Hour,Min,Sec,MSec);
  Result := Result * 10000 + Hour * 100 + Min;
end;


function IntToDate(RQ: integer): TDate;
var
	Yea, Mon, Day: word;
begin
	Yea:=RQ div 10000;
	Mon:=(RQ - Yea * 10000)div 100 ;
	Day:= RQ - Yea * 10000 - Mon * 100;
	result := EncodeDate(Yea, Mon, Day);
end;

function DateToInt(RQ: TDate): Integer;
var
        Yea, Mon ,Day: Word;
begin
        DecodeDate(RQ, Yea, Mon, Day);
        Result:= Yea * 10000 + Mon * 100 + Day;
end;

function FloorSize(V, M: integer): integer;
begin
        result := V div M;
        if V mod M > 0 then inc(result);
end;

procedure StocksBit64Index(var Bit64: Int64; Index: integer);
begin
        //类似 Mod 64
        Bit64 := Bit64 or (1 shl (Index and 63));
end;

{ TString64Hash }

procedure TString64Hash.Add(const Key: string; Value: Int64);
var
        Hash: Integer;
        Bucket: PHash64Item;
begin
        Hash := HashOf(Key) mod Cardinal(Length(Buckets));
        New(Bucket);
        Bucket^.Key := Key;
        Bucket^.Value := Value;
        Bucket^.Next := Buckets[Hash];
        Buckets[Hash] := Bucket;
end;

procedure TString64Hash.Clear;
var
        I: Integer;
        P, N: PHash64Item;
begin
        for I := 0 to Length(Buckets) - 1 do begin
                P := Buckets[I];
                while P <> nil do begin
                        N := P^.Next;
                        Dispose(P);
                        P := N;
                end;
                Buckets[I] := nil;
        end;
end;

constructor TString64Hash.Create(Size: Cardinal);
begin
        inherited Create;
        SetLength(Buckets, Size);
end;

destructor TString64Hash.Destroy;
begin
        Clear;
        inherited Destroy;
end;

function TString64Hash.Find(const Key: string): PPHash64Item;
var
        Hash: Integer;
begin
        Hash := HashOf(Key) mod Cardinal(Length(Buckets));
        Result := @Buckets[Hash];
        while Result^ <> nil do begin
                if Result^.Key = Key then
                        Exit
                else Result := @Result^.Next;
        end;
end;

function TString64Hash.HashOf(const Key: string): Cardinal;
var
        I: Integer;
begin
        Result := 0;
        for I := 1 to Length(Key) do
                Result := ((Result shl 2) or (Result shr (SizeOf(Result) * 8 - 2))) xor
                        Ord(Key[I]);
end;

function TString64Hash.Modify(const Key: string; Value: Int64): Boolean;
var
        P: PHash64Item;
begin
        P := Find(Key)^;
        if P <> nil then begin
                Result := True;
                P^.Value := Value;
        end else Result := False;
end;

procedure TString64Hash.Remove(const Key: string);
var
        P: PHash64Item;
        Prev: PPHash64Item;
begin
        Prev := Find(Key);
        P := Prev^;
        if P <> nil then begin
                Prev^ := P^.Next;
                Dispose(P);
        end;
end;

function TString64Hash.ValueOf(const Key: string): Int64;
var
        P: PHash64Item;
begin
        P := Find(Key)^;
        if P <> nil then
                Result := P^.Value
        else
                Result := -1;
end;


{ TIntegerHash }

procedure TIntegerHash.Add(const Key: Int64; Value: Int64);
var
        Hash: Int64;
        Bucket: PHashItem;
begin
        Hash := Abs(Key) and (FSize - 1);   //这个结果不会出现负数

        New(Bucket);
        Bucket^.Key := Key;
        Bucket^.Value := Value;
        Bucket^.Next := Buckets[Hash];
        Buckets[Hash] := Bucket;

        FEmpty := false;
end;

procedure TIntegerHash.Clear;
var
        I: Integer;
        P, N: PHashItem;
begin
        for I := 0 to Length(Buckets) - 1 do begin
                P := Buckets[I];
                while P <> nil do begin
                        N := P^.Next;
                        Dispose(P);
                        P := N;
                end;
                Buckets[I] := nil;
        end;
        FEmpty := true;
end;

constructor TIntegerHash.Create(ShlBit: Cardinal);
begin
        FSize := 1 shl ShlBit;
        SetLength(Buckets, FSize);
        FEmpty := true;
end;

destructor TIntegerHash.Destroy;
begin
        Clear;
        inherited Destroy;
end;

function TIntegerHash.Find(const Key: Int64): PPHashItem;
var
        Hash: Int64;
begin
        Hash := Abs(Key) and (FSize - 1);   //这个结果不会出现负数
        Result := @Buckets[Hash];
        while Result^ <> nil do begin
                if Result^.Key = Key then
                        Exit
                else Result := @Result^.Next;
        end;
end;

function TIntegerHash.Modify(const Key: Int64; Value: Int64): Boolean;
var
        P: PHashItem;
begin
        P := Find(Key)^;
        if P <> nil then begin
                Result := True;
                P^.Value := Value;
        end else Result := False;
end;

procedure TIntegerHash.Remove(const Key: Int64);
var
        P: PHashItem;
        Prev: PPHashItem;
begin
        Prev := Find(Key);
        P := Prev^;
        if P <> nil then begin
                Prev^ := P^.Next;
                Dispose(P);
        end;
end;

function TIntegerHash.ValueOf(const Key: Int64): Int64;
var
        P: PHashItem;
begin
        P := Find(Key)^;
        if P <> nil then
                Result := P^.Value
        else Result := -1;
end;

function TIntegerHash.ValueOf(const Key: Int64; var Value: Int64): boolean;
var
        P: PHashItem;
begin
        P := Find(Key)^;
        if P <> nil then begin
                Value := P^.Value;
                result := true;
        end else result := false;
end;

{ TIntegerList }
constructor TIntegerList.Create;
begin
        Clean;
end;

destructor TIntegerList.Destroy;
begin
        Clean;
        inherited Destroy;
end;

function TIntegerList.Add(Value: Int64): integer;
begin
        if FCount = FCapacity then GrowList;
        FIndexList^[FCount] := Value;
        result := FCount;
        Inc(FCount);
end;

procedure TIntegerList.Clean;
begin
        if Assigned(FIndexList) then
                FreeMem(FIndexList, 0);
        FIndexList := nil;
        FCapacity := 0;
        FCount := 0;
end;

function TIntegerList.DeltaCount(Value: integer): integer;
begin
        if value > 64 then result := value + value div 4
        else if value > 8 then result := value + 16
        else result := value + 4;
end;

function TIntegerList.GetItems(Index: integer): Int64;
begin
        result := FIndexList^[Index];
end;

procedure TIntegerList.GrowList;
begin
        FCapacity := DeltaCount(FCapacity);
        ReallocMem(FIndexList, FCapacity * SizeOf(int64));
end;

procedure TIntegerList.SetCount(const Value: integer);
begin
        if Value > FCapacity then begin
                FCapacity := Value;
                ReallocMem(FIndexList, FCapacity * SizeOf(int64));
        end;
        FCount := Value;
end;

function TIntegerList.IndexOf(Value: Int64): integer;
var
        i: integer;
begin
        result := -1;
        for i := 0 to FCount - 1 do begin
                if Items[i] = Value then begin
                        result := i;
                        break;
                end;
        end;
end;

procedure TIntegerList.SetItems(Index: integer; const Value: Int64);
begin
        if Index < FCount then
                FIndexList^[Index] := Value;
end;

procedure TIntegerList.InitItems;
begin
        if FCount > 0 then
                FillMemory(FIndexList, FCount * SizeOf(Int64), 0);
end;

procedure TIntegerList.Delete(Index: integer);
begin
        Dec(FCount);
        if Index < FCount then
                System.Move(FIndexList^[Index + 1], FIndexList^[Index], (FCount - Index) * SizeOf(Int64));
end;

procedure TIntegerList.Insert(Index: integer; Value: Int64);
begin
        if FCount = FCapacity then GrowList;
        if Index < FCount then  System.Move(FIndexList^[Index], FIndexList^[Index + 1],  (FCount - Index) * SizeOf(Int64));
        FIndexList^[Index] := Value;
        Inc(FCount);
end;

function TIntegerList.GetCount: integer;
begin
        result := FCount;
end;

function TIntegerList.GetIndexList: PIndexData;
begin
        result := FIndexList;
end;

function TIntegerList.GetTag: Int64;
begin
        result := FTag;
end;

procedure TIntegerList.SetTag(const Value: Int64);
begin
        FTag := Value;
end;

procedure memset(p: Pointer; b: Byte; count: Integer); cdecl;
begin
        FillChar(p^, count, b);
end;

function strlen(Str :PAnsiChar): integer; cdecl;
begin
        result := Ansistrings.StrLen(Str);
end;

function MinCountToHHMM(ATime:Integer):Integer; //当日的分钟数转换为 HHMM格式的整数
begin
  //前一天
  if ATime < 0  then ATime := ATime + 60 * 24;
  if ATime < 0 then exit(0);
  ATime := ATime mod 24 * 60;
  result := ATime div 60 * 100 + ATime mod 60;
end;

function IncHHMMMin(ATime:Integer;ACount:Integer):Integer;
begin
  if ATime < 0 then ATime := 0;
  ATime := ATime div 100 * 60 + ATime mod 100 + ACount;
  Result := MinCountToHHMM(ATime);
end;

end.
