unit LibaryInfo;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Store dynamic library load information
// Author£º      lksoulman
// Date£º        2017-8-16
// Comments£º    Store dynamic library load information.
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  WFactory,
  AppContext,
  CommonRefCounter,
  Generics.Collections;

type

  // Export Function
  TDllGetWFactoryFunc = function: IInterface; stdcall;

  TLibaryInfo = class(TAutoObject)
  private
    // Id
    FId: Integer;
    // Dynamic libary
    FName: string;
    // Is Exe
    FIsExe: Boolean;
    // Dynamic libary Module
    FHModule: HModule;
    // Dynamic libary ID
    FLibaryID: Integer;
    // Factory interface
    FWFactory: IWFactory;
    // Loaded count
    FLoadedCount: Integer;
    // Appliction context
    FAppContext: IAppContext;
    // Create Factory function name
    FCreateFactoryFuncName: string;
  protected
    // Load Dynamic libary
    procedure DoLoadLib;
    // UnLoad Dynamic libary
    procedure DoUnLoadLib;
    // Create interface by FuncName
    function DoCreateInterfaceByFuncName(AFuncName: string): IInterface;
  public
    // Constructor method
    constructor Create; override;
    // Destructor method
    destructor Destroy; override;
    // Create Factory
    procedure CreateFactory;
    // Initialize resources(only execute once)
    procedure Initialize(AContext: IAppContext);
    // Releasing resources(only execute once)
    procedure UnInitialize;


    property Id: Integer read FId write FId;
    property Name: string read FName write FName;
    property IsExe: Boolean read FIsExe write FIsExe;
    property HModule: HModule read FHModule write FHModule;
    property LibaryID: Integer read FLibaryID write FLibaryID;
    property WFactory: IWFactory read FWFactory;
  end;

  TLibaryInfoDynArray = Array Of TLibaryInfo;

implementation

uses
  LogLevel;

{ TLibaryInfo }

constructor TLibaryInfo.Create;
begin
  inherited;
  FId := 0;
  FIsExe := False;
  FHModule := 0;
  FLoadedCount := 0;
  FCreateFactoryFuncName := 'GetWFactory';
end;

destructor TLibaryInfo.Destroy;
begin
  DoUnLoadLib;
  inherited;
end;

procedure TLibaryInfo.CreateFactory;
begin
  DoLoadLib;
end;

procedure TLibaryInfo.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;

end;

procedure TLibaryInfo.UnInitialize;
begin

  FAppContext := nil;
end;

procedure TLibaryInfo.DoLoadLib;
begin
  if FIsExe then Exit;

  if (FHModule = 0)  then begin
    FHModule := LoadLibrary(PChar(FName));
  end;

  if (FHModule <> 0)
    and (FWFactory <> nil) then begin
    FWFactory := DoCreateInterfaceByFuncName(FCreateFactoryFuncName) as IWFactory;
  end;
end;

procedure TLibaryInfo.DoUnLoadLib;
begin
  if FWFactory <> nil then begin
    FWFactory := nil;
  end;
  if (not FIsExe) and (FHModule <> 0) then begin
    FreeLibrary(FHModule);
  end;
end;

function TLibaryInfo.DoCreateInterfaceByFuncName(AFuncName: string): IInterface;
var
  LGetWFactoryFunc: TDllGetWFactoryFunc;
begin
  Result := nil;
  LGetWFactoryFunc := GetProcAddress(FHModule, PChar(AFuncName));
  if LGetWFactoryFunc = nil then Exit;
  Result := LGetWFactoryFunc;
end;

end.
