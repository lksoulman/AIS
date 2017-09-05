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
  AppContext,
  CommonObject,
  SyncAsyncImpl,
  CommonRefCounter;

type

  TVerifyImpl = class(TSyncAsyncImpl, IVerify)
  private
    // 验证码个数
    FVerifyCodeCount: Integer;
  protected
  public
    // Constructor method
    constructor Create; override;
    // Destructor method
    destructor Destroy; override;

    { ISyncAsync }

    // Initialize resources(only execute once)
    procedure Initialize(AContext: IAppContext); override;
    // Releasing resources(only execute once)
    procedure UnInitialize; override;
    // Blocking primary thread execution(only execute once)
    procedure SyncBlockExecute; override;
    // Non blocking primary thread execution(only execute once)
    procedure AsyncNoBlockExecute; override;
    // Obtain dependency
    function Dependences: WideString; override;

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
  inherited Initialize(AContext);
end;

procedure TVerifyImpl.UnInitialize;
begin
  inherited UnInitialize;
end;

procedure TVerifyImpl.SyncBlockExecute;
begin

end;

procedure TVerifyImpl.AsyncNoBlockExecute;
begin

end;

function TVerifyImpl.Dependences: WideString;
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
