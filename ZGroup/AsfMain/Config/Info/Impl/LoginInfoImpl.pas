unit LoginInfoImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-7-20
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  IniFiles,
  LoginInfo,
  AppContext;

type

  TLoginInfoImpl = class(TInterfacedObject, ILoginInfo)
  private
//    // 登录模式
//    FLoginType: Integer;
    // 应用程序上下文接口
    FAppContext: IAppContext;
  protected
  public
    // 构造方法
    constructor Create;
    // 析构函数
    destructor Destroy; override;

    { ILoginInfo }

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

{ TLoginInfoImpl }

constructor TLoginInfoImpl.Create;
begin
  inherited;

end;

destructor TLoginInfoImpl.Destroy;
begin

  inherited;
end;

procedure TLoginInfoImpl.Initialize(AContext: IInterface);
begin
//  FAppContext := AContext;

end;

procedure TLoginInfoImpl.UnInitialize;
begin
  FAppContext := nil;
end;

procedure TLoginInfoImpl.LoadByIniFile(AFile: TIniFile);
begin

end;

procedure TLoginInfoImpl.LoadCache;
begin

end;

end.
