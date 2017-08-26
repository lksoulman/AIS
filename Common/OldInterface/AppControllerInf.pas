unit AppControllerInf;

interface

uses
  Winapi.Windows, System.Classes, Vcl.Graphics, Vcl.Forms,
  KeyFairySinkInf, WNDataSetInf, GFDataMngr_TLB, UserLocalOperateIntf;

const
  C_QueryUFXData = 'UFXDATA';
  Con_SkinBlack = 'Black';
  CONST_DEBUG_FLAGE = 'debug.debug';

type

  // Module     模块    ModuleComp  组件
  // AppHost   主程序
  // PBMngr     数据通道
  // QuoteMngr  行情
  // TradeMngr  交易
  // LangMngr   公式
  // LogMngr    日志
  // Favorite   收藏夹

  // EncdDecd    加解密
  // Notify      通知机制
  // HashList    keyValue 数据
  // ObjPool     对像池
  // MenuBar     菜单toolbar
  // Status      状态
  // History     历史记录
  // Auth        权限
  // TimeMngr    定时器
  // ThreadPool  线程池 （线程转主进程）
  // keyFairy    键盘精灵
  // AlertWin    提示信息

  // 初始化,可以在这里创建些东西,在里取接口是安全的
  TOnGFDataArrive = procedure(const GFData: IGFData) of object;

  LanguageEnum = (leChineseChina);

  TConfigType = (ctSkin);

  ProxyType = (ptNoProxy = $00000001, ptHTTPProxy = $00000002, ptSocks4 = $00000003, ptSocks5 = $00000004);

  PProxyRec = ^TProxyRec;

  TProxyRec = record
    mtype: ProxyType;
    mIP: string;
    mPort: Word;
    User: string;
    Pwd: string;
    NTLM: Boolean;
    NTLMDomain: string;
  end;

  // leChineseChina = $00000000;
  // leChineseTaiwan = $00000001;
  // leEnglishUK = $00000002;
  PStockInfoRec = ^StockInfoRec;

  StockInfoRec = packed record
    NBBM: Integer;
    GPDM: WideString;
    ZQJC: WideString;
    ZQSC: Smallint;
    ZQLB: Integer;
    PYDM: WideString;
    GSDM: Integer;
    RZRQ: Integer;
    GGT: Integer;
    FormerName: WideString;
    FormerSpell: WideString;
    // oZQLB: Smallint;
    // HYDM: WideString;
    procedure clone(AStockInfoRec: StockInfoRec);
  end;

const
  LOGLEVELStr: array [0 .. 4] of String = ('DEBUG', 'INFO', 'WARNING', 'ERROR', 'FATAL');
  LOGLEVELStrOut: array [0 .. 4] of String = ('DEBUG  ', 'INFO---', 'WARNING', 'ERROR▲▲', 'FATAL●●');

