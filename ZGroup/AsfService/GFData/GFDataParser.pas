unit GFDataParser;

interface

uses System.Classes, System.SysUtils, System.RTLConsts, System.Character;

type

{ TGFDataParser }

  TGFDataParser = class(TObject)
  private type
    TCharType = (ctOther, ctLetterStart, ctLetterNumber, ctNumber, ctHash, ctQuote, ctDollar, ctDash);
  private
    FStream: TStream;
    FOrigin: Longint;
    FBuffer: TBytes;
    FBufPtr: Integer;
    FBufEnd: Integer;
    FSourcePtr: Integer;
    FSourceEnd: Integer;
    FTokenPtr: Integer;
    FStringPtr: Integer;
    FSourceLine: Integer;
    FSaveChar: Byte;
    FToken: Char;
    FFloatType: Char;
    FWideStr: TCharArray;
    FOnError: TParserErrorEvent;
    FEncoding: TEncoding;
    FFormatSettings: TFormatSettings;
    procedure ReadBuffer;
    procedure SkipBlanks;
    function CharType(var ABufPos: Integer): TCharType;
  protected
    function GetLinePos: Integer;
  public
    constructor Create(Stream: TStream; Encoding: TEncoding; AOnError: TParserErrorEvent = nil); overload;
    constructor Create(Stream: TStream; const FormatSettings: TFormatSettings; Encoding: TEncoding; AOnError: TParserErrorEvent = nil); overload;
    destructor Destroy; override;
    procedure CheckToken(T: Char);
    procedure CheckTokenSymbol(const S: string);
    procedure Error(const Ident: string);
    procedure ErrorFmt(const Ident: string; const Args: array of const);
    procedure ErrorStr(const Message: string);
    procedure HexToBinary(Stream: TStream);
    function NextToken: Char;
    function SourcePos: Longint;
    function TokenComponentIdent: string;
    function TokenFloat: Extended;
    function TokenInt: Int64;
    function TokenString: string;
    function TokenWideString: UnicodeString;
    function TokenSymbolIs(const S: string): Boolean;
    property FloatType: Char read FFloatType;
    property SourceLine: Integer read FSourceLine;
    property LinePos: Integer read GetLinePos;
    property Token: Char read FToken;
    property OnError: TParserErrorEvent read FOnError write FOnError;
  end;

implementation

{ TGFDataParser }

const
   ParseBufSize = 4096;

constructor TGFDataParser.Create(Stream: TStream; Encoding: TEncoding; AOnError: TParserErrorEvent = nil);
begin
  { Call the other constructor. Use default format settings. }
  Create(Stream, FormatSettings, Encoding, AOnError);
end;

constructor TGFDataParser.Create(Stream: TStream; const FormatSettings: TFormatSettings; Encoding: TEncoding; AOnError: TParserErrorEvent = nil);
var
  Size: integer;
begin
  inherited Create;
  FFormatSettings := FormatSettings;
  FStream := Stream;


  if Stream.size = 0 then
        Size :=  ParseBufSize
  else Size := Stream.Size + 2;

  SetLength(FBuffer, Size); //为了一次取出
  FBuffer[0] := 0;
  FBufPtr := 0;
  FBufEnd := Size - 1;
  FSourcePtr := 0;
  FSourceEnd := 0;
  FTokenPtr := 0;
  FSourceLine := 1;
  FOnError := AOnError;
  ReadBuffer;
  FEncoding := Encoding;
 // FSourcePtr := FSourcePtr + TEncoding.GetBufferEncoding(FBuffer, FEncoding);
 // if (FEncoding = nil) or ((FEncoding <> TEncoding.ASCII) and (FEncoding <> TEncoding.ANSI) and (FEncoding <> TEncoding.UTF8)) then
 //   Error(SAnsiUTF8Expected);

  NextToken;
end;

destructor TGFDataParser.Destroy;
begin
  if Length(FBuffer) > 0 then
    FStream.Seek(Int64(FTokenPtr) - Int64(FBufPtr), TSeekOrigin.soCurrent);
  inherited Destroy;
