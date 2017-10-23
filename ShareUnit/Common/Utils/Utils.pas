unit Utils;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-5-10
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Json,
  GFData,
  Windows,
  Classes,
  SysUtils,
  ErrorCode,
  NativeXml,
  GFDataSet,
  ComDataSet,
  WNDataSetInf;


  { Replace Enter and Newline}

  // 替换回车和换行
  function ReplaceEnterNewLine(AString, ANewPattern: string): string;

  { DataSet }

  // GFData 转化 GFDataSet 数据集
  function GFData2GFDataSet(AGFData: IGFData): TGFDataSet;
  // GFData 转换 WNDataSet 数据集
  function GFData2WNDataSet(AGFData: IGFData): IWNDataSet;

  { Json }

  // 通过字符串获取 JsonObject
  function GetJsonObjectByString(AString: string): TJSONObject;
  // 通过标签从 JsonObject 获取标签对应的字符串
  function GetStringByJsonObject(AJsonObject: TJSONObject; ATagName: string): string;
  // 通过标签从 JsonObject 获取标签对应的 JsonObject
  function GetJsonObjectByJsonObject(AJsonObject: TJSONObject; ATagName: string): TJSONObject;

  { NativeXml }

  // 获取字符串
  function GetStringByChildNodeName(APNode: TXMLNode; AName: string): string;
  // 获取 Int64
  function GetInt64ByChildNodeName(APNode: TXMLNode; AName: string; ADefault: Int64): Int64;
  // 获取 Integer
  function GetIntegerByChildNodeName(APNode: TXMLNode; AName: string; ADefault: Integer): Integer;


implementation


  { Replace Enter and Newline}

  // 替换回车和换行
  function ReplaceEnterNewLine(AString, ANewPattern: string): string;
  begin
    Result := StringReplace(AString, #13, ANewPattern, [rfReplaceAll]);
    Result := StringReplace(Result, #10, ANewPattern, [rfReplaceAll]);
  end;

  { DataSet }

  // GFData 转化 GFDataSet 数据集
  function GFData2GFDataSet(AGFData: IGFData): TGFDataSet;
  begin
    if (AGFData <> nil)
      and (AGFData.GetErrorCode = ErrorCode_Success) then begin
      Result := TGFDataSet.Create(AGFData);
    end else begin
      Result := nil;
    end;
  end;

  // GFData 转换 WNDataSet 数据集
  function GFData2WNDataSet(AGFData: IGFData): IWNDataSet;
  var
    LGFDataSet: TGFDataSet;
  begin
    LGFDataSet := GFData2GFDataSet(AGFData);
    if LGFDataSet <> nil then begin
      Result := TCustomComDataSet.Create(LGFDataSet, true)
    end else begin
      Result := nil;
    end;
  end;

  // 通过字符串获取 JsonObject
  function GetJsonObjectByString(AString: string): TJSONObject;
  begin
    try
      Result := TJSONObject.ParseJSONValue(Trim(AString)) as TJSONObject;
    except
      on Ex: Exception do begin
        Result := nil;
//        FastSysLog(llERROR, Format('[GetJsonObjectByString] TJSONObject.ParseJSONValue(%s) return json is exception, exception is %s.', [AString]));
      end;
    end;
  end;

  // 通过标签从 JsonObject 获取标签对应的字符串
  function GetStringByJsonObject(AJsonObject: TJSONObject; ATagName: string): string;
  begin
    try
      Result := AJsonObject.GetValue(ATagName).ToString;
      Result := StringReplace(Result, '"', '', [rfReplaceAll]);
    except
      on Ex: Exception do begin
        Result := '';
//        FastSysLog(llERROR, Format('[GetStringByJsonObject] The parse tag name(%s) does not match, exception is %s.', [ATagName, Ex.Message]));
      end;
    end;
  end;

  // 通过标签从 JsonObject 获取标签对应的 JsonObject
  function GetJsonObjectByJsonObject(AJsonObject: TJSONObject; ATagName: string): TJSONObject;
  begin
    try
      Result := AJsonObject.GetValue(ATagName) as TJSONObject;
    except
      on Ex: Exception do begin
        Result := nil;
//        FastSysLog(llERROR, Format('[GetJsonObjectByJsonObject] The parse tag name(%s) does not match, exception is %s.', [ATagName, Ex.Message]));
      end;
    end;
  end;

  { NativeXml }

  // 获取字符串
  function GetStringByChildNodeName(APNode: TXMLNode; AName: string): string;
  var
    LNode: TXMLNode;
  begin
    Result := '';
    if APNode = nil then Exit;
    LNode := APNode.FindNode(UTF8String(AName));
    if LNode <> nil then begin
      Result := string(LNode.Value);
    end else begin
//      FastSysLog(llERROR, Format('[GetStringByChildNodeName] NativeXml find nodename(%s) is nil.', [AName]));
    end;
  end;

  // 获取 Int64
  function GetInt64ByChildNodeName(APNode: TXMLNode; AName: string; ADefault: Int64): Int64;
  var
    LNode: TXMLNode;
  begin
    Result := ADefault;
    if APNode = nil then Exit;
    LNode := APNode.FindNode(UTF8String(AName));
    if LNode <> nil then begin
      Result := StrToInt64Def(string(LNode.Value), ADefault);
    end else begin
//      FastSysLog(llERROR, Format('[GetInt64ByChildNodeName] NativeXml find nodename(%s) is nil.', [AName]));
    end;
  end;

  // 获取 Integer
  function GetIntegerByChildNodeName(APNode: TXMLNode; AName: string; ADefault: Integer): Integer;
  var
    LNode: TXMLNode;
  begin
    Result := ADefault;
    if APNode = nil then Exit;
    LNode := APNode.FindNode(UTF8String(AName));
    if LNode <> nil then begin
      Result := StrToIntDef(string(LNode.Value), ADefault);
    end else begin
//      FastSysLog(llERROR, Format('[GetIntegerByChildNodeName] NativeXml find nodename(%s) is nil.', [AName]));
    end;
  end;

end.
