unit LoginUI;

interface

uses
  Windows,
  Classes,
  SysUtils,
  LoginMainUI;

type

  ILoginUI = Interface(IInterface)
    ['{6174EEEE-AACA-4DC3-B74A-8C8DD2EE0420}']
    // 展示登录主窗口
    procedure ShowLoginMainUI; safecall;
    // 展示绑定窗口
    procedure ShowLoginBindUI; safecall;
    // 展示登录信息
    procedure ShowLoginInfo(AMsg: WideString); safecall;
    // 设置登录回调方法
    procedure SetLoginFunc(ALoginFunc: TCallBackLoginFunc); safecall;
  end;

implementation

end.
