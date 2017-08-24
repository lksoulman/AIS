unit LanguageMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-21
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Language,
  SyncAsync,
  AppContext,
  LanguageMgr,
  LanguageType,
  CommonRefCounter;

type

  TLanguageMgrImpl = class(TAutoInterfacedObject, ISyncAsync, ILanguageMgr)
  private
    // 语言包
    FLanguage: TLanguage;
    // 应用程序上下文接口
    FAppContext: IAppContext;
    // 语言类型
    FLanguageType: TLanguageType;
  protected
  public
    // 构造函数
    constructor Create; override;
    // 析构函数
    destructor Destroy; override;

    // 初始化需要的资源
    procedure Initialize(AContext: IAppContext); safecall;
    // 释放不需要的资源
    procedure UnInitialize; safecall;
    // 是不是必须同步执行
    function IsNeedSync: WordBool; safecall;
    // 同步执行方法
    procedure SyncExecute; safecall;
    // 异步执行方法
    procedure AsyncExecute; safecall;

    { ILanguageMgr }

    // 切换语言包
    procedure ChangeLanguage; safecall;
  end;

implementation

{ TLanguageMgrImpl }

constructor TLanguageMgrImpl.Create;
begin
  inherited;

end;

destructor TLanguageMgrImpl.Destroy;
begin

  inherited;
end;

procedure TLanguageMgrImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;

end;

procedure TLanguageMgrImpl.UnInitialize;
begin
  FAppContext := nil;
end;

function TLanguageMgrImpl.IsNeedSync: WordBool;
begin
  Result := True;
end;

procedure TLanguageMgrImpl.SyncExecute;
begin

end;

procedure TLanguageMgrImpl.AsyncExecute;
begin

end;

procedure TLanguageMgrImpl.ChangeLanguage;
begin

end;

end.
