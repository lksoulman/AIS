unit ServiceAssetImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-10
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Service,
  SyncAsync,
  AppContext,
  ServiceImpl,
  ServiceAsset,
  GFDataMngr_TLB;

type

  TServiceAssetImpl = class(TGFServiceImpl, IServiceAsset)
  private
  protected
    // ��¼
    procedure DoUserLogin(AErrorCode: Integer; const AValue: AnsiString); override;
  public
    // ���췽��
    constructor Create;
    // ��������
    destructor Destroy; override;

    { ISyncAsync }

    // ��ʼ����Ҫ����Դ
    procedure Initialize(AContext: IAppContext); override;
    // �ͷŲ���Ҫ����Դ
    procedure UnInitialize; override;
    // �ǲ��Ǳ���ͬ��ִ��
    function IsNeedSync: WordBool; override;
    // ͬ��ִ�з���
    procedure SyncExecute; override;
    // �첽ִ�з���
    procedure AsyncExecute; override;

    { IGFServiceAsset }

    // ���ô���
    function SetProxy: Boolean; safecall;
    // ��ȡ GF ���ݷ���ӿ�
    function GetGFDataManager: IGFDataManager; safecall;
    // ������������
    function PasswordReset(AUserName, AOldPassword, ANewPassword: WideString; var AErrorCode: Integer; var AErrorMsg: WideString): Boolean; safecall;
    // ��Դ�û���¼�ʲ����񷽷�
    function GilUserLogin(AServerUrl, AUserName, AUserPassword: WideString; var APasswordInfo, AErrorMsg: WideString; var AErrorCode: Integer): Boolean; safecall;
    // UFX �û���¼�ʲ����񷽷�
    function UFXUserLogin(AServerUrl, AAssetUserName, AOrgNo, AAssetNo, AAssetUserPassword: WideString; var AErrorMsg: WideString; var AErrorCode: Integer): Boolean; safecall;
    // PBox �û���¼�ʲ����񷽷�
    function PBoxUserLogin(AServerUrl, AAssetUserName, AOrgNo, AAssetNo, AAssetUserPassword: WideString; var AErrorMsg: WideString; var AErrorCode: Integer): Boolean; safecall;
  end;

implementation

uses
  Config,
  LoginMgr,
  FastLogLevel,
  ServiceConst;

{ TServiceAssetImpl }

constructor TServiceAssetImpl.Create;
begin
  Inherited;

end;

destructor TServiceAssetImpl.Destroy;
begin

  Inherited;
end;

procedure TServiceAssetImpl.Initialize(AContext: IAppContext);
begin
  Inherited Initialize(AContext);
end;

procedure TServiceAssetImpl.UnInitialize;
begin
  Inherited UnInitialize;
end;

function TServiceAssetImpl.IsNeedSync: WordBool;
begin
  Result := True;
end;

procedure TServiceAssetImpl.SyncExecute;
begin

end;

procedure TServiceAssetImpl.AsyncExecute;
begin

end;

function TServiceAssetImpl.SetProxy: Boolean;
begin
  DoSetProxy;
end;

function TServiceAssetImpl.GetGFDataManager: IGFDataManager;
begin
  Result := FGFDataManager;
end;

function TServiceAssetImpl.PasswordReset(AUserName, AOldPassword, ANewPassword: WideString; var AErrorCode: Integer; var AErrorMsg: WideString): Boolean;
begin
  Result := False;
  AErrorCode := 0;
  AErrorMsg := '';
  if FServerUrl = '' then Exit;

  if FGFDataManager = nil then begin
    AErrorCode := ECODE_SERVICE_ASSET_NIL;
    Exit;
  end;

  SetProxy;
  try
    Result := FGFDataManager.PassSetup(0, FServerUrl, AUserName, AOldPassword, ANewPassword, AErrorCode, AErrorMsg);
  except
    on Ex: Exception do begin
      AErrorCode := ECODE_SERVICE_ASSET_EXEC_EXCEPT;
      FAppContext.AppLog(llError, Format('[TGFServiceAssetImpl.PasswordReset] FGFDataManager.PassSetup Exception, Exception is %s, (ErrorCode=%d), (ErrorMsg=%s)', [Ex.Message, AErrorCode, AErrorMsg]));
    end;
  end;
end;

function TServiceAssetImpl.GilUserLogin(AServerUrl, AUserName, AUserPassword: WideString; var APasswordInfo, AErrorMsg: WideString; var AErrorCode: Integer): Boolean;
var
  LErrorCode: Integer;
  LErrorMsg: WideString;
