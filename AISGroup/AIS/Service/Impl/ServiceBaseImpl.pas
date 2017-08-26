unit ServiceBaseImpl;

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
  UserInfo,
  SyncAsync,
  AppContext,
  ServiceImpl,
  ServiceBase,
  GFDataMngr_TLB,
  GFDataMngrEvents;

type

  // ��������ӿ�
  TServiceBaseImpl = class(TGFServiceImpl, IServiceBase)
  private
  protected
    // ��¼
    procedure DoUserLogin(ACode: integer; const AValue: AnsiString); override;
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

    { IServiceBase }

    // ���ô���
    function SetProxy: Boolean; safecall;
    // ��ȡ GF ���ݷ���ӿ�
    function GetGFDataManager: IGFDataManager; safecall;
    // ��Դ��
    function GilUserBind(AServerUrl, AUserName, AAssetUserName, AOrgNo, AAssetNo: WideString; var ABindLicense, ABindOrgSign, AErrorMsg: WideString; var AErrorCode: Integer): Boolean; safecall;
    // ��Դ��¼
    function GilUserLogin(ALoginType: TLoginType; AServerUrl, ABindLicense, AAssetUserName, AOrgNo, AAssetNo: WideString; var AErrorMsg: WideString; var AErrorCode: Integer): Boolean; safecall;
  end;

implementation

uses
  Utils,
  Config,
  LoginMgr,
  FastLogLevel,
  WNDataSetInf,
  ServiceConst;

{ TServiceBaseImpl }

constructor TServiceBaseImpl.Create;
begin
  inherited;
  FWorkThreadCount := 9;
end;

destructor TServiceBaseImpl.Destroy;
begin

  inherited;
end;

procedure TServiceBaseImpl.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);
end;

procedure TServiceBaseImpl.UnInitialize;
begin
  inherited UnInitialize;
end;

function TServiceBaseImpl.IsNeedSync: WordBool;
begin
  Result := True;
end;

procedure TServiceBaseImpl.SyncExecute;
begin

end;

procedure TServiceBaseImpl.AsyncExecute;
begin

end;

function TServiceBaseImpl.SetProxy: Boolean;
begin
  DoSetProxy;
end;

function TServiceBaseImpl.GetGFDataManager: IGFDataManager;
begin
  Result := FGFDataManager;
end;

function TServiceBaseImpl.GilUserBind(AServerUrl, AUserName, AAssetUserName, AOrgNo, AAssetNo: WideString; var ABindLicense, ABindOrgSign, AErrorMsg: WideString; var AErrorCode: Integer): Boolean;
var
  LGFData: IGFData;
  LErrorCode: Integer;
  LErrorMsg: WideString;
  LDataSet: IWNDataSet;
