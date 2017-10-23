unit ResourceSkinImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Resource Skin Interface Implementation
// Author£º      lksoulman
// Date£º        2017-8-25
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Graphics,
  NativeXml,
  AppContext,
  CommonPool,
  ResourceSkin,
  CommonRefCounter,
  Generics.Collections;

type

  // Color Info
  TColorInfo = packed record
    FColor: TColor;
    FValue: string;
    procedure ResetValue;
  end;
  // PColor Info
  PColorInfo = ^TColorInfo;

  // Color Info Pool
  TColorInfoPool = class(TPointerPool)
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

  // Resource Skin Interface Implementation
  TResourceSkinImpl = class(TAutoInterfacedObject, IResourceSkin)
  private
    // Skin Style
    FSkinStyle: string;
    // Instance
    FInstance: HMODULE;
    // Application Context
    FAppContext: IAppContext;
    // Color Info Pool
    FColorInfoPool: TColorInfoPool;
    // Skin Instance Dictionary
    FInstanceDic: TDictionary<string, HMODULE>;
    // Skin Color Info Dictionary
    FColorInfoDic: TDictionary<string, PColorInfo>;
    // Skin Color Infos Dictionary
    FStyleColorInfoDic: TDictionary<string, TDictionary<string, PColorInfo>>;
  protected
    // Change Skin
    procedure DoChangeSkin;
    // Init Library
    procedure DoInitLibrary;
    // Un Init Library
    procedure DoUnInitLibrary;
    // Change Color Library
    procedure DoChangeLibrary;
    // Change Color Info Dic
    procedure DoChangeSkinColorInfoDic;
    // Clear Style Color Info Dic
    procedure DoClearStyleColorInfoDic;
    // Clear Color Info
    procedure DoClearColorInfoDic(AColorInfoDic: TDictionary<string, PColorInfo>);
    // Load Library
    function DoLoadLibrary(AFile: string): HMODULE;
    // Get File
    function DoGetFile(ASkinStyle: string): string;
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;

    { IResourceSkin }

    // Init
    procedure Initialize(AContext: IInterface);
    // Un Init
    procedure UnInitialize;
    // Change Skin
    function ChangeSkin: Boolean;
    // Get Instance
    function GetInstance: HMODULE;
    // Get Color
    function GetColor(AKey: string): TColor;
    // Get Color String
    function GetColorString(AKey: string): string;
    // Get Stream
    function GetStream(AResourceName: string): TResourceStream;
  end;

implementation

uses
  Cfg,
  LogLevel;

const
  RESOURCE_FILE_SKINSBLACK   = 'AsfSkinsBlack.dll';
  RESOURCE_FILE_SKINSWHITE   = 'AsfSkinsWhite.dll';
  RESOURCE_FILE_SKINSCLASSIC = 'AsfSkinsClassic.dll';
  RESOURCE_COLORSCFG         = 'COLORSCFG';

function HexToIntEx(AStrHex: string; ADefValue: Integer): Integer;
var
  LValue: string;
  LIndex: Integer;
  LTempValue: Cardinal;
begin
  LTempValue := 0;
  LValue := UpperCase(Trim(AStrHex));
  LIndex := Pos('X', LValue);
  if LIndex > 0 then begin
    LValue := Copy(AStrHex, LIndex + 1, Length(LValue))
  end else if (Length(AStrHex) > 1)
    and (AStrHex[1] = '$') then begin
    LValue := Copy(AStrHex, 2, Length(LValue));
  end;
  if Length(LValue) < 8 then begin
    LValue := '0' + LValue;
  end;
  try
    HexToBin(pChar(LValue), @LTempValue, SizeOf(Result));
    Result := Integer((LTempValue and $FF shl 24)
      or (LTempValue and $FF00 shl 8)
      or (LTempValue and $FF0000 shr 8)
      or (LTempValue and $FF000000 shr 24));
  Except
    Result := ADefValue;
  end;
end;

{ TColorInfo }

procedure TColorInfo.ResetValue;
begin
  FColor := 0;
  FValue := '';
end;

{ TColorInfoPool }

function TColorInfoPool.DoCreate: Pointer;
begin
  Result := New(PColorInfo);
end;

procedure TColorInfoPool.DoDestroy(APointer: Pointer);
begin
  if APointer <> nil then begin
    Dispose(APointer);
  end;