begin
  Result := False;
  AErrorMsg := '';
  AErrorCode := ECODE_OTHER;
  FServerUrl := AServerUrl;
  if FGFDataManager = nil then begin
    AErrorCode := ECODE_SERVICE_ASSET_NIL;
    Exit;
  end;

  SetProxy;
  try
    AErrorMsg := FGFDataManager.JYUserLogin(0, AServerUrl, AUserName, AUserPassword, LErrorCode, LErrorMsg, APasswordInfo);
    if LErrorCode = 0 then begin
      AErrorCode := ECODE_SUCCESS;
      Result := True;
    end else if LErrorCode = -1003 then begin
      AErrorCode := ECODE_SERVICE_ASSET_NETWORK_EXCEPT;
      FAppContext.AppLog(llError, Format('[TGFServiceAssetImpl.GilUserLogin] Network is Except, (Url=%s), (ErrorMsg=%s)', [AServerUrl, AErrorMsg]));
    end else begin
      AErrorMsg := LErrorMsg;
      FAppContext.AppLog(llError, Format('[TGFServiceAssetImpl.GilUserLogin] return other error, (ErrorCode=%d), (ErrorMsg=%s)', [LErrorCode, LErrorMsg]));
    end;
  except
    on Ex: Exception do begin
      AErrorCode := ECODE_SERVICE_ASSET_EXEC_EXCEPT;
      FAppContext.AppLog(llError, Format('[TGFServiceAssetImpl.GilUserLogin] FGFDataManager.JYUserLogin is Exception, Exception is %s, (ErrorCode=%d), (ErrorMsg=%s)', [Ex.Message, LErrorCode, LErrorMsg]));
    end;
  end;
end;

function TServiceAssetImpl.UFXUserLogin(AServerUrl, AAssetUserName, AOrgNo, AAssetNo, AAssetUserPassword: WideString; var AErrorMsg: WideString; var AErrorCode: Integer): Boolean;
var
  LErrorCode: Integer;
  LErrorMsg: WideString;
begin
  Result := False;
  AErrorMsg := '';
  AErrorCode := ECODE_OTHER;
  FServerUrl := AServerUrl;
  if FGFDataManager = nil then begin
    AErrorCode := ECODE_SERVICE_ASSET_NIL;
    Exit;
  end;

  try
    Result := FGFDataManager.UserLogin(0, AServerUrl, AAssetUserName + '@' + AOrgNo + '@' + AAssetNo, AAssetUserPassword, LErrorCode, LErrorMsg);
    if Result then begin
      LErrorCode := ECODE_SUCCESS;
      AErrorMsg := LErrorMsg;
    end else begin
      if LErrorCode = -1003 then begin
        AErrorCode := ECODE_SERVICE_ASSET_NETWORK_EXCEPT;
        FAppContext.AppLog(llError, Format('[TGFServiceAssetImpl.GilUserLogin] Network is Except, (Url=%s), (ErrorMsg=%s)', [AServerUrl, AErrorMsg]));
      end else begin // �û�����������
        AErrorMsg := LErrorMsg;
        FAppContext.AppLog(llError, Format('[TGFServiceAssetImpl.GilUserLogin] return other error, (ErrorCode=%d), (ErrorMsg=%s)', [LErrorCode, LErrorMsg]));
      end;
    end;
  except
    on Ex: Exception do begin
      AErrorCode := ECODE_SERVICE_ASSET_EXEC_EXCEPT;
      FAppContext.AppLog(llError, Format('[TGFServiceAssetImpl.GilUserLogin] FGFDataManager.JYUserLogin Exception is %s, (ErrorCode=%d), (ErrorMsg=%s)', [Ex.Message, LErrorCode, LErrorMsg]));
    end;
  end;
end;

function TServiceAssetImpl.PBoxUserLogin(AServerUrl, AAssetUserName, AOrgNo, AAssetNo, AAssetUserPassword: WideString; var AErrorMsg: WideString; var AErrorCode: Integer): Boolean;
var
  LErrorCode: Integer;
  LErrorMsg: WideString;
begin
  Result := False;
  AErrorMsg := '';
  AErrorCode := ECODE_OTHER;
  FServerUrl := AServerUrl;
  if FGFDataManager = nil then begin
    AErrorCode := ECODE_SERVICE_ASSET_NIL;
    Exit;
  end;

  try
    Result := FGFDataManager.PBOXLogin(0, AServerUrl, AAssetUserName + '@' + AOrgNo + '@' + AAssetNo, AAssetUserPassword, LErrorCode, LErrorMsg);
    if Result then begin
      LErrorCode := ECODE_SUCCESS;
      AErrorMsg := LErrorMsg;
    end else begin
      if LErrorCode = -1003 then begin
        AErrorCode := ECODE_SERVICE_ASSET_NETWORK_EXCEPT;
        FAppContext.AppLog(llError, Format('[TGFServiceAssetImpl.PBoxUserLogin] Network is Except, (Url=%s), (ErrorMsg=%s)', [AServerUrl, AErrorMsg]));
      end else begin // �û�����������
        AErrorMsg := LErrorMsg;
        FAppContext.AppLog(llError, Format('[TGFServiceAssetImpl.PBoxUserLogin] return other error, (ErrorCode=%d), (ErrorMsg=%s)', [LErrorCode, LErrorMsg]));
      end;
    end;
  except
    on Ex: Exception do begin
      AErrorCode := ECODE_SERVICE_ASSET_EXEC_EXCEPT;
      FAppContext.AppLog(llError, Format('[TGFServiceAssetImpl.PBoxUserLogin] FGFDataManager.JYUserLogin Exception, Exception is %s, (ErrorCode=%d), (ErrorMsg=%s)', [Ex.Message, LErrorCode, LErrorMsg]));
    end;
  end;
end;

procedure TServiceAssetImpl.DoUserLogin(AErrorCode: integer; const AValue: AnsiString);
var
  LValue: WideString;
begin
  if FAppContext = nil then Exit;
  LValue := AValue;
  if FAppContext.GetLoginMgr <> nil then begin
    (FAppContext.GetLoginMgr as ILoginMgr).AssetGFUserLogin(AErrorCode, LValue);
  end;
end;

end.
