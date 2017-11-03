unit AppStatusImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description： App Status Interface Implementation
// Author：      lksoulman
// Date：        2017-11-1
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  UserInfo,
  AppStatus,
  AppContext,
  CommonPool,
  CommonLock,
  CommonRefCounter,
  Generics.Collections;

type

  // App News Item
  TAppNewsItemPool = class(TPointerPool)
  private
  protected
    // Create
    function DoCreate: Pointer; override;
    // Destroy
    procedure DoDestroy(APointer: Pointer); override;
    // Allocate Before
    procedure DoAllocateBefore(APointer: Pointer); override;
    // DeAllocate Before
    procedure DoDeAllocateBefore(APointer: Pointer); override;
  public
  end;

  // App Status Interface Implementation
  TAppStatusImpl = class(TAutoInterfacedObject, IAppStatus)
  private
    // Lock
    FNewLock: TCSLock;
    // App Context
    FAppContext: IAppContext;
    // User Status Item
    FUserItem: TAppUserItem;
    // L Hq Status Items
    FLHqItems: TList<PAppHqItem>;
    // R Hq Status Items
    FRHqItems: TList<PAppHqItem>;
    // News Status Item
    FNewsItems: TList<PAppNewsItem>;
    // News Status Item Pool
    FNewsItemPool: TAppNewsItemPool;
    // App HqServer Status Item
    FNetworkItems: TList<PAppNetworkItem>;
  protected
    //
    procedure DoInitHqItems;
    //
    procedure DoInitUserItem;
    //
    procedure DoInitNetworkItems;
    // Clear Hq Items
    procedure DoClearHqItems(AItems: TList<PAppHqItem>);
    // Clear News Status Items
    procedure DoClearNewsItems(AItems: TList<PAppNewsItem>);
    // Clear Hq Server Status Items
    procedure DoClearNetworkItems(AItems: TList<PAppNetworkItem>);
    // Do Reset Hq Items
    procedure DoResetHqItems;
    // Do Reset Hq Status Item
    procedure DoResetHqItem(APAppHqItem: PAppHqItem);
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;

    { IAppStatus }

    // Init
    procedure Initialize(AContext: IAppContext);
    // Un Init
    procedure UnInitialize;
    // Lock
    procedure NewsLock;
    // Un Lock
    procedure NewsUnLock;
    // Get L Hq Status Item Count
    function GetLHqItemCount: Integer;
    // Get R Hq Status Item Count
    function GetRHqItemCount: Integer;
    // Get L Hq Status Item
    function GetLHqItem(AIndex: Integer): PAppHqItem;
    // Get R Hq Status Item
    function GetRHqItem(AIndex: Integer): PAppHqItem;
    // Get User Status Item
    function GetUserItem: PAppUserItem;
    // Get HqServer Status Item Count
    function GetNetworkItemCount: Integer;
    // Get HqServer Status Item
    function GetNetworkItem(AIndex: Integer): PAppNetworkItem;
  end;

implementation

{ TAppNewsItemPool }

function TAppNewsItemPool.DoCreate: Pointer;
begin
  New(Result);
end;

procedure TAppNewsItemPool.DoDestroy(APointer: Pointer);
begin
  if APointer = nil then Exit;

  Dispose(APointer);
end;

procedure TAppNewsItemPool.DoAllocateBefore(APointer: Pointer);
begin

end;

procedure TAppNewsItemPool.DoDeAllocateBefore(APointer: Pointer);
begin

end;

{ TAppStatusImpl }

constructor TAppStatusImpl.Create;
begin
  inherited;
  FNewLock := TCSLock.Create;
  FLHqItems := TList<PAppHqItem>.Create;
  FRHqItems := TList<PAppHqItem>.Create;
  FNewsItems := TList<PAppNewsItem>.Create;
  FNewsItemPool := TAppNewsItemPool.Create(20);
  FNetworkItems := TList<PAppNetworkItem>.Create;
  DoInitHqItems;
end;

