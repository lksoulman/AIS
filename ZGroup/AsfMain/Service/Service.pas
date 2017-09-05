unit Service;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-10
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  GFDataMngr_TLB;

type

  IService = Interface(IInterface)
    ['{A276ED5E-059E-427C-8552-78EEB9AD9A15}']
    // 设置代理
    function SetProxy: Boolean; safecall;
    // 获取 GF 数据服务接口
    function GetGFDataManager: IGFDataManager; safecall;
  end;

implementation

end.