type
  LogLevel = (llDebug, // 调试信息
    llInfo, // 提示信息
    llWarn, // 警告
    llError, // 错误
    llFatal); // 严重错误

  UserInfoRec = packed record
    UserName: WideString;
    UserPwd: WideString;
    // UserLable: WideString;
    // UserType: Integer;
    // UserID: WideString;
    // Lisense:WideString;
  end;

  //web模块的URL信息对象
  TModuleUrlData = packed record
    Caption: string;
    WebIPName: string;
    URL: string;
    URLDef: string;
  end;

  // 判断是否登录的用户类型 聚源用户，UFX用户，两者
  TLoginedUserType = (lutJY, lutUFX, lutAll);

  // IChromeEmbed = Interface;
  ILogWriter = Interface
    ['{F2F6ACF3-0E1A-4C1F-8525-C7F7222E9A43}']

    procedure Log(Const ALogLevel: LogLevel; const ALog: WideString); safecall;
    function GetLogLevel: LogLevel; safecall;
  End;

  IKeyFairyMng = interface
    ['{3B3F30CC-8C26-49B8-8EC8-93B511BF172B}']
    procedure KeyFairyDisplay(const AHandle: HRESULT; const Key: WideString; const Param: WideString); safecall;
    function KeyFairyChooseStock(const AHandle: HRESULT; const Key: WideString; const SinkIDS: WideString;
      const Param: WideString; top, Left: Integer; out StockInfo: StockInfoRec): WordBool; safecall;
    function KeyFairyData(const Key: WideString; const SinkIDS: WideString; const Param: WideString): WideString;
      safecall;

    procedure RegisterKeyFairy(const WNKeyFairySink: IKeyFairySink); safecall;
    procedure UnregisterKeyFairy(const WNKeyFairySink: IKeyFairySink); safecall;
    function QueryKeyFairy(const SinkID: WideString; out WNKeyFairySink: IKeyFairySink): WordBool; safecall;
    function GetCount: Integer; safecall;
    function GetKeySink(index: Integer): IKeyFairySink; safecall;
    function GetKeyFairHeight: Integer; safecall;
    procedure Sort; safecall;
    function IskeyFairyString(const AStr: WideString): Boolean; safecall;
    procedure LoadSecu(const WNKeyFairySink: IKeyFairySink; Const IsAsynchrony: WordBool); safecall;
    procedure RefreshSecuList; safecall;
  end;

  IChromeEmbed = interface
    ['{39686777-9E1E-45D8-B548-74F007FA3026}']
    procedure SetHeader(AKey,AValue: WideString); safecall;
    procedure SetSize(ParentHandle: int64; ALeft: Integer; ATop: Integer; AWidth: Integer; AHeight: Integer); safecall;
    function Get_Handle: int64; safecall;
    function Get_Url: WideString; safecall;
    function Get_CurrentURL: WideString; safecall;
    procedure Set_Url(const Value: WideString); safecall;
    function IsInputTag: WordBool; safecall;
    function Get_ExVal(const Key: WideString): WideString; safecall;
    procedure Set_ExVal(const Key: WideString; const Value: WideString); safecall;
    procedure ShowChrome(AMode: Integer; const ACaption: WideString); safecall;
    procedure SetInvoker(InvokeHandle: int64); safecall;
    procedure NotifyExValChange(const Key: WideString); safecall;
    function Get_Module: IInterface; safecall; // 获取当前IModule（先Set_Module）
    procedure Set_Module(const Value: IInterface); safecall; // 设置当前IModule
    procedure SetParent(AParent: int64); safecall;
    // function ModuleCtl():TComponent; safecall;
    procedure ShowModuleChrome(const ACaption: WideString; const AHandle: int64; const Width: Integer;
      const Height: Integer; const Event: int64); safecall;
    procedure SetFocus(); safecall;
    procedure GoHistory(const IsNext: WordBool); safecall;
    function CanGoHistory(const IsNext: WordBool): WordBool; safecall;
    procedure Refresh(); safecall;
    procedure OnDisconnection(); safecall;
    // JS：执行的js函数，包括参数
    // URL： 当前页面的URL
    // StartLine： 默认0
    procedure ExecuteWebJS(JS: WideString; URL: WideString; StartLine: Integer); safecall;
  end;

  ITranslateMsg = interface
    ['{180401F9-C788-4948-B985-3D3C1F326DC8}']
    function TranslateMsg(PMsg: int64): WordBool; safecall;
  end;

  // 记录用户行为管理
  IUserBehaviorMgr = Interface
    ['{DA0E099E-FA8F-46D6-BDDA-0F779C13551C}']

    procedure Add(const AModuleID: WideString); safecall;
  End;

  IGilAppController = interface(IDispatch)
    ['{34B39C07-2903-4CC8-88FC-3239C3CC91DB}']

    function GetAppPath: WideString; safecall;
    Function GetSettingPath: WideString; safecall;
    function GetUserPath: WideString; safecall;
    function GetUserName: WideString; safecall;
    // 可以不要
    function GetConfigPath: WideString; safecall;

    function Get_ApplicationHandle: HRESULT; safecall;
    function QueryInterface(IID: TGUID; out Obj: IUnknown): WordBool; safecall; safecall;
    procedure RegisterInterface(IID: TGUID; const Obj: IUnknown); safecall;

    function QueryStockInfo(NBBM: Integer; out StockInfo: StockInfoRec): WordBool; safecall;

    function Get_Language: LanguageEnum; safecall;
    procedure Set_Language(Value: LanguageEnum); safecall;
    function LanguagePath: WideString; safecall;

    function Get_UserInfo: UserInfoRec; safecall;
    function GetKeyFairyMng: IKeyFairyMng; safecall;

    function GetCurrentStock(): Integer; safecall;
    function SetCurrentStock(NBBM: Integer): WordBool; safecall;

    function CreateModule(const ProgID: WideString): IUnknown; safecall;
    procedure CreateModuleByAlias(const Alias, SubParam: WideString); safecall;
    // procedure CreateModuleByProgID(const ProgID, Param, SubParam: WideString); safecall;

    function Get_WNMainFormHandle: int64; safecall;
    function Command(const CMD: WideString): WideString; safecall;
    function Get_ProNO: WideString; safecall; // 产品编号
    function Get_AssetSystemType: WideString; safecall; // 资产系统类型
    Function Get_OrgNO: WideString; safecall; // 机构号
    procedure SaveHistory(const Alias, SubParam: WideString); safecall;
    // 添加接口
    function Style(): WideString;
    function GetSkinInstance(): HINST; safecall;
    function Config(ConfigType: TConfigType; const Key: WideString): WideString;
    function ColorOf(ConfigType: TConfigType; const Key: WideString; const ADefaultColor: TColor = 0): TColor;
    procedure SetGlobleParam(const Name, Value: WideString);
    Function GetGlobleParam(const Name: WideString): WideString;
    function GetLogWriter(): ILogWriter;
    Function CacheQueryData(const ATables, ASQL: WideString): IWNDataSet; safecall;
    function GetActiveModule(): IInterface; safecall;
    procedure ModifySwatchType(AModule: int64; SubParam: WideString); safecall;
    function GetQuoteRangeCookie(): IUnknown; safecall;
    function GetProxyInfo(): PProxyRec; safecall;
    // GF通道取数据接口
    function GFQueryDataBlocking(Handle: int64; const SQL: WideString; Tag: int64; WaitTime: DWORD): IWNDataSet; safecall;
    // WaitTime 超时时间（毫秒），=INFINITE 不超时  超时直接返回nil
    function GFQueryHighDataBlocking(Handle: int64; const SQL: WideString; Tag: int64; WaitTime: DWORD): IWNDataSet;
      safecall; // WaitTime 超时时间（毫秒），=INFINITE 不超时 超时直接返回nil
    function GFQueryData(Handle: int64; const SQL: WideString; DataArrive: int64; Tag: int64): IGFData; safecall;
    function CreateChromeEmbed(): IChromeEmbed; safecall;
    function GetWebIP(AParam: WideString): WideString; safecall;
    function GetConfigOprateIntf(): IUserSetting; safecall;
    procedure GoHistory(IsNext: WordBool); safecall;
    // 获取字体大小,大字体返回 '1080P',小字体返回 '768P';
    function FontRatio(): WideString; safecall;

    function AssetGFQueryDataBlocking(Handle: int64; const SQL: WideString; Tag: int64; WaitTime: DWORD): IWNDataSet;
      safecall; // WaitTime 超时时间（毫秒），=INFINITE 不超时  超时直接返回nil
    function AssetGFQueryData(Handle: int64; const SQL: WideString; DataArrive: int64; Tag: int64): IGFData; safecall;
    function IsHaveLisence(ALicense: Integer): WordBool; safecall;
    function IsHaveModuleLicese(Alias: string): WordBool; safecall;
    function JYSessionID: WideString; safecall;
    function GetCurrentMdiMainForm: TCustomForm; safecall;
    procedure AddNotifyToCurrMdiMainForm(ANotify: TNotifyEvent); safecall;
    function Logined(ALoginedUserType: TLoginedUserType): WordBool; safecall;
    function GetScreenID(APoint: TPoint): Integer; safecall;
    function GetUserBehaviorMgr: IUserBehaviorMgr; safecall;
    procedure AddUserBehavior(const AModuleID: WideString); safecall;
    function GetLockTimeOut: Integer; safecall;
    procedure SetLockTimeOut(AInterval: Integer); safecall;
    function GetSkinStyle: Integer; safecall;

    function GFQueryHighDataBlockingWithSuccess(Handle: int64; const SQL: WideString;
      Tag: int64; WaitTime: DWORD; out IsSuccess: Boolean): IWNDataSet; safecall; // WaitTime 超时时间（毫秒），=INFINITE 不超时 超时直接返回nil  增加了一个bool返回变量，用来指示指标执行是否成功
    //通过模块别名从配置文件中读取url
    procedure GetModuleUrlByAliasFromConfig(Alias: string; var AModuleUrlData: TModuleUrlData); safecall;
    function ExecSql_DataSet(const ASql: WideString): WordBool; safecall;
    procedure LocalCacheMng(var ALocalCacheMng: TObject); safecall;
    procedure DeleteNotifyToCurrMdiMainForm(ANotify: TNotifyEvent); safecall;
    function GetO32LinkageSwitch: WordBool; safecall;
    procedure SetO32LinkageSwitch(AEnable: WordBool); safecall;
  end;

  // 通知事件
  INotify = interface(IInterface)
    ['{5D2B1251-051F-4552-924A-C1E6B76C3EC1}']
    function Get_Handle: int64; safecall;
    function Get_Active: WordBool; safecall;
    procedure Set_Active(Value: WordBool); safecall;
    procedure Connect(); safecall;
    procedure DisConnect(); safecall;
  end;

  // 通知服务
  INotifyServices = interface(IInterface)
    ['{CACBF7FC-2B7B-4524-8668-637504E20C8E}']
    procedure RegestNotify(ANotify: INotify); safecall;
    procedure UnregestNotify(ANotify: INotify); safecall;
    procedure Notify(NotifyEvent, Param: NativeUInt); safecall;
  end;

