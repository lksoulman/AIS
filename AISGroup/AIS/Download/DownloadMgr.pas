unit DownloadMgr;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-7-28
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  IDownloadMgr = Interface(IInterface)
    ['{07E084CA-100D-4262-843E-F8269BB12A2D}']
    // 提交下载任务
    function SubmitJob(): WideString; safecall;
  end;

implementation

end.
