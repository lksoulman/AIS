unit AssetServiceImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Asset Service Interface implementation
// Author£º      lksoulman
// Date£º        2017-9-13
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Proxy,
  GFData,
  Windows,
  Classes,
  SysUtils,
  AssetService,
  AbstractServiceImpl;

type

  // Asset Service Interface implementation
  TAssetServiceImpl = class(TAbstractServiceImpl, IAssetService)
  private
  protected
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;

    { IAssetService }

    // Is Logined
    function IsLogined: Boolean; safecall;
    // Get SessionId
    function GetSessionId: WideString; safecall;
    // UFX Login
    function UFXLogin(APUFXLogin: PUFXLogin): Boolean; safecall;
    // GIL Login
    function GILLogin(APGILLogin: PGILLogin): Boolean; safecall;
    // PBOX Login
    function PBOXLogin(APPBOXLogin: PPBOXLogin): Boolean; safecall;
    // Set Re Login Event
    function SetReLoginEvent(AReLoginEvent: TReLoginEvent): Boolean; safecall;
    // Synchronous POST
    function SyncPost(AIndicator: WideString; AWaitTime: DWORD): IGFData; safecall;
    // Asynchronous POST
    function AsyncPOST(AIndicator: WideString; AEvent: TGFDataEvent; AKey: Int64): IGFData; safecall;
    // Priority Synchronous POST
    function PrioritySyncPost(AIndicator: WideString; AWaitTime: DWORD): IGFData; safecall;
    // Priority Asynchronous POST
    function PriorityAsyncPOST(AIndicator: WideString; AEvent: TGFDataEvent; AKey: Int64): IGFData; safecall;
  end;

implementation

uses
  DB,
  ErrorCode,
  GFDataSet;

{ TAssetServiceImpl }

constructor TAssetServiceImpl.Create;
begin
  inherited;
  FExecutorCount := 1;
  FPriorityExecutorCount := 1;
end;

destructor TAssetServiceImpl.Destroy;
begin

  inherited Destroy;
end;

function TAssetServiceImpl.IsLogined: Boolean;
begin
  Result := FShareMgr.GetIsLogined;
end;

function TAssetServiceImpl.GetSessionId: WideString;
begin
  Result := FShareMgr.GetSessionId;
end;

function TAssetServiceImpl.UFXLogin(APUFXLogin: PUFXLogin): Boolean;
var
  LField: TField;
  LGFData: IGFData;
  LGFDataSet: TGFDataSet;
  LIndicator, LAssetUserId: string;
begin
  Result := False;
  if APUFXLogin = nil then Exit;

  FShareMgr.SetUrl(APUFXLogin^.FServerUrl);
  FShareMgr.SetHardDiskIdMD5(APUFXLogin^.FHardDiskIdMD5);
  LAssetUserId := APUFXLogin^.FUserName + '@' + APUFXLogin^.FOrgNo + '@' + APUFXLogin^.FAssetNo;
  LIndicator := Format('UFX_USER_LOGIN_NEW("%s", "%s", "pc", "%s", "%s", "%s", "", "")',
                  [LAssetUserId,
                   APUFXLogin^.FCipherPassword,
                   APUFXLogin^.FHardDiskIdMD5,
                   APUFXLogin^.FMacAddress,
                   APUFXLogin^.FHardDiskId]);
  LGFData := DoPrioritySyncPost(LIndicator, 300000);
  try
    if LGFData.GetErrorCode = ErrorCode_Success then begin
      LGFDataSet := TGFDataSet.Create(LGFData);
      try
        LGFDataSet.First;
        LField := LGFDataSet.FieldByName('sid');
        if LField <> nil then begin
          FLastHeartBeatTick := GetTickCount;
          FShareMgr.SetSessionId(LField.AsString);
          FShareMgr.SetIsLogined(True);
          Result := True;
        end else begin
          FShareMgr.SetIsLogined(False);
        end;
      finally
        LGFDataSet.Free;
      end;
    end else begin
      FShareMgr.SetIsLogined(False);
      APUFXLogin^.FErrorCode := LGFData.GetErrorCode;
      APUFXLogin^.FErrorInfo := FAppContext.GetErrorInfo(LGFData.GetErrorCode);
    end;
  finally
    LGFData := nil;
  end;
end;

function TAssetServiceImpl.GILLogin(APGILLogin: PGILLogin): Boolean;
var
  LGFData: IGFData;
  LIndicator: string;
  LGFDataSet: TGFDataSet;
  LSidField, LUserNameField, LErrorInfoField: TField;
