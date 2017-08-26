unit VerifyImpl;

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
  Verify,
  Windows,
  Classes,
  SysUtils,
  SyncAsync,
  AppContext,
  CommonObject,
  CommonRefCounter;

type

  TVerifyImpl = class(TAutoInterfacedObject, ISyncAsync, IVerify)
  private
    // 验证码个数
    FVerifyCodeCount: Integer;
  protected
  public
    // 构造函数
    constructor Create; override;
    // 析构函数
    destructor Destroy; override;

    { ISyncAsync }

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

    { IVerify }

    // 设置产生验证码个数
    procedure SetVerifyCodeCount(ACount: Integer); safeCall;
    // 获取验证码对应的流
    function GetStreamByVerifyCode(AVerifyCode: Integer): TStream; safeCall;
    // 获取验证码对应字符串
    function GetStringByVerifyCode(AVerifyCode: Integer): WideString; safeCall;
    // 产生随机码
    procedure GenerateVerifyCodes(var AVerifyCodes: TIntegerDynArray); safeCall;
  end;

implementation

const

  VERIFYCODE : Array [0..35] of Char = ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
                                        'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P',
                                        'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'Z',
                                        'X', 'C', 'V', 'B', 'N', 'M');


{ TVerifyImpl }

constructor TVerifyImpl.Create;
begin
  inherited;
  FVerifyCodeCount := 4;
end;

destructor TVerifyImpl.Destroy;
begin

  inherited;
end;

procedure TVerifyImpl.Initialize(AContext: IAppContext);
begin

end;

procedure TVerifyImpl.UnInitialize;
begin

end;

function TVerifyImpl.IsNeedSync: WordBool;
begin

end;

procedure TVerifyImpl.SyncExecute;
begin

end;

procedure TVerifyImpl.AsyncExecute;
begin

end;

procedure TVerifyImpl.SetVerifyCodeCount(ACount: Integer);
begin
  if (ACount < 0) or (ACount > 10) then Exit;

  FVerifyCodeCount := ACount;
end;

function TVerifyImpl.GetStreamByVerifyCode(AVerifyCode: Integer): TStream;
begin
  if (AVerifyCode < 0) or (AVerifyCode > 35) then begin
    Result := nil;
    Exit;
  end;


end;

function TVerifyImpl.GetStringByVerifyCode(AVerifyCode: Integer): WideString;
begin

end;

procedure TVerifyImpl.GenerateVerifyCodes(var AVerifyCodes: TIntegerDynArray);
begin

end;

end.
