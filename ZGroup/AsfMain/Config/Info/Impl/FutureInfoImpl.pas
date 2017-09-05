unit FutureInfoImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-28
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  FutureInfo,
  AppContext,
  CommonRefCounter,
  Generics.Collections;

type

  TFutureInfoImpl = class(TAutoInterfacedObject, IFutureInfo)
  private
    type
      TFutureCode = packed record
        FInnerCode: Integer;
        FAgentCode: string;
      end;
      PFutureCode = ^TFutureCode;
  private
    // 应用程序上下文接口
    FAppContext: IAppContext;
    // 期货Code数组大小
    FFutureCodeCount: Integer;
    // 期货Code数组
    FFutureCodes: TArray<PFutureCode>;
    // 期货Code字典
    FFutureCodeDic: TDictionary<Integer, PFutureCode>;
  protected
    // 释放数据
    procedure DoClearFutureCodeDic;
  public
    // 构造函数
    constructor Create; override;
    // 析构函数
    destructor Destroy; override;

    { IFutureInfo }

    // 初始化需要的资源
    procedure Initialize(AContext: IInterface); safecall;
    // 释放不需要的资源
    procedure UnInitialize; safecall;
    // 加载数据
    procedure LoadXmlNodes(ANodeList: TList); safecall;
    // 期货 Code 的个数
    function GetFutureCodeCount: Integer; safecall;
    // 获取 InnerCode
    function GetInnerCode(AIndex: Integer): Integer; safecall;
    // 获取 AgentCode
    function GetAgentCode(AIndex: Integer): WideString; safecall;
    // 获取是不是存在 InnerCode
    function GetFutureCode(AInnerCode: Integer; var ACodeAgent: WideString): Boolean; safecall;
  end;

implementation

uses
  Utils,
  NativeXml;

{ TFutureInfoImpl }

constructor TFutureInfoImpl.Create;
begin
  inherited;
  FFutureCodeDic := TDictionary<Integer, PFutureCode>.Create;
end;

destructor TFutureInfoImpl.Destroy;
begin
  DoClearFutureCodeDic;
//  FFutureCodes.Free;
  inherited;
end;

procedure TFutureInfoImpl.DoClearFutureCodeDic;
//var
//  LIndex: Integer;
//  LFutureCode: PFutureCode;
begin
//  for LIndex := 0 to FFutureCodes.Count - 1 do begin
//    LFutureCode := FFutureCodes.Items[LIndex];
//    if LFutureCode <> nil then begin
//      Dispose(LFutureCode);
//    end;
//  end;
//  FFutureCodes.Clear;
end;

procedure TFutureInfoImpl.Initialize(AContext: IInterface);
begin
  FAppContext := AContext as IAppContext;
end;

procedure TFutureInfoImpl.UnInitialize;
begin
  FAppContext := nil;
end;

procedure TFutureInfoImpl.LoadXmlNodes(ANodeList: TList);
var
  LAgentCode: string;
  LIndex, LInnerCode: Integer;
  LNode: TXmlNode;
  LFutureCode: PFutureCode;
begin
  if ANodeList = nil then Exit;

  for LIndex := 0 to ANodeList.Count - 1 do begin
    LNode := ANodeList.Items[LIndex];
    if LNode <> nil then begin
      LInnerCode := Utils.GetIntegerByChildNodeName(LNode, 'InnerCode', -1);
      LAgentCode := Utils.GetStringByChildNodeName(LNode, 'AgentCode');
      if (LInnerCode <> -1)
        and (LAgentCode <> '') then begin
        New(LFutureCode);
        if LFutureCode <> nil then begin
          LFutureCode.FInnerCode := LInnerCode;
          LFutureCode.FAgentCode := LAgentCode;
          FFutureCodeDic.AddOrSetValue(LInnerCode, LFutureCode);
        end;
      end;
    end;
  end;
  FFutureCodes := FFutureCodeDic.Values.ToArray;
  FFutureCodeCount := Length(FFutureCodes);
end;

function TFutureInfoImpl.GetFutureCode(AInnerCode: Integer; var ACodeAgent: WideString): boolean;
var
  LFutureCode: PFutureCode;
begin
  if FFutureCodeDic.TryGetValue(AInnerCode, LFutureCode) then begin
    ACodeAgent := LFutureCode.FAgentCode;
    Result := True;
  end else begin
    ACodeAgent := '';
  end;
end;

function TFutureInfoImpl.GetFutureCodeCount: Integer;
begin
  Result := FFutureCodeCount;
end;

function TFutureInfoImpl.GetInnerCode(AIndex: Integer): Integer;
begin
  if (AIndex >= 0) and (AIndex < FFutureCodeCount) then begin
    Result := FFutureCodes[AIndex].FInnerCode;
  end else begin
    Result := -1;
  end;
end;

function TFutureInfoImpl.GetAgentCode(AIndex: Integer): WideString;
begin
  if (AIndex >= 0) and (AIndex < FFutureCodeCount) then begin
    Result := FFutureCodes[AIndex].FAgentCode;
  end else begin
    Result := '';
  end;
end;

end.
