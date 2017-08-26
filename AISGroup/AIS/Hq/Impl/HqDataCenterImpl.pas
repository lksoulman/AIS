unit HqDataCenterImpl;

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
  HqDataCenter,
  CommonRefCounter;

type

  // 行情订阅适配
  THqDataCenterImpl = class(TAutoInterfacedObject, IHqDataCenter)
  private
    // 应用程序上下文接口
    FAppContext: IAppContext;
  protected
  public
    // 构造函数
    constructor Create; override;
    // 析构函数
    destructor Destroy; override;

    { IHqDataCenter }

    // 初始化需要的资源
    procedure Initialize(AContext: IAppContext); safecall;
    // 释放不需要的资源
    procedure UnInitialize; safecall;
  end;

implementation

{ THqDataCenterImpl }

constructor THqDataCenterImpl.Create;
begin
  inherited;

end;

destructor THqDataCenterImpl.Destroy;
begin

  inherited;
end;

procedure THqDataCenterImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
end;

procedure THqDataCenterImpl.UnInitialize;
begin
  FAppContext := nil;
end;

end.
