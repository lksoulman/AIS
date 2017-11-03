unit FactoryMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Factory Manager Interface Implementation
// Author£º      lksoulman
// Date£º        2017-8-29
// Comments£º    Factory class management interface implementation of
//               multiple dynamic libraries.
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  PlugIn,
  Windows,
  Classes,
  SysUtils,
  WFactory,
  CommonLock,
  FactoryMgr,
  AppContext,
  LibaryInfo,
  PlugInConst,
  CommonQueue,
  CommonRefCounter,
  Generics.Collections;

type

  // Factory Manager Interface Implementation
  TFactoryMgrImpl = class(TAutoInterfacedObject, IFactoryMgr)
  private
    // Lock
    FLock: TCSLock;
    // Application Context
    FAppContext: IAppContext;
    // PlugIn
    FPlugIns: TList<IPlugIn>;
    // Libary Info Array
    FLibaryInfos: TList<TLibaryInfo>;


    // Get Libary Info
    function GetLibaryInfo(AId: Integer): TLibaryInfo;
    // Add Libary Info
    function AddLibaryInfo(AId: Integer; AName: string; AIsExe: Boolean): TLibaryInfo;
  protected
    // Clear PlugIn
    procedure DoClearPlugIns;
    // Init Libary Infos
    procedure DoInitLibaryInfos;
    // UnInit Libary Infos
    procedure DoUnInitLibaryInfos;
  public
    // Constructor
    constructor Create; override;
    // Destructor
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
//  GDIPOBJ,
  FactoryAsfMainImpl;

{ TFactoryMgrImpl }

constructor TFactoryMgrImpl.Create;
begin
  inherited;
  FLock := TCSLock.Create;
  FPlugIns := TList<IPlugIn>.Create;
  FLibaryInfos := TList<TLibaryInfo>.Create;
end;

destructor TFactoryMgrImpl.Destroy;
begin
  FLibaryInfos.Free;
  FPlugIns.Free;
  FLock.Free;
  inherited;
end;

procedure TFactoryMgrImpl.Initialize(AContext: IInterface);
begin
  FAppContext := AContext as IAppContext;
  DoInitLibaryInfos;
end;

procedure TFactoryMgrImpl.UnInitialize;
begin
  DoClearPlugIns;
  DoUnInitLibaryInfos;
  FAppContext := nil;
end;

function TFactoryMgrImpl.CreatePlugInById(APlugInId: Integer): IInterface;
var
  LPlugIn: IPlugIn;
  LLibaryInfo: TLibaryInfo;
begin
  Result := nil;
  FLock.Lock;
  try
    LLibaryInfo := GetLibaryInfo(APlugInId);
    if LLibaryInfo <> nil then begin
      if LLibaryInfo.WFactory = nil then begin
        LLibaryInfo.CreateFactory;
      end;
      if LLibaryInfo.WFactory <> nil then begin
        Result := LLibaryInfo.WFactory.CreatePlugInById(APlugInId);
        if Result <> nil then begin
          LPlugIn := Result as IPlugIn;
          if FPlugIns.IndexOf(LPlugIn) < 0 then begin
            FPlugIns.Add(LPlugIn);
          end;
          LPlugIn.SyncBlockExecute;
        end;
      end;
    end;
  finally
    FLock.UnLock;
  end;
end;

procedure TFactoryMgrImpl.DoClearPlugIns;
var
  LIndex: Integer;
  LPlugIn: IPlugIn;
begin
  for LIndex := FPlugIns.Count - 1 downto 0 do begin
     LPlugIn := FPlugIns.Items[LIndex];
    if LPlugIn <> nil then begin
      LPlugIn.UnInitialize;
      LPlugIn := nil;
    end;
  end;
  FPlugIns.Clear;
//  while not FPlugIns.IsEmpty do begin
//    LPlugIn := FPlugIns.Dequeue;
//    if LPlugIn <> nil then begin
//      LPlugIn.UnInitialize;
//      LPlugIn := nil;
//    end;
//  end;
end;

procedure TFactoryMgrImpl.DoInitLibaryInfos;
var
  LExeName: string;
  LLibaryInfo: TLibaryInfo;
begin
  LExeName := Application.ExeName;
  LExeName := ExtractFileName(LExeName);
  LLibaryInfo := AddLibaryInfo(LIB_ID_ASFMAIN, LExeName, True);
  LLibaryInfo.Initialize(FAppContext);
  LLibaryInfo.WFactory := G_WFactory as IWFactory;
  LLibaryInfo.WFactory.Initialize(FAppContext);

  LLibaryInfo := AddLibaryInfo(LIB_ID_ASFSERVICE, LIB_ASFSERVICE, False);
  LLibaryInfo.Initialize(FAppContext);

  LLibaryInfo := AddLibaryInfo(LIB_ID_ASFTOOL, LIB_ASFTOOL, False);
  LLibaryInfo.Initialize(FAppContext);

  LLibaryInfo := AddLibaryInfo(LIB_ID_ASFAUTH, LIB_ASFAUTH, False);
  LLibaryInfo.Initialize(FAppContext);

  LLibaryInfo := AddLibaryInfo(LIB_ID_ASFCACHE, LIB_ASFCACHE, False);
  LLibaryInfo.Initialize(FAppContext);

  LLibaryInfo := AddLibaryInfo(LIB_ID_ASFMEM, LIB_ASFMEM, False);
  LLibaryInfo.Initialize(FAppContext);

  LLibaryInfo := AddLibaryInfo(LIB_ID_ASFAUI, LIB_ASFAUI, False);
  LLibaryInfo.Initialize(FAppContext);
end;

procedure TFactoryMgrImpl.DoUnInitLibaryInfos;
var
  LIndex: Integer;
  LLibaryInfo: TLibaryInfo;
begin
  for LIndex := FLibaryInfos.Count - 1 downto 0 do begin
    LLibaryInfo := FLibaryInfos.Items[LIndex];
    LLibaryInfo.UnInitialize;
    LLibaryInfo.Free;
  end;
  FLibaryInfos.Clear;
end;

function TFactoryMgrImpl.GetLibaryInfo(AId: Integer): TLibaryInfo;
var
  LIndex: Integer;
//  LGraph: TGPGraphics;
begin
  LIndex := AId div 1000000 - 1;
  if (LIndex >= 0)
    and (LIndex < FLibaryInfos.Count) then begin
    Result := FLibaryInfos.Items[LIndex];
  end else begin
    Result := nil;
  end;
end;

function TFactoryMgrImpl.AddLibaryInfo(AId: Integer; AName: string; AIsExe: Boolean): TLibaryInfo;
begin
  Result := TLibaryInfo.Create;
  Result.Id := AId;
  Result.Name := AName;
  Result.IsExe := AIsExe;
  FLibaryInfos.Add(Result);
end;

end.