end;

procedure TColorInfoPool.DoAllocateBefore(APointer: Pointer);
begin
  if APointer <> nil then begin
    PColorInfo(APointer)^.ResetValue;
  end;
end;

procedure TColorInfoPool.DoDeAllocateBefore(APointer: Pointer);
begin

end;

{ TResourceSkinImpl }

constructor TResourceSkinImpl.Create;
begin
  inherited;
  FInstance := 0;
  FColorInfoPool := TColorInfoPool.Create(20);
  FInstanceDic := TDictionary<string, HMODULE>.Create(5);
  FStyleColorInfoDic := TDictionary<string, TDictionary<string, PColorInfo>>.Create(5);
end;

destructor TResourceSkinImpl.Destroy;
begin
  FStyleColorInfoDic.Free;
  FInstanceDic.Free;
  FColorInfoPool.Free;
  inherited;
end;

procedure TResourceSkinImpl.Initialize(AContext: IInterface);
begin
  FAppContext := AContext as IAppContext;
  
end;

procedure TResourceSkinImpl.UnInitialize;
begin
  DoClearStyleColorInfoDic;
  DoUnInitLibrary;

  FAppContext := nil;
end;

function TResourceSkinImpl.ChangeSkin: Boolean;
begin
  Result := True;
  DoChangeSkin;
end;

function TResourceSkinImpl.GetInstance: HMODULE;
begin
  Result := FInstance;
end;

function TResourceSkinImpl.GetColor(AKey: string): TColor;
var
  LPColorInfo: PColorInfo;
begin
  if (FColorInfoDic <> nil)
    and FColorInfoDic.TryGetValue(AKey, LPColorInfo) then begin
    Result := LPColorInfo.FColor;
  end else begin
    Result := -1;
  end;
end;

function TResourceSkinImpl.GetColorString(AKey: string): string;
var
  LPColorInfo: PColorInfo;
begin
  if (FColorInfoDic <> nil)
    and FColorInfoDic.TryGetValue(AKey, LPColorInfo) then begin
    Result := LPColorInfo.FValue;
  end else begin
    Result := '';
  end;
end;

function TResourceSkinImpl.GetStream(AResourceName: string): TResourceStream;
begin
  Result := nil;
  if FInstance <> 0 then begin
    try
      Result := TResourceStream.Create(FInstance, AResourceName, RT_RCDATA);
    except
      on Ex: Exception do begin
        Result := nil;
        FAppContext.SysLog(llERROR, Format('[TResourceSkinImpl][GetStream] TResourceStream.Create(%d, %s, RT_RCDATA)', [FInstance, AResourceName]));
      end;
    end;
  end;
end;

procedure TResourceSkinImpl.DoChangeSkin;
begin
  FSkinStyle := FAppContext.GetCfg.GetSysCfg.GetSystemInfo.GetSystemInfo.FSkinStyle;
  if FSkinStyle <> '' then begin
    DoChangeLibrary;
    DoChangeSkinColorInfoDic;
  end;
end;

procedure TResourceSkinImpl.DoInitLibrary;
begin
  DoChangeSkin;
end;

procedure TResourceSkinImpl.DoUnInitLibrary;
var
  LEnum: TDictionary<string, HMODULE>.TPairEnumerator;
begin
  LEnum := FInstanceDic.GetEnumerator;
  try
    while LEnum.MoveNext do begin
      if LEnum.Current.Value <> 0 then begin
        FreeLibrary(LEnum.Current.Value);
      end;
    end;
    FInstanceDic.Clear;
  finally
    LEnum.Free;
  end;
end;

procedure TResourceSkinImpl.DoChangeLibrary;
begin
  if not FInstanceDic.ContainsKey(FSkinStyle) then begin
    FInstance := DoLoadLibrary(DoGetFile(FSkinStyle));
    FInstanceDic.AddOrSetValue(FSkinStyle, FInstance);
  end else begin
    FInstance := FInstanceDic[FSkinStyle];
  end;
end;

