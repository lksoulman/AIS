unit AppContextImpl;

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
  Vcl.Forms,
  Windows,
  Classes,
  SysUtils,
  LoginMgr,
  CipherMgr,
  CacheType,
  AppContext,
  ServiceBase,
  ServiceAsset,
  UserBehavior,
  FastLogLevel,
  WNDataSetInf,
  CacheBaseData,
  CacheUserData,
  GFDataMngr_TLB,
  Generics.Collections;

type

  TAppContextImpl = class(TInterfacedObject, IAppContext)
  private
    // �����ļ��ӿ�
    FConfig: IInterface;
    // ��¼�ӿ�
    FLoginMgr: ILoginMgr;
    // ���ܽ��ܽӿ�
    FCipherMgr: ICipherMgr;
    // ��������
    FServiceBase: IServiceBase;
    // �ʲ�����
    FServiceAsset: IServiceAsset;
    // �û���Ϊ�ӿ��ϴ��ӿ�
    FUserBehavior: IUserBehavior;
    // ���� cache ���ݽӿ�
    FCacheBaseData: ICacheBaseData;
    // �û� cache ���ݽӿ�
    FCacheUserData: ICacheUserData;
    // �������ݷ���ӿ�
    FBaseGFDataManager: IGFDataManager;
    // �ʲ����ݷ���ӿ�
    FAssetGFDataManager: IGFDataManager;
    // �ӿڴ洢����
    FInterfaceDic: TDictionary<string, IUnknown>;
  protected
    // �ȴ�����
    function DoWaitForSingleObject(AGFData: IGFData; AWaitTime: DWORD; ALogSuffix: string): IWNDataSet;
    // GF�첽���ݲ�ѯ�ӿ�
    function DoGFASyncQueryData(AGFDataManager: IGFDataManager; ASql: WideString; ADataArrive: Int64; ATag: Int64; LogSuffix: string): IGFData;
    // GFͬ�����ݲ�ѯ�ӿ�
    function DoGFSyncQueryDataSet(AGFDataManager: IGFDataManager; ASql: string; ATag: Int64; AWaitTime: DWORD; LogSuffix: string): IWNDataSet;
    // GF�����ȼ�ͬ�����ݲ�ѯ�ӿ�
    function DoGFSyncQueryHighDataSet(AGFDataManager: IGFDataManager; ASql: string; ATag: Int64; AWaitTime: DWORD; LogSuffix: string): IWNDataSet;
  public
    // ���캯��
    constructor Create;
    // ��������
    destructor Destroy; override;

    { IAppContext }

    // �˳�Ӧ�ó���
    procedure ExitApp; safecall;
    // ����Ӧ�ó���
    procedure ReStartApp; safecall;
    // ��ȡ���ýӿ�
    function GetConfig: IInterface; safecall;
    // ��ȡ��¼�ӿ�
    function GetLoginMgr: ILoginMgr; safecall;
    // ��ȡ���ܽ��ܽӿ�
    function GetCipherMgr: ICipherMgr; safecall;
    // ��ȡ��������
    function GetServiceBase: IInterface; safecall;
    // ��ȡ�ʲ�����
    function GetServiceAsset: IInterface; safecall;
    // ע��ӿ�
    procedure RegisterInterface(AGUID: TGUID; const AObj: IUnknown); safecall;
    // ж�ؽӿ�
    procedure UnRegisterInterface(AGUID: TGUID); safecall;
    // ��ѯ�ӿ�
    function QueryInterface(AGUID: TGUID): IUnknown; safecall;
    // ����û���Ϊ����
    procedure AddBehavior(ABehavior: WideString); safecall;
    // ������־���
    procedure HQLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
    // ��ҳ��־���
    procedure WebLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
    // Ӧ��ϵͳ��־���
    procedure AppLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
    // ָ����־���
    procedure IndicatorLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
    // Cache���ݻ�ȡ�ӿ�
    function SyncCacheQueryData(ACacheType: TCacheType; ASql: WideString): IWNDataSet; safecall;
    // GF �첽���ݲ�ѯ����
    function GFASyncQueryData(AGFType: TGFType; ASql: WideString; ADataArrive: Int64; ATag: Int64): IGFData; safecall;
    // GF ͬ�����ݲ�ѯ����
    function GFSyncQueryData(AGFType: TGFType; ASqL: WideString; ATag: Int64; AWaitTime: DWORD): IWNDataSet; safecall;
    // GF ͬ�������ȼ����ݲ�ѯ����
    function GFSyncQueryHighData(AGFType: TGFType; ASqL: WideString; ATag: Int64; AWaitTime: DWORD): IWNDataSet; safecall;
  end;

