unit HqSubcribeAdapter;

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
  Windows,
  Classes,
  SysUtils,
  AppContext,
  HqSubscribeData;

type


  // 行情订阅适配
  IHqSubcribeAdapter = Interface(IInterface)
    ['{680B94C1-C877-4674-9C75-BB7394201B3B}']
    // 初始化需要的资源
    procedure Initialize(AContext: IAppContext); safecall;
    // 释放不需要的资源
    procedure UnInitialize; safecall;
  end;

implementation

end.