begin
  Result := False;
  AErrorMsg := '';
  ABindLicense := '';
  ABindOrgSign := '';
  AErrorCode := ECODE_OTHER;
  if FGFDataManager = nil then begin
    AErrorCode := ECODE_SERVICE_BASE_NIL;
    Exit;
  end;

  try
    LGFData := FGFDataManager.HSUserBind(0, AServerUrl, AUserName, AAssetUserName + '@' + AOrgNo + '@' + AAssetNo, LErrorCode, LErrorMsg);
    if (LGFData <> nil) and (LErrorCode = 0) then begin
      LDataSet := Utils.GFData2WNDataSet(LGFData);
      if (LDataSet <> nil) and (LDataSet.RecordCount > 0) then begin
        if LDataSet.FieldCount >= 3 then begin
          LDataSet.First;
          ABindLicense := LDataSet.Fields(1).AsString;
          ABindOrgSign := LDataSet.Fields(2).AsString;
          Result := True;
          AErrorCode := ECODE_SUCCESS;
        end else begin
          AErrorCode := ECODE_BIND_BASE_RETURN_FIELD;
        end;
      end else begin
        AErrorCode := ECODE_BIND_BASE_RETURN_NIL;
      end;
    end else begin
      if LErrorCode = 6010 then begin // License ������
        AErrorCode := ECODE_BIND_BASE_USER_NOEXIST;
      end else if LErrorCode = 6012 then begin // License �Ѱ�
        AErrorCode := ECODE_BIND_BASE_USER_EXIST;
      end else if LErrorCode = -1003 then begin // �������
        AErrorCode := ECODE_SERVICE_BASE_NETWORK_EXCEPT;
        FAppContext.AppLog(llError, Format('[TGFServiceAssetImpl.GilUserLogin] Network is Except, (Url=%s), (ErrorMsg=%s)', [AServerUrl, AErrorMsg]));
      end else begin // �û�����������
        AErrorCode := ECODE_OTHER;
        FAppContext.AppLog(llError, Format('[TGFServiceBaseImpl.GilUserBind] return other error, (ErrorCode=%d), (ErrorMsg=%s)', [LErrorCode, LErrorMsg]));
      end;
    end;
  except
    on Ex: Exception do begin
      AErrorCode := ECODE_SERVICE_BASE_EXEC_EXCEPT;
      FAppContext.AppLog(llError, Format('[TGFServiceBaseImpl.GilUserBind] FGFDataManager.HSUserBind is Exception, Exception is %s, (ErrorCode=%d), (ErrorMsg=%s)', [Ex.Message, LErrorCode, LErrorMsg]));
    end;
  end;
end;

function TServiceBaseImpl.GilUserLogin(ALoginType: TLoginType; AServerUrl, ABindLicense, AAssetUserName, AOrgNo, AAssetNo: WideString; var AErrorMsg: WideString; var AErrorCode: Integer): Boolean;
var
  LErrorCode: Integer;
  LErrorMsg: WideString;
begin
  Result := False;
  AErrorMsg := '';
  AErrorCode := ECODE_OTHER;
  if FGFDataManager = nil then begin
    AErrorCode := ECODE_SERVICE_BASE_NIL;
    Exit;
  end;

  SetProxy;
  try
    Result := FGFDataManager.HSUserLogin(0, AServerUrl, ABindLicense, AAssetUserName + '@' + AOrgNo + '@' + AAssetNo, LErrorCode, LErrorMsg);
    if not Result then begin
      if LErrorCode = -1003 then begin
        AErrorCode := ECODE_SERVICE_BASE_NETWORK_EXCEPT;
        FAppContext.AppLog(llError, Format('[TGFServiceAssetImpl.GilUserLogin] Network is Except, (Url=%s), (ErrorMsg=%s)', [AServerUrl, AErrorMsg]));
      end else if (LErrorCode = 6010) and (ALoginType <> ltGIL) then begin
        AErrorCode := ECODE_BIND_BASE_NEED_REPEAT;
        AErrorMsg := LErrorMsg;
      end else begin
        AErrorMsg := LErrorMsg;
        FAppContext.AppLog(llError, Format('[TGFServiceBaseImpl.GilUserLogin] return other error, (ErrorCode=%d), (ErrorMsg=%s)', [LErrorCode, LErrorMsg]));
      end;
    end else begin
      AErrorCode := ECODE_SUCCESS;
    end;
  except
    on Ex: Exception do begin
      AErrorCode := ECODE_SERVICE_BASE_EXEC_EXCEPT;
      FAppContext.AppLog(llError, Format('[TGFServiceBaseImpl.GilUserLogin] FGFDataManager.HSUserLogin Exception, Exception is %s, (ErrorCode=%d), (ErrorMsg=%s)', [Ex.Message, LErrorCode, LErrorMsg]));
    end;
  end;
end;

procedure TServiceBaseImpl.DoUserLogin(ACode: integer; const AValue: AnsiString);
begin
  if FAppContext = nil then Exit;

  if FAppContext.GetLoginMgr <> nil then begin
    (FAppContext.GetLoginMgr as ILoginMgr).BaseGFUserLogin(ACode, AValue);
  end;
end;

end.

