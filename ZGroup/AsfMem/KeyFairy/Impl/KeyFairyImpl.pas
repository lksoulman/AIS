unit KeyFairyImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Key Fairy Interface implementation
// Author£º      lksoulman
// Date£º        2017-9-3
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  KeyFairy,
  KeyFairyType,
  KeyFairyItem,
  ExecutorThread,
  CommonDynArray,
  CommonRefCounter,
  Generics.Collections;

type

  // Key Fairy Interface implementation
  TKeyFairyImpl = class(TAutoInterfacedObject, IKeyFairy)
  private
    // Command Id
    FCommandId: Integer;
    // Item Capacity
    FItemCapacity: Integer;
    //
    FSearchMaxCount: Integer;
    // Key Fairy Type
    FKeyFairyType: TKeyFairyType;
    // Search Thread
    FSearchThread: TExecutorThread;
    // Search Key Char Type
    FSearchKeyCharType: TKeyCharType;
    // Key Fairy Items
    FKeyFairyItems: TDynArray<PKeyFairyItem>;
    // Search Key Fairy Items
    FSearchKeyFairyItems: TDynArray<PKeyFairyItem>;
    // Key Fairy Item Dictionary
    FKeyFairyItemDic: TDictionary<Integer, PKeyFairyItem>;
  protected
    // Search Key Fairy Items Sort
    function DoSearchKeyFairyItemsSort: Boolean;
    // Fuzzy Search Updating
    function DoFuzzySearchUpdating(AKey: string): Boolean;
    // Fuzzy Search No Updating
    function DoFuzzySearchNoUpdating(AKey: string): Boolean;
    // Search Filter
    function DoSearchFilter(AKey: string; APKeyFairyItem: PKeyFairyItem): Boolean;
    // Search Key Fairy Items To Param
    function DoCopySearchFairyItems(AKeyFairyItems: TDynArray<PKeyFairyItem>): Boolean;
  public
    // Constructor
    constructor Create(ASearchThread: TExecutorThread; AKeyFairyType: TKeyFairyType; AItemCapacity, ASearchMaxCount: Integer); reintroduce;
    // Destructor
    destructor Destroy; override;

    { IKeyFairy }

    // Get Command Id
    function GetCommandId: Integer; safecall;
    // Get Key Fairy Type
    function GetKeyFairyType: TKeyFairyType; safecall;
    // Get Key Fairy Type Item (Id is InnerCode, shortcut key Id)
    function GetKeyFairyItem(AId: Integer): PKeyFairyItem; safecall;
    // Add Key Fairy Item
    function AddKeyFairyItem(APKeyFairyItem: PKeyFairyItem): Boolean; safecall;
    // Set Search Key Char Type
    function SetSearchKeyCharType(AKeyCharType: TKeyCharType): Boolean; safecall;
    // Fuzzy Search Updating
    function FuzzySearchUpdating(AKey: string; AKeyFairyItems: TDynArray<PKeyFairyItem>): Boolean; safecall;
    // Fuzzy Search No Updating
    function FuzzySearchNoUpdating(AKey: string; AKeyFairyItems: TDynArray<PKeyFairyItem>): Boolean; safecall;
  end;

implementation

{ TKeyFairyImpl }

constructor TKeyFairyImpl.Create(ASearchThread: TExecutorThread; AKeyFairyType: TKeyFairyType; AItemCapacity, ASearchMaxCount: Integer);
begin
  inherited Create;
  if AItemCapacity > 0 then begin
    FItemCapacity := AItemCapacity;
  end else begin
    FItemCapacity := 0;
  end;
  FSearchMaxCount := ASearchMaxCount;
  FKeyFairyType := AKeyFairyType;
  FSearchThread := ASearchThread;
  FKeyFairyItems := TDynArray<PKeyFairyItem>.Create(FItemCapacity);
  FKeyFairyItemDic := TDictionary<Integer, PKeyFairyItem>.Create(FItemCapacity);

end;

destructor TKeyFairyImpl.Destroy;
begin
  FKeyFairyItemDic.Free;
  FKeyFairyItems.Free;
  inherited;
end;

function TKeyFairyImpl.GetCommandId: Integer;
begin
  Result := FCommandId;
end;

function TKeyFairyImpl.GetKeyFairyType: TKeyFairyType;
begin
  Result := FKeyFairyType;
end;

function TKeyFairyImpl.GetKeyFairyItem(AId: Integer): PKeyFairyItem;
begin
  if not (FKeyFairyItemDic.TryGetValue(AId, Result)
    and (Result <> nil)) then begin
    Result := nil;
  end;
