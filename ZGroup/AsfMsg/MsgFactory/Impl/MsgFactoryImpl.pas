unit MsgFactoryImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Message Factory Interface implementation
// Author£º      lksoulman
// Date£º        2017-7-29
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  MsgEx,
  MsgType,
  MsgPool,
  Windows,
  Classes,
  SysUtils,
  AppContext,
  MsgFactory,
  CommonLock,
  CommonRefCounter;

type

  // Message Factory Interface implementation
  TMsgFactoryImpl = class(TAutoInterfacedObject, IMsgFactory)
  private
    // Message Increment Id
    FMsgIncrId: Integer;
    // Message Pool
    FMsgPool: TMsgPool;
    // Application context interface
    FAppContext: IAppContext;
  protected
    // Create Message Extend
    function DoCreateMsgEx: TObject;
  public
    // Constructor method
    constructor Create; override;
    // Destructor method
    destructor Destroy; override;

    { IMsgFactory }

    // Initialize resources(only execute once)
    procedure Initialize(AContext: IAppContext); safecall;
    // Releasing resources(only execute once)
    procedure UnInitialize; safecall;
    // Create Message Extend
    function CreateMsg(AProID: Integer; AMsgType: TMsgType; AMsgInfo: string): TMsgEx; safecall;
    // DeAllocate Message Extend
    procedure DeAllocate(AMsgEx: TMsgEx); safecall;
  end;

implementation

uses
  MsgExImpl;

{ TMsgFactoryImpl }

constructor TMsgFactoryImpl.Create;
begin
  inherited;
  FMsgIncrId := 0;
  FMsgPool := TMsgPool.Create(DoCreateMsgEx);
end;

destructor TMsgFactoryImpl.Destroy;
begin
  FMsgPool.Free;
  inherited;
end;

procedure TMsgFactoryImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
end;

procedure TMsgFactoryImpl.UnInitialize;
begin
  FAppContext := nil;
end;

function TMsgFactoryImpl.CreateMsg(AProID: Integer; AMsgType: TMsgType; AMsgInfo: string): TMsgEx;
var
  LMsgExImpl: TMsgExImpl;
begin
  Result := nil;
  if AMsgType = mtNone then Exit;
  LMsgExImpl := TMsgExImpl(FMsgPool.Allocate);
  FMsgPool.Lock;
  try
    if LMsgExImpl <> nil then begin
      LMsgExImpl.Clear;
      LMsgExImpl.SetId(FMsgIncrId);
      LMsgExImpl.SetProId(AProID);
      LMsgExImpl.SetProTime(Now);
      LMsgExImpl.SetMsgType(AMsgType);
      LMsgExImpl.SetMsgInfo(AMsgInfo);
//    Result.SetOperateName();
      Result := LMsgExImpl;
    end;
    Inc(FMsgIncrId);
  finally
    FMsgPool.UnLock;
  end;
end;

procedure TMsgFactoryImpl.DeAllocate(AMsgEx: TMsgEx);
begin
  FMsgPool.DeAllocate(AMsgEx);
end;

function TMsgFactoryImpl.DoCreateMsgEx: TObject;
begin
  Result := TMsgExImpl.Create(FAppContext, Self as IMsgFactory);
end;

end.
