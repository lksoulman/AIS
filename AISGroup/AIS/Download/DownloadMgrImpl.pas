unit DownloadMgrImpl;

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
  SysUtils,
  DownloadMgr;

type

  TDownloadMgrImpl = class(TInterfacedObject, IDownloadMgr)
  private
  protected
  public
    // 构造方法
    constructor Create;
    // 析构函数
    destructor Destroy; override;

    { IDownload }

    // 提交下载任务
    function SubmitJob(): WideString; safecall;
  end;

implementation

{ TDownloadMgrImpl }

constructor TDownloadMgrImpl.Create;
begin
  inherited;

end;

destructor TDownloadMgrImpl.Destroy;
begin

  inherited;
end;

function TDownloadMgrImpl.SubmitJob: WideString;
begin

end;

end.
