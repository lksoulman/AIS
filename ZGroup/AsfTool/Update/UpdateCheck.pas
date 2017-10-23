unit UpdateCheck;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Update Check
// Author£º      lksoulman
// Date£º        2017-10-12
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

  // Update Check
  TUpdateCheck = class(TAutoObject)
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
    // Check
    procedure Check(AServerUpdateInfos, AAddUpdateInfos: TList<TUpdateInfo>);
  end;

implementation

{ TUpdateCheck }

constructor TUpdateCheck.Create;
begin
  inherited;

end;

destructor TUpdateCheck.Destroy;
begin

  inherited;
end;

procedure TUpdateCheck.Initialize(AContext: IUpdateAppContext);
begin
  FUpdateAppContext := AContext;
end;

procedure TUpdateCheck.UnInitialize(AContext: IUpdateAppContext);
begin
  FUpdateAppContext := nil;
end;

procedure TUpdateCheck.Check(AServerUpdateInfos, AAddUpdateInfos: TList<TUpdateInfo>);
var
  LIndex: Integer;
begin
  if AServerUpdateInfos = nil then Exit;

  for LIndex := 0 to AServerUpdateInfos.Count - 1 do begin

  end;
end;

end.
