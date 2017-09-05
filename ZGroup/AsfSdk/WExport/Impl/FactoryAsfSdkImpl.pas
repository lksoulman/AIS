unit FactoryAsfSdkImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º
// Author£º      lksoulman
// Date£º        2017-8-29
// Comments£º    A dynamic library has only one implementation factory,
//               A factory is a singleton.
//               AsfSdk project factory implementation.
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  CipherMgr,
  FastLogMgr,
  PlugInConst,
  WFactoryImpl;

type

  // AsfSdk project factory implementation
  TFactoryAsfSdkImpl = class(TWFactoryImpl)
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
  // Global FastLogMgr
  G_FastLogMgr: IFastLogMgr;
  // Global CipherMgr
  G_CipherMgr: ICipherMgr;


implementation

uses
  PlugIn,
  WFactory,
  CipherMgrPlugInImpl,
  FastLogMgrPlugInImpl;

{ TFactoryAsfSdkImpl }

constructor TFactoryAsfSdkImpl.Create;
begin
  inherited;

end;

destructor TFactoryAsfSdkImpl.Destroy;
begin

  inherited;
end;

procedure TFactoryAsfSdkImpl.DoRegisterPlugIns;
begin
  DoRegisterPlugIn(PLUGIN_ID_FASTLOGMGR, itSingleInstance, lmInitialization, TFastLogMgrPlugInImpl);
  DoRegisterPlugIn(PLUGIN_ID_CIPHERMGR, itSingleInstance, lmInitialization, TCipherMgrPlugInImpl);
end;

initialization

  // Create global factory
  if G_WFactory = nil then begin
    G_WFactory :=  TFactoryAsfSdkImpl.Create as IInterface;
    G_FastLogMgr := (G_WFactory as IWFactory).GetPlugInById(PLUGIN_ID_FASTLOGMGR) as IFastLogMgr;
    G_CipherMgr := (G_WFactory as IWFactory).GetPlugInById(PLUGIN_ID_CIPHERMGR) as ICipherMgr;
  end;

finalization

  // Free global factory interface
  if G_WFactory <> nil then begin
    G_CipherMgr := nil;
    G_FastLogMgr := nil;
    G_WFactory := nil;
  end;

end.
