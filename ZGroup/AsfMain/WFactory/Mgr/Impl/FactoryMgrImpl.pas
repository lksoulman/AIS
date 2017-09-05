unit FactoryMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º
// Author£º      lksoulman
// Date£º        2017-8-29
// Comments£º    Factory class management interface implementation of
//               multiple dynamic libraries.
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  WFactory,
  CommonLock,
  FactoryMgr,
  AppContext,
  DynamicLib,
  PlugInConst,

  CommonRefCounter,
  Generics.Collections;

type

  TGuidDynLibary = packed record
    FName: string;
    FGuid: string;
  end;

  TGuidDynLibaryDynArray = Array Of TGuidDynLibary;

  // Factory class management interface implementation of multiple dynamic libraries
  TFactoryMgrImpl = class(TAutoInterfacedObject, IFactoryMgr)
  private
    // Thread Lock
    FLock: TCSLock;
    // Application Context Interface
    FAppContext: IAppContext;
    // AIS.exe
    FAsfMainLib: TDynamicLib;
    // Dynamic Libary Count
    FDynamicLibCount: Integer;
    // Dynamic Libary Array
    FDynamicLibs: TDynamicLibDynArray;

    // Add Dynamic Libary to Array
    procedure AddDynamicLib(ADynamicLib: TDynamicLib);
    //
    function GetDynamicLib(AId: Integer): TDynamicLib;
    // Add DynamicLib
    function NewDynamicLib(AId: Integer; AName: string; AIsExe: Boolean): TDynamicLib;
  protected
    // UnInit Dynamic libary
    procedure DoInitDynamicLibs;
    // UnInit Dynamic libary
    procedure DoUnInitDynamicLibs;
  public
    // constructor method
    constructor Create; override;
    // destructor method
    destructor Destroy; override;

    { IFactoryMgr }

    // Initialize resources(only execute once)
    procedure Initialize(AContext: IInterface); safecall;
    // Releasing resources(only execute once)
    procedure UnInitialize; safecall;
    // Create interface
    function CreatePlugInById(APlugInId: Integer): IInterface; safecall;
  end;

implementation

uses
  Forms,
  Config,
  LoginMgr,
  CipherMgr,
  FastLogMgr,
  ServiceBase,
  ServiceAsset,
  FactoryAsfMainImpl;

{ TFactoryMgrImpl }

constructor TFactoryMgrImpl.Create;
begin
  inherited;
  FDynamicLibCount := 0;
  FLock := TCSLock.Create;
end;

destructor TFactoryMgrImpl.Destroy;
begin
  FLock.Free;
  inherited;
end;

procedure TFactoryMgrImpl.Initialize(AContext: IInterface);
begin
  FAppContext := AContext as IAppContext;
  DoInitDynamicLibs;
end;

procedure TFactoryMgrImpl.UnInitialize;
begin
  DoUnInitDynamicLibs;
  FAppContext := nil;
end;

function TFactoryMgrImpl.CreatePlugInById(APlugInId: Integer): IInterface;
var
  LDynamicLib: TDynamicLib;
begin
  Result := nil;
  FLock.Lock;
  try
    LDynamicLib := GetDynamicLib((APlugInId div 1000000) - 1);
    if LDynamicLib <> nil then begin
      if LDynamicLib.WFactory = nil then begin
        LDynamicLib.CreateFactory;
        LDynamicLib.Initialize(FAppContext);
      end;
      if LDynamicLib.WFactory <> nil then begin
        Result := LDynamicLib.WFactory.CreatePlugInById(APlugInId);
      end;
    end;
  finally
    FLock.UnLock;
  end;
end;

procedure TFactoryMgrImpl.DoInitDynamicLibs;
var
  LExeName: string;
  LDynamicLib: TDynamicLib;
begin
  LExeName := Application.ExeName;
  LExeName := ExtractFileName(LExeName);
  FAsfMainLib := NewDynamicLib(DYN_LIB_ID_AIS, LExeName, True);
  AddDynamicLib(FAsfMainLib);
  LDynamicLib := NewDynamicLib(DYN_LIB_ID_ASFSDK, DYN_LIB_ASFSDK, False);
  AddDynamicLib(LDynamicLib);
  LDynamicLib := NewDynamicLib(DYN_LIB_ID_ASFAUTH, DYN_LIB_ASFAUTH, False);
  AddDynamicLib(LDynamicLib);
  LDynamicLib := NewDynamicLib(DYN_LIB_ID_ASFCACHE, DYN_LIB_ASFCACHE, False);
  AddDynamicLib(LDynamicLib);
  LDynamicLib := NewDynamicLib(DYN_LIB_ID_ASFHQCORE, DYN_LIB_ASFHQCORE, False);
  AddDynamicLib(LDynamicLib);
  LDynamicLib := NewDynamicLib(DYN_LIB_ID_ASFMSG, DYN_LIB_ASFMSG, False);
  AddDynamicLib(LDynamicLib);
end;

procedure TFactoryMgrImpl.DoUnInitDynamicLibs;
begin
 

end;

procedure TFactoryMgrImpl.AddDynamicLib(ADynamicLib: TDynamicLib);
begin
  SetLength(FDynamicLibs, FDynamicLibCount + 1);
  FDynamicLibs[FDynamicLibCount] := ADynamicLib;
  Inc(FDynamicLibCount);
end;

function TFactoryMgrImpl.GetDynamicLib(AId: Integer): TDynamicLib;
begin
  if (AId >= 0)
    and (AId < FDynamicLibCount) then begin
    Result := FDynamicLibs[AId];
  end else begin
    Result := nil;
  end;
end;

function TFactoryMgrImpl.NewDynamicLib(AId: Integer; AName: string; AIsExe: Boolean): TDynamicLib;
begin
  Result := TDynamicLib.Create;
  Result.Id := AId;
  Result.Name := AName;
  Result.IsExe := AIsExe;
end;

end.
