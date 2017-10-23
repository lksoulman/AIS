unit HqAuthImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Hq Authority Interface Implementation
// Author£º      lksoulman
// Date£º        2017-7-24
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  HqAuth,
  Windows,
  Classes,
  SysUtils,
  AppContext,
  WNDataSetInf,
  SyncAsyncImpl,
  Generics.Collections;

type

  // Hq Authority Interface Implementation
  THqAuthImpl = class(TSyncAsyncImpl, IHqAuth)
  private
    // Is Has HK Real Authority
    FIsHasHKReal: Boolean;
    // Is Has Level2 Authority
    FIsHasLevel2: Boolean;
    // Level2 UserName
    FLevel2UserName: string;
    // Level2 Password
    FLevel2Password: string;
  protected
    // Get HKReal
    procedure DoGetHKReal;
    // Get Level2
    procedure DoGetLevel2;
  public
    // Constructor
    constructor Create; override;
    // Destructor
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
    // Dependency
    function Dependences: WideString; override;

    { IHqAuth }

    // Is Has HK Real Authority
    function GetIsHasHKReal: Boolean; safecall;
    // Is Has Level2 Authority
    function GetIsHasLevel2: Boolean; safecall;
    // Get Level2 UserName
    function GetLevel2UserName: WideString; safecall;
    // Get Level2 Password
    function GetLevel2Password: WideString; safecall;
  end;

implementation

uses
  Login,
  LogLevel,
  ServiceType;

{ THqAuthImpl }

constructor THqAuthImpl.Create;
begin
  inherited;
  FIsHasHKReal := False;
  FIsHasLevel2 := False;
end;

destructor THqAuthImpl.Destroy;
begin
  inherited;
end;

procedure THqAuthImpl.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);

end;

procedure THqAuthImpl.UnInitialize;
begin

  inherited UnInitialize;
end;

procedure THqAuthImpl.SyncBlockExecute;
begin
  if FAppContext <> nil then begin
    if (FAppContext.GetLogin <> nil) then begin
      if FAppContext.GetLogin.IsLoginService(stBasic) then begin
        DoGetLevel2;
        DoGetHKReal;
      end else begin
        FAppContext.SysLog(llERROR, '[THqAuthImpl][SyncBlockExecute] GetLogin.IsLoginService(stBasic) return is false, permission is not load.');
      end;
    end else begin
      FAppContext.SysLog(llERROR, '[THqAuthImpl][SyncBlockExecute] GetLogin is nil');
    end;
  end;
end;

procedure THqAuthImpl.AsyncNoBlockExecute;
begin

end;

function THqAuthImpl.Dependences: WideString;
begin
  Result := Format('%s', [GUIDToString(ILogin)]);
end;

function THqAuthImpl.GetIsHasHKReal: Boolean;
begin
  Result := FIsHasHKReal;
end;

function THqAuthImpl.GetIsHasLevel2: Boolean;
begin
  Result := FIsHasLevel2;
end;

function THqAuthImpl.GetLevel2UserName: WideString;
begin
  Result := FLevel2UserName;
end;

function THqAuthImpl.GetLevel2Password: WideString;
begin
  Result := FLevel2Password;
end;

procedure THqAuthImpl.DoGetHKReal;
var
{$IFDEF DEBUG}
  LTick: Cardinal;
{$ENDIF}
  LDataSet: IWNDataSet;
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
  try
{$ENDIF}

    FIsHasHKReal := False;
    LDataSet := FAppContext.GFPrioritySyncQuery(stBasic, 'USER_QX_HK()', 5000);
    if LDataSet <> nil then begin
      if LDataSet.RecordCount > 0 then begin
        LDataSet.First;
        if (LDataSet.FieldCount > 0)
          and (not LDataSet.Fields(0).IsNull) then begin
          FIsHasHKReal := (LDataSet.Fields(0).AsInteger > 0);
        end else begin
          FAppContext.IndicatorLog(llERROR, Format('[THqAuthImpl][DoGetHKReal] [Indicator][%s] Return data fieldcount is 0 or field data is nil.', ['USER_QX_HK()']));
        end;
      end else begin
        FAppContext.IndicatorLog(llERROR, Format('[THqAuthImpl][DoGetHKReal] [Indicator][%s] Return data is nil.', ['USER_QX_HK()']));
      end;
      LDataSet := nil;
    end else begin
      FAppContext.IndicatorLog(llERROR, Format('[THqAuthImpl][DoGetHKReal] [Indicator][%s] Return data is nil.', ['USER_QX_HK()']));
    end;
{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
    FAppContext.SysLog(llSLOW, Format('[THqAuthImpl][DoGetHKReal] Load HKReal data to dictionary use time is %d ms.', [LTick]), LTick);
  end;
{$ENDIF}
end;

procedure THqAuthImpl.DoGetLevel2;
var
{$IFDEF DEBUG}
  LTick: Cardinal;
{$ENDIF}
  LDataSet: IWNDataSet;
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
  try
{$ENDIF}

    FIsHasLevel2 := False;
    LDataSet := FAppContext.GFPrioritySyncQuery(stBasic, 'USER_LEVEL2_INFO()', 5000);
    if LDataSet <> nil then begin
      if LDataSet.RecordCount > 0 then begin
        LDataSet.First;
        if (LDataSet.FieldCount > 2) then begin
          FLevel2UserName := LDataSet.Fields(0).AsString;
          FLevel2Password := LDataSet.Fields(1).AsString;
          FIsHasLevel2 := True;
        end else begin
          FAppContext.IndicatorLog(llERROR, Format('[THqAuthImpl][DoGetLevel2] [Indicator][%s] Return data fieldcount low 2.', ['USER_LEVEL2_INFO()']));
        end;
      end else begin
        FAppContext.IndicatorLog(llERROR, Format('[THqAuthImpl][DoGetLevel2] [Indicator][%s] Return data is nil.', ['USER_LEVEL2_INFO()']));
      end;
      LDataSet := nil;
    end else begin
      FAppContext.IndicatorLog(llERROR, Format('[THqAuthImpl][DoGetLevel2] [Indicator][%s] Return data is nil.', ['USER_LEVEL2_INFO()']));
    end;

{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
    FAppContext.SysLog(llSLOW, Format('[THqAuthImpl][DoGetLevel2] Load LevelII data to dictionary use time is %d ms.', [LTick]), LTick);
  end;
{$ENDIF}
end;

end.
