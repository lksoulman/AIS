unit CfgCache;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-7-23
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  AppContext;

type

  // 配置缓存接口
  ICfgCache = Interface(IInterface)
    ['{865B342F-C51B-40FA-82D0-3DEF0D058E73}']
    // 初始化需要的资源
    procedure Initialize(AContext: IAppContext); safecall;
    // 释放不需要的资源
    procedure UnInitialize; safecall;
    // 保存缓存
    procedure SaveCache; safecall;
    // 加载配置缓存数据
    procedure LoadCfgCacheData; safecall;
    // 设置配置缓存目录
    procedure SetCfgCachePath(APath: WideString); safecall;
    // 获取数据
    function GetValue(AKey: WideString): WideString; safecall;
    // 保存数据
    function SetValue(AKey, AValue: WideString): boolean; safecall;
  end;

implementation

end.