implementation

uses
  Config,
  Utils;

{ TAppContextImpl }

constructor TAppContextImpl.Create;
begin
  FInterfaceDic := TDictionary<string, IUnknown>.Create;
end;

destructor TAppContextImpl.Destroy;
begin
  FInterfaceDic.Free;
end;

procedure TAppContextImpl.ExitApp;
begin
  Application.Terminate;
end;

procedure TAppContextImpl.ReStartApp;
begin

end;

function TAppContextImpl.GetConfig: IInterface;
begin
  Result := FConfig;
end;

function TAppContextImpl.GetLoginMgr: ILoginMgr;
begin
  Result := FLoginMgr;
end;

function TAppContextImpl.GetCipherMgr: ICipherMgr;
begin
  Result := FCipherMgr;
end;

function TAppContextImpl.GetServiceBase: IInterface;
begin
  Result := FServiceBase;
end;

function TAppContextImpl.GetServiceAsset: IInterface;
begin
  Result := FServiceAsset;
end;

procedure TAppContextImpl.RegisterInterface(AGUID: TGUID; const AObj: IUnknown);
var
  LGUID: string;
begin
  if AObj = nil then Exit;
  LGUID := GUIDToString(AGUID);
  FInterfaceDic.AddOrSetValue(LGUID, AObj);
  if LGUID = GUIDToString(IConfig) then begin
    FConfig := AObj as IInterface;
  end else if LGUID = GUIDToString(ILoginMgr) then begin
    FLoginMgr := AObj as ILoginMgr;
  end else if LGUID = GUIDToString(ICipherMgr) then begin
    FCipherMgr := AObj as ICipherMgr;
  end else if LGUID = GUIDToString(IUserBehavior) then begin
    FUserBehavior := AObj as IUserBehavior;
  end else if LGUID = GUIDToString(ICacheBaseData) then begin
    FCacheBaseData := AObj as ICacheBaseData;
  end else if LGUID = GUIDToString(ICacheUserData) then begin
    FCacheUserData := AObj as ICacheUserData;
  end else if LGUID = GUIDToString(IServiceBase) then begin
    FServiceBase := AObj as IServiceBase;
    FBaseGFDataManager := FServiceBase.GetGFDataManager;
  end else if LGUID = GUIDToString(IServiceAsset) then begin
    FServiceAsset := AObj as IServiceAsset;
    FAssetGFDataManager := FServiceAsset.GetGFDataManager;
  end;
end;

procedure TAppContextImpl.UnRegisterInterface(AGUID: TGUID);
begin
  FInterfaceDic.Remove(GUIDToString(AGUID));
end;

function TAppContextImpl.QueryInterface(AGUID: TGUID): IUnknown;
begin
  if not FInterfaceDic.TryGetValue(GUIDToString(AGUID), Result) then begin
    Result := nil;
  end;
end;

procedure TAppContextImpl.AddBehavior(ABehavior: WideString);
begin
  if FUserBehavior <> nil then begin
    FUserBehavior.AddBehavior(ABehavior);
  end;
end;

procedure TAppContextImpl.HQLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
begin
  FastHQLog(ALevel, ALog, AUseTime);
end;

procedure TAppContextImpl.WebLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
begin
  FastWebLog(ALevel, ALog, AUseTime);
end;

procedure TAppContextImpl.AppLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
begin
  FastAppLog(ALevel, ALog, AUseTime);
end;

procedure TAppContextImpl.IndicatorLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
begin
  FastIndicatorLog(ALevel, ALog, AUseTime);
end;

function TAppContextImpl.SyncCacheQueryData(ACacheType: TCacheType; ASql: WideString): IWNDataSet;
begin
  case ACacheType of
    ctBaseData:
      begin
        if FCacheBaseData <> nil then begin
          Result := FCacheBaseData.SyncCacheQueryData(ASql);
        end;
      end;
    ctUserDaata:
      begin
        if FCacheUserData <> nil then begin
          Result := FCacheUserData.SyncCacheQueryData(ASql);
        end;
      end;
  end;
end;

