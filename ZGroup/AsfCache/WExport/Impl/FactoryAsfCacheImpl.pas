unit FactoryAsfCacheImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º
// Author£º      lksoulman
// Date£º        2017-8-29
// Comments£º    A dynamic library has only one implementation factory,
//               A factory is a singleton.
//               AsfCache project factory implementation.
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  PlugInConst,
  WFactoryImpl;

type

  // AsfCache project factory implementation
  TFactoryAsfCacheImpl = class(TWFactoryImpl)
  private
  protected
    // Register PlugIns
    procedure DoRegisterPlugIns; override;
  public
    // Constructor method
    constructor Create; override;
    // Destructor method
    destructor Destroy; override;
  end;

var
  // Global factory
  G_WFactory: IInterface;

implementation

uses
  PlugIn,
  BaseCache,
  UserCache,
  UserAssetCache,
  BaseCachePlugInImpl,
  UserCachePlugInImpl,
  UserAssetCachePlugInImpl;

{ TFactoryAsfCacheImpl }

constructor TFactoryAsfCacheImpl.Create;
begin
  inherited;

end;

destructor TFactoryAsfCacheImpl.Destroy;
begin

  inherited;
end;

procedure TFactoryAsfCacheImpl.DoRegisterPlugIns;
begin
//  DoRegisterPlugIn(GUIDToString(IBaseCache), PLUGIN_ID_HQAUTH, TBaseCachePlugInImpl);
//  DoRegisterPlugIn(GUIDToString(IUserCache), PLUGIN_ID_PRODUCTAUTH, TUserCachePlugInImpl);
//  DoRegisterPlugIn(GUIDToString(IUserAssetCache), PLUGIN_ID_PRODUCTAUTH, TUserAssetCachePlugInImpl);
end;

initialization

  // Create global factory
  if G_WFactory = nil then begin
    G_WFactory := TFactoryAsfCacheImpl.Create as IInterface;
  end;

finalization

  // Free global factory interface
  if G_WFactory <> nil then begin
    G_WFactory := nil;
  end;

end.
