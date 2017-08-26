unit HqIndicatorMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-25
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  AppContext,
  HqIndicatorMgr,
  CommonRefCounter;

type

  // 行情订阅适配
  THqIndicatorMgrImpl = class(TAutoInterfacedObject, IHqIndicatorMgr)
  private
    // 应用程序上下文接口
    FAppContext: IAppContext;
  protected
  public
    // 构造函数
    constructor Create; override;
    // 析构函数
    destructor Destroy; override;

    { IHqIndicatorMgr }

    // 初始化需要的资源
    procedure Initialize(AContext: IAppContext); safecall;
    // 释放不需要的资源
    procedure UnInitialize; safecall;
  end;

implementation

{ THqIndicatorMgrImpl }

constructor THqIndicatorMgrImpl.Create;
begin
  inherited;

end;

destructor THqIndicatorMgrImpl.Destroy;
begin

  inherited;
end;

procedure THqIndicatorMgrImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
end;

procedure THqIndicatorMgrImpl.UnInitialize;
begin
  FAppContext := nil;
end;

end.