procedure TResourceSkinImpl.DoChangeSkinColorInfoDic;
var
{$IFDEF DEBUG}
  LTick: Cardinal;
{$ENDIF}
  LKey: string;
  LIndex: Integer;
  LXml: TNativeXml;
  LRoot, LNode: TXmlNode;
  LPColorInfo: PColorInfo;
  LStream: TResourceStream;
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
{$ENDIF}

  if not FStyleColorInfoDic.TryGetValue(FSkinStyle, FColorInfoDic) then begin
    FColorInfoDic := TDictionary<string, PColorInfo>.Create(1800);
    FStyleColorInfoDic.AddOrSetValue(FSkinStyle, FColorInfoDic);
    LStream := GetStream(RESOURCE_COLORSCFG);
    if LStream = nil then Exit;
    try
      LXml := TNativeXml.Create(nil);
      try
        LXml.LoadFromStream(LStream);
        LXml.XmlFormat := xfReadable;
        LRoot := LXml.Root;
        for LIndex := 0 to LRoot.NodeCount - 1 do begin
          LNode := LRoot.Nodes[LIndex];
          if LNode <> nil then begin
            LKey := string(LNode.AttributeValueByName[UTF8String('Key')]);
            if (LKey <> '') then begin
              if not FColorInfoDic.ContainsKey(LKey) then begin
                LPColorInfo := PColorInfo(FColorInfoPool.Allocate);
                if LPColorInfo <> nil then begin
                  LPColorInfo.FValue := string(LNode.AttributeValueByName[UTF8String('Val')]);
                  LPColorInfo.FColor := HexToIntEx(LPColorInfo.FValue, 0);
                  FColorInfoDic.AddOrSetValue(LKey, LPColorInfo);
                end;
              end;
            end;
          end;
        end;
      finally
        LXml.Free;
      end;
    finally
      LStream.Free;
    end;
  end;

{$IFDEF DEBUG}
  LTick := GetTickCount - LTick;
  FAppContext.SysLog(llSLOW, Format('[TResourceSkinImpl][DoChangeSkinColorInfoDic] Execute use time %d.', [LTick]));
{$ENDIF}
end;

procedure TResourceSkinImpl.DoClearColorInfoDic(AColorInfoDic: TDictionary<string, PColorInfo>);
var
  LPColorInfo: PColorInfo;
  LEnum: TDictionary<string, PColorInfo>.TPairEnumerator;
begin
  if AColorInfoDic = nil then Exit;

  LEnum := AColorInfoDic.GetEnumerator;
  try
    while LEnum.MoveNext do begin
      LPColorInfo := LEnum.Current.Value;
      if LPColorInfo <> nil then begin
        Dispose(LPColorInfo);
      end;
    end;
  finally
    LEnum.Free;
  end;
end;

procedure TResourceSkinImpl.DoClearStyleColorInfoDic;
var
  LEnum: TDictionary<string, TDictionary<string, PColorInfo>>.TPairEnumerator;
begin
  LEnum := FStyleColorInfoDic.GetEnumerator;
  try
    while LEnum.MoveNext do begin
      DoClearColorInfoDic(LEnum.Current.Value);
    end;
  finally
    LEnum.Free;
  end;
end;

function TResourceSkinImpl.DoGetFile(ASkinStyle: string): string;
begin
  if ASkinStyle = 'Classic' then begin
    Result := RESOURCE_FILE_SKINSCLASSIC;
  end else if ASkinStyle = 'White' then begin
    Result := RESOURCE_FILE_SKINSWHITE;
  end else begin
    Result := RESOURCE_FILE_SKINSBLACK;
  end;
end;

function TResourceSkinImpl.DoLoadLibrary(AFile: string): HMODULE;
{$IFDEF DEBUG}
var
  LTick: Cardinal;
{$ENDIF}
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
{$ENDIF}

  if FileExists(AFile) then begin
    Result := LoadLibrary(PChar(AFile));
    if Result = 0 then begin
      FAppContext.SysLog(llERROR, Format('[TResourceImpl][LoadLibrary] LoadLibrary(%s) return is 0, GetLastError is %d.', [AFile, GetLastError]));
    end;
  end else begin
    Result := 0;
    FAppContext.SysLog(llERROR, Format('[TResourceImpl][LoadLibrary] %s is not exists.', [AFile]));
  end;

{$IFDEF DEBUG}
  LTick := GetTickCount - LTick;
  FAppContext.SysLog(llSLOW, Format('[TResourceSkinImpl][DoLoadLibrary] LoadLibrary(%s) Execute use time %d.', [AFile, LTick]));
{$ENDIF}
end;

end.
