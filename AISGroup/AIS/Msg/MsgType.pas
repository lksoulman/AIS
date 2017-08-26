unit MsgType;

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
  SysUtils;

type

  // 消息类型
  TMsgType = (mtLoadPlugs,              // 插件加载消息
              mtNDayModifyPassword,     // 系统提示消息
              mtSecuBaseDataUpdate      // 证券主表数据发生改变，通知内存更新
              );

  TMsgTypeDynArray = Array of TMsgType;

  // 消息回调方法定义
  TMsgCallBackFunc = procedure (AMsgType: TMsgType; AMsgInfo: string; var ALogTag: string) of Object;


implementation

end.
