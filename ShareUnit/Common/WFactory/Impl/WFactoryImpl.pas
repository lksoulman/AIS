unit WFactoryImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Factory Interface implementation
// Author£º      lksoulman
// Date£º        2017-8-29
// Comments£º    A dynamic library has only one implementation factory,
//               A factory is a singleton.
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  WFactory,
  PlugInImpl,
  AppContext,
  CommonRefCounter,
  Generics.Collections;

type

  // Factory Interface implementation
  TWFactoryImpl = class(TAutoInterfacedObject, IWFactory)
  private
  protected
    type
      // Instancing mode for classes
      TInstanceType = (itSingleInstance,
                       itMultiInstance
                       );
      // Loading mode for classes
      TLoadModeType = (lmLazy,
                       lmInitialization
                       );
      // Plug-in information
      TWRegisterInfo = packed record
        FPlugInId: Integer;
        FInterface: IInterface;
        FInstanceType: TInstanceType;
        FLoadModeType: TLoadModeType;
        FPlugInImplClass: TPlugInImplClass;
      end;
      // Plug-in information pointer
      PWRegisterInfo = ^TWRegisterInfo;
  private
    // PlugIn Register Information List
    FPlugInRegisterInfos: TList<PWRegisterInfo>;
    // PlugIn Register Information  dictionary
    FPlugInRegisterInfoDic: TDictionary<Integer, PWRegisterInfo>;

     // Initialization PlugIn
    procedure DoInitializationPlugIns;
  protected
    // Application Context Interface
    FAppContext: IAppContext;

    // Initialize
    procedure DoInitialize;
    // Un Initialize
    procedure DoUnInitialize;
    // Register PlugIns
    procedure DoRegisterPlugIns; virtual;
    // UnRegister PlugIns
    procedure DoUnRegisterPlugIns; virtual;
    // Create interface
    function DoCreatePlugInByInfo(APWRegisterInfo: PWRegisterInfo): IInterface;
    // Register PlugIn
    procedure DoRegisterPlugIn(APlugInId: Integer; AInstanceType: TInstanceType; ALoadModeType: TLoadModeType; APlugInImplClass: TPlugInImplClass);
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;

    { IWFactory }

    // Initialize resources(only execute once)
    procedure Initialize(AContext: IInterface); virtual; safecall;
    // Releasing resources(only execute once)
    procedure UnInitialize; virtual; safecall;
    // Get Application Context
    function GetAppContext: IInterface; safecall;
    // Get PlugIn
    function GetPlugInById(APlugInId: Integer): IInterface; safecall;
    // Create interface
    function CreatePlugInById(APlugInId: Integer): IInterface; safecall;
  end;

implementation

uses
  PlugIn;

{ TWFactoryImpl }

constructor TWFactoryImpl.Create;
begin
  inherited;
  FPlugInRegisterInfos := TList<PWRegisterInfo>.Create;
  FPlugInRegisterInfoDic := TDictionary<Integer, PWRegisterInfo>.Create(15);
end;

destructor TWFactoryImpl.Destroy;
begin
  FPlugInRegisterInfoDic.Free;
  FPlugInRegisterInfos.Free;
  inherited;
end;

procedure TWFactoryImpl.Initialize(AContext: IInterface);
begin
  FAppContext := AContext as IAppContext;
  DoInitialize;
end;

procedure TWFactoryImpl.UnInitialize;
begin
  DoUnInitialize;
  FAppContext := nil;
end;

function TWFactoryImpl.GetAppContext: IInterface;
begin
  Result := FAppContext;
end;

function TWFactoryImpl.GetPlugInById(APlugInId: Integer): IInterface;
var
  LPWRegisterInfo: PWRegisterInfo;
begin
  if FPlugInRegisterInfoDic.TryGetValue(APlugInId, LPWRegisterInfo)
    and (LPWRegisterInfo <> nil) then begin
    Result := LPWRegisterInfo^.FInterface;
  end else begin
    Result := nil;
  end;
end;

function TWFactoryImpl.CreatePlugInById(APlugInId: Integer): IInterface;
var
  LPWRegisterInfo: PWRegisterInfo;
begin
  if FPlugInRegisterInfoDic.TryGetValue(APlugInId, LPWRegisterInfo)
    and (LPWRegisterInfo <> nil) then begin
    Result := DoCreatePlugInByInfo(LPWRegisterInfo);
  end else begin
    Result := nil;
  end;
end;

procedure TWFactoryImpl.DoInitialize;
begin
  DoRegisterPlugIns;
  DoInitializationPlugIns;
end;

procedure TWFactoryImpl.DoUnInitialize;
begin
  DoUnRegisterPlugIns;
end;

procedure TWFactoryImpl.DoRegisterPlugIns;
begin

end;

procedure TWFactoryImpl.DoUnRegisterPlugIns;
var
  LIndex: Integer;
  LPWRegisterInfo: PWRegisterInfo;
begin
  for LIndex := 0 to FPlugInRegisterInfos.Count - 1 do begin
    LPWRegisterInfo := FPlugInRegisterInfos.Items[LIndex];
    if (LPWRegisterInfo <> nil) then begin
      if LPWRegisterInfo^.FInterface <> nil then begin
        LPWRegisterInfo^.FInterface := nil;
      end;
      Dispose(LPWRegisterInfo);
    end;
  end;
  FPlugInRegisterInfos.Clear;
end;

procedure TWFactoryImpl.DoInitializationPlugIns;
var
  LIndex: Integer;
  LPWRegisterInfo: PWRegisterInfo;
begin
  for LIndex := 0 to FPlugInRegisterInfos.Count - 1 do begin
    LPWRegisterInfo := FPlugInRegisterInfos.Items[LIndex];
    if (LPWRegisterInfo <> nil) then begin
      if LPWRegisterInfo^.FLoadModeType = lmInitialization then begin
        DoCreatePlugInByInfo(LPWRegisterInfo);
      end;
    end;
  end;
end;

function TWFactoryImpl.DoCreatePlugInByInfo(APWRegisterInfo: PWRegisterInfo): IInterface;
begin
  case APWRegisterInfo^.FInstanceType of
    itSingleInstance:
      begin
        if APWRegisterInfo^.FInterface = nil then begin
          APWRegisterInfo^.FInterface := APWRegisterInfo^.FPlugInImplClass.Create as IInterface;
          (APWRegisterInfo^.FInterface as IPlugIn).Initialize(FAppContext);
        end;
        Result := APWRegisterInfo^.FInterface;
      end;
    itMultiInstance:
      begin
        Result := APWRegisterInfo^.FPlugInImplClass.Create as IInterface;
      end;
  end;
end;

procedure TWFactoryImpl.DoRegisterPlugIn(APlugInId: Integer; AInstanceType: TInstanceType; ALoadModeType: TLoadModeType; APlugInImplClass: TPlugInImplClass);
var
  LPWRegisterInfo: PWRegisterInfo;
begin
  if not FPlugInRegisterInfoDic.ContainsKey(APlugInId) then begin
    New(LPWRegisterInfo);
    LPWRegisterInfo^.FInterface := nil;
    LPWRegisterInfo^.FPlugInId := APlugInId;
    LPWRegisterInfo^.FInstanceType := AInstanceType;
    LPWRegisterInfo^.FLoadModeType := ALoadModeType;
    LPWRegisterInfo^.FPlugInImplClass := APlugInImplClass;
    FPlugInRegisterInfoDic.AddOrSetValue(APlugInId, LPWRegisterInfo);
    FPlugInRegisterInfos.Add(LPWRegisterInfo);
  end;
end;

end.