function TAppContextImpl.GFASyncQueryData(AGFType: TGFType; ASql: WideString;
  ADataArrive: Int64; ATag: Int64): IGFData;
{$IFDEF DEBUG}
var
  LTick: Integer;
{$ENDIF}
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
  try
{$ENDIF}
    case AGFType of
      gtBaseData:
        begin
          Result := DoGFASyncQueryData(FBaseGFDataManager, ASql, ADataArrive, ATag, '[TAppContextImpl.GFASyncQueryData FBaseGFDataManager]');
        end;
      gtAssetData:
        begin
          Result := DoGFASyncQueryData(FAssetGFDataManager, ASql, ADataArrive, ATag, '[TAppContextImpl.GFASyncQueryData FAssetGFDataManager]');
        end;
    end;
{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
    case AGFType of
      gtBaseData:
        begin
          IndicatorLog(llSlow, Format('[FBaseGFDataManager.QueryDataSet DoGFASyncQueryData] Execute Indicator(%s) use time is %d ms.', [ASql, LTick]), LTick);
        end;
      gtAssetData:
        begin
          IndicatorLog(llSlow, Format('[FAssetGFDataManager.QueryDataSet DoGFASyncQueryData] Execute Indicator(%s) use time is %d ms.', [ASql, LTick]), LTick);
        end;
    end;
  end;
{$ENDIF}
end;

function TAppContextImpl.GFSyncQueryData(AGFType: TGFType; ASQL: WideString;
  ATag: Int64; AWaitTime: DWORD): IWNDataSet;
{$IFDEF DEBUG}
var
  LTick: Integer;
{$ENDIF}
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
  try
{$ENDIF}
    case AGFType of
      gtBaseData:
        begin
          Result := DoGFSyncQueryDataSet(FBaseGFDataManager, ASql, ATag, AWaitTime, '[TAppContextImpl.GFSyncQueryData FBaseGFDataManager]');
        end;
      gtAssetData:
        begin
          Result := DoGFSyncQueryDataSet(FAssetGFDataManager, ASql, ATag, AWaitTime, '[TAppContextImpl.GFSyncQueryData FAssetGFDataManager]');
        end;
    end;
{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
    case AGFType of
      gtBaseData:
        begin
          IndicatorLog(llSlow, Format('[FBaseGFDataManager.QueryDataSet DoGFSyncQueryDataSet] Execute Indicator(%s) use time is %d ms.', [ASql, LTick]), LTick);
        end;
      gtAssetData:
        begin
          IndicatorLog(llSlow, Format('[FAssetGFDataManager.QueryDataSet DoGFSyncQueryDataSet] Execute Indicator(%s) use time is %d ms.', [ASql, LTick]), LTick);
        end;
    end;
  end;
{$ENDIF}
end;

function TAppContextImpl.GFSyncQueryHighData(AGFType: TGFType; ASQL: WideString;
  ATag: Int64; AWaitTime: DWORD): IWNDataSet;
{$IFDEF DEBUG}
var
  LTick: Integer;
{$ENDIF}
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
  try
{$ENDIF}
    case AGFType of
      gtBaseData:
        begin
          Result := DoGFSyncQueryHighDataSet(FBaseGFDataManager, ASql, ATag, AWaitTime, '[TAppContextImpl.GFSyncQueryHighData FBaseGFDataManager]');
        end;
      gtAssetData:
        begin
          Result := DoGFSyncQueryHighDataSet(FAssetGFDataManager, ASql, ATag, AWaitTime, '[TAppContextImpl.GFSyncQueryHighData FAssetGFDataManager]');
        end;
    end;
{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
    case AGFType of
      gtBaseData:
        begin
          IndicatorLog(llSlow, Format('[FBaseGFDataManager.QueryHighDataSet DoGFSyncQueryHighDataSet] Execute Indicator(%s) use time is %d ms.', [ASql, LTick]), LTick);
        end;
      gtAssetData:
        begin
          IndicatorLog(llSlow, Format('[FAssetGFDataManager.QueryHighDataSet DoGFSyncQueryHighDataSet] Execute Indicator(%s) use time is %d ms.', [ASql, LTick]), LTick);
        end;
    end;
  end;
{$ENDIF}
end;

function TAppContextImpl.DoWaitForSingleObject(AGFData: IGFData; AWaitTime: DWORD; ALogSuffix: string): IWNDataSet;
var
  LResult: Cardinal;
begin
  LResult := WaitForSingleObject(AGFData.WaitEvent, AWaitTime);
  case LResult of
    WAIT_OBJECT_0:
      begin
        Result := Utils.GFData2WNDataSet(AGFData);
        if Result = nil then begin
          AppLog(llError, ALogSuffix + ' WaitForSingleObject return is nil.');
        end;
      end;
    WAIT_TIMEOUT:
      begin
        AppLog(llError, ALogSuffix + ' WaitForSingleObject is timeout.');
      end;
    WAIT_FAILED:
      begin
        AppLog(llError, ALogSuffix + ' WaitForSingleObject is Failed.');
      end;
  end;
end;

function TAppContextImpl.DoGFASyncQueryData(AGFDataManager: IGFDataManager; ASql: WideString; ADataArrive: Int64; ATag: Int64; LogSuffix: string): IGFData;
begin
  if (AGFDataManager <> nil) then begin
    if AGFDataManager.Login then begin
      try
        Result := FBaseGFDataManager.QueryDataSet(0, ASql, wmNonBlocking, ADataArrive, ATag);
      except
        on Ex: Exception do begin
          Result := nil;
          AppLog(llError, Format('[%s] GFDataManager.QueryDataSet is exception, exception is %s, Execute Indicator(%s).', [LogSuffix, Ex.Message, ASql]));
        end;
      end;
    end else begin
      Result := nil;
      AppLog(llError, Format('[%s] GFDataManager.Login is false, Execute Indicator(%s).', [LogSuffix, ASql]));
    end;
  end else begin
    Result := nil;
    AppLog(llError, Format('[%s] GFDataManager is nil, Execute Indicator(%s).', [LogSuffix, ASql]));
  end;
end;

function TAppContextImpl.DoGFSyncQueryDataSet(AGFDataManager: IGFDataManager; ASql: string; ATag: Int64; AWaitTime: DWORD; LogSuffix: string): IWNDataSet;
var
  LEvent: Int64;
  LGFData: IGFData;
begin
  if AGFDataManager <> nil then begin
    if AGFDataManager.Login then begin
      LEvent := 0;
      try
        LGFData := AGFDataManager.QueryDataSet(0, ASql, wmBlocking, LEvent, ATag);
        if LGFData <> nil then begin
          Result := DoWaitForSingleObject(LGFData, AWaitTime, Format('[%s] GFDataManager.QueryDataSet Execute Indicator(%s),', [LogSuffix, ASql]));
        end else begin
          Result := nil;
        end;
      except
        on Ex: Exception do begin
          Result := nil;
          AppLog(llError, Format('[%s] GFDataManager.QueryDataSet is exception, exception is %s, Execute Indicator(%s).', [LogSuffix, Ex.Message, ASql]));
        end;
      end;
    end else begin
      Result := nil;
      AppLog(llError, Format('[%s] GFDataManager.Login is false, Execute Indicator(%s).', [LogSuffix, ASql]));
    end;
  end else begin
    Result := nil;
    AppLog(llError, Format('[%s] GFDataManager is nil, Execute Indicator(%s).', [LogSuffix, ASql]));
  end;
end;

function TAppContextImpl.DoGFSyncQueryHighDataSet(AGFDataManager: IGFDataManager; ASql: string; ATag: Int64; AWaitTime: DWORD; LogSuffix: string): IWNDataSet;
var
  LEvent: Int64;
  LGFData: IGFData;
begin
  if AGFDataManager <> nil then begin
    if AGFDataManager.Login then begin
      LEvent := 0;
      try
        LGFData := AGFDataManager.QueryHighDataSet(0, ASql, wmBlocking, LEvent, ATag);
        if LGFData <> nil then begin
          Result := DoWaitForSingleObject(LGFData, AWaitTime, Format('[%s] GFDataManager.QueryHighDataSet Execute Indicator(%s),', [LogSuffix, ASql]));
        end else begin
          Result := nil;
        end;
      except
        on Ex: Exception do begin
          Result := nil;
          AppLog(llError, Format('[%s] GFDataManager.QueryHighDataSet is exception, exception is %s, Execute Indicator(%s).', [LogSuffix, Ex.Message, ASql]));
        end;
      end;
    end else begin
      Result := nil;
      AppLog(llError, Format('[%s] GFDataManager.Login is false, Execute Indicator(%s).', [LogSuffix, ASql]));
    end;
  end else begin
    Result := nil;
    AppLog(llError, Format('[%s] GFDataManager is nil, Execute Indicator(%s).', [LogSuffix, ASql]));
  end;
end;

end.
