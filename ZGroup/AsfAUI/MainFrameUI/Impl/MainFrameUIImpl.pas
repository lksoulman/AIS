unit MainFrameUIImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Main Frame UI Implementation
// Author£º      lksoulman
// Date£º        2017-10-16
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  AppStatus,
  AppContext,
  MainFrameUI,
  SyncAsyncImpl,
  AppMainFormUI,
  Generics.Collections;

type

  // Main Frame UI Implementation
  TMainFrameUIImpl = class(TSyncAsyncImpl, IMainFrameUI)
  private
    // App Status
    FAppStatus: IAppStatus;
    // App Main Form
    FAppMainFormUI: TAppMainFormUI;
  protected
    // Clear Form
    procedure DoClearFormDic;
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;

    { ISyncAsync }

    // Initialize Resources(only execute once)
    procedure Initialize(AContext: IAppContext); override;
    // Releasing Resources(only execute once)
    procedure UnInitialize; override;
    // Blocking primary thread execution(only execute once)
    procedure SyncBlockExecute; override;
    // Non blocking primary thread execution(only execute once)
    procedure AsyncNoBlockExecute; override;
    // Dependency
    function Dependences: WideString; override;
  end;

implementation

uses
  AppStatusImpl;

{ TMainFrameUIImpl }

constructor TMainFrameUIImpl.Create;
begin
  inherited;
  FAppStatus := TAppStatusImpl.Create as IAppStatus;
  FAppMainFormUI := TAppMainFormUI.Create(FAppStatus);
end;

destructor TMainFrameUIImpl.Destroy;
begin
  FAppMainFormUI.Free;
  FAppStatus := nil;
  inherited;
end;

procedure TMainFrameUIImpl.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);
  FAppStatus.Initialize(AContext);
  FAppMainFormUI.Initialize(AContext);
end;

procedure TMainFrameUIImpl.UnInitialize;
begin
  FAppMainFormUI.UnInitialize;
  FAppStatus.UnInitialize;
  inherited UnInitialize;
end;

procedure TMainFrameUIImpl.SyncBlockExecute;
begin
  FAppMainFormUI.Show;
end;

procedure TMainFrameUIImpl.AsyncNoBlockExecute;
begin

end;

function TMainFrameUIImpl.Dependences: WideString;
begin

end;

procedure TMainFrameUIImpl.DoClearFormDic;
//var
//  LMDIForm: TMDIForm;
//  LEnum: TDictionary<Integer, TMDIForm>.TPairEnumerator;
begin
//  LEnum := FMDIFormDic.GetEnumerator;
//  try
//    while LEnum.MoveNext do begin
//      LMDIForm := LEnum.Current.Value;
//      if LMDIForm <> nil then begin
//        LMDIForm.UnInitialize;
//        LMDIForm.Free;
//      end;
//    end;
//  finally
//    LEnum.Free;
//  end;
end;

end.
