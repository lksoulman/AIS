unit LoginMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-19
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Controls,
  Login,
  Config,
  LoginMgr,
  SyncAsync,
  AppContext,
  LoginGFType;

type

  TLoginMgrImpl = class(TInterfacedObject, ISyncAsync, ILoginMgr)
  private
    // ��¼����
    FLogin: TLogin;
    // ���ýӿ�
    FConfig: IConfig;
    // Ӧ�ó��������Ľӿ�
    FAppContext: IAppContext;
  protected
    // ��ʼ��
    procedure DoCreateLogin;
  public
    // ���캯��
    constructor Create;
    // ��������
    destructor Destroy; override;

    {ISyncAsync}

    // ��ʼ����Ҫ����Դ
    procedure Initialize(AContext: IAppContext); safecall;
    // �ͷŲ���Ҫ����Դ
    procedure UnInitialize; safecall;
    // �ǲ��Ǳ���ͬ��ִ��
    function IsNeedSync: WordBool; safecall;
    // ͬ��ִ�з���
    procedure SyncExecute; safecall;
    // �첽ִ�з���
    procedure AsyncExecute; safecall;

    { ILoginMgr }

    // �ǲ��ǵ�¼ GF ����
    function IsLoginGF(AGFType: TLoginGFType): Boolean; safecall;
    // �����������µ�¼
    procedure BaseGFUserLogin(AErrorCode: Integer; const AValue: WideString); safecall;
    // �ʲ��������µ�¼
    procedure AssetGFUserLogin(AErrorCode: Integer; const AValue: WideString); safecall;
  end;

implementation

uses
  UserInfo,
  LoginUFXUser,
  LoginGILUser,
  LoginPBOXUser;

{ TLoginMgrImpl }

constructor TLoginMgrImpl.Create;
begin
  inherited;

end;

destructor TLoginMgrImpl.Destroy;
begin

  inherited;
end;

procedure TLoginMgrImpl.DoCreateLogin;
begin
  if FConfig <> nil then begin
    if FConfig.GetUserInfo <> nil then begin
      case FConfig.GetUserInfo.GetLoginType of
        ltUFX:
          begin
            FLogin := TLoginUFXUser.Create;
          end;
        ltGIL:
          begin
            FLogin := TLoginGILUser.Create;
          end;
        ltPBOX:
          begin
            FLogin := TLoginPBOXUser.Create;
          end;
      end;
      FLogin.Initialize(FAppContext);
    end;
  end;
end;

procedure TLoginMgrImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  FConfig := FAppContext.GetConfig as IConfig;
  DoCreateLogin;
end;

procedure TLoginMgrImpl.UnInitialize;
begin
  if FLogin <> nil then begin
    FLogin.UnInitialize;
    FLogin.Free;
    FLogin := nil;
  end;
  FConfig := nil;
  FAppContext := nil;
end;

function TLoginMgrImpl.IsNeedSync: WordBool;
begin
  Result := True;
end;

procedure TLoginMgrImpl.SyncExecute;
begin
  if FLogin <> nil then begin
    if FLogin.ShowLoginMainUI = mrOk then begin
      if  FLogin.IsLoginGF(lGFAll) then begin
        if FConfig <> nil then begin
          FConfig.GetUserInfo.SaveCache;
          FConfig.ForceInitUserDirectories;
        end;
      end;
    end;
  end;
end;

procedure TLoginMgrImpl.AsyncExecute;
begin

end;

function TLoginMgrImpl.IsLoginGF(AGFType: TLoginGFType): Boolean;
begin
  Result := FLogin.IsLoginGF(AGFType);
end;

procedure TLoginMgrImpl.BaseGFUserLogin(AErrorCode: Integer; const AValue: WideString);
begin

end;

procedure TLoginMgrImpl.AssetGFUserLogin(AErrorCode: Integer; const AValue: WideString);
begin

end;

end.