destructor TAppStatusImpl.Destroy;
begin
  DoClearNetworkItems(FNetworkItems);
  DoClearHqItems(FLHqItems);
  DoClearHqItems(FRHqItems);
  FNetworkItems.Free;
  FNewsItemPool.Free;
  FNewsItems.Free;
  FLHqItems.Free;
  FRHqItems.Free;
  FNewLock.Free;
  inherited;
end;

procedure TAppStatusImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
end;

procedure TAppStatusImpl.UnInitialize;
begin
  FAppContext := nil;
end;

procedure TAppStatusImpl.NewsLock;
begin
  FNewLock.Lock;
end;

procedure TAppStatusImpl.NewsUnLock;
begin
  FNewLock.UnLock;
end;

function TAppStatusImpl.GetLHqItemCount: Integer;
begin
  Result := FLHqItems.Count;
end;

function TAppStatusImpl.GetRHqItemCount: Integer;
begin
  Result := FRHqItems.Count;
end;

function TAppStatusImpl.GetLHqItem(AIndex: Integer): PAppHqItem;
begin
  if (AIndex >= 0) and (AIndex < FLHqItems.Count) then begin
    Result := FLHqItems.Items[AIndex];
  end else begin
    Result := 0;
  end;
end;

function TAppStatusImpl.GetRHqItem(AIndex: Integer): PAppHqItem;
begin
  if (AIndex >= 0) and (AIndex < FRHqItems.Count) then begin
    Result := FRHqItems.Items[AIndex];
  end else begin
    Result := 0;
  end;
end;

function TAppStatusImpl.GetUserItem: PAppUserItem;
begin
  Result := @FUserItem;
end;

function TAppStatusImpl.GetNetworkItemCount: Integer;
begin
  Result := FNetworkItems.Count;
end;

function TAppStatusImpl.GetNetworkItem(AIndex: Integer): PAppNetworkItem;
begin
  if (AIndex >= 0) and (AIndex < FNetworkItems.Count) then begin
    Result := FNetworkItems.Items[AIndex];
  end else begin
    Result := nil;
  end;
end;

procedure TAppStatusImpl.DoInitHqItems;
var
  LPAppHqItem: PAppHqItem;
begin
  New(LPAppHqItem);
  LPAppHqItem^.FInnerCode := 0;
  LPAppHqItem^.FSecuAbbr := '上证';
  LPAppHqItem^.FSecuInfo := '';
  LPAppHqItem^.FSecuInfo := '';
  LPAppHqItem^.FNowPrice := 0;
  LPAppHqItem^.FPreClose := 0;
  LPAppHqItem^.FTurnover := 0;
  FLHqItems.Add(LPAppHqItem);

  New(LPAppHqItem);
  LPAppHqItem^.FInnerCode := 0;
  LPAppHqItem^.FSecuAbbr := '创业板';
  LPAppHqItem^.FSecuInfo := '';
  LPAppHqItem^.FSecuInfo := '';
  LPAppHqItem^.FNowPrice := 0;
  LPAppHqItem^.FPreClose := 0;
  LPAppHqItem^.FTurnover := 0;
  FLHqItems.Add(LPAppHqItem);

  New(LPAppHqItem);
  LPAppHqItem^.FInnerCode := 0;
  LPAppHqItem^.FSecuAbbr := '恒指';
  LPAppHqItem^.FSecuInfo := '';
  LPAppHqItem^.FSecuInfo := '';
  LPAppHqItem^.FNowPrice := 0;
  LPAppHqItem^.FPreClose := 0;
  LPAppHqItem^.FTurnover := 0;
  FLHqItems.Add(LPAppHqItem);

  New(LPAppHqItem);
  LPAppHqItem^.FInnerCode := 0;
  LPAppHqItem^.FSecuAbbr := '深证';
  LPAppHqItem^.FSecuInfo := '';
  LPAppHqItem^.FSecuInfo := '';
  LPAppHqItem^.FNowPrice := 0;
  LPAppHqItem^.FPreClose := 0;
  LPAppHqItem^.FTurnover := 0;
  FRHqItems.Add(LPAppHqItem);

  New(LPAppHqItem);
  LPAppHqItem^.FInnerCode := 0;
  LPAppHqItem^.FSecuAbbr := '中小板';
  LPAppHqItem^.FSecuInfo := '';
  LPAppHqItem^.FSecuInfo := '';
  LPAppHqItem^.FNowPrice := 0;
  LPAppHqItem^.FPreClose := 0;
  LPAppHqItem^.FTurnover := 0;
  FRHqItems.Add(LPAppHqItem);

  New(LPAppHqItem);
  LPAppHqItem^.FInnerCode := 0;
  LPAppHqItem^.FSecuAbbr := '沪深300';
  LPAppHqItem^.FSecuInfo := '';
  LPAppHqItem^.FSecuInfo := '';
  LPAppHqItem^.FNowPrice := 0;
  LPAppHqItem^.FPreClose := 0;
  LPAppHqItem^.FTurnover := 0;
  FRHqItems.Add(LPAppHqItem);