begin
  Result := False;
  if APGILLogin = nil then Exit;

  FShareMgr.SetUrl(APGILLogin^.FServerUrl);
  FShareMgr.SetHardDiskIdMD5(APGILLogin^.FHardDiskIdMD5);
  LIndicator := Format('JY_USER_LOGIN_NEW("%s", "%s", "pc", "%s", "%s", "%s")',
                [APGILLogin^.FGilUserName,
                 APGILLogin^.FCipherPassword,
                 APGILLogin^.FHardDiskIdMD5,
                 APGILLogin^.FOrgNo,
                 APGILLogin^.FAssetNo]);
  LGFData := DoPrioritySyncPost(LIndicator, 300000);
  try
    if LGFData.GetErrorCode = ErrorCode_Success then begin
      LGFDataSet := TGFDataSet.Create(LGFData);
      try
        LGFDataSet.First;
        LSidField := LGFDataSet.FieldByName('sid');
        LUserNameField := LGFDataSet.FieldByName('operatorCode');
        LErrorInfoField := LGFDataSet.FieldByName('pwdInfo');
        if (LSidField <> nil)
          and (LUserNameField <> nil)
          and (LErrorInfoField <> nil) then begin
          FLastHeartBeatTick := GetTickCount;
          FShareMgr.SetSessionId(LSidField.AsString);
          FShareMgr.SetIsLogined(True);
          APGILLogin^.FUserName := LUserNameField.AsString;
          APGILLogin^.FErrorInfo := LErrorInfoField.AsString;
          Result := True;
        end else begin
          FShareMgr.SetIsLogined(False);
        end;
      finally
        LGFDataSet.Free;
      end;
    end else begin
      FShareMgr.SetIsLogined(False);
      APGILLogin^.FErrorCode := LGFData.GetErrorCode;
      APGILLogin^.FErrorInfo := FAppContext.GetErrorInfo(LGFData.GetErrorCode);
    end;
  finally
    LGFData := nil;
  end;
end;

function TAssetServiceImpl.PBOXLogin(APPBOXLogin: PPBOXLogin): Boolean;
var
  LField: TField;
  LGFData: IGFData;
  LGFDataSet: TGFDataSet;
  LIndicator, LAssetUserId: string;
begin
  Result := False;
  if APPBOXLogin = nil then Exit;

  FShareMgr.SetUrl(APPBOXLogin^.FServerUrl);
  FShareMgr.SetHardDiskIdMD5(APPBOXLogin^.FHardDiskIdMD5);
  LAssetUserId := APPBOXLogin^.FUserName + '@' + APPBOXLogin^.FOrgNo + '@' + APPBOXLogin^.FAssetNo;
  LIndicator := Format('UFX_USER_LOGIN_NEW("%s", "%s", "pc", "%s", "%s", "%s", "", "")',
                  [LAssetUserId,
                   APPBOXLogin^.FCipherPassword,
                   APPBOXLogin^.FHardDiskIdMD5,
                   APPBOXLogin^.FMacAddress,
                   APPBOXLogin^.FHardDiskId]);
  LGFData := DoPrioritySyncPost(LIndicator, 300000);
  try
    if LGFData.GetErrorCode = ErrorCode_Success then begin
      LGFDataSet := TGFDataSet.Create(LGFData);
      try
        LGFDataSet.First;
        LField := LGFDataSet.FieldByName('sid');
        if LField <> nil then begin
          FLastHeartBeatTick := GetTickCount;
          FShareMgr.SetSessionId(LField.AsString);
          FShareMgr.SetIsLogined(True);
          Result := True;
        end else begin
          FShareMgr.SetIsLogined(False);
        end;
      finally
        LGFDataSet.Free;
      end;
    end else begin
      FShareMgr.SetIsLogined(False);
      APPBOXLogin^.FErrorCode := LGFData.GetErrorCode;
      APPBOXLogin^.FErrorInfo := FAppContext.GetErrorInfo(LGFData.GetErrorCode);
    end;
  finally
    LGFData := nil;
  end;
end;

function TAssetServiceImpl.SetReLoginEvent(AReLoginEvent: TReLoginEvent): Boolean;
begin
  FShareMgr.SetReLoginEvent(AReLoginEvent);
end;

function TAssetServiceImpl.SyncPost(AIndicator: WideString; AWaitTime: DWORD): IGFData;
begin
  if FShareMgr.GetIsLogined then begin
    Result := DoSyncPost(AIndicator, AWaitTime);
  end else begin
    Result := DoCreateGFData;
    DoNoLoginDefaultPost(Result);
  end;
end;

function TAssetServiceImpl.AsyncPost(AIndicator: WideString; AEvent: TGFDataEvent; AKey: Int64): IGFData;
begin
  if FShareMgr.GetIsLogined then begin
    Result := DoAsyncPost(AIndicator, AEvent, AKey);
  end else begin
    Result := DoCreateGFData;
    DoNoLoginDefaultPost(Result);
  end;
end;

function TAssetServiceImpl.PrioritySyncPost(AIndicator: WideString; AWaitTime: DWORD): IGFData;
begin
  if FShareMgr.GetIsLogined then begin
    Result := DoPrioritySyncPost(AIndicator, AWaitTime);
  end else begin
    Result := DoCreateGFData;
    DoNoLoginDefaultPost(Result);
  end;
end;

function TAssetServiceImpl.PriorityAsyncPOST(AIndicator: WideString; AEvent: TGFDataEvent; AKey: Int64): IGFData;
begin
  if FShareMgr.GetIsLogined then begin
    Result := DoPriorityAsyncPOST(AIndicator, AEvent, AKey);
  end else begin
    Result := DoCreateGFData;
    DoNoLoginDefaultPost(Result);
  end;
end;

end.
