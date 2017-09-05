unit HqServerTypeInfo;

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
  SysUtils,
  QuoteMngr_TLB;

type

  // 行情服务器连接状态
  THqServerStatus = ( ssInit,
                      ssConnecting,      // 正在连接
                      ssConnected,       // 已连接
                      ssDisConnected     // 连接断开
                      );

  // 行情服务器类型
  THqServerTypeItem = packed record
    FName: string;
    FIsUsed: Boolean;
    FServers: string;
    FTypeEnum: ServerTypeEnum;
    FServerStatus: THqServerStatus;
    FLastHeartBeatTime: Cardinal;
  end;

  // 行情服务器类型接口
  PHqServerTypeItem = ^THqServerTypeItem;

  // 行情服务器类型信息接口
  IHqServerTypeInfo = Interface(IInterface)
    ['{7F5600EE-0ADA-4995-A364-248ADE6940A3}']
    // 初始化需要的资源
    procedure Initialize(AContext: IInterface); safecall;
    // 释放不需要的资源
    procedure UnInitialize; safecall;
    // 加载数据
    procedure LoadXmlNodes(ANodeList: TList); safecall;
    // 加锁
    procedure Lock; safecall;
    // 解锁
    procedure UnLock; safecall;
    // 获取行情服务器类型个数
    function GetHqServerTypeItemCount: Integer; safecall;
    // 获取行情服务器类型指针
    function GetHqServerTypeItem(AIndex: Integer): PHqServerTypeItem; safecall;
    // 获取行情服务器类型指针通过枚举
    function GetHqServerTypeNameByEnum(AEnum: ServerTypeEnum): WideString; safecall;
    // 获取行情服务器类型指针通过枚举
    function GetHqServerTypeItemByEnum(AEnum: ServerTypeEnum): PHqServerTypeItem; safecall;
  end;


implementation

end.