end;

procedure TAppStatusImpl.DoInitUserItem;
begin
  case FAppContext.GetCfg.GetSysCfg.GetUserInfo.GetAccountType of
    atUFX:
      begin
        FUserItem.FUserName := FAppContext.GetCfg.GetSysCfg.GetUserInfo.GetUFXAccountInfo.FUserName;
      end;
    atGIL:
      begin
        FUserItem.FUserName := FAppContext.GetCfg.GetSysCfg.GetUserInfo.GetGilAccountInfo.FUserName;
      end;
    atPBOX:
      begin
        FUserItem.FUserName := FAppContext.GetCfg.GetSysCfg.GetUserInfo.GetPBoxAccountInfo.FUserName;
      end;
  end;
end;

procedure TAppStatusImpl.DoInitNetworkItems;
begin

end;

procedure TAppStatusImpl.DoClearHqItems(AItems: TList<PAppHqItem>);
var
  LIndex: Integer;
  LPAppHqItem: PAppHqItem;
begin
  for LIndex := 0 to AItems.Count - 1 do begin
    LPAppHqItem := AItems.Items[LIndex];
    if LPAppHqItem <> nil then begin
      Dispose(LPAppHqItem);
    end;
  end;
  AItems.Clear;
end;

procedure TAppStatusImpl.DoClearNewsItems(AItems: TList<PAppNewsItem>);
var
  LIndex: Integer;
  LPAppNewsItem: PAppNewsItem;
begin
  for LIndex := 0 to AItems.Count - 1 do begin
    LPAppNewsItem := AItems.Items[LIndex];
    if LPAppNewsItem <> nil then begin
      FNewsItemPool.DeAllocate(LPAppNewsItem);
    end;
  end;
  AItems.Clear;
end;

procedure TAppStatusImpl.DoClearNetworkItems(AItems: TList<PAppNetworkItem>);
var
  LIndex: Integer;
  LPAppNetworkItem: PAppNetworkItem;
begin
  for LIndex := 0 to AItems.Count - 1 do begin
    LPAppNetworkItem := AItems.Items[LIndex];
    if LPAppNetworkItem <> nil then begin
      Dispose(LPAppNetworkItem);
    end;
  end;
  AItems.Clear;
end;

procedure TAppStatusImpl.DoResetHqItems;
var
  LIndex: Integer;
  LPAppHqItem: PAppHqItem;
begin
  for LIndex := 0 to FLHqItems.Count - 1 do begin
    LPAppHqItem := FLHqItems.Items[LIndex];
    DoResetHqItem(LPAppHqItem);
  end;

  for LIndex := 0 to FRHqItems.Count - 1 do begin
    LPAppHqItem := FRHqItems.Items[LIndex];
    DoResetHqItem(LPAppHqItem);
  end;
end;

procedure TAppStatusImpl.DoResetHqItem(APAppHqItem: PAppHqItem);
begin
  APAppHqItem^.FNowPrice := 0;
  APAppHqItem^.FPreClose := 0;
  APAppHqItem^.FTurnover := 0;
end;

end.
