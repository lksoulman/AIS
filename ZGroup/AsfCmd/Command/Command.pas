unit Command;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-6
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  AppContext;

type

  // 命令接口
  ICommand = Interface(IInterface)
    ['{64B65307-CF3E-40E6-9E46-935D0C56922F}']
    // 初始化需要的资源
    procedure Initialize(AContext: IAppContext); safecall;
    // 释放不需要的资源
    procedure UnInitialize; safecall;
    // 设置激活
    procedure SetActive; safecall;
    // 设置非激活
    procedure SetNoActive; safecall;
    // 命令执行方法
    procedure ExecCommand(APermMask: Integer; AParams: WideString); safecall;
  end;

implementation

end.
