unit FutureInfo;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-28
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  // 期货行情转化CODE
  IFutureInfo = Interface(IInterface)
    ['{4C410229-A9D0-46C6-9E74-CA4F86F527C3}']
    // 初始化需要的资源
    procedure Initialize(AContext: IInterface); safecall;
    // 释放不需要的资源
    procedure UnInitialize; safecall;
    // 加载数据
    procedure LoadXmlNodes(ANodeList: TList); safecall;
    // 期货 Code 的个数
//    function GetFutureCodeCount: Integer; safecall;
//    // 获取 InnerCode
//    function GetInnerCode(AIndex: Integer): Integer; safecall;
//    // 获取 AgentCode
//    function GetAgentCode(AIndex: Integer): WideString; safecall;
    // 获取是不是存在 InnerCode
    function GetFutureCode(AInnerCode: Integer; var ACodeAgent: WideString): Boolean; safecall;
  end;

implementation

end.
