unit AppContextImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-10
// Comments：
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
    // 配置文件接口
    FConfig: IInterface;
    // 登录接口
    FLoginMgr: ILoginMgr;
    // 加密解密接口
    FCipherMgr: ICipherMgr;
    // 基础服务
    FServiceBase: IServiceBase;
    // 资产服务
    FServiceAsset: IServiceAsset;
    // 用户行为接口上传接口
    FUserBehavior: IUserBehavior;
    // 基础 cache 数据接口
    FCacheBaseData: ICacheBaseData;
    // 用户 cache 数据接口
    FCacheUserData: ICacheUserData;
    // 基础数据服务接口
    FBaseGFDataManager: IGFDataManager;
    // 资产数据服务接口
    FAssetGFDataManager: IGFDataManager;
    // 接口存储方法
    FInterfaceDic: TDictionary<string, IUnknown>;
  protected
    // 等待方法
    function DoWaitForSingleObject(AGFData: IGFData; AWaitTime: DWORD; ALogSuffix: string): IWNDataSet;
    // GF异步数据查询接口
    function DoGFASyncQueryData(AGFDataManager: IGFDataManager; ASql: WideString; ADataArrive: Int64; ATag: Int64; LogSuffix: string): IGFData;
    // GF同步数据查询接口
    function DoGFSyncQueryDataSet(AGFDataManager: IGFDataManager; ASql: string; ATag: Int64; AWaitTime: DWORD; LogSuffix: string): IWNDataSet;
    // GF高优先级同步数据查询接口
    function DoGFSyncQueryHighDataSet(AGFDataManager: IGFDataManager; ASql: string; ATag: Int64; AWaitTime: DWORD; LogSuffix: string): IWNDataSet;
  public
    // 构造函数
    constructor Create;
    // 析构函数
    destructor Destroy; override;

    { IAppContext }

    // 退出应用程序
    procedure ExitApp; safecall;
    // 重启应用程序
    procedure ReStartApp; safecall;
    // 获取配置接口
    function GetConfig: IInterface; safecall;
    // 获取登录接口
    function GetLoginMgr: ILoginMgr; safecall;
    // 获取加密解密接口
    function GetCipherMgr: ICipherMgr; safecall;
    // 获取基础服务
    function GetServiceBase: IInterface; safecall;
    // 获取资产服务
    function GetServiceAsset: IInterface; safecall;
    // 注册接口
    procedure RegisterInterface(AGUID: TGUID; const AObj: IUnknown); safecall;
    // 卸载接口
    procedure UnRegisterInterface(AGUID: TGUID); safecall;
    // 查询接口
    function QueryInterface(AGUID: TGUID): IUnknown; safecall;
    // 添加用户行为方法
    procedure AddBehavior(ABehavior: WideString); safecall;
    // 行情日志输出
    procedure HQLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
    // 网页日志输出
    procedure WebLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
    // 应用系统日志输出
    procedure AppLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
    // 指标日志输出
    procedure IndicatorLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
    // Cache数据获取接口
    function SyncCacheQueryData(ACacheType: TCacheType; ASql: WideString): IWNDataSet; safecall;
    // GF 异步数据查询方法
    function GFASyncQueryData(AGFType: TGFType; ASql: WideString; ADataArrive: Int64; ATag: Int64): IGFData; safecall;
    // GF 同步数据查询方法
    function GFSyncQueryData(AGFType: TGFType; ASqL: WideString; ATag: Int64; AWaitTime: DWORD): IWNDataSet; safecall;
    // GF 同步高优先级数据查询方法
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
