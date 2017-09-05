{*******************************************************}
{                                                       }
{           CodeGear Delphi Runtime Library             }
{                                                       }
{ Copyright(c) 1995-2014 Embarcadero Technologies, Inc. }
{                                                       }
{*******************************************************}

{*******************************************************}
{       Date/time Utilities Unit                        }
{*******************************************************}

{ The following unit is ISO 8601 compliant.  What that means is this unit
  considers Monday the first day of the week (5.2.3).  Additionally ISO 8601
  dictates the following "the first calendar week of the year is the one
  that includes the first Thursday of that year" (3.17).  In other words the
  first week of the year is the first one that has four or more days.  For
  more information about ISO 8601 see: http://www.iso.ch/markete/8601.pdf

  The functions most impacted by ISO 8601 are marked as such in the interface
  section.

  The functions marked with "ISO 8601x" are not directly covered by ISO 8601
  but their functionality is a logical extension to the standard.

  Some of the functions, concepts or constants in this unit were provided by
  Jeroen W. Pluimers (http://www.all-im.com), Glenn Crouch, Rune Moberg and
  Ray Lischner (http://www.tempest-sw.com).

  The Julian Date and Modified Julian Date functions are based on code
  from NASA's SOHO site (http://sohowww.nascom.nasa.gov/solarsoft/gen/idl/time)
  in which they credit the underlying algorithms as by Fliegel and Van
  Flandern (1968) which was reprinted in the Explanatory Supplement to the
  Astronomical Almanac, 1992.

  Julian Date and Modified Julian Date is discussed in some detail on the
  US Naval Observatory Time Service site (http://tycho.usno.navy.mil/mjd.html).
  Additional information can be found at (http://www.treasure-troves.com/astro).

  Note that the Delphi RTL Date/Time system uses the "Proleptic Gregorian Calendar".
  That is, the Delphi RTL assumes the Gregorian calendar is in effect all the way
  back to 1/1/0001 (i.e., January 1, Year 1).   A definition of this calendaring
  system can be found at:

  http://en.wikipedia.org/wiki/Proleptic_Gregorian_calendar

  Therefore,  the RTL does not account for lost days that resulted from the transition
  from the Julian calendar to the Gregorian Calendar that the world underwent at
  various times during the 16th, 17th, and 18th centuries, or even later.  (For
  example, Russia did not adopt the Gregorian calendar until 1918)

  More about that transition, and the missing dates that resulted, can be found on
  Wikipedia:

  http://en.wikipedia.org/wiki/Gregorian_calendar

  It should also be noted that there is no connection between a "Julian Date" and
  the "Julian Calendar".

}

unit DateUtilsHelper;

interface

uses
  SysUtils, Types, TimeSpan;

const
  { System.DateUtils }
  SInvalidDateString = 'Invalid date string: %s';
  SInvalidTimeString = 'Invalid time string: %s';
  SInvalidOffsetString = 'Invalid time Offset string: %s';

type
  EDateTimeException = class(Exception);
/// <summary>
/// Converts an ISO8601 encoded date/time string to TDateTime. The result is in local time, if AReturnUTC is false.
/// </summary>
/// <example>
/// <para> "2013-10-18T20:36:22.966Z"  </para>
/// <para> This is 20:36 UTC time (Zulu). If the local timezone is MEST (UTC+2), then resulting time will be 22:36. </para>
/// </example>

function ISO8601ToDate(const AISODate: string): TDateTime;

/// <summary> Converts a TDateTime value to ISO8601 format. </summary>
/// <param name="ADate"> A TDateTime value </param>
/// <param name="AInputIsUTC">
/// If AInputIsUTC is true, then the resulting ISO8601 string will show the exact same time as ADate has. </param>
/// <returns> ISO8601 representation of ADate. The resulting ISO string will be in UTC, i.e. will have a Z (Zulu) post
/// fix. If AInputIsUTC = true, then the time portion of ADate will not be modified. </returns>
function DateToISO8601(const ADate: TDateTime): string;

implementation

uses
  {$IFDEF MSWINDOWS}        Windows, {$ENDIF}
  Character, RTLConsts, SysConst, Generics.Collections, Generics.Defaults,
  DateUtils;

type
  DTErrorCode = (InvDate, InvTime, InvOffset);

function IsDigit(AChar: Char): Boolean;
begin
  Result := (AChar >= '0') and (AChar <= '9');
end;

function IsInArray(AChar: Char; const SomeChars: array of char): Boolean;
var
  LChar: Char;
begin
  for LChar in SomeChars do
    if LChar = AChar then
      Exit(True);
  Result := False;
end;

function IndexOf(AString: string; value: Char): Integer;
begin
  Result := System.Pos(Value, AString) - 1;
end;

function Substring(AString: string; StartIndex: Integer): string; overload;
begin
  Result := System.Copy(AString, StartIndex + 1, Length(AString));
end;

function Substring(AString: string; StartIndex: Integer; Length: Integer): string; overload;
begin
  Result := System.Copy(AString, StartIndex + 1, Length);
end;

procedure DTFmtError(AErrorCode: DTErrorCode; const AValue: string);
const
  Errors: array[DTErrorCode] of string = (SInvalidDateString, SInvalidTimeString, SInvalidOffsetString);
begin
  raise EDateTimeException.CreateFmt(Errors[AErrorCode], [AValue]);
end;

function GetNextDTComp(var P: PChar; const PEnd: PChar; ErrorCode: DTErrorCode; const AValue: string): string; overload;
begin
  Result := '';
  while ((P <= PEnd) and IsDigit(P^)) do
  begin
    Result := Result + P^;
    Inc(P);
  end;
  if Result = '' then
    DTFmtError(ErrorCode, AValue);
end;

function GetNextDTComp(var P: PChar; const PEnd: PChar; const DefValue: string; Prefix: Char; IsOptional: Boolean; ErrorCode: DTErrorCode; const AValue: string): string; overload;
begin
  if (P >= PEnd) then
  begin
    Result := DefValue;
    Exit;
  end;

  if P^ <> Prefix then
  begin
    if IsOptional then
    begin
      Result := DefValue;
      Exit;
    end;
    DTFmtError(ErrorCode, AValue);
  end;
  Inc(P);

  Result := '';
  while ((P <= PEnd) and IsDigit(P^)) do
  begin
    Result := Result + P^;
    Inc(P);
  end;
  if Result = '' then
    DTFmtError(ErrorCode, AValue);
end;

function DateToISO8601(const ADate: TDateTime): string;
const
  SDateFormat: string = 'yyyy''-''mm''-''dd''T''hh'':''nn'':''ss''.''zzz''Z'''; { Do not localize }
  SOffsetFormat: string = '%s%s%.02d:%.02d'; { Do not localize }
  Neg: array[Boolean] of string = ('+', '-'); { Do not localize }
begin
  Result := FormaTDateTime(SDateFormat, ADate);
end;

procedure DecodeISO8601Date(const DateString: string; var AYear, AMonth, ADay: Word);

  procedure ConvertDate(const AValue: string);
  const
    SDateSeparator: Char = '-';
  var
    P, PE: PChar;
  begin
    P := PChar(AValue);
    PE := P + (Length(AValue) - 1);
    AYear := StrToInt(GetNextDTComp(P, PE, InvTime, AValue));
    AMonth := StrToInt(GetNextDTComp(P, PE, '00', SDateSeparator, True, InvDate, AValue));
    ADay := StrToInt(GetNextDTComp(P, PE, '00', SDateSeparator, True, InvDate, AValue));
  end;

var
  TempValue: string;
  LNegativeDate: Boolean;
begin
  AYear := 0;
  AMonth := 0;
  ADay := 1;

  LNegativeDate := (DateString[1] = '-');
  if LNegativeDate then
    TempValue := Substring(DateString, 1)
  else
    TempValue := DateString;
  if Length(TempValue) < 4 then
    raise EDateTimeException.CreateFmt(SInvalidDateString, [TempValue]);
  ConvertDate(TempValue);
end;

procedure DecodeISO8601Time(const TimeString: string; var AHour, AMinute, ASecond, AMillisecond: Word; var AHourOffset, AMinuteOffset: Integer);
const
  STimeSeparator: Char = ':';
  SMilSecSeparator: Char = '.';
var
  LFractionalSecondString: string;
  P, PE: PChar;
  LOffsetSign: Char;
begin
  AHour := 0;
  AMinute := 0;
  ASecond := 0;
  AMillisecond := 0;
  AHourOffset := 0;
  AMinuteOffset := 0;
  if TimeString <> '' then
  begin
    P := PChar(TimeString);
    PE := P + (Length(TimeString) - 1);
    AHour := StrToInt(GetNextDTComp(P, PE, InvTime, TimeString));
    AMinute := StrToInt(GetNextDTComp(P, PE, '00', STimeSeparator, False, InvTime, TimeString));
    ASecond := StrToInt(GetNextDTComp(P, PE, '00', STimeSeparator, True, InvTime, TimeString));
    LFractionalSecondString := GetNextDTComp(P, PE, '', SMilSecSeparator, True, InvTime, TimeString);
    if LFractionalSecondString <> '' then
      AMillisecond := StrToInt(LFractionalSecondString + StringOfChar('0', (3 - Length(LFractionalSecondString))));
    if IsInArray(P^, ['-', '+']) then
    begin
      LOffsetSign := P^;
      Inc(P);
      if not IsDigit(P^) then
        DTFmtError(InvTime, TimeString);
      AHourOffset := StrToInt(LOffsetSign + GetNextDTComp(P, PE, InvOffset, TimeString));
      AMinuteOffset := StrToInt(LOffsetSign + GetNextDTComp(P, PE, '00', STimeSeparator, True, InvOffset, TimeString));
    end;
  end;
end;

function AdjustDateTime(const ADate: TDateTime; AHourOffset, AMinuteOffset: Integer): TDateTime;
var
  AdjustDT: TDateTime;
begin
  Result := ADate;
    { If we have an offset, adjust time to go back to UTC }
  if (AHourOffset <> 0) or (AMinuteOffset <> 0) then
  begin
    AdjustDT := EncodeTime(Abs(AHourOffset), Abs(AMinuteOffset), 0, 0);
    if ((AHourOffset * MinsPerHour) + AMinuteOffset) > 0 then
      Result := Result - AdjustDT
    else
      Result := Result + AdjustDT;
  end;
end;

function ISO8601ToDate(const AISODate: string): TDateTime;
const
  STimePrefix: Char = 'T';
var
  TimeString, DateString: string;
  TimePosition: Integer;
  Year, Month, Day, Hour, Minute, Second, Millisecond: Word;
  HourOffset, MinuteOffset: Integer;
begin
  HourOffset := 0;
  MinuteOffset := 0;
  TimePosition := IndexOf(AISODate, STimePrefix);
  if TimePosition >= 0 then
  begin
    DateString := Substring(AISODate, 0, TimePosition);
    TimeString := Substring(AISODate, TimePosition + 1);
  end
  else
  begin
    Hour := 0;
    Minute := 0;
    Second := 0;
    Millisecond := 0;
    HourOffset := 0;
    MinuteOffset := 0;
    DateString := AISODate;
    TimeString := '';
  end;
  DecodeISO8601Date(DateString, Year, Month, Day);
  DecodeISO8601Time(TimeString, Hour, Minute, Second, Millisecond, HourOffset, MinuteOffset);
  Result := EncodeDateTime(Year, Month, Day, Hour, Minute, Second, Millisecond);
  Result := AdjustDateTime(Result, HourOffset, MinuteOffset);
end;

end.

