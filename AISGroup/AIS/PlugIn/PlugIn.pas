unit PlugIn;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-16
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

  IPlugIn = Interface(IInterface)
    ['{F436FEEF-B7E4-4DBE-8615-F4A1CE553B94}']
    // 初始化需要的资源
    procedure Initialize(AContext: IAppContext); safecall;
    // 释放不需要的资源
    procedure UnInitialize; safecall;
    // 是不是需要同步加载操作
    function IsNeedSync: WordBool; safecall;
    // 同步实现
    procedure SyncExecuteOperate; safecall;
    // 异步实现操作
    procedure AsyncExecuteOperate; safecall;
    // 插件类名称
    function PlugInClassName: WideString; safecall;
  end;

implementation

end.

