unit MsgExImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º
// Author£º      lksoulman
// Date£º        2017-7-29
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  MsgEx,
  MsgType,
  MsgFunc,
  Windows,
  Classes,
  SysUtils,
  MsgFactory,
  AppContext,
  CommonLock,
  CommonRefCounter;

type

  // Message extend interface implementation
  TMsgExImpl = class(TMsgEx)
  private
  protected
    // Thread lock
    FLock: TCSLock;
    // Object ref Counter
    FObjRefCounter: Integer;
    // is init
    FIsInit: Boolean;
    // Message Id
    FId: UInt;
    // Producer Id
    FProId: Integer;
    // Produce Time
    FProTime: TDateTime;
    // Message sysem Information
    FMsgInfo: string;
    // Message sysem type
    FMsgType: TMsgType;
    // Message operate name
    FOperateName: string;
    // Message operate
    FMsgOperate: TMsgFuncOperate;
    // Message extend factory
    FMsgFactory: IMsgFactory;
    // Application context interface
    FAppContext: IAppContext;
  public
    // Constructor method
    constructor Create(AContext: IAppContext; AMsgFactory: IMsgFactory); reintroduce;
    // Destructor method
    destructor Destroy; override;
    // Clear
    procedure Clear;
    // Invoke Operate Execute
    function InvokeOperateExecute: Boolean; override;
    // Incr ref counter
    procedure IncrRefCounter;
    // Decr ref counter
    procedure DecrRefCounter;
    // Get Id
    function GetId: UInt; override;
    // Set Id
    procedure SetId(AId: UInt);
    // Get Producer ID
    function GetProId: Integer; override;
    // Set Producer ID
    procedure SetProId(AProID: Integer);
    // Get Produce Time
    function GetProTime: TDateTime; override;
    // Set Produce Time
    procedure SetProTime(ProTime: TDateTime);
    // Get Message Information
    function GetMsgInfo: WideString; override;
    // Set Message Information
    procedure SetMsgInfo(AMsgInfo: WideString);
    // Get Message type
    function GetMsgType: TMsgType; override;
    // Set Message type
    procedure SetMsgType(AMsgType: TMsgType);
    // Get Operate Name
    function GetOperateName: WideString; override;
    // Set Operate Name
    procedure SetOperateName(AOperateName: WideString);
    // Set Message Operate
    procedure SetMsgOperate(AMsgOperate: TMsgFuncOperate);
  end;

implementation

{ TMsgExImpl }

constructor TMsgExImpl.Create(AContext: IAppContext; AMsgFactory: IMsgFactory);
begin
  inherited Create;
  FLock := TCSLock.Create;
  FObjRefCounter := 0;
  FAppContext := AContext;
  FMsgFactory := AMsgFactory;
end;

destructor TMsgExImpl.Destroy;
begin
  FMsgFactory := nil;
  FAppContext := nil;
  FLock.Free;
  inherited;
end;

procedure TMsgExImpl.IncrRefCounter;
begin
  FLock.Lock;
  try
    Inc(FObjRefCounter);
  finally
    FLock.UnLock;
  end;
end;

procedure TMsgExImpl.DecrRefCounter;
begin
  FLock.Lock;
  try
    Dec(FObjRefCounter);
    if FObjRefCounter = 0 then begin
      FMsgFactory.DeAllocate(Self);
    end;
  finally
    FLock.UnLock;
  end;
end;

procedure TMsgExImpl.Clear;
begin
  FProId := 0;
  FObjRefCounter := 0;
  FMsgInfo := '';
  FOperateName := '';
  FMsgOperate := nil;
end;

function TMsgExImpl.GetId: UInt;
begin
  Result := FId;
end;

procedure TMsgExImpl.SetId(AId: UInt);
begin
  FId := AId;
end;

function TMsgExImpl.InvokeOperateExecute: Boolean;
begin
  Result := False;
  if Assigned(FMsgOperate) then begin
    FMsgOperate;
    Result := True;
  end;
end;

function TMsgExImpl.GetProId: Integer;
begin
  Result := FProID;
end;

procedure TMsgExImpl.SetProId(AProID: Integer);
begin
  FProID := AProID;
end;

function TMsgExImpl.GetProTime: TDateTime;
begin
  Result := FProTime;
end;

procedure TMsgExImpl.SetProTime(ProTime: TDateTime);
begin
  FProTime := ProTime;
end;

function TMsgExImpl.GetMsgInfo: WideString;
begin
  Result := FMsgInfo;
end;

procedure TMsgExImpl.SetMsgInfo(AMsgInfo: WideString);
begin
  FMsgInfo := AMsgInfo;
end;

function TMsgExImpl.GetMsgType: TMsgType;
begin
  Result := FMsgType;
end;

procedure TMsgExImpl.SetMsgType(AMsgType: TMsgType);
begin
  FMsgType := AMsgType;
end;

function TMsgExImpl.GetOperateName: WideString;
begin
  Result := FOperateName;
end;

procedure TMsgExImpl.SetOperateName(AOperateName: WideString);
begin
  FOperateName := AOperateName;
end;

procedure TMsgExImpl.SetMsgOperate(AMsgOperate: TMsgFuncOperate);
begin
  FMsgOperate := AMsgOperate;
end;

end.
