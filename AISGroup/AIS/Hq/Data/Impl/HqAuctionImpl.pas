unit HqAuctionImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-26
// Comments：
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

  // 集合竞价
  THqAuctionImpl = class(TAutoInterfacedObject, IHqAuction)
  private
  protected
  public
    // 构造函数
    constructor Create; override;
    // 析构函数
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

