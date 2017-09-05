unit UpdateInfoImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-7-22
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  IniFiles,
  UpdateInfo,
  AppContext;

type

  TUpdateInfoImpl = class(TInterfacedObject, IUpdateInfo)
  private
//    // 应用程序名称
//    FAppExeName: string;
//    // 更新程序名称
//    FUpdateExeName: string;
    // 应用程序上下文接口
    FAppContext: IAppContext;
  protected
  public
    // 构造方法
    constructor Create;
    // 析构函数
    destructor Destroy; override;

    { ISyscfgInfo }

    // 初始化需要的资源
    procedure Initialize(AContext: IInterface); safecall;
    // 释放不需要的资源
    procedure UnInitialize; safecall;
    // 加载缓存
    procedure LoadCache; safecall;
    // 通过Ini对象加载
    procedure LoadByIniFile(AFile: TIniFile); safecall;
  end;

implementation

{ TUpdateInfoImpl }

constructor TUpdateInfoImpl.Create;
begin

end;

destructor TUpdateInfoImpl.Destroy;
begin

  inherited;
end;

procedure TUpdateInfoImpl.Initialize(AContext: IInterface);
begin
  FAppContext := AContext as IAppContext;

end;

procedure TUpdateInfoImpl.UnInitialize;
begin
  FAppContext := nil;
end;

procedure TUpdateInfoImpl.LoadByIniFile(AFile: TIniFile);
begin

end;

procedure TUpdateInfoImpl.LoadCache;
begin

end;

end.
