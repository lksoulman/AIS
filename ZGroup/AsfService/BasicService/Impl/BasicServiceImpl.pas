unit BasicServiceImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Basic Service Interface implementation
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
  GFDataUpdate,
  BasicService,
  AbstractServiceImpl;

type

  // Basic Service Interface
  TBasicServiceImpl = class(TAbstractServiceImpl, IBasicService)
  private
  protected
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;

    { IBasicService }

    // Is Logined
    function IsLogined: Boolean; safecall;
    // Get SessionId
    function GetSessionId: WideString; safecall;
    // Gil Bind
    function GilBind(APBasicBind: PGilBasicBind): Boolean; safecall;
    // Gil Login
    function GilLogin(APBasicLogin: PGilBasicLogin): Boolean; safecall;
    // Set Re Login Event
    function SetReLoginEvent(AReLoginEvent: TReLoginEvent): Boolean; safecall;
    // Gil Password Set
    function GilPasswordSet(APBasicPasswordSet: PGilBasicPasswordSet): Boolean; safecall;
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

{ TBasicServiceImpl }

constructor TBasicServiceImpl.Create;
begin
  inherited;
  FExecutorCount := 4;
  FPriorityExecutorCount := 1;
end;

destructor TBasicServiceImpl.Destroy;
begin

  inherited;
end;

function TBasicServiceImpl.IsLogined: Boolean;
begin
  Result := FShareMgr.GetIsLogined;
end;

function TBasicServiceImpl.GetSessionId: WideString;
begin
  Result := FShareMgr.GetSessionId;
end;

function TBasicServiceImpl.GilBind(APBasicBind: PGilBasicBind): Boolean;
var
  LGFData: IGFData;
  LGFDataSet: TGFDataSet;
  LIndicator, LAssetUserId: string;
  LLicenseField, LOrgSignField: TField;
begin
  Result := False;
  if APBasicBind = nil then Exit;

  FShareMgr.SetUrl(APBasicBind^.FServerUrl);
  FShareMgr.SetHardDiskIdMD5(APBasicBind^.FHardDiskIdMD5);
  LAssetUserId := APBasicBind^.FUserName + '@' + APBasicBind^.FOrgNo + '@' + APBasicBind^.FAssetNo;
  LIndicator := Format('HS_USER_BIND("%s", "%s",  "pc", "%s")',
                  [APBasicBind^.FGilUserName,
                   LAssetUserId,
                   APBasicBind^.FHardDiskIdMD5]);
  LGFData := DoPrioritySyncPost(LIndicator, 300000);
  try
    if LGFData.GetErrorCode = ErrorCode_Success then begin
      LGFDataSet := TGFDataSet.Create(LGFData);
      try
        LGFDataSet.First;
        LLicenseField := LGFDataSet.Fields[1];
        LOrgSignField := LGFDataSet.Fields[2];
        if (LLicenseField <> nil)
          and (LOrgSignField <> nil) then begin
          APBasicBind^.FLicense := LLicenseField.AsString;
          APBasicBind^.FOrgSign := LOrgSignField.AsString;
          Result := True;
        end else begin
          APBasicBind^.FErrorCode := ErrorCode_Service_Indicator_Return_Result_Except;
          APBasicBind^.FErrorInfo := LIndicator;
        end;
      finally
        LGFDataSet.Free;
      end;
    end else begin
      APBasicBind^.FErrorCode := LGFData.GetErrorCode;
      APBasicBind^.FErrorInfo := LGFData.GetErrorInfo;
    end;
  finally
    LGFData := nil;
  end;
end;

function TBasicServiceImpl.GilLogin(APBasicLogin: PGilBasicLogin): Boolean;
var
  LField: TField;
  LGFData: IGFData;
  LGFDataSet: TGFDataSet;
  LIndicator, LAssetUserId: string;
begin
  Result := False;
  if APBasicLogin = nil then Exit;

  FShareMgr.SetUrl(APBasicLogin^.FServerUrl);
  FShareMgr.SetHardDiskIdMD5(APBasicLogin^.FHardDiskIdMD5);
  LAssetUserId :=  APBasicLogin^.FUserName + '@' + APBasicLogin^.FOrgNo + '@' + APBasicLogin^.FAssetNo;
  LIndicator := Format('HS_USER_LOGIN("%s", "%s", "pc", "%s")',
                  [APBasicLogin^.FLicense,
                   LAssetUserId,
                   APBasicLogin^.FHardDiskIdMD5]);
  LGFData := DoPrioritySyncPost(LIndicator, 300000);
  try
    if LGFData.GetErrorCode = ErrorCode_Success then begin
      LGFDataSet := TGFDataSet.Create(LGFData);
      try
        LGFDataSet.First;
        LField := LGFDataSet.FieldByName('sid');
        if (LField <> nil) then begin
          FLastHeartBeatTick := GetTickCount;
          FShareMgr.SetSessionId(LField.AsString);
          FShareMgr.SetIsLogined(True);
          Result := True;
        end else begin
          FShareMgr.SetIsLogined(False);
          APBasicLogin^.FErrorCode := ErrorCode_Service_Indicator_Return_Result_Except;
          APBasicLogin^.FErrorInfo := LIndicator;
        end;
      finally
        LGFDataSet.Free;
      end;
    end else begin
      FShareMgr.SetIsLogined(False);
      APBasicLogin^.FErrorCode := LGFData.GetErrorCode;
      APBasicLogin^.FErrorInfo := LGFData.GetErrorInfo;
    end;
  finally
    LGFData := nil;
  end;
end;

function TBasicServiceImpl.SetReLoginEvent(AReLoginEvent: TReLoginEvent): Boolean;
begin
  FShareMgr.SetReLoginEvent(AReLoginEvent);
end;

function TBasicServiceImpl.GilPasswordSet(APBasicPasswordSet: PGilBasicPasswordSet): Boolean;
//var
//  LGFData: IGFData;
//  LIndicator: string;
begin

end;

function TBasicServiceImpl.SyncPost(AIndicator: WideString; AWaitTime: DWORD): IGFData;
begin
  if FShareMgr.GetIsLogined then begin
    Result := DoSyncPost(AIndicator, AWaitTime);
  end else begin
    Result := DoCreateGFData;
    DoNoLoginDefaultPost(Result);
  end;
end;

function TBasicServiceImpl.AsyncPOST(AIndicator: WideString; AEvent: TGFDataEvent; AKey: Int64): IGFData;
begin
  if FShareMgr.GetIsLogined then begin
    Result := DoAsyncPOST(AIndicator, AEvent, AKey);
  end else begin
    Result := DoCreateGFData;
    DoNoLoginDefaultPost(Result);
  end;
end;

function TBasicServiceImpl.PrioritySyncPost(AIndicator: WideString; AWaitTime: DWORD): IGFData;
begin
  if FShareMgr.GetIsLogined then begin
    Result := DoPrioritySyncPost(AIndicator, AWaitTime);
  end else begin
    Result := DoCreateGFData;
    DoNoLoginDefaultPost(Result);
  end;
end;

function TBasicServiceImpl.PriorityAsyncPOST(AIndicator: WideString; AEvent: TGFDataEvent; AKey: Int64): IGFData;
begin
  if FShareMgr.GetIsLogined then begin
    Result := DoPriorityAsyncPOST(AIndicator, AEvent, AKey);
  end else begin
    Result := DoCreateGFData;
    DoNoLoginDefaultPost(Result);
  end;
end;

end.
