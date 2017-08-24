unit MsgSys;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-7-29
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  MsgType,
  AppContext;

type

  IMsgSys = Interface(IInterface)
    ['{85D1204E-01AE-474D-B3D1-1D34781434BF}']
    // 初始化
    procedure Initialize(AContext: IAppContext); safecall;
    // 释放接口资源
    procedure UnInitialize; safecall;
    // 消息类型
    function MsgType: TMsgType; safecall;
    // 消息信息
    function MsgInfo: WideString; safecall;
    // 消息产生者 ID
    function ProducerID: Integer; safecall;
    // 消息产生时间
    function ProduceDate: TDateTime; safecall;
    // 执行操作名称
    function OperateName: WideString; safecall;
    // 执行操作实现方法
    function ExecuteOperate: WordBool; safecall;
  end;

implementation

end.
