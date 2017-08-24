unit ExecutorFixed;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-5-1
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  ExecutorService;

type

  IExecutorFixed = Interface(IExecutorService)
    ['{8629F89D-4A93-4857-9746-043A1FA3D61D}']
    // 设置启动线程的个数
    procedure SetFixedThread(ACount: Integer); safecall;
  end;

implementation

end.
