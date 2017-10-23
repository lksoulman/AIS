unit WebCfgImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Web Cfg Interface
// Author£º      lksoulman
// Date£º        2017-8-25
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  WebCfg,
  WebInfo,
  Windows,
  Classes,
  SysUtils,
  AppContext,
  CommonRefCounter,
  Generics.Collections;

type

  // Web Cfg Interface
  TWebCfgImpl = class(TAutoInterfacedObject, IWebCfg)
  private
    // Application Context
    FAppContext: IAppContext;
    // Url Info Dictionary
    FWebInfoDic: TDictionary<Integer, IWebInfo>;
  protected
    // Init Web Info
    procedure DoInitWebInfos;
    // Load Xml Nodes
    procedure DoLoadXmlNodes(ANodeList: TList);
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;

    { IWebCfg }

    // Initialize resources(only execute once)
    procedure Initialize(AContext: IInterface);
    // Releasing resources(only execute once)
    procedure UnInitialize;
    // Get url
    function GetUrl(AWebID: Integer): WideString;
    // Get UrlInfo
    function GetUrlInfo(AWebID: Integer): IWebInfo;
  end;

implementation

uses
  Cfg,
  Utils,
  LogLevel,
  NativeXml,
  SystemInfo,
  WebInfoImpl;

const
  SERVERIP = '!ServerIP';
  SKINSTYLE = '!skinstyle';
  FONTRATIO = '!fontRatio';

{ TWebCfgImpl }

constructor TWebCfgImpl.Create;
begin
  inherited;
  FWebInfoDic := TDictionary<Integer, IWebInfo>.Create;
end;

destructor TWebCfgImpl.Destroy;
begin
  FWebInfoDic.Free;
  inherited;
end;

procedure TWebCfgImpl.DoInitWebInfos;
var
  LFile: string;
  LNode: TXmlNode;
  LXml: TNativeXml;
  LNodeList: TList;
begin
  LFile := FAppContext.GetCfg.GetCfgPath + 'Web\WebCfg.xml';
  if FileExists(LFile) then begin
    LXml := TNativeXml.Create(nil);
    try
      LXml.LoadFromFile(LFile);
      LXml.XmlFormat := xfReadable;
      LNode := LXml.Root;
      LNodeList := TList.Create;
      try
        LNode.FindNodes('WebInfo', LNodeList);
        DoLoadXmlNodes(LNodeList);
      finally
        LNodeList.Free;
      end;
    finally
      LXml.Free;
    end;
  end else begin
    FAppContext.SysLog(llERROR, Format('[TWebCfgImpl][DoInitWebInfos] Load file %s is not exist.', [LFile]));
  end;
end;

procedure TWebCfgImpl.DoLoadXmlNodes(ANodeList: TList);
var
  LNode: TXmlNode;
  LWebInfo: IWebInfo;
  LIndex, LWebID: Integer;
begin
  if ANodeList = nil then Exit;

  for LIndex := 0 to ANodeList.Count - 1 do begin
    LNode := ANodeList.Items[LIndex];
    if LNode <> nil then begin
      LWebID := Utils.GetIntegerByChildNodeName(LNode, 'WebID', 0);
      if not FWebInfoDic.ContainsKey(LWebID) then begin
        LWebInfo := TWebInfoImpl.Create as IWebInfo;
        FWebInfoDic.AddOrSetValue(LWebID, LWebInfo);
        LWebInfo.SetWebID(LWebID);
        LWebInfo.SetUrl(Utils.GetStringByChildNodeName(LNode, 'Url'));
        LWebInfo.SetServerName(Utils.GetStringByChildNodeName(LNode, 'ServerName'));
        LWebInfo.SetDescription(Utils.GetStringByChildNodeName(LNode, 'Description'));
      end;
    end;
  end;
end;

procedure TWebCfgImpl.Initialize(AContext: IInterface);
begin
  FAppContext := AContext as IAppContext;
  DoInitWebInfos;
end;

procedure TWebCfgImpl.UnInitialize;
begin

  FAppContext := nil;
end;

function TWebCfgImpl.GetUrl(AWebID: Integer): WideString;
var
  LWebInfo: IWebInfo;
  LServerIP, LSkinStyle, LFontRatio: string;
begin
  if FWebInfoDic.TryGetValue(AWebID, LWebInfo)
    and (LWebInfo <> nil) then begin
    LServerIP := FAppContext.GetCfg.GetServerCfg.GetServerUrl(LWebInfo.GetServerName);
    Result := StringReplace(LWebInfo.GetUrl, SERVERIP, LServerIP, [rfReplaceAll]);
    LSkinStyle := FAppContext.GetCfg.GetSysCfg.GetSystemInfo.GetSystemInfo^.FSkinStyle;
    if LSkinStyle <> '' then begin
      Result := StringReplace(Result, SKINSTYLE, LSkinStyle, [rfReplaceAll]);
    end;
    LFontRatio := FAppContext.GetCfg.GetSysCfg.GetSystemInfo.GetSystemInfo^.FFontRatio;
    if LSkinStyle <> '' then begin
      Result := StringReplace(Result, FONTRATIO, LFontRatio, [rfReplaceAll]);
    end;
  end else begin
    Result := '';
  end;
end;

function TWebCfgImpl.GetUrlInfo(AWebID: Integer): IWebInfo;
begin
  if not (FWebInfoDic.TryGetValue(AWebID, Result)
    and (Result <> nil)) then begin
    Result := nil;
  end;
end;

end.
