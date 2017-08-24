unit PlugInImpl;

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
  PlugIn,
  AppContext;

type

  TPlugInImpl = class(TInterfacedObject, IPlugIn)
  private
  protected
  public
    // 构造函数
    constructor Create;
    // 析构函数
    destructor Destroy; override;

    { IPlugIn }

    // 初始化需要的资源
    procedure Initialize(AContext: IAppContext); virtual; safecall;
    // 释放不需要的资源
    procedure UnInitialize; virtual; safecall;
    // 是不是需要同步加载操作
    function IsNeedSync: WordBool; virtual; safecall;
    // 同步实现
    procedure SyncExecuteOperate; virtual; safecall;
    // 异步实现操作
    procedure AsyncExecuteOperate; virtual; safecall;
    // 插件类名称
    function PlugInClassName: WideString; virtual; safecall;
  end;

  // 插件类
  TPlugInImplClass = class of TPlugInImpl;

implementation

{ TPlugInImpl }

constructor TPlugInImpl.Create;
begin

end;

destructor TPlugInImpl.Destroy;
begin

  inherited;
end;

procedure TPlugInImpl.Initialize(AContext: IAppContext);
begin

end;

procedure TPlugInImpl.UnInitialize;
begin

end;

function TPlugInImpl.IsNeedSync: WordBool;
begin

end;

procedure TPlugInImpl.SyncExecuteOperate;
begin

end;

procedure TPlugInImpl.AsyncExecuteOperate;
begin

end;

function TPlugInImpl.PlugInClassName: WideString;
begin
  Result := Self.ClassName;
end;

end.
