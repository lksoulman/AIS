unit DownloadMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-7-28
// Comments��
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
    // ���췽��
    constructor Create;
    // ��������
    destructor Destroy; override;

    { IDownload }

    // �ύ��������
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
