unit AppContext;

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
  Windows,
  Classes,
  SysUtils,
  LoginMgr,
  CipherMgr,
  CacheType,
  FastLogLevel,
  WNDataSetInf,
  PermissionMgr,
  GFDataMngr_TLB;

type

  // GF 请求数据类型
  TGFType = (gtBaseData,       // 基础数据
             gtAssetData       // 资产数据
             );

  IAppContext = Interface(IInterface)
    ['{919A20C7-3242-4DBB-81F7-18EF05813380}']
    // 退出应用程序
    procedure ExitApp; safecall;
    // 重启应用程序
    procedure ReStartApp; safecall;
    // 获取配置接口
    function GetConfig: IInterface; safecall;
    // 获取登录接口
    function GetLoginMgr: IInterface; safecall;
    // 获取加密解密接口
    function GetCipherMgr: IInterface; safecall;
    // 获取系统消息服务接口
    function GetMsgServices: IInterface; safecall;
    // 获取基础服务
    function GetServiceBase: IInterface; safecall;
    // 获取资产服务
    function GetServiceAsset: IInterface; safecall;
    // 获取权限管理接口
    function GetPermissionMgr: IInterface; safecall;
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
    function GFSyncQueryData(AGFType: TGFType; ASQL: WideString; ATag: Int64; AWaitTime: DWORD): IWNDataSet; safecall;
    // GF 同步高优先级数据查询方法
    function GFSyncQueryHighData(AGFType: TGFType; ASQL: WideString; ATag: Int64; AWaitTime: DWORD): IWNDataSet; safecall;
  end;

implementation

end.
