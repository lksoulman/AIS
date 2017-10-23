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
  MDI,
  Windows,
  Classes,
  SysUtils,
  AppContext,
  MainFrameUI,
  SyncAsyncImpl,
  Generics.Collections;

type

  // Main Frame UI Implementation
  TMainFrameUIImpl = class(TSyncAsyncImpl, IMainFrameUI)
  private
    FCurrentMDIForm: TMDIForm;
    // MDI Form Dic
    FMDIFormDic: TDictionary<Integer, TMDIForm>;
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

{ TMainFrameUIImpl }

constructor TMainFrameUIImpl.Create;
begin
  inherited;
  FMDIFormDic := TDictionary<Integer, TMDIForm>.Create(9);

end;

destructor TMainFrameUIImpl.Destroy;
begin

  FMDIFormDic.Free;
  inherited;
end;

procedure TMainFrameUIImpl.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);

  FCurrentMDIForm := TMDIForm.Create(nil);
  FCurrentMDIForm.Initialize(AContext);
  FMDIFormDic.AddOrSetValue(FCurrentMDIForm.Handle, FCurrentMDIForm);
end;

procedure TMainFrameUIImpl.UnInitialize;
begin

  inherited UnInitialize;
end;

procedure TMainFrameUIImpl.SyncBlockExecute;
begin
  FCurrentMDIForm.Show;
end;

procedure TMainFrameUIImpl.AsyncNoBlockExecute;
begin

end;

function TMainFrameUIImpl.Dependences: WideString;
begin

end;

procedure TMainFrameUIImpl.DoClearFormDic;
var
  LMDIForm: TMDIForm;
  LEnum: TDictionary<Integer, TMDIForm>.TPairEnumerator;
begin
  LEnum := FMDIFormDic.GetEnumerator;
  try
    while LEnum.MoveNext do begin
      LMDIForm := LEnum.Current.Value;
      if LMDIForm <> nil then begin
        LMDIForm.UnInitialize;
        LMDIForm.Free;
      end;
    end;
  finally
    LEnum.Free;
  end;
end;

end.