end;
function UTF8Len(B: Byte): Integer; inline;
begin
  case B of
    $00..$7F: Result := 1; //
    $C2..$DF: Result := 2; // 110x xxxx C0 - DF
    $E0..$EF: Result := 3; // 1110 xxxx E0 - EF
    $F0..$F7: Result := 4; // 1111 0xxx F0 - F7 // outside traditional UNICODE
  else
    Result := 0; // Illegal leading character.
  end;
end;

function UTF8ToCategory(const ABuffer: TBytes; var ABufPos: Integer): TUnicodeCategory;
var
  CharSize: Integer;
  C: UCS4Char;
begin
  CharSize := UTF8Len(ABuffer[ABufPos]);
  Assert((CharSize > 0) and (CharSize + ABufPos < Length(ABuffer)), 'Invalid UTF8 Character'); // do not localize
  case CharSize of
    1: C := UCS4Char(ABuffer[ABufPos]);
    2: C := UCS4Char(((ABuffer[ABufPos] and $1F) shl 6 ) or (ABuffer[ABufPos + 1] and $3F));
    3: C := UCS4Char(((ABuffer[ABufPos] and $0F) shl 12) or ((ABuffer[ABufPos + 1] and $3F) shl 6 ) or (ABuffer[ABufPos + 2] and $3F));
    4: C := UCS4Char(((ABuffer[ABufPos] and $07) shl 18) or ((ABuffer[ABufPos + 1] and $3F) shl 12) or ((ABuffer[ABufPos + 2] and $3F) shl 6) or (ABuffer[ABufPos + 2] and $3F));
  else
    C := 0;
  end;
  Inc(ABufPos, CharSize);
  if C > $0000FFFF then
    Result := Char.GetUnicodeCategory(Char.ConvertFromUtf32(C), 1)
  else
    Result := Char.GetUnicodeCategory(C);
end;

function TGFDataParser.CharType(var ABufPos: Integer): TCharType;
begin
  Inc(ABufPos);
  case Char(FBuffer[ABufPos - 1]) of
    'A'..'Z', 'a'..'z', '_': Result := ctLetterStart;
    '0'..'9': Result := ctNumber;
    '#': Result := ctHash;
    '-': Result := ctDash;
    '$': Result := ctDollar;
    '"': Result := ctQuote;
  else
    if (FEncoding = TEncoding.UTF8) and (FBuffer[ABufPos - 1] > 127) then
    begin
      Dec(ABufPos);
      case UTF8ToCategory(FBuffer, ABufPos) of
        TUnicodeCategory.ucLowercaseLetter,
        TUnicodeCategory.ucModifierLetter,
        TUnicodeCategory.ucOtherLetter,
        TUnicodeCategory.ucTitlecaseLetter,
        TUnicodeCategory.ucUppercaseLetter,
        TUnicodeCategory.ucLetterNumber:
          Result := ctLetterStart;

        TUnicodeCategory.ucCombiningMark,
        TUnicodeCategory.ucNonSpacingMark,
        TUnicodeCategory.ucConnectPunctuation,
        TUnicodeCategory.ucFormat,
        TUnicodeCategory.ucDecimalNumber:
          Result := ctLetterNumber;
      else
        Result := ctOther;
      end;
    end else
      Result := ctOther;
  end;
end;

procedure TGFDataParser.CheckToken(T: Char);
begin
  if Token <> T then
    case T of
      toSymbol:
        Error(SIdentifierExpected);
      System.Classes.toString, toWString:
        Error(SStringExpected);
      toInteger, toFloat:
        Error(SNumberExpected);
    else
      ErrorFmt(SCharExpected, [T]);
    end;
end;

procedure TGFDataParser.CheckTokenSymbol(const S: string);
begin
  if not TokenSymbolIs(S) then
    ErrorFmt(SSymbolExpected, [S]);
end;

procedure TGFDataParser.Error(const Ident: string);
begin
  ErrorStr(Ident);
end;

procedure TGFDataParser.ErrorFmt(const Ident: string; const Args: array of const);
begin
  ErrorStr(Format(Ident, Args));
