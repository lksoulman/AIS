
{*******************************************************}
{                                                       }
{             Delphi REST Client Framework              }
{                                                       }
{ Copyright(c) 2016 Embarcadero Technologies, Inc.      }
{              All rights reserved                      }
{                                                       }
{*******************************************************}
unit REST.Json;

/// <summary>
/// REST.Json implements a TJson class that offers several convenience methods:
/// - converting Objects to Json and vice versa
/// - formating Json
/// </summary>

interface

uses
  System.JSON, Data.DBXJSONReflect;

type
  TJsonOption = (joIgnoreEmptyStrings, joIgnoreEmptyArrays, joDateIsUTC, joDateFormatUnix, joDateFormatISO8601, joDateFormatMongo, joDateFormatParse);

  TJsonOptions = set of TJsonOption;

  TJson = class(TObject)
  public
    /// <summary>
    /// Converts any TObject descendant into its Json representation.
    /// </summary>
    class function ObjectToJsonObject(AObject: TObject): TJSONObject;
    /// <summary>
    ///   Converts any TObject decendant into its Json string representation. The resulting string has proper Json
    ///   encoding applied.
    /// </summary>
    class function ObjectToJsonString(AObject: TObject): string;
    class function JsonToObject<T: class, constructor>(AJsonObject: TJSONObject): T; overload;
    class function JsonToObject<T: class, constructor>(AJson: string): T; overload;
    class procedure JsonToObject(AObject: TObject; AJsonObject: TJSONObject); overload;
    class function Format(AJsonValue: TJSONValue): string;

    /// <summary>
    ///   Encodes the string representation of a TJSONValue descendant so that line breaks, tabulators etc are escaped
    ///   using backslashes.
    /// </summary>
    /// <example>
    ///   {"name":"something\else"} will be encoded as {"name":"something\\else"}
    /// </example>
    class function JsonEncode(AJsonValue: TJSONValue): string; overload;
    class function JsonEncode(AJsonString: string): string; overload;
  end;

implementation

uses
  DateUtils, SysUtils, Rtti, Character, System.JSONConsts;

class function TJson.Format(AJsonValue: TJSONValue): string;
var
  s: string;
  c: Char;
  EOL: string;
  INDENT: string;
  LIndent: string;
  isEOL: Boolean;
  isInString: Boolean;
  isEscape: Boolean;
begin
  EOL := #13#10;
  INDENT := '  ';
  isEOL := True;
  isInString := False;
  isEscape := False;
  s := AJsonValue.ToString; //This will basically display all strings as Delphi strings. Technically we should show "Json encoded" strings here.
  for c in s do
  begin
    if not isInString and ((c = '{') or (c = '[')) then
    begin
      if not isEOL then
        Result := Result + EOL;
      Result := Result + LIndent + c + EOL;
      LIndent := LIndent + INDENT;
      Result := Result + LIndent;
      isEOL := True;
    end
    else if not isInString and (c = ',') then
    begin
      isEOL := False;
      Result := Result + c + EOL + LIndent;
    end
    else if not isInString and ((c = '}') or (c = ']')) then
    begin
      Delete(LIndent, 1, Length(INDENT));
      if not isEOL then
        Result := Result + EOL;
      Result := Result + LIndent + c + EOL;
      isEOL := True;
    end
    else
    begin
      isEOL := False;
      Result := Result + c;
    end;
    isEscape := (c = '\') and not isEscape;
    if not isEscape and (c = '"') then
      isInString := not isInString;
  end;
end;

class function TJson.JsonToObject<T>(AJson: string): T;
var
  LJSONValue: TJSONValue;
  LJSONObject: TJSONObject;
begin
  LJSONValue := TJSONObject.ParseJSONValue(AJson);
  try
    if Assigned(LJSONValue) and (LJSONValue is TJSONObject) then
      LJSONObject := LJSONValue as TJSONObject
    else
      raise EConversionError.Create(SCannotCreateObject);
    Result := JsonToObject<T>(LJSONObject);
  finally
    FreeAndNil(LJSONObject);
  end;
end;

class function TJson.JsonEncode(AJsonValue: TJSONValue): string;
var
  LBytes: TArray<Byte>;
begin
  SetLength(LBytes, Length(AJsonValue.ToString) * 6); //Length can not be predicted. Worst case: every single char gets escaped
  SetLength(LBytes, AJsonValue.ToBytes(LBytes, 0)); //adjust Array to actual length
  Result := TEncoding.UTF8.GetString(LBytes);
end;

class function TJson.JsonEncode(AJsonString: string): string;
var
  LJsonValue: TJSONValue;
begin
  LJsonValue := TJSONObject.ParseJSONValue(AJsonString);
  try
    Result := JsonEncode(LJsonValue);
  finally
    LJsonValue.Free;
  end;
end;

class procedure TJson.JsonToObject(AObject: TObject; AJsonObject: TJSONObject);
var
  LUnMarshaler: TJSONUnMarshal;
begin
  LUnMarshaler := TJSONUnMarshal.Create;
  try
    AObject := LUnMarshaler.Unmarshal(AJsonObject);
  finally
    FreeAndNil(LUnMarshaler);
  end;
end;

class function TJson.JsonToObject<T>(AJsonObject: TJSONObject): T;
var
  LUnMarshaler: TJSONUnMarshal;
begin
  LUnMarshaler := TJSONUnMarshal.Create;
  try

    Result := T(LUnMarshaler.Unmarshal(AJsonObject));
  finally
    FreeAndNil(LUnMarshaler);
  end;
end;

class function TJson.ObjectToJsonObject(AObject: TObject): TJSONObject;
var
  LMarshaler: TJSONMarshal;
  LJSONObject: TJSONObject;
begin
  LMarshaler := TJSONMarshal.Create(TJSONConverter.Create);
  try
    LJSONObject := LMarshaler.Marshal(AObject) as TJSONObject;
    Result := LJSONObject;
  finally
    FreeAndNil(LMarshaler);
  end;
end;

class function TJson.ObjectToJsonString(AObject: TObject): string;
var
  LJSONObject: TJSONObject;
begin
  LJSONObject := ObjectToJsonObject(AObject);
  try
    Result := TJson.JsonEncode(LJSONObject);
  finally
    FreeAndNil(LJSONObject);
  end;
end;

end.

