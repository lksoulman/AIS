{ ==============================================================================|
  | Project : Ararat Synapse                                       | 004.015.000 |
  |==============================================================================|
  | Content: support procedures and functions                                    |
  |==============================================================================|
  | Copyright (c)1999-2012, Lukas Gebauer                                        |
  | All rights reserved.                                                         |
  |                                                                              |
  | Redistribution and use in source and binary forms, with or without           |
  | modification, are permitted provided that the following conditions are met:  |
  |                                                                              |
  | Redistributions of source code must retain the above copyright notice, this  |
  | list of conditions and the following disclaimer.                             |
  |                                                                              |
  | Redistributions in binary form must reproduce the above copyright notice,    |
  | this list of conditions and the following disclaimer in the documentation    |
  | and/or other materials provided with the distribution.                       |
  |                                                                              |
  | Neither the name of Lukas Gebauer nor the names of its contributors may      |
  | be used to endorse or promote products derived from this software without    |
  | specific prior written permission.                                           |
  |                                                                              |
  | THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"  |
  | AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE    |
  | IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE   |
  | ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR  |
  | ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL       |
  | DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR   |
  | SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER   |
  | CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT           |
  | LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY    |
  | OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH  |
  | DAMAGE.                                                                      |
  |==============================================================================|
  | The Initial Developer of the Original Code is Lukas Gebauer (Czech Republic).|
  | Portions created by Lukas Gebauer are Copyright (c) 1999-2012.               |
  | Portions created by Hernan Sanchez are Copyright (c) 2000.                   |
  | Portions created by Petr Fejfar are Copyright (c)2011-2012.                  |
  | All Rights Reserved.                                                         |
  |==============================================================================|
  | Contributor(s):                                                              |
  |   Hernan Sanchez (hernan.sanchez@iname.com)                                  |
  |==============================================================================|
  | History: see HISTORY.HTM from distribution package                           |
  |          (Found at URL: http://www.ararat.cz/synapse/)                       |
  |============================================================================== }

{ :@abstract(Support procedures and functions) }

{$IFDEF FPC}
{$MODE DELPHI}
{$ENDIF}
{$Q-}
{$R-}
{$H+}
// old Delphi does not have MSWINDOWS define.
{$IFDEF WIN32}
{$IFNDEF MSWINDOWS}
{$DEFINE MSWINDOWS}
{$ENDIF}
{$ENDIF}
{$IFDEF UNICODE}
{$WARN IMPLICIT_STRING_CAST OFF}
{$WARN IMPLICIT_STRING_CAST_LOSS OFF}
{$WARN SUSPICIOUS_TYPECAST OFF}
{$ENDIF}
unit synautil;

interface

uses
{$IFDEF MSWINDOWS}
  Windows,
{$ELSE}
{$IFDEF FPC}
  UnixUtil, Unix, BaseUnix,
{$ELSE}
  Libc,
{$ENDIF}
{$ENDIF}
{$IFDEF CIL}
  System.IO,
{$ENDIF}
  SysUtils, Classes, SynaFpc;

{$IFDEF VER100}

type
  int64 = integer;
{$ENDIF}
  { :Return your timezone bias from UTC time in minutes. }
function TimeZoneBias: integer;

{ :Return your timezone bias from UTC time in string representation like "+0200". }
function TimeZone: string;

{ :Returns current time in format defined in RFC-822. Useful for SMTP messages,
  but other protocols use this time format as well. Results contains the timezone
  specification. Four digit year is used to break any Y2K concerns. (Example
  'Fri, 15 Oct 1999 21:14:56 +0200') }
function Rfc822DateTime(t: TDateTime): string;

{ :Returns date and time in format defined in C compilers in format "mmm dd hh:nn:ss" }
function CDateTime(t: TDateTime): string;

{ :Returns date and time in format defined in format 'yymmdd hhnnss' }
function SimpleDateTime(t: TDateTime): string;

{ :Returns date and time in format defined in ANSI C compilers in format
  "ddd mmm d hh:nn:ss yyyy" }
function AnsiCDateTime(t: TDateTime): string;

{ :Decode three-letter string with name of month to their month number. If string
  not match any month name, then is returned 0. For parsing are used predefined
  names for English, French and German and names from system locale too. }
function GetMonthNumber(Value: String): integer;

{ :Return decoded time from given string. Time must be witch separator ':'. You
  can use "hh:mm" or "hh:mm:ss". }
function GetTimeFromStr(Value: string): TDateTime;

{ :Decode string in format "m-d-y" to TDateTime type. }
function GetDateMDYFromStr(Value: string): TDateTime;

{ :Decode various string representations of date and time to Tdatetime type.
  This function do all timezone corrections too! This function can decode lot of
  formats like:
  @longcode(#
  ddd, d mmm yyyy hh:mm:ss
  ddd, d mmm yy hh:mm:ss
  ddd, mmm d yyyy hh:mm:ss
  ddd mmm dd hh:mm:ss yyyy #)

  and more with lot of modifications, include:
  @longcode(#
  Sun, 06 Nov 1994 08:49:37 GMT    ; RFC 822, updated by RFC 1123
  Sunday, 06-Nov-94 08:49:37 GMT   ; RFC 850, obsoleted by RFC 1036
  Sun Nov  6 08:49:37 1994         ; ANSI C's asctime() Format
  #)
  Timezone corrections known lot of symbolic timezone names (like CEST, EDT, etc.)
  or numeric representation (like +0200). By convention defined in RFC timezone
  +0000 is GMT and -0000 is current your system timezone. }
function DecodeRfcDateTime(Value: string): TDateTime;

{ :Return current system date and time in UTC timezone. }
function GetUTTime: TDateTime;

{ :Set Newdt as current system date and time in UTC timezone. This function work
  only if you have administrator rights! }
function SetUTTime(Newdt: TDateTime): Boolean;

{ :Return current value of system timer with precizion 1 millisecond. Good for
  measure time difference. }
function GetTick: LongWord;

{ :Return difference between two timestamps. It working fine only for differences
  smaller then maxint. (difference must be smaller then 24 days.) }
function TickDelta(TickOld, TickNew: LongWord): LongWord;

{ :Return two characters, which ordinal values represents the value in byte
  format. (High-endian) }
function CodeInt(Value: Word): Ansistring;

{ :Decodes two characters located at "Index" offset position of the "Value"
  string to Word values. }
function DecodeInt(const Value: Ansistring; Index: integer): Word;

{ :Return four characters, which ordinal values represents the value in byte
  format. (High-endian) }
function CodeLongInt(Value: LongInt): Ansistring;

{ :Decodes four characters located at "Index" offset position of the "Value"
  string to LongInt values. }
function DecodeLongInt(const Value: Ansistring; Index: integer): LongInt;

{ :Dump binary buffer stored in a string to a result string. }
function DumpStr(const Buffer: Ansistring): string;

{ :Dump binary buffer stored in a string to a result string. All bytes with code
  of character is written as character, not as hexadecimal value. }
function DumpExStr(const Buffer: Ansistring): string;

{ :Dump binary buffer stored in a string to a file with DumpFile filename. }
procedure Dump(const Buffer: Ansistring; DumpFile: string);

{ :Dump binary buffer stored in a string to a file with DumpFile filename. All
  bytes with code of character is written as character, not as hexadecimal value. }
procedure DumpEx(const Buffer: Ansistring; DumpFile: string);

{ :Like TrimLeft, but remove only spaces, not control characters! }
function TrimSPLeft(const S: string): string;

{ :Like TrimRight, but remove only spaces, not control characters! }
function TrimSPRight(const S: string): string;

{ :Like Trim, but remove only spaces, not control characters! }
function TrimSP(const S: string): string;

{ :Returns a portion of the "Value" string located to the left of the "Delimiter"
  string. If a delimiter is not found, results is original string. }
function SeparateLeft(const Value, Delimiter: string): string;

{ :Returns the portion of the "Value" string located to the right of the
  "Delimiter" string. If a delimiter is not found, results is original string. }
function SeparateRight(const Value, Delimiter: string): string;

{ :Returns parameter value from string in format:
  parameter1="value1"; parameter2=value2 }
function GetParameter(const Value, Parameter: string): string;

{ :parse value string with elements differed by Delimiter into stringlist. }
procedure ParseParametersEx(Value, Delimiter: string;
  const Parameters: TStrings);

{ :parse value string with elements differed by ';' into stringlist. }
procedure ParseParameters(Value: string; const Parameters: TStrings);

{ :Index of string in stringlist with same beginning as Value is returned. }
function IndexByBegin(Value: string; const List: TStrings): integer;

{ :Returns only the e-mail portion of an address from the full address format.
  i.e. returns 'nobody@@somewhere.com' from '"someone" <nobody@@somewhere.com>' }
function GetEmailAddr(const Value: string): string;

{ :Returns only the description part from a full address format. i.e. returns
  'someone' from '"someone" <nobody@@somewhere.com>' }
function GetEmailDesc(Value: string): string;

{ :Returns a string with hexadecimal digits representing the corresponding values
  of the bytes found in "Value" string. }
function StrToHex(const Value: Ansistring): string;

{ :Returns a string of binary "Digits" representing "Value". }
function IntToBin(Value: integer; Digits: Byte): string;

{ :Returns an integer equivalent of the binary string in "Value".
  (i.e. ('10001010') returns 138) }
function BinToInt(const Value: string): integer;

{ :Parses a URL to its various components. }
function ParseURL(URL: string; var Prot, User, Pass, Host, Port, Path,
  Para: string): string;

{ :Replaces all "Search" string values found within "Value" string, with the
  "Replace" string value. }
function ReplaceString(Value, Search, Replace: Ansistring): Ansistring;

{ :It is like RPos, but search is from specified possition. }
function RPosEx(const Sub, Value: string; From: integer): integer;

{ :It is like POS function, but from right side of Value string. }
function RPos(const Sub, Value: String): integer;

{ :Like @link(fetch), but working with binary strings, not with text. }
function FetchBin(var Value: string; const Delimiter: string): string;

{ :Fetch string from left of Value string. }
function Fetch(var Value: string; const Delimiter: string): string;

{ :Fetch string from left of Value string. This function ignore delimitesr inside
  quotations. }
function FetchEx(var Value: string; const Delimiter, Quotation: string): string;

{ :If string is binary string (contains non-printable characters), then is
  returned true. }
function IsBinaryString(const Value: Ansistring): Boolean;

{ :return position of string terminator in string. If terminator found, then is
  returned in terminator parameter.
  Possible line terminators are: CRLF, LFCR, CR, LF }
function PosCRLF(const Value: Ansistring; var Terminator: Ansistring): integer;

{ :Delete empty strings from end of stringlist. }
Procedure StringsTrim(const Value: TStrings);

{ :Like Pos function, buf from given string possition. }
function PosFrom(const SubStr, Value: String; From: integer): integer;

{$IFNDEF CIL}
{ :Increase pointer by value. }
function IncPoint(const p: pointer; Value: integer): pointer;
{$ENDIF}
{ :Get string between PairBegin and PairEnd. This function respect nesting.
  For example:
  @longcode(#
  Value is: 'Hi! (hello(yes!))'
  pairbegin is: '('
  pairend is: ')'
  In this case result is: 'hello(yes!)'#) }
function GetBetween(const PairBegin, PairEnd, Value: string): string;

{ :Return count of Chr in Value string. }
function CountOfChar(const Value: string; Chr: char): integer;

{ :Remove quotation from Value string. If Value is not quoted, then return same
  string without any modification. }
function UnquoteStr(const Value: string; Quote: char): string;

{ :Quote Value string. If Value contains some Quote chars, then it is doubled. }
function QuoteStr(const Value: string; Quote: char): string;

{ :Convert lines in stringlist from 'name: value' form to 'name=value' form. }
procedure HeadersToList(const Value: TStrings);

{ :Convert lines in stringlist from 'name=value' form to 'name: value' form. }
procedure ListToHeaders(const Value: TStrings);

{ :swap bytes in integer. }
function SwapBytes(Value: integer): integer;

{ :read string with requested length form stream. }
function ReadStrFromStream(const Stream: TStream; len: integer): Ansistring;

{ :write string to stream. }
procedure WriteStrToStream(const Stream: TStream; Value: Ansistring);

{ :Return filename of new temporary file in Dir (if empty, then default temporary
  directory is used) and with optional filename prefix. }
function GetTempFile(const Dir, prefix: Ansistring): Ansistring;

{ :Return padded string. If length is greater, string is truncated. If length is
  smaller, string is padded by Pad character. }
function PadString(const Value: Ansistring; len: integer; Pad: AnsiChar)
  : Ansistring;

{ :XOR each byte in the strings }
function XorString(Indata1, Indata2: Ansistring): Ansistring;

{ :Read header from "Value" stringlist beginning at "Index" position. If header
  is Splitted into multiple lines, then this procedure de-split it into one line. }
function NormalizeHeader(Value: TStrings; var Index: integer): string;

{ pf }
{ :Search for one of line terminators CR, LF or NUL. Return position of the
  line beginning and length of text. }
procedure SearchForLineBreak(var APtr: PANSIChar; AEtx: PANSIChar;
  out ABol: PANSIChar; out ALength: integer);
{ :Skip both line terminators CR LF (if any). Move APtr position forward. }
procedure SkipLineBreak(var APtr: PANSIChar; AEtx: PANSIChar);
{ :Skip all blank lines in a buffer starting at APtr and move APtr position forward. }
procedure SkipNullLines(var APtr: PANSIChar; AEtx: PANSIChar);
{ :Copy all lines from a buffer starting at APtr to ALines until empty line
  or end of the buffer is reached. Move APtr position forward). }
procedure CopyLinesFromStreamUntilNullLine(var APtr: PANSIChar; AEtx: PANSIChar;
  ALines: TStrings);
{ :Copy all lines from a buffer starting at APtr to ALines until ABoundary
  or end of the buffer is reached. Move APtr position forward). }
procedure CopyLinesFromStreamUntilBoundary(var APtr: PANSIChar; AEtx: PANSIChar;
  ALines: TStrings; const ABoundary: Ansistring);
{ :Search ABoundary in a buffer starting at APtr.
  Return beginning of the ABoundary. Move APtr forward behind a trailing CRLF if any). }
function SearchForBoundary(var APtr: PANSIChar; AEtx: PANSIChar;
  const ABoundary: Ansistring): PANSIChar;
{ :Compare a text at position ABOL with ABoundary and return position behind the
  match (including a trailing CRLF if any). }
function MatchBoundary(ABol, AEtx: PANSIChar; const ABoundary: Ansistring)
  : PANSIChar;
{ :Compare a text at position ABOL with ABoundary + the last boundary suffix
  and return position behind the match (including a trailing CRLF if any). }
function MatchLastBoundary(ABol, AEtx: PANSIChar; const ABoundary: Ansistring)
  : PANSIChar;
{ :Copy data from a buffer starting at position APtr and delimited by AEtx
  position into ANSIString. }
function BuildStringFromBuffer(AStx, AEtx: PANSIChar): Ansistring;
{ /pf }

var
  { :can be used for your own months strings for @link(getmonthnumber) }
  CustomMonthNames: array [1 .. 12] of string;

implementation

{ ============================================================================== }

const
  MyDayNames: array [1 .. 7] of Ansistring = ('Sun', 'Mon', 'Tue', 'Wed', 'Thu',
    'Fri', 'Sat');

var
  MyMonthNames: array [0 .. 6, 1 .. 12] of String =
    (('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', // rewrited by system locales
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'), ('Jan', 'Feb', 'Mar', 'Apr',
    'May', 'Jun', // English
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'), ('jan', 'fév', 'mar', 'avr',
    'mai', 'jun', // French
    'jul', 'ao?', 'sep', 'oct', 'nov', 'déc'), ('jan', 'fev', 'mar', 'avr',
    'mai', 'jun', // French#2
    'jul', 'aou', 'sep', 'oct', 'nov', 'dec'), ('Jan', 'Feb', 'Mar', 'Apr',
    'Mai', 'Jun', // German
    'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dez'), ('Jan', 'Feb', 'Mär', 'Apr',
    'Mai', 'Jun', // German#2
    'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dez'), ('Led', 'Úno', 'Bøe', 'Dub', 'Kv?',
    'Èen', // Czech
    'Èec', 'Srp', 'Záø', 'Øíj', 'Lis', 'Pro'));

  { ============================================================================== }

function TimeZoneBias: integer;
{$IFNDEF MSWINDOWS}
{$IFNDEF FPC}
var
  t: TTime_T;
  UT: TUnixTime;
begin
  __time(@t);
  localtime_r(@t, UT);
  Result := UT.__tm_gmtoff div 60;
{$ELSE}
begin
  Result := TZSeconds div 60;
{$ENDIF}
{$ELSE}
var
  zoneinfo: TTimeZoneInformation;
  bias: integer;
begin
  case GetTimeZoneInformation(zoneinfo) of
    2:
      bias := zoneinfo.bias + zoneinfo.DaylightBias;
    1:
      bias := zoneinfo.bias + zoneinfo.StandardBias;
  else
    bias := zoneinfo.bias;
  end;
  Result := bias * (-1);
{$ENDIF}
end;

{ ============================================================================== }

function TimeZone: string;
var
  bias: integer;
  h, m: integer;
begin
  bias := TimeZoneBias;
  if bias >= 0 then
    Result := '+'
  else
    Result := '-';
  bias := Abs(bias);
  h := bias div 60;
  m := bias mod 60;
  Result := Result + Format('%.2d%.2d', [h, m]);
end;

{ ============================================================================== }

function Rfc822DateTime(t: TDateTime): string;
var
  wYear, wMonth, wDay: Word;
begin
  DecodeDate(t, wYear, wMonth, wDay);
  Result := Format('%s, %d %s %s %s', [MyDayNames[DayOfWeek(t)], wDay,
    MyMonthNames[1, wMonth], FormatDateTime('yyyy hh":"nn":"ss', t), TimeZone]);
end;

{ ============================================================================== }

function CDateTime(t: TDateTime): string;
var
  wYear, wMonth, wDay: Word;
begin
  DecodeDate(t, wYear, wMonth, wDay);
  Result := Format('%s %2d %s', [MyMonthNames[1, wMonth], wDay,
    FormatDateTime('hh":"nn":"ss', t)]);
end;

{ ============================================================================== }

function SimpleDateTime(t: TDateTime): string;
begin
  Result := FormatDateTime('yymmdd hhnnss', t);
end;

{ ============================================================================== }

function AnsiCDateTime(t: TDateTime): string;
var
  wYear, wMonth, wDay: Word;
begin
  DecodeDate(t, wYear, wMonth, wDay);
  Result := Format('%s %s %d %s', [MyDayNames[DayOfWeek(t)],
    MyMonthNames[1, wMonth], wDay, FormatDateTime('hh":"nn":"ss yyyy ', t)]);
end;

{ ============================================================================== }

function DecodeTimeZone(Value: string; var Zone: integer): Boolean;
var
  x: integer;
  zh, zm: integer;
  S: string;
begin
  Result := false;
  S := Value;
  if (Pos('+', S) = 1) or (Pos('-', S) = 1) then
  begin
    if S = '-0000' then
      Zone := TimeZoneBias
    else if Length(S) > 4 then
    begin
      zh := StrToIntdef(S[2] + S[3], 0);
      zm := StrToIntdef(S[4] + S[5], 0);
      Zone := zh * 60 + zm;
      if S[1] = '-' then
        Zone := Zone * (-1);
    end;
    Result := True;
  end
  else
  begin
    x := 32767;
    if S = 'NZDT' then
      x := 13;
    if S = 'IDLE' then
      x := 12;
    if S = 'NZST' then
      x := 12;
    if S = 'NZT' then
      x := 12;
    if S = 'EADT' then
      x := 11;
    if S = 'GST' then
      x := 10;
    if S = 'JST' then
      x := 9;
    if S = 'CCT' then
      x := 8;
    if S = 'WADT' then
      x := 8;
    if S = 'WAST' then
      x := 7;
    if S = 'ZP6' then
      x := 6;
    if S = 'ZP5' then
      x := 5;
    if S = 'ZP4' then
      x := 4;
    if S = 'BT' then
      x := 3;
    if S = 'EET' then
      x := 2;
    if S = 'MEST' then
      x := 2;
    if S = 'MESZ' then
      x := 2;
    if S = 'SST' then
      x := 2;
    if S = 'FST' then
      x := 2;
    if S = 'CEST' then
      x := 2;
    if S = 'CET' then
      x := 1;
    if S = 'FWT' then
      x := 1;
    if S = 'MET' then
      x := 1;
    if S = 'MEWT' then
      x := 1;
    if S = 'SWT' then
      x := 1;
    if S = 'UT' then
      x := 0;
    if S = 'UTC' then
      x := 0;
    if S = 'GMT' then
      x := 0;
    if S = 'WET' then
      x := 0;
    if S = 'WAT' then
      x := -1;
    if S = 'BST' then
      x := -1;
    if S = 'AT' then
      x := -2;
    if S = 'ADT' then
      x := -3;
    if S = 'AST' then
      x := -4;
    if S = 'EDT' then
      x := -4;
    if S = 'EST' then
      x := -5;
    if S = 'CDT' then
      x := -5;
    if S = 'CST' then
      x := -6;
    if S = 'MDT' then
      x := -6;
    if S = 'MST' then
      x := -7;
    if S = 'PDT' then
      x := -7;
    if S = 'PST' then
      x := -8;
    if S = 'YDT' then
      x := -8;
    if S = 'YST' then
      x := -9;
    if S = 'HDT' then
      x := -9;
    if S = 'AHST' then
      x := -10;
    if S = 'CAT' then
      x := -10;
    if S = 'HST' then
      x := -10;
    if S = 'EAST' then
      x := -10;
    if S = 'NT' then
      x := -11;
    if S = 'IDLW' then
      x := -12;
    if x <> 32767 then
    begin
      Zone := x * 60;
      Result := True;
    end;
  end;
end;

{ ============================================================================== }

function GetMonthNumber(Value: String): integer;
var
  n: integer;
  function TestMonth(Value: String; Index: integer): Boolean;
  var
    n: integer;
  begin
    Result := false;
    for n := 0 to 6 do
      if Value = AnsiUppercase(MyMonthNames[n, Index]) then
      begin
        Result := True;
        Break;
      end;
  end;

begin
  Result := 0;
  Value := AnsiUppercase(Value);
  for n := 1 to 12 do
    if TestMonth(Value, n) or (Value = AnsiUppercase(CustomMonthNames[n])) then
    begin
      Result := n;
      Break;
    end;
end;

{ ============================================================================== }

function GetTimeFromStr(Value: string): TDateTime;
var
  x: integer;
  formatSetting: TFormatSettings;
begin
  x := RPos(':', Value);
  if (x > 0) and ((Length(Value) - x) > 2) then
    Value := Copy(Value, 1, x + 2);
  {$IFDEF VER210}
   Value := ReplaceString(Value, ':', formatSetting.TimeSeparator);
   {$ELSE}
  formatSetting := TFormatSettings.Create;
  Value := ReplaceString(Value, ':', formatSetting.TimeSeparator);
  {$ENDIF}
  Result := -1;
  try
    Result := StrToTime(Value);
  except
    on Exception do;
  end;
end;

{ ============================================================================== }

function GetDateMDYFromStr(Value: string): TDateTime;
var
  wYear, wMonth, wDay: Word;
  S: string;
begin
  Result := 0;
  S := Fetch(Value, '-');
  wMonth := StrToIntdef(S, 12);
  S := Fetch(Value, '-');
  wDay := StrToIntdef(S, 30);
  wYear := StrToIntdef(Value, 1899);
  if wYear < 1000 then
    if (wYear > 99) then
      wYear := wYear + 1900
    else if wYear > 50 then
      wYear := wYear + 1900
    else
      wYear := wYear + 2000;
  try
    Result := EncodeDate(wYear, wMonth, wDay);
  except
    on Exception do;
  end;
end;

{ ============================================================================== }

function DecodeRfcDateTime(Value: string): TDateTime;
var
  day, month, year: Word;
  Zone: integer;
  x, y: integer;
  S: string;
  t: TDateTime;
begin
  // ddd, d mmm yyyy hh:mm:ss
  // ddd, d mmm yy hh:mm:ss
  // ddd, mmm d yyyy hh:mm:ss
  // ddd mmm dd hh:mm:ss yyyy
  // Sun, 06 Nov 1994 08:49:37 GMT    ; RFC 822, updated by RFC 1123
  // Sunday, 06-Nov-94 08:49:37 GMT   ; RFC 850, obsoleted by RFC 1036
  // Sun Nov  6 08:49:37 1994         ; ANSI C's asctime() Format

  Result := 0;
  if Value = '' then
    Exit;
  day := 0;
  month := 0;
  year := 0;
  Zone := 0;
  Value := ReplaceString(Value, ' -', ' #');
  Value := ReplaceString(Value, '-', ' ');
  Value := ReplaceString(Value, ' #', ' -');
  while Value <> '' do
  begin
    S := Fetch(Value, ' ');
    S := uppercase(S);
    // timezone
    if DecodeTimeZone(S, x) then
    begin
      Zone := x;
      continue;
    end;
    x := StrToIntdef(S, 0);
    // day or year
    if x > 0 then
      if (x < 32) and (day = 0) then
      begin
        day := x;
        continue;
      end
      else
      begin
        if (year = 0) and ((month > 0) or (x > 12)) then
        begin
          year := x;
          if year < 32 then
            year := year + 2000;
          if year < 1000 then
            year := year + 1900;
          continue;
        end;
      end;
    // time
    if RPos(':', S) > Pos(':', S) then
    begin
      t := GetTimeFromStr(S);
      if t <> -1 then
        Result := t;
      continue;
    end;
    // timezone daylight saving time
    if S = 'DST' then
    begin
      Zone := Zone + 60;
      continue;
    end;
    // month
    y := GetMonthNumber(S);
    if (y > 0) and (month = 0) then
      month := y;
  end;
  if year = 0 then
    year := 1980;
  if month < 1 then
    month := 1;
  if month > 12 then
    month := 12;
  if day < 1 then
    day := 1;
  x := MonthDays[IsLeapYear(year), month];
  if day > x then
    day := x;
  Result := Result + EncodeDate(year, month, day);
  Zone := Zone - TimeZoneBias;
  x := Zone div 1440;
  Result := Result - x;
  Zone := Zone mod 1440;
  t := EncodeTime(Abs(Zone) div 60, Abs(Zone) mod 60, 0, 0);
  if Zone < 0 then
    t := 0 - t;
  Result := Result - t;
end;

{ ============================================================================== }

function GetUTTime: TDateTime;
{$IFDEF MSWINDOWS}
{$IFNDEF FPC}
var
  st: TSystemTime;
begin
  GetSystemTime(st);
  Result := SystemTimeToDateTime(st);
{$ELSE}
var
  st: SysUtils.TSystemTime;
  stw: Windows.TSystemTime;
begin
  GetSystemTime(stw);
  st.year := stw.wYear;
  st.month := stw.wMonth;
  st.day := stw.wDay;
  st.Hour := stw.wHour;
  st.Minute := stw.wMinute;
  st.Second := stw.wSecond;
  st.Millisecond := stw.wMilliseconds;
  Result := SystemTimeToDateTime(st);
{$ENDIF}
{$ELSE}
{$IFNDEF FPC}
var
  TV: TTimeVal;
begin
  gettimeofday(TV, nil);
  Result := UnixDateDelta + (TV.tv_sec + TV.tv_usec / 1000000) / 86400;
{$ELSE}
var
  TV: TimeVal;
begin
  fpgettimeofday(@TV, nil);
  Result := UnixDateDelta + (TV.tv_sec + TV.tv_usec / 1000000) / 86400;
{$ENDIF}
{$ENDIF}
end;

{ ============================================================================== }

function SetUTTime(Newdt: TDateTime): Boolean;
{$IFDEF MSWINDOWS}
{$IFNDEF FPC}
var
  st: TSystemTime;
begin
  DateTimeToSystemTime(Newdt, st);
  Result := SetSystemTime(st);
{$ELSE}
var
  st: SysUtils.TSystemTime;
  stw: Windows.TSystemTime;
begin
  DateTimeToSystemTime(Newdt, st);
  stw.wYear := st.year;
  stw.wMonth := st.month;
  stw.wDay := st.day;
  stw.wHour := st.Hour;
  stw.wMinute := st.Minute;
  stw.wSecond := st.Second;
  stw.wMilliseconds := st.Millisecond;
  Result := SetSystemTime(stw);
{$ENDIF}
{$ELSE}
{$IFNDEF FPC}
var
  TV: TTimeVal;
  d: double;
  TZ: Ttimezone;
  PZ: PTimeZone;
begin
  TZ.tz_minuteswest := 0;
  TZ.tz_dsttime := 0;
  PZ := @TZ;
  gettimeofday(TV, PZ);
  d := (Newdt - UnixDateDelta) * 86400;
  TV.tv_sec := trunc(d);
  TV.tv_usec := trunc(frac(d) * 1000000);
  Result := settimeofday(TV, TZ) <> -1;
{$ELSE}
var
  TV: TimeVal;
  d: double;
begin
  d := (Newdt - UnixDateDelta) * 86400;
  TV.tv_sec := trunc(d);
  TV.tv_usec := trunc(frac(d) * 1000000);
  Result := fpsettimeofday(@TV, nil) <> -1;
{$ENDIF}
{$ENDIF}
end;

{ ============================================================================== }

{$IFNDEF MSWINDOWS}

function GetTick: LongWord;
var
  Stamp: TTimeStamp;
begin
  Stamp := DateTimeToTimeStamp(Now);
  Result := Stamp.Time;
end;
{$ELSE}

function GetTick: LongWord;
var
  tick, freq: TLargeInteger;
{$IFDEF VER100}
  x: TLargeInteger;
{$ENDIF}
begin
  if Windows.QueryPerformanceFrequency(freq) then
  begin
    Windows.QueryPerformanceCounter(tick);
{$IFDEF VER100}
    x.QuadPart := (tick.QuadPart / freq.QuadPart) * 1000;
    Result := x.LowPart;
{$ELSE}
    Result := trunc((tick / freq) * 1000) and High(LongWord)
{$ENDIF}
  end
  else
    Result := Windows.GetTickCount;
end;
{$ENDIF}
{ ============================================================================== }

function TickDelta(TickOld, TickNew: LongWord): LongWord;
begin
  // if DWord is signed type (older Deplhi),
  // then it not work properly on differencies larger then maxint!
  Result := 0;
  if TickOld <> TickNew then
  begin
    if TickNew < TickOld then
    begin
      TickNew := TickNew + LongWord(MaxInt) + 1;
      TickOld := TickOld + LongWord(MaxInt) + 1;
    end;
    Result := TickNew - TickOld;
    if TickNew < TickOld then
      if Result > 0 then
        Result := 0 - Result;
  end;
end;

{ ============================================================================== }

function CodeInt(Value: Word): Ansistring;
begin
  setlength(Result, 2);
  Result[1] := AnsiChar(Value div 256);
  Result[2] := AnsiChar(Value mod 256);
  // Result := AnsiChar(Value div 256) + AnsiChar(Value mod 256)
end;

{ ============================================================================== }

function DecodeInt(const Value: Ansistring; Index: integer): Word;
var
  x, y: Byte;
begin
  if Length(Value) > Index then
    x := Ord(Value[Index])
  else
    x := 0;
  if Length(Value) >= (Index + 1) then
    y := Ord(Value[Index + 1])
  else
    y := 0;
  Result := x * 256 + y;
end;

{ ============================================================================== }

function CodeLongInt(Value: LongInt): Ansistring;
var
  x, y: Word;
begin
  // this is fix for negative numbers on systems where longint = integer
  x := (Value shr 16) and integer($FFFF);
  y := Value and integer($FFFF);
  setlength(Result, 4);
  Result[1] := AnsiChar(x div 256);
  Result[2] := AnsiChar(x mod 256);
  Result[3] := AnsiChar(y div 256);
  Result[4] := AnsiChar(y mod 256);
end;

{ ============================================================================== }

function DecodeLongInt(const Value: Ansistring; Index: integer): LongInt;
var
  x, y: Byte;
  xl, yl: Byte;
begin
  if Length(Value) > Index then
    x := Ord(Value[Index])
  else
    x := 0;
  if Length(Value) >= (Index + 1) then
    y := Ord(Value[Index + 1])
  else
    y := 0;
  if Length(Value) >= (Index + 2) then
    xl := Ord(Value[Index + 2])
  else
    xl := 0;
  if Length(Value) >= (Index + 3) then
    yl := Ord(Value[Index + 3])
  else
    yl := 0;
  Result := ((x * 256 + y) * 65536) + (xl * 256 + yl);
end;

{ ============================================================================== }

function DumpStr(const Buffer: Ansistring): string;
var
  n: integer;
begin
  Result := '';
  for n := 1 to Length(Buffer) do
    Result := Result + ' +#$' + IntToHex(Ord(Buffer[n]), 2);
end;

{ ============================================================================== }

function DumpExStr(const Buffer: Ansistring): string;
var
  n: integer;
  x: Byte;
begin
  Result := '';
  for n := 1 to Length(Buffer) do
  begin
    x := Ord(Buffer[n]);
    if x in [65 .. 90, 97 .. 122] then
      Result := Result + ' +''' + char(x) + ''''
    else
      Result := Result + ' +#$' + IntToHex(Ord(Buffer[n]), 2);
  end;
end;

{ ============================================================================== }

procedure Dump(const Buffer: Ansistring; DumpFile: string);
var
  f: Text;
begin
  AssignFile(f, DumpFile);
  if FileExists(DumpFile) then
    DeleteFile(DumpFile);
  Rewrite(f);
  try
    Writeln(f, DumpStr(Buffer));
  finally
    CloseFile(f);
  end;
end;

{ ============================================================================== }

procedure DumpEx(const Buffer: Ansistring; DumpFile: string);
var
  f: Text;
begin
  AssignFile(f, DumpFile);
  if FileExists(DumpFile) then
    DeleteFile(DumpFile);
  Rewrite(f);
  try
    Writeln(f, DumpExStr(Buffer));
  finally
    CloseFile(f);
  end;
end;

{ ============================================================================== }

function TrimSPLeft(const S: string): string;
var
  I, L: integer;
begin
  Result := '';
  if S = '' then
    Exit;
  L := Length(S);
  I := 1;
  while (I <= L) and (S[I] = ' ') do
    Inc(I);
  Result := Copy(S, I, MaxInt);
end;

{ ============================================================================== }

function TrimSPRight(const S: string): string;
var
  I: integer;
begin
  Result := '';
  if S = '' then
    Exit;
  I := Length(S);
  while (I > 0) and (S[I] = ' ') do
    Dec(I);
  Result := Copy(S, 1, I);
end;

{ ============================================================================== }

function TrimSP(const S: string): string;
begin
  Result := TrimSPLeft(S);
  Result := TrimSPRight(Result);
end;

{ ============================================================================== }

function SeparateLeft(const Value, Delimiter: string): string;
var
  x: integer;
begin
  x := Pos(Delimiter, Value);
  if x < 1 then
    Result := Value
  else
    Result := Copy(Value, 1, x - 1);
end;

{ ============================================================================== }

function SeparateRight(const Value, Delimiter: string): string;
var
  x: integer;
begin
  x := Pos(Delimiter, Value);
  if x > 0 then
    x := x + Length(Delimiter) - 1;
  Result := Copy(Value, x + 1, Length(Value) - x);
end;

{ ============================================================================== }

function GetParameter(const Value, Parameter: string): string;
var
  S: string;
  v: string;
begin
  Result := '';
  v := Value;
  while v <> '' do
  begin
    S := Trim(FetchEx(v, ';', '"'));
    if Pos(uppercase(Parameter), uppercase(S)) = 1 then
    begin
      Delete(S, 1, Length(Parameter));
      S := Trim(S);
      if S = '' then
        Break;
      if S[1] = '=' then
      begin
        Result := Trim(SeparateRight(S, '='));
        Result := UnquoteStr(Result, '"');
        Break;
      end;
    end;
  end;
end;

{ ============================================================================== }

procedure ParseParametersEx(Value, Delimiter: string;
  const Parameters: TStrings);
var
  S: string;
begin
  Parameters.Clear;
  while Value <> '' do
  begin
    S := Trim(FetchEx(Value, Delimiter, '"'));
    Parameters.Add(S);
  end;
end;

{ ============================================================================== }

procedure ParseParameters(Value: string; const Parameters: TStrings);
begin
  ParseParametersEx(Value, ';', Parameters);
end;

{ ============================================================================== }

function IndexByBegin(Value: string; const List: TStrings): integer;
var
  n: integer;
  S: string;
begin
  Result := -1;
  Value := uppercase(Value);
  for n := 0 to List.Count - 1 do
  begin
    S := uppercase(List[n]);
    if Pos(Value, S) = 1 then
    begin
      Result := n;
      Break;
    end;
  end;
end;

{ ============================================================================== }

function GetEmailAddr(const Value: string): string;
var
  S: string;
begin
  S := SeparateRight(Value, '<');
  S := SeparateLeft(S, '>');
  Result := Trim(S);
end;

{ ============================================================================== }

function GetEmailDesc(Value: string): string;
var
  S: string;
begin
  Value := Trim(Value);
  S := SeparateRight(Value, '"');
  if S <> Value then
    S := SeparateLeft(S, '"')
  else
  begin
    S := SeparateLeft(Value, '<');
    if S = Value then
    begin
      S := SeparateRight(Value, '(');
      if S <> Value then
        S := SeparateLeft(S, ')')
      else
        S := '';
    end;
  end;
  Result := Trim(S);
end;

{ ============================================================================== }

function StrToHex(const Value: Ansistring): string;
var
  n: integer;
begin
  Result := '';
  for n := 1 to Length(Value) do
    Result := Result + IntToHex(Byte(Value[n]), 2);
  Result := LowerCase(Result);
end;

{ ============================================================================== }

function IntToBin(Value: integer; Digits: Byte): string;
var
  x, y, n: integer;
begin
  Result := '';
  x := Value;
  repeat
    y := x mod 2;
    x := x div 2;
    if y > 0 then
      Result := '1' + Result
    else
      Result := '0' + Result;
  until x = 0;
  x := Length(Result);
  for n := x to Digits - 1 do
    Result := '0' + Result;
end;

{ ============================================================================== }

function BinToInt(const Value: string): integer;
var
  n: integer;
begin
  Result := 0;
  for n := 1 to Length(Value) do
  begin
    if Value[n] = '0' then
      Result := Result * 2
    else if Value[n] = '1' then
      Result := Result * 2 + 1
    else
      Break;
  end;
end;

{ ============================================================================== }

function ParseURL(URL: string; var Prot, User, Pass, Host, Port, Path,
  Para: string): string;
var
  x, y: integer;
  sURL: string;
  S: string;
  s1, s2: string;
begin
  Prot := 'http';
  User := '';
  Pass := '';
  Port := '80';
  Para := '';

  x := Pos('://', URL);
  if x > 0 then
  begin
    Prot := SeparateLeft(URL, '://');
    sURL := SeparateRight(URL, '://');
  end
  else
    sURL := URL;
  if uppercase(Prot) = 'HTTPS' then
    Port := '443';
  if uppercase(Prot) = 'FTP' then
    Port := '21';
  x := Pos('@', sURL);
  y := Pos('/', sURL);
  if (x > 0) and ((x < y) or (y < 1)) then
  begin
    S := SeparateLeft(sURL, '@');
    sURL := SeparateRight(sURL, '@');
    x := Pos(':', S);
    if x > 0 then
    begin
      User := SeparateLeft(S, ':');
      Pass := SeparateRight(S, ':');
    end
    else
      User := S;
  end;
  x := Pos('/', sURL);
  if x > 0 then
  begin
    s1 := SeparateLeft(sURL, '/');
    s2 := SeparateRight(sURL, '/');
  end
  else
  begin
    s1 := sURL;
    s2 := '';
  end;
  if Pos('[', s1) = 1 then
  begin
    Host := SeparateLeft(s1, ']');
    Delete(Host, 1, 1);
    s1 := SeparateRight(s1, ']');
    if Pos(':', s1) = 1 then
      Port := SeparateRight(s1, ':');
  end
  else
  begin
    x := Pos(':', s1);
    if x > 0 then
    begin
      Host := SeparateLeft(s1, ':');
      Port := SeparateRight(s1, ':');
    end
    else
      Host := s1;
  end;
  Result := '/' + s2;
  x := Pos('?', s2);
  if x > 0 then
  begin
    Path := '/' + SeparateLeft(s2, '?');
    Para := SeparateRight(s2, '?');
  end
  else
    Path := '/' + s2;
  if Host = '' then
    Host := 'localhost';
end;

{ ============================================================================== }

function ReplaceString(Value, Search, Replace: Ansistring): Ansistring;
var
  x, L, ls, lr: integer;
begin
  if (Value = '') or (Search = '') then
  begin
    Result := Value;
    Exit;
  end;
  ls := Length(Search);
  lr := Length(Replace);
  Result := '';
  x := Pos(Search, Value);
  while x > 0 do
  begin
{$IFNDEF CIL}
    L := Length(Result);
    setlength(Result, L + x - 1);
    Move(pointer(Value)^, pointer(@Result[L + 1])^, x - 1);
{$ELSE}
    Result := Result + Copy(Value, 1, x - 1);
{$ENDIF}
{$IFNDEF CIL}
    L := Length(Result);
    setlength(Result, L + lr);
    Move(pointer(Replace)^, pointer(@Result[L + 1])^, lr);
{$ELSE}
    Result := Result + Replace;
{$ENDIF}
    Delete(Value, 1, x - 1 + ls);
    x := Pos(Search, Value);
  end;
  Result := Result + Value;
end;

{ ============================================================================== }

function RPosEx(const Sub, Value: string; From: integer): integer;
var
  n: integer;
  L: integer;
begin
  Result := 0;
  L := Length(Sub);
  for n := From - L + 1 downto 1 do
  begin
    if Copy(Value, n, L) = Sub then
    begin
      Result := n;
      Break;
    end;
  end;
end;

{ ============================================================================== }

function RPos(const Sub, Value: String): integer;
begin
  Result := RPosEx(Sub, Value, Length(Value));
end;

{ ============================================================================== }

function FetchBin(var Value: string; const Delimiter: string): string;
var
  S: string;
begin
  Result := SeparateLeft(Value, Delimiter);
  S := SeparateRight(Value, Delimiter);
  if S = Value then
    Value := ''
  else
    Value := S;
end;

{ ============================================================================== }

function Fetch(var Value: string; const Delimiter: string): string;
begin
  Result := FetchBin(Value, Delimiter);
  Result := TrimSP(Result);
  Value := TrimSP(Value);
end;

{ ============================================================================== }

function FetchEx(var Value: string; const Delimiter, Quotation: string): string;
var
  b: Boolean;
begin
  Result := '';
  b := false;
  while Length(Value) > 0 do
  begin
    if b then
    begin
      if Pos(Quotation, Value) = 1 then
        b := false;
      Result := Result + Value[1];
      Delete(Value, 1, 1);
    end
    else
    begin
      if Pos(Delimiter, Value) = 1 then
      begin
        Delete(Value, 1, Length(Delimiter));
        Break;
      end;
      b := Pos(Quotation, Value) = 1;
      Result := Result + Value[1];
      Delete(Value, 1, 1);
    end;
  end;
end;

{ ============================================================================== }

function IsBinaryString(const Value: Ansistring): Boolean;
var
  n: integer;
begin
  Result := false;
  for n := 1 to Length(Value) do
    if Value[n] in [#0 .. #8, #10 .. #31] then
      // ignore null-terminated strings
      if not((n = Length(Value)) and (Value[n] = AnsiChar(#0))) then
      begin
        Result := True;
        Break;
      end;
end;

{ ============================================================================== }

function PosCRLF(const Value: Ansistring; var Terminator: Ansistring): integer;
var
  n, L: integer;
begin
  Result := -1;
  Terminator := '';
  L := Length(Value);
  for n := 1 to L do
    if Value[n] in [#$0d, #$0a] then
    begin
      Result := n;
      Terminator := Value[n];
      if n <> L then
        case Value[n] of
          #$0d:
            if Value[n + 1] = #$0a then
              Terminator := #$0d + #$0a;
          #$0a:
            if Value[n + 1] = #$0d then
              Terminator := #$0a + #$0d;
        end;
      Break;
    end;
end;

{ ============================================================================== }

Procedure StringsTrim(const Value: TStrings);
var
  n: integer;
begin
  for n := Value.Count - 1 downto 0 do
    if Value[n] = '' then
      Value.Delete(n)
    else
      Break;
end;

{ ============================================================================== }

function PosFrom(const SubStr, Value: String; From: integer): integer;
var
  ls, lv: integer;
begin
  Result := 0;
  ls := Length(SubStr);
  lv := Length(Value);
  if (ls = 0) or (lv = 0) then
    Exit;
  if From < 1 then
    From := 1;
  while (ls + From - 1) <= (lv) do
  begin
{$IFNDEF CIL}
    if CompareMem(@SubStr[1], @Value[From], ls) then
{$ELSE}
    if SubStr = Copy(Value, From, ls) then
{$ENDIF}
    begin
      Result := From;
      Break;
    end
    else
      Inc(From);
  end;
end;

{ ============================================================================== }

{$IFNDEF CIL}

function IncPoint(const p: pointer; Value: integer): pointer;
begin
  Result := PANSIChar(p) + Value;
end;
{$ENDIF}

{ ============================================================================== }
// improved by 'DoggyDawg'
function GetBetween(const PairBegin, PairEnd, Value: string): string;
var
  n: integer;
  x: integer;
  S: string;
  lenBegin: integer;
  lenEnd: integer;
  str: string;
  max: integer;
begin
  lenBegin := Length(PairBegin);
  lenEnd := Length(PairEnd);
  n := Length(Value);
  if (Value = PairBegin + PairEnd) then
  begin
    Result := ''; // nothing between
    Exit;
  end;
  if (n < lenBegin + lenEnd) then
  begin
    Result := Value;
    Exit;
  end;
  S := SeparateRight(Value, PairBegin);
  if (S = Value) then
  begin
    Result := Value;
    Exit;
  end;
  n := Pos(PairEnd, S);
  if (n = 0) then
  begin
    Result := Value;
    Exit;
  end;
  Result := '';
  x := 1;
  max := Length(S) - lenEnd + 1;
  for n := 1 to max do
  begin
    str := Copy(S, n, lenEnd);
    if (str = PairEnd) then
    begin
      Dec(x);
      if (x <= 0) then
        Break;
    end;
    str := Copy(S, n, lenBegin);
    if (str = PairBegin) then
      Inc(x);
    Result := Result + S[n];
  end;
end;

{ ============================================================================== }

function CountOfChar(const Value: string; Chr: char): integer;
var
  n: integer;
begin
  Result := 0;
  for n := 1 to Length(Value) do
    if Value[n] = Chr then
      Inc(Result);
end;

{ ============================================================================== }
// ! do not use AnsiExtractQuotedStr, it's very buggy and can crash application!
function UnquoteStr(const Value: string; Quote: char): string;
var
  n: integer;
  inq, dq: Boolean;
  c, cn: char;
begin
  Result := '';
  if Value = '' then
    Exit;
  if Value = Quote + Quote then
    Exit;
  inq := false;
  dq := false;
  for n := 1 to Length(Value) do
  begin
    c := Value[n];
    if n <> Length(Value) then
      cn := Value[n + 1]
    else
      cn := #0;
    if c = Quote then
      if dq then
        dq := false
      else if not inq then
        inq := True
      else if cn = Quote then
      begin
        Result := Result + Quote;
        dq := True;
      end
      else
        inq := false
    else
      Result := Result + c;
  end;
end;

{ ============================================================================== }

function QuoteStr(const Value: string; Quote: char): string;
var
  n: integer;
begin
  Result := '';
  for n := 1 to Length(Value) do
  begin
    Result := Result + Value[n];
    if Value[n] = Quote then
      Result := Result + Quote;
  end;
  Result := Quote + Result + Quote;
end;

{ ============================================================================== }

procedure HeadersToList(const Value: TStrings);
var
  n, x, y: integer;
  S: string;
begin
  for n := 0 to Value.Count - 1 do
  begin
    S := Value[n];
    x := Pos(':', S);
    if x > 0 then
    begin
      y := Pos('=', S);
      if not((y > 0) and (y < x)) then
      begin
        S[x] := '=';
        Value[n] := S;
      end;
    end;
  end;
end;

{ ============================================================================== }

procedure ListToHeaders(const Value: TStrings);
var
  n, x: integer;
  S: string;
begin
  for n := 0 to Value.Count - 1 do
  begin
    S := Value[n];
    x := Pos('=', S);
    if x > 0 then
    begin
      S[x] := ':';
      Value[n] := S;
    end;
  end;
end;

{ ============================================================================== }

function SwapBytes(Value: integer): integer;
var
  S: Ansistring;
  x, y, xl, yl: Byte;
begin
  S := CodeLongInt(Value);
  x := Ord(S[4]);
  y := Ord(S[3]);
  xl := Ord(S[2]);
  yl := Ord(S[1]);
  Result := ((x * 256 + y) * 65536) + (xl * 256 + yl);
end;

{ ============================================================================== }

function ReadStrFromStream(const Stream: TStream; len: integer): Ansistring;
var
  x: integer;
{$IFDEF CIL}
  buf: Array of Byte;
{$ENDIF}
begin
{$IFDEF CIL}
  setlength(buf, len);
  x := Stream.read(buf, len);
  setlength(buf, x);
  Result := StringOf(buf);
{$ELSE}
  setlength(Result, len);
  x := Stream.read(PANSIChar(Result)^, len);
  setlength(Result, x);
{$ENDIF}
end;

{ ============================================================================== }

procedure WriteStrToStream(const Stream: TStream; Value: Ansistring);
{$IFDEF CIL}
var
  buf: Array of Byte;
{$ENDIF}
begin
{$IFDEF CIL}
  buf := BytesOf(Value);
  Stream.Write(buf, Length(Value));
{$ELSE}
  Stream.Write(PANSIChar(Value)^, Length(Value));
{$ENDIF}
end;

{ ============================================================================== }
function GetTempFile(const Dir, prefix: Ansistring): Ansistring;
{$IFNDEF FPC}
{$IFDEF MSWINDOWS}
var
  Path: Ansistring;
  x: integer;
{$ENDIF}
{$ENDIF}
begin
{$IFDEF FPC}
  Result := GetTempFileName(Dir, prefix);
{$ELSE}
{$IFNDEF MSWINDOWS}
  Result := tempnam(pointer(Dir), pointer(prefix));
{$ELSE}
{$IFDEF CIL}
  Result := System.IO.Path.GetTempFileName;
{$ELSE}
  if Dir = '' then
  begin
    setlength(Path, MAX_PATH);
    x := GetTempPath(Length(Path), PChar(Path));
    setlength(Path, x);
  end
  else
    Path := Dir;
  x := Length(Path);
  if Path[x] <> '\' then
    Path := Path + '\';
  setlength(Result, MAX_PATH + 1);
  GetTempFileName(PChar(Path), PChar(prefix), 0, PChar(Result));
  Result := PChar(Result);
  SetFileattributes(PChar(Result), GetFileAttributes(PChar(Result)) or
    FILE_ATTRIBUTE_TEMPORARY);
{$ENDIF}
{$ENDIF}
{$ENDIF}
end;

{ ============================================================================== }

function PadString(const Value: Ansistring; len: integer; Pad: AnsiChar)
  : Ansistring;
begin
  if Length(Value) >= len then
    Result := Copy(Value, 1, len)
  else
    Result := Value + StringOfChar(Pad, len - Length(Value));
end;

{ ============================================================================== }

function XorString(Indata1, Indata2: Ansistring): Ansistring;
var
  I: integer;
begin
  Indata2 := PadString(Indata2, Length(Indata1), #0);
  Result := '';
  for I := 1 to Length(Indata1) do
    Result := Result + AnsiChar(Ord(Indata1[I]) xor Ord(Indata2[I]));
end;

{ ============================================================================== }

function NormalizeHeader(Value: TStrings; var Index: integer): string;
var
  S, t: string;
  n: integer;
begin
  S := Value[Index];
  Inc(Index);
  if S <> '' then
    while (Value.Count - 1) > Index do
    begin
      t := Value[Index];
      if t = '' then
        Break;
      for n := 1 to Length(t) do
        if t[n] = #9 then
          t[n] := ' ';
      if not(AnsiChar(t[1]) in [' ', '"', ':', '=']) then
        Break
      else
      begin
        S := S + ' ' + Trim(t);
        Inc(Index);
      end;
    end;
  Result := TrimRight(S);
end;

{ ============================================================================== }

{ pf }
procedure SearchForLineBreak(var APtr: PANSIChar; AEtx: PANSIChar;
  out ABol: PANSIChar; out ALength: integer);
begin
  ABol := APtr;
  while (APtr < AEtx) and not(APtr^ in [#0, #10, #13]) do
    Inc(APtr);
  ALength := APtr - ABol;
end;
{ /pf }

{ pf }
procedure SkipLineBreak(var APtr: PANSIChar; AEtx: PANSIChar);
begin
  if (APtr < AEtx) and (APtr^ = #13) then
    Inc(APtr);
  if (APtr < AEtx) and (APtr^ = #10) then
    Inc(APtr);
end;
{ /pf }

{ pf }
procedure SkipNullLines(var APtr: PANSIChar; AEtx: PANSIChar);
var
  bol: PANSIChar;
  lng: integer;
begin
  while (APtr < AEtx) do
  begin
    SearchForLineBreak(APtr, AEtx, bol, lng);
    SkipLineBreak(APtr, AEtx);
    if lng > 0 then
    begin
      APtr := bol;
      Break;
    end;
  end;
end;
{ /pf }

{ pf }
procedure CopyLinesFromStreamUntilNullLine(var APtr: PANSIChar; AEtx: PANSIChar;
  ALines: TStrings);
var
  bol: PANSIChar;
  lng: integer;
  S: Ansistring;
begin
  // Copying until body separator will be reached
  while (APtr < AEtx) and (APtr^ <> #0) do
  begin
    SearchForLineBreak(APtr, AEtx, bol, lng);
    SkipLineBreak(APtr, AEtx);
    if lng = 0 then
      Break;
    SetString(S, bol, lng);
    ALines.Add(S);
  end;
end;
{ /pf }

{ pf }
procedure CopyLinesFromStreamUntilBoundary(var APtr: PANSIChar; AEtx: PANSIChar;
  ALines: TStrings; const ABoundary: Ansistring);
var
  bol: PANSIChar;
  lng: integer;
  S: Ansistring;
  BackStop: Ansistring;
  eob1: PANSIChar;
  eob2: PANSIChar;
begin
  BackStop := '--' + ABoundary;
  eob2 := nil;
  // Copying until Boundary will be reached
  while (APtr < AEtx) do
  begin
    SearchForLineBreak(APtr, AEtx, bol, lng);
    SkipLineBreak(APtr, AEtx);
    eob1 := MatchBoundary(bol, APtr, ABoundary);
    if Assigned(eob1) then
      eob2 := MatchLastBoundary(bol, AEtx, ABoundary);
    if Assigned(eob2) then
    begin
      APtr := eob2;
      Break;
    end
    else if Assigned(eob1) then
    begin
      APtr := eob1;
      Break;
    end
    else
    begin
      SetString(S, bol, lng);
      ALines.Add(S);
    end;
  end;
end;
{ /pf }

{ pf }
function SearchForBoundary(var APtr: PANSIChar; AEtx: PANSIChar;
  const ABoundary: Ansistring): PANSIChar;
var
  eob: PANSIChar;
  Step: integer;
begin
  Result := nil;
  // Moving Aptr position forward until boundary will be reached
  while (APtr < AEtx) do
  begin
    if strlcomp(APtr, #13#10'--', 4) = 0 then
    begin
      eob := MatchBoundary(APtr, AEtx, ABoundary);
      Step := 4;
    end
    else if strlcomp(APtr, '--', 2) = 0 then
    begin
      eob := MatchBoundary(APtr, AEtx, ABoundary);
      Step := 2;
    end
    else
    begin
      eob := nil;
      Step := 1;
    end;
    if Assigned(eob) then
    begin
      Result := APtr; // boundary beginning
      APtr := eob; // boundary end
      Exit;
    end
    else
      Inc(APtr, Step);
  end;
end;
{ /pf }

{ pf }
function MatchBoundary(ABol, AEtx: PANSIChar; const ABoundary: Ansistring)
  : PANSIChar;
var
  MatchPos: PANSIChar;
  lng: integer;
begin
  Result := nil;
  MatchPos := ABol;
  lng := Length(ABoundary);
  if (MatchPos + 2 + lng) > AEtx then
    Exit;
  if strlcomp(MatchPos, #13#10, 2) = 0 then
    Inc(MatchPos, 2);
  if (MatchPos + 2 + lng) > AEtx then
    Exit;
  if strlcomp(MatchPos, '--', 2) <> 0 then
    Exit;
  Inc(MatchPos, 2);
  if strlcomp(MatchPos, PANSIChar(ABoundary), lng) <> 0 then
    Exit;
  Inc(MatchPos, lng);
  if ((MatchPos + 2) <= AEtx) and (strlcomp(MatchPos, #13#10, 2) = 0) then
    Inc(MatchPos, 2);
  Result := MatchPos;
end;
{ /pf }

{ pf }
function MatchLastBoundary(ABol, AEtx: PANSIChar; const ABoundary: Ansistring)
  : PANSIChar;
var
  MatchPos: PANSIChar;
begin
  Result := nil;
  MatchPos := MatchBoundary(ABol, AEtx, ABoundary);
  if not Assigned(MatchPos) then
    Exit;
  if strlcomp(MatchPos, '--', 2) <> 0 then
    Exit;
  Inc(MatchPos, 2);
  if (MatchPos + 2 <= AEtx) and (strlcomp(MatchPos, #13#10, 2) = 0) then
    Inc(MatchPos, 2);
  Result := MatchPos;
end;
{ /pf }

{ pf }
function BuildStringFromBuffer(AStx, AEtx: PANSIChar): Ansistring;
var
  lng: integer;
begin
  lng := 0;
  if Assigned(AStx) and Assigned(AEtx) then
  begin
    lng := AEtx - AStx;
    if lng < 0 then
      lng := 0;
  end;
  SetString(Result, AStx, lng);
end;
{ /pf }

{ ============================================================================== }
var
  n: integer;
  formatSetting: TFormatSettings;
begin
  {$IFDEF VER210}
  for n :=  1 to 12 do
  begin
    CustomMonthNames[n] := ShortMonthNames[n];
    MyMonthNames[0, n] := ShortMonthNames[n];
  end;
  {$ELSE}
  formatSetting := TFormatSettings.Create;
  for n := 1 to 12 do
  begin
    CustomMonthNames[n] := formatSetting.ShortMonthNames[n];
    MyMonthNames[0, n] := formatSetting.ShortMonthNames[n];
  end;
  {$ENDIF}
end.
