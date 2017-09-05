unit WebInfoImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-25
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  WebInfo,
  UrlInfo,
  Windows,
  Classes,
  SysUtils,
  AppContext,
  CommonRefCounter,
  Generics.Collections;

type

  TWebInfoImpl = class(TAutoInterfacedObject, IWebInfo)
  private
    // 应用程序上下文接口
    FAppContext: IAppContext;
    // Url 信息字典
    FUrlInfoDic: TDictionary<Integer, IUrlInfo>;
  protected
  public
    // 构造函数
    constructor Create; override;
    // 析构函数
    destructor Destroy; override;

    { IWebInfo }

    // 初始化需要的资源
    procedure Initialize(AContext: IInterface); safecall;
    // 释放不需要的资源
    procedure UnInitialize; safecall;
    // 加载数据
    procedure LoadXmlNodes(ANodeList: TList); safecall;
    // 获取 url
    function GetUrl(AWebID: Integer): WideString; safecall;
    // 获取 UrlInfo
    function GetUrlInfo(AWebID: Integer): IUrlInfo; safecall;
  end;

implementation

uses
  Utils,
  Config,
  NativeXml,
  SyscfgInfo,
  UrlInfoImpl;

const
  SERVERIP = '!ServerIP';
  SKINSTYLE = '!skinstyle';
  FONTRATIO = '!fontRatio';

{ TWebInfoImpl }

constructor TWebInfoImpl.Create;
begin
  inherited;
  FUrlInfoDic := TDictionary<Integer, IUrlInfo>.Create;
end;

destructor TWebInfoImpl.Destroy;
begin
  FUrlInfoDic.Free;
  inherited;
end;

procedure TWebInfoImpl.Initialize(AContext: IInterface);
begin
  FAppContext := AContext as IAppContext;

end;

procedure TWebInfoImpl.UnInitialize;
begin
  FUrlInfoDic.Clear;
  FAppContext := nil;
end;

procedure TWebInfoImpl.LoadXmlNodes(ANodeList: TList);
var
  LNode: TXmlNode;
  LUrlInfo: IUrlInfo;
  LIndex, LWebID: Integer;
begin
  if ANodeList = nil then Exit;

  for LIndex := 0 to ANodeList.Count - 1 do begin
    LNode := ANodeList.Items[LIndex];
    if LNode <> nil then begin
      LWebID := Utils.GetIntegerByChildNodeName(LNode, 'WebID', 0);
      if not FUrlInfoDic.ContainsKey(LWebID) then begin
        LUrlInfo := TUrlInfoImpl.Create as IUrlInfo;
        FUrlInfoDic.AddOrSetValue(LWebID, LUrlInfo);
        LUrlInfo.SetWebID(LWebID);
        LUrlInfo.SetUrl(Utils.GetStringByChildNodeName(LNode, 'Url'));
        LUrlInfo.SetServerName(Utils.GetStringByChildNodeName(LNode, 'ServerName'));
        LUrlInfo.SetDescription(Utils.GetStringByChildNodeName(LNode, 'Description'));
      end;
    end;
  end;
end;

function TWebInfoImpl.GetUrl(AWebID: Integer): WideString;
var
  LUrlInfo: IUrlInfo;
  LServerIP, LSkinStyle, LFontRatio: string;
begin
  if FUrlInfoDic.TryGetValue(AWebID, LUrlInfo)
    and (LUrlInfo <> nil) then begin
    if FAppContext.GetConfig <> nil then begin
      LServerIP := (FAppContext.GetConfig as IConfig).GetServerIP(LUrlInfo.GetServerName);
      Result := StringReplace(LUrlInfo.GetUrl, SERVERIP, LServerIP, [rfReplaceAll]);
      if (FAppContext.GetConfig as IConfig).GetSyscfgInfo <> nil then begin
        LSkinStyle := (FAppContext.GetConfig as IConfig).GetSyscfgInfo.GetSkinStyle;
        if LSkinStyle <> '' then begin
          Result := StringReplace(Result, SKINSTYLE, LSkinStyle, [rfReplaceAll]);
        end;
        LFontRatio := (FAppContext.GetConfig as IConfig).GetSyscfgInfo.GetFontRatio;
        if LSkinStyle <> '' then begin
          Result := StringReplace(Result, FONTRATIO, LFontRatio, [rfReplaceAll]);
        end;
      end;
    end;
  end else begin
    Result := '';
  end;
end;

function TWebInfoImpl.GetUrlInfo(AWebID: Integer): IUrlInfo;
begin
  if not (FUrlInfoDic.TryGetValue(AWebID, Result)
    and (Result <> nil)) then begin
    Result := nil;
  end;
end;

end.