end;

procedure TGFDataParser.ErrorStr(const Message: string);
var
  Handled: Boolean;
begin
  Handled := False;
  if Assigned(FOnError) then
    FOnError(Self, Message, Handled);
  if not Handled then
    raise EParserError.CreateResFmt(@SParseError, [Message, FSourceLine]);
end;

function TGFDataParser.GetLinePos: Integer;
begin
  Result := FTokenPtr - LineStart(FBuffer, FTokenPtr);
end;

procedure TGFDataParser.HexToBinary(Stream: TStream);
var
  Count: Integer;
  Buffer: TBytes;
begin
  SetLength(Buffer, 256);
  SkipBlanks;
  while Char(FBuffer[FSourcePtr]) <> '}' do
  begin
    Count := HexToBin(FBuffer, FSourcePtr, Buffer, 0, Length(Buffer));
    if Count = 0 then
    begin
      Error(SInvalidBinary);
      Exit;
    end;
    Stream.Write(Buffer, 0, Count);
    Inc(FSourcePtr, Count * 2);
    SkipBlanks;
  end;
  NextToken;
end;

function TGFDataParser.NextToken: Char;
var
  I, J: Integer;
  IsWideStr: Boolean;
  P, Q, S: Integer;
begin
  SkipBlanks;
  P := FSourcePtr;
  FTokenPtr := P;
  Q := P;
  case CharType(Q) of
    ctLetterStart:
      begin
        P := Q;
        while CharType(Q) in [ctLetterStart, ctLetterNumber, ctNumber] do
          P := Q;
        Result := toSymbol;
      end;
    ctHash, ctQuote:
      begin
        IsWideStr := False;
        J := 0;
        S := P;
        while True do
          case Char(FBuffer[P]) of
            '#':
              begin
                Inc(P);
                I := 0;
                while FBuffer[P] in [Ord('0')..Ord('9')] do
                begin
                  I := I * 10 + (FBuffer[P] - Ord('0'));
                  Inc(P);
                end;
                if (I > 127) then
                  IsWideStr := True;
                Inc(J);
              end;
            '"':
              begin
                Inc(P);
                while True do
                begin
                  case FBuffer[P] of
                    0{, 10, 13}:
                      begin
                        Error(SInvalidString);
                        Break;
                      end;
                    Ord('"'):
                      begin
                        Inc(P);
                        if Char(FBuffer[P]) <> '"' then
                          Break;
                      end;
                  end;
                  Inc(J);
                  Inc(P);
                end;
              end;
          else
            Break;
          end;
        P := S;
        if IsWideStr then
          SetLength(FWideStr, J);
        J := 0;
        while True do
          case Char(FBuffer[P]) of
            '#':
              begin
                Inc(P);
                I := 0;
                while FBuffer[P] in [Ord('0')..Ord('9')] do
                begin
                  I := I * 10 + (FBuffer[P] - Ord('0'));
                  Inc(P);
                end;
                if IsWideStr then
                begin
                  FWideStr[J] := WideChar(SmallInt(I));
                  Inc(J);
                end else
                begin
                  FBuffer[S] := I;
                  Inc(S);
                end;
              end;
            '"':
              begin
                Inc(P);
                while True do
                begin
                  case FBuffer[P] of
                    0{, 10, 13}:
                      begin
                        Error(SInvalidString);
                        Break;
                      end;
                    Ord('"'):
                      begin
                        Inc(P);
                        if FBuffer[P] <> Ord('"') then
                          Break;
                      end;
                  end;
                  if IsWideStr then
                  begin
                    FWideStr[J] := WideChar(FBuffer[P]);
                    Inc(J);
                  end else
                  begin
                    FBuffer[S] := FBuffer[P];
                    Inc(S);
                  end;
                  Inc(P);
                end;
              end;
          else
            Break;
          end;
        FStringPtr := S;
        if IsWideStr then
          Result := toWString
        else
          Result := System.Classes.toString;
      end;
    ctDollar:
      begin
        Inc(P);
        while FBuffer[P] in [Ord('0')..Ord('9'), Ord('A')..Ord('F'), Ord('a')..Ord('f')] do
          Inc(P);
        Result := toInteger;
      end;
    ctDash, ctNumber:
      begin
        Inc(P);
        while FBuffer[P] in [Ord('0')..Ord('9')] do
          Inc(P);
        Result := toInteger;
        while FBuffer[P] in [Ord('0')..Ord('9'), Ord('.'), Ord('e'), Ord('E'), Ord('+'), Ord('-')] do
        begin
          Inc(P);
          Result := toFloat;
        end;
        if FBuffer[P] in [Ord('c'), Ord('C'), Ord('d'), Ord('D'), Ord('s'), Ord('S'), Ord('f'), Ord('F')] then
        begin
          Result := toFloat;
          FFloatType := Char(FBuffer[P]);
          Inc(P);
        end else
          FFloatType := #0;
      end;
  else
    Result := Char(FBuffer[P]);
    if Result <> toEOF then
      Inc(P);
  end;
  FSourcePtr := P;
  FToken := Result;
