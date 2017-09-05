unit PlugInImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Plug-in interface implementation
// Author£º      lksoulman
// Date£º        2017-8-16
// Comments£º    The plug-in interface implements the base class.
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  PlugIn,
  Windows,
  Classes,
  SysUtils,
  AppContext,
  CommonRefCounter;

type

  // Plug-in interface implementation
  TPlugInImpl = class(TAutoInterfacedObject, IPlugIn)
  private
  protected
    // Application context interface
    FAppContext: IAppContext;
  public
    // Constructor method
    constructor Create; override;
    // Destructor method
    destructor Destroy; override;

    { IPlugIn }

    // Initialize resources(only execute once)
    procedure Initialize(AContext: IAppContext); virtual; safecall;
    // Releasing resources(only execute once)
    procedure UnInitialize; virtual; safecall;
    // Blocking primary thread execution(only execute once)
    procedure SyncBlockExecute; virtual; safecall;
    // Non blocking primary thread execution(only execute once)
    procedure AsyncNoBlockExecute; virtual; safecall;
    // Get dependency
    function Dependences: WideString; virtual; safecall;
    // Get the plug-in interface implementation type name
    function GetClassName: WideString; virtual; safecall;
  end;

  // Plug-in class of class
  TPlugInImplClass = class of TPlugInImpl;

implementation

{ TPlugInImpl }

constructor TPlugInImpl.Create;
begin
  Inherited;

end;

destructor TPlugInImpl.Destroy;
begin

  inherited;
end;

procedure TPlugInImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
end;

procedure TPlugInImpl.UnInitialize;
begin
  FAppContext := nil;
end;

procedure TPlugInImpl.SyncBlockExecute;
begin

end;

procedure TPlugInImpl.AsyncNoBlockExecute;
begin

end;

function TPlugInImpl.Dependences: WideString;
begin

end;

function TPlugInImpl.GetClassName: WideString;
begin
  Result := Self.ClassName;
end;

end.
