unit UpdateBackUp;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Update BackUp
// Author£º      lksoulman
// Date£º        2017-10-13
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  UpdateInfo,
  UpdateAppContext,
  CommonRefCounter,
  Generics.Collections;

type

  // Update BackUp
  TUpdateBackUp = class(TAutoObject)
  private
    // Application Context
    FUpdateAppContext: IUpdateAppContext;
  protected
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;
    // Init
    procedure Initialize(AContext: IUpdateAppContext);
    // UnInit
    procedure UnInitialize(AContext: IUpdateAppContext);
  end;

implementation

{ TUpdateBackUp }

constructor TUpdateBackUp.Create;
begin
  inherited;

end;

destructor TUpdateBackUp.Destroy;
begin

  inherited;
end;

procedure TUpdateBackUp.Initialize(AContext: IUpdateAppContext);
begin
  FUpdateAppContext := AContext;
end;

procedure TUpdateBackUp.UnInitialize(AContext: IUpdateAppContext);
begin
  FUpdateAppContext := nil;
end;

end.
