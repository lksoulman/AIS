unit HqAuctionImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-26
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  HqAuction,
  CommonRefCounter;

type

  // ���Ͼ���
  THqAuctionImpl = class(TAutoInterfacedObject, IHqAuction)
  private
  protected
  public
    // ���캯��
    constructor Create; override;
    // ��������
    destructor Destroy; override;
  end;

implementation

{ THqAuctionImpl }

constructor THqAuctionImpl.Create;
begin
  inherited;

end;

destructor THqAuctionImpl.Destroy;
begin

  inherited;
end;

end.