end;

procedure TGFDataParser.ReadBuffer;
var
  Count: Integer;
begin
  Inc(FOrigin, FSourcePtr);
  FBuffer[FSourceEnd] := FSaveChar;
  Count := FBufPtr - FSourcePtr;
  if Count <> 0 then
    Move(FBuffer[FSourcePtr], FBuffer[0], Count);
  FBufPtr := Count;
  Inc(FBufPtr, FStream.Read(FBuffer, FBufPtr, FBufEnd - FBufPtr));
  FSourcePtr := 0;
  FSourceEnd := FBufPtr;
  if FSourceEnd = FBufEnd then
  begin
    FSourceEnd := LineStart(FBuffer, FSourceEnd - 1);
    if FSourceEnd = 0 then
      Error(SLineTooLong);
  end;
  FSaveChar := FBuffer[FSourceEnd];
  FBuffer[FSourceEnd] := 0;
end;

procedure TGFDataParser.SkipBlanks;
begin
  while True do
  begin
    case FBuffer[FSourcePtr] of
      0:
        begin
          ReadBuffer;
          if FBuffer[FSourcePtr] = 0 then
            Exit;
          Continue;
        end;
      10:
        Inc(FSourceLine);
      33..255:
        Exit;
    end;
    Inc(FSourcePtr);
  end;
end;

function TGFDataParser.SourcePos: Longint;
begin
  Result := FOrigin + FTokenPtr;
end;

function TGFDataParser.TokenFloat: Extended;
begin
  if FFloatType <> #0 then
    Dec(FSourcePtr);
  Result := StrToFloat(TokenString, FFormatSettings);
  if FFloatType <> #0 then
    Inc(FSourcePtr);
end;

function TGFDataParser.TokenInt: Int64;
begin
  Result := StrToInt64(TokenString);
end;

function TGFDataParser.TokenString: string;
var
  L: Integer;
begin
  if FToken = System.Classes.toString then
    L := FStringPtr - FTokenPtr
  else
    L := FSourcePtr - FTokenPtr;
  Result := FEncoding.GetString(FBuffer, FTokenPtr, L);
end;

function TGFDataParser.TokenWideString: UnicodeString;
begin
  if FToken = System.Classes.toString then
    Result := TokenString
  else
    Result := string.Create(FWideStr);
end;

function TGFDataParser.TokenSymbolIs(const S: string): Boolean;
begin
  Result := (Token = toSymbol) and SameText(S, TokenString);
end;

function TGFDataParser.TokenComponentIdent: string;
var
  P, Q: Integer;
begin
  CheckToken(toSymbol);
  P := FSourcePtr;
  while FBuffer[P] = Ord('.') do
  begin
    Inc(P);
    Q := P;
    if CharType(Q) <> ctLetterStart then
      Error(SIdentifierExpected);
    repeat
      P := Q;
    until not (CharType(Q) in [ctLetterStart, ctLetterNumber, ctNumber]);
  end;
  FSourcePtr := P;
  Result := TokenString;
end;
end.
