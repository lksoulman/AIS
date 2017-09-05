unit HqCoreMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Hq core manager implementation
// Author£º      lksoulman
// Date£º        2017-8-25
// Comments£º    Hq core manager implementation
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  HqCoreMgr,
  AppContext,
  HqDataCenter,
  SyncAsyncImpl,
  HqIndicatorMgr,
  CommonRefCounter,
  HqSubcribeAdapter;

type

  // Hq core manager interface implementation
  THqCoreMgrImpl = class(TSyncAsyncImpl, IHqCoreMgr)
  private
    // Hq data center interface
    FHqDataCenter: IHqDataCenter;
    // Hq indicator manager interface
    FHqIndicatorMgr: IHqIndicatorMgr;
    // Hq Subcribe Adapter interface
    FHqSubcribeAdapter: IHqSubcribeAdapter;
  protected
  public
    // Constructor method
    constructor Create; override;
    // Destructor method
    destructor Destroy; override;

    { ISyncAsync }

    // Initialize resources(only execute once)
    procedure Initialize(AContext: IAppContext); override;
    // Releasing resources(only execute once)
    procedure UnInitialize; override;
    // Blocking primary thread execution(only execute once)
    procedure SyncBlockExecute; override;
    // Non blocking primary thread execution(only execute once)
    procedure AsyncNoBlockExecute; override;
    // Obtain dependency
    function Dependences: WideString; override;

    { IHqCoreMgr }

    // Get Hq data center interface
    function GetHqDataCenter: IHqDataCenter; safecall;
    // Get Hq indicator manager interface
    function GetHqIndicatorMgr: IHqIndicatorMgr; safecall;
    // Get Hq subcribe adapter interface
    function GetHqSubcribeAdapter: IHqSubcribeAdapter; safecall;
  end;

implementation

{ THqCoreMgrImpl }

constructor THqCoreMgrImpl.Create;
begin
  inherited;

end;

destructor THqCoreMgrImpl.Destroy;
begin

  inherited;
end;

procedure THqCoreMgrImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
end;

procedure THqCoreMgrImpl.UnInitialize;
begin
  FAppContext := nil;
end;

procedure THqCoreMgrImpl.SyncBlockExecute;
begin

end;

procedure THqCoreMgrImpl.AsyncNoBlockExecute;
begin

end;

function THqCoreMgrImpl.Dependences: WideString;
begin

end;

function THqCoreMgrImpl.GetHqDataCenter: IHqDataCenter;
begin
  Result := FHqDataCenter;
end;

function THqCoreMgrImpl.GetHqIndicatorMgr: IHqIndicatorMgr;
begin
  Result := FHqIndicatorMgr;
end;

function THqCoreMgrImpl.GetHqSubcribeAdapter: IHqSubcribeAdapter;
begin
  Result := FHqSubcribeAdapter;
end;

end.