end;

function TKeyFairyImpl.AddKeyFairyItem(APKeyFairyItem: PKeyFairyItem): Boolean;
begin
  FKeyFairyItems.Add(APKeyFairyItem);
  FKeyFairyItemDic.AddOrSetValue(APKeyFairyItem^.FId, APKeyFairyItem);
end;

function TKeyFairyImpl.SetSearchKeyCharType(AKeyCharType: TKeyCharType): Boolean;
begin
  FSearchKeyCharType := AKeyCharType;
end;

function TKeyFairyImpl.FuzzySearchUpdating(AKey: string; AKeyFairyItems: TDynArray<PKeyFairyItem>): Boolean;
begin
  Result := DoFuzzySearchUpdating(AKey);
//  Result := Result and DoSearchKeyFairyItemsSort;
  Result := Result and DoCopySearchFairyItems(AKeyFairyItems);
end;

function TKeyFairyImpl.FuzzySearchNoUpdating(AKey: string; AKeyFairyItems: TDynArray<PKeyFairyItem>): Boolean;
begin
  Result := DoFuzzySearchNoUpdating(AKey);
//  Result := Result and DoSearchKeyFairyItemsSort;
  Result := Result and  DoCopySearchFairyItems(AKeyFairyItems);
end;

function TKeyFairyImpl.DoFuzzySearchUpdating(AKey: string): Boolean;
var
  LIndex: Integer;
  LPKeyFairyItem: PKeyFairyItem;
begin
  Result := False;
  if FSearchThread.IsTerminated then Exit;

  for LIndex := 0 to FKeyFairyItems.GetCount - 1 do begin
    if FSearchKeyFairyItems.GetCount >= FSearchMaxCount then Exit;

    LPKeyFairyItem := FKeyFairyItems.GetElement(LIndex);
    if DoSearchFilter(AKey, LPKeyFairyItem) then begin
      FSearchKeyFairyItems.Add(LPKeyFairyItem);
    end;
  end;
  Result := True;
end;

function TKeyFairyImpl.DoFuzzySearchNoUpdating(AKey: string): Boolean;
var
  LIndex: Integer;
  LPKeyFairyItem: PKeyFairyItem;
begin
  Result := False;
  if FSearchThread.IsTerminated then Exit;

  for LIndex := 0 to FKeyFairyItems.GetCount - 1 do begin
    if FSearchKeyFairyItems.GetCount >= FSearchMaxCount then Exit;
    
    LPKeyFairyItem := FKeyFairyItems.GetElement(LIndex);
    if LPKeyFairyItem.FPSecuMainItem.FIsUsed and
       DoSearchFilter(AKey, LPKeyFairyItem) then begin
      FSearchKeyFairyItems.Add(LPKeyFairyItem);
    end;
  end;
  Result := True;
end;

function TKeyFairyImpl.DoSearchKeyFairyItemsSort: Boolean;
begin
  Result := False;
  if FSearchThread.IsTerminated then Exit;
  FSearchKeyFairyItems.QuickSort;
  Result := True;
end;

function TKeyFairyImpl.DoSearchFilter(AKey: string; APKeyFairyItem: PKeyFairyItem): Boolean;
begin
  Result := False;
  case self.FSearchKeyCharType of
    kcNomeric:
      begin
        if Pos(AKey, APKeyFairyItem.FPSecuMainItem.FSecuCode) >= 0 then begin
          Result := True;
        end;
      end;
    kcAlpha:
      begin
        if (Pos(AKey, APKeyFairyItem.FPSecuMainItem.FSecuAbbr) >= 0)
          or (Pos(AKey, APKeyFairyItem.FPSecuMainItem.FSecuCode) >= 0) then begin
          Result := True;
        end;
      end;
    kcChinese:
      begin
        if (Pos(AKey, APKeyFairyItem.FPSecuMainItem.FSecuAbbr) >= 0) then begin
          Result := True;
        end;
      end;
  end;
end;

function TKeyFairyImpl.DoCopySearchFairyItems(AKeyFairyItems: TDynArray<PKeyFairyItem>): Boolean;
var
  LIndex: Integer;
begin
  Result := False;
  if FSearchThread.IsTerminated then Exit;
  for LIndex := 0 to FSearchKeyFairyItems.GetCount - 1 do begin
    AKeyFairyItems.Add(FSearchKeyFairyItems.GetElement(LIndex));
  end;
  Result := True;
end;

end.
