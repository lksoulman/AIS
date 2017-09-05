unit ProductAuthImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º
// Author£º      lksoulman
// Date£º        2017-8-17
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  AppContext,
  ProductAuth,
  WNDataSetInf,
  SyncAsyncImpl,
  Generics.Collections;

type

  // Product Authority interface implementation
  TProductAuthImpl = class(TSyncAsyncImpl, IProductAuth)
  private
    type
      //
      TAuthority = packed record
        FFuncNo: Integer;       // Function No
        FFuncName: string;      // Function Name
        FEndDate: TDateTime;    // Start Date
        FStartDate: TDateTime;  // End Date
      end;
      //
      PAuthority = ^TAuthority;
  private
    // Product Authority Dictionary
    FAuthorityDic: TDictionary<Integer, PAuthority>;
  protected
    // Get Authority
    procedure DoGetAuthority;
    // Clear Authority Dictionary
    procedure DoClearAuthorityDic;
    // Load Data
    procedure DoLoadData(ADataSet: IWNDataSet; ANoField, ANameField, ASDateField, AEDateField: IWNField);
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
    // blocking primary thread execution(only execute once)
    procedure SyncBlockExecute; override;
    // Non blocking primary thread execution(only execute once)
    procedure AsyncNoBlockExecute; override;
    // Obtain dependency
    function Dependences: WideString; override;

    { IProductAuth }

    // Get the Product is have this function permission
    function GetIsHasAuth(AFuncNo: Integer): Boolean; safecall;
  end;

implementation

uses
  LoginMgr,
  LoginType,
  ServiceType,
  FastLogLevel,
  AsfSdkExport;

{ TProductAuthImpl }

constructor TProductAuthImpl.Create;
begin
  inherited;
  FAuthorityDic := TDictionary<Integer, PAuthority>.Create;
end;

destructor TProductAuthImpl.Destroy;
begin
  DoClearAuthorityDic;
  FAuthorityDic.Free;
  inherited;
end;

procedure TProductAuthImpl.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);

end;

procedure TProductAuthImpl.UnInitialize;
begin

  inherited UnInitialize;
end;

procedure TProductAuthImpl.SyncBlockExecute;
begin
  if (FAppContext.GetLoginMgr <> nil) then begin
    if (FAppContext.GetLoginMgr as ILoginMgr).IsLoginGF(ltBase) then begin
      DoGetAuthority;
    end else begin
      FastSysLog(llERROR, '[TProductAuthImpl][SyncBlockExecute] GetLoginMgr.IsLoginGF(lGFBase) return is false, permission is not load.');
    end;
  end else begin
    FastSysLog(llERROR, '[TProductAuthImpl][SyncBlockExecute] GetLoginMgr is nil');
  end;
end;

procedure TProductAuthImpl.AsyncNoBlockExecute;
begin

end;

function TProductAuthImpl.Dependences: WideString;
begin
  Result := Format('%s', [GUIDToString(ILoginMgr)]);
end;

function TProductAuthImpl.GetIsHasAuth(AFuncNo: Integer): Boolean;
begin
  Result := FAuthorityDic.ContainsKey(AFuncNo);
end;

procedure TProductAuthImpl.DoGetAuthority;
var
{$IFDEF DEBUG}
  LTick: Cardinal;
{$ENDIF}
  LDataSet: IWNDataSet;
  LNoField, LNameField, LEDateField, LSDateField: IWNField;
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
  try
{$ENDIF}

    LDataSet := FAppContext.GFSyncHighQuery(stBase, 'USER_QX', 0, 100000);
    if (LDataSet <> nil) and (LDataSet.RecordCount > 0) then begin
      LNoField := LDataSet.FieldByName('mkid');
      LNameField := LDataSet.FieldByName('qx');
      LEDateField := LDataSet.FieldByName('jzrq');
      LSDateField := LDataSet.FieldByName('qsrq');

      if (LNoField = nil) then begin
        FastIndicatorLog(llERROR, Format('[TProductAuthImpl][DoGetAuthority] [Indicator][USER_QX] Return field %s is nil.', ['FuncNo']));
        Exit;
      end;
      if (LNameField = nil) then begin
        FastIndicatorLog(llERROR, Format('[TProductAuthImpl][DoGetAuthority] [Indicator][USER_QX] Return field %s is nil.', ['FuncName']));
        Exit;
      end;

      if (LEDateField = nil) then begin
        FastIndicatorLog(llERROR, Format('[TPermissionMgrImpl][DoGetAuthority] [Indicator][USER_QX] Return field %s is nil.', ['EndDate']));
        Exit;
      end;

      if (LSDateField = nil) then begin
        FastIndicatorLog(llERROR, Format('[TProductAuthImpl][DoGetAuthority] [Indicator][USER_QX] Return field %s is nil.', ['StartDate']));
        Exit;
      end;
      DoLoadData(LDataSet, LNoField, LNameField, LSDateField, LEDateField);
      LDataSet := nil;
    end;

{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
    FastSysLog(llSLOW, Format('[TProductAuthImpl][DoGetAuthority] Load permissions data to dictionary use time is %d ms.', [LTick]), LTick);
  end;
{$ENDIF}
end;

procedure TProductAuthImpl.DoClearAuthorityDic;
var
  LPAuthority: PAuthority;
  LEnum: TDictionary<Integer, PAuthority>.TPairEnumerator;
begin
  LEnum := FAuthorityDic.GetEnumerator;
  try
    while LEnum.MoveNext do begin
      LPAuthority := LEnum.Current.Value;
      if (LPAuthority <> nil) then begin
        Dispose(LPAuthority);
      end;
    end;
  finally
    LEnum.Free;
  end;
  FAuthorityDic.Clear;
end;

procedure TProductAuthImpl.DoLoadData(ADataSet: IWNDataSet; ANoField, ANameField, ASDateField, AEDateField: IWNField);
var
  LFuncNo: Integer;
  LPAuthority: PAuthority;
begin
  ADataSet.First;
  try
    while not ADataSet.Eof do begin
      LFuncNo := ANoField.AsInteger;
      if FAuthorityDic.TryGetValue(LFuncNo, LPAuthority)
        and (LPAuthority <> nil) then begin
        FastIndicatorLog(llERROR, Format('[TProductAuthImpl][DoLoadData] [Indicator][USER_QX] return dataset FuncNo(%d) is repeated.', [LFuncNo]));
      end else begin
        New(LPAuthority);
        FAuthorityDic.AddOrSetValue(LFuncNo, LPAuthority);
      end;
      LPAuthority^.FFuncNo := LFuncNo;
      LPAuthority^.FFuncName := ANameField.AsString;
      LPAuthority^.FEndDate := AEDateField.AsDateTime;
      LPAuthority^.FStartDate := ASDateField.AsDateTime;
      ADataSet.Next;
    end;
  except
    on Ex: Exception do begin
      FastSysLog(llError, Format('[TProductAuthImpl][DoLoadData] Load data is exception, exception is %s.', [Ex.Message]));
    end;
  end;
end;

end.
