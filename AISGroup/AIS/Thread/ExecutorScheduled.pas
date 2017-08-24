unit ExecutorScheduled;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-5-1
// Comments：    {Doug Lea thread}
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  ExecutorTask,
  ExecutorService;

type

  IExecutorScheduled = interface(IInterface)
    ['{31F8B49C-CB4A-434C-A7EE-D03486782ADC}']
    // 启动
    procedure Start; safecall;
    // 关闭
    procedure ShutDown; safecall;
    // 是不是已经结束
    function IsTerminated: boolean; safecall;
    // 设置线程个数
    procedure SetScheduledThread(ACount: Integer); safecall;
    // 固定的周期执行
    function SubmitTaskAtFixedPeriod(ATask: IExecutorTask; APeriod: Cardinal): boolean; safecall;
  end;

implementation

end.