const

  IID_IExtensibility = '{DDF9BCB5-F8DA-46E8-A462-58AF0763535C}';

type
  IExtensibility = interface(IInterface)
    ['{DDF9BCB5-F8DA-46E8-A462-58AF0763535C}']
    procedure OnConnection(const GilAppController: IGilAppController; NotifySvr: INotifyServices;
      AHandle: THandle); safecall;
    procedure OnDisconnection; safecall;
    procedure OnChangeLanguage; safecall;
  end;

  // 模块定义
  IModule = interface(IExtensibility)
    ['{092A68FC-AD6C-4CA6-862C-F46BBE5043A4}']
    // 1 创建
    // procedure OnConnection(const Controller: IGilAppController; const NotifySvr: INotifyServices); safecall;
    // 2 传参
    procedure OnTransferParam(Const Param, SubParam: WideString); safecall;
    // 3 获取控件
    function ModuleCtl: TComponent safecall;
    // 4 显示
    // procedure OnShowModule; safecall;
    // 5 释放
    // procedure OnDisconnection; safecall;
    // 6 显示模块
    procedure OnBringToFront; safecall;
    // 7 隐藏模块
    procedure OnSendToBack; safecall;
    // 改变证券
    function OnChangeStock(const SinkID: WideString; StockInfo: StockInfoRec): WordBool; safecall;
    // 设置窗口句柄  放到Connection
    function ModuleCommond(const Param: WideString): WideString; safecall;

    procedure OnChangeSkin(); safecall;
    // procedure SetHandle(AHandle:THandle); safecall;
    //
    function OnKeyPress(Key: Integer): Boolean; safecall;
    // 模块工具条
    // function ToolsCtl: TComponent; safecall;
  end;

  IInnerModuleMng = Interface
    ['{B7B46556-E48B-4218-A90C-48CC4AEED566}']
    procedure GoHistory(IsNext: WordBool); safecall;
    function CanGoHistory(IsNext: WordBool): WordBool; safecall;
    function CanRefresh(): WordBool; safecall;
    procedure Refresh(); safecall;
  End;

  TCreateModuleProc = function(ProgID: WideString): IModule; stdcall;

implementation

{ StockInfoRec }

procedure StockInfoRec.clone(AStockInfoRec: StockInfoRec);
begin
  self.NBBM := AStockInfoRec.NBBM;
  self.GPDM := AStockInfoRec.GPDM;
  self.ZQJC := AStockInfoRec.ZQJC;
  self.ZQSC := AStockInfoRec.ZQSC;
  self.ZQLB := AStockInfoRec.ZQLB;
  self.PYDM := AStockInfoRec.PYDM;
  self.GSDM := AStockInfoRec.GSDM;
  self.RZRQ := AStockInfoRec.RZRQ;
  self.GGT := AStockInfoRec.GGT;
  self.FormerName := AStockInfoRec.FormerName;
  self.FormerSpell := AStockInfoRec.FormerSpell;
end;

end.
