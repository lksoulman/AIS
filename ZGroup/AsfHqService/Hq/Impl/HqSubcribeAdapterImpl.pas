unit HqSubcribeAdapterImpl;

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
  CommonRefCounter,
  HqSubcribeAdapter;

type

  // 行情订阅适配
  THqSubcribeAdapterImpl = class(TAutoInterfacedObject, IHqSubcribeAdapter)
  private
    // 应用程序上下文接口
    FAppContext: IAppContext;
  protected
  public
    // 构造函数
    constructor Create; override;
    // 析构函数
    destructor Destroy; override;

    { IHqSubcribeAdapter }

    // 初始化需要的资源
    procedure Initialize(AContext: IAppContext); safecall;
    // 释放不需要的资源
    procedure UnInitialize; safecall;
  end;

implementation

{ THqSubcribeAdapterImpl }

constructor THqSubcribeAdapterImpl.Create;
begin
  inherited;

end;

destructor THqSubcribeAdapterImpl.Destroy;
begin

  inherited;
end;

procedure THqSubcribeAdapterImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
end;

procedure THqSubcribeAdapterImpl.UnInitialize;
begin
  FAppContext := nil;
end;

end.
