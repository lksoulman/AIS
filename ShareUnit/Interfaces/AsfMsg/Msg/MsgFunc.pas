unit MsgFunc;

////////////////////////////////////////////////////////////////////////////////
//
// Description： Message Function Definition
// Author：      lksoulman
// Date：        2017-7-29
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  MsgEx;

type

  // 操作
  TMsgFuncOperate = procedure of Object;

  // 创建事件
  TMsgFuncCreate = function: TObject of Object;

  // 消息回调方法定义
  TMsgFuncCallBack = procedure (AMsgEx: TMsgEx; var ALogTag: string) of Object;

implementation

end.
