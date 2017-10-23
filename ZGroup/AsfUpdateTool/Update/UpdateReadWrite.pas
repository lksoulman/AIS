unit UpdateReadWrite;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Update Read Write
// Author£º      lksoulman
// Date£º        2017-10-13
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  NativeXml,
  UpdateInfo,
  UpdateAppContext,
  CommonRefCounter,
  Generics.Collections;

type

  // Update Read Write
  TUpdateReadWrite = class(TAutoObject)
  private
    // Application Context
    FUpdateAppContext: IUpdateAppContext;
  protected
    // Get Update Info
    function GetUpdateInfo(ANode: TXMlNode): TUpdateInfo;
    // Set Node By Update Info
    procedure SetNode(ANode: TXMlNode; AUpdateFileInfo: TUpdateInfo);
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;
    // Init
    procedure Initialize(AContext: IUpdateAppContext);
    // UnInit
    procedure UnInitialize;
    // Read
    procedure Read(AUpdateListFile: string; AUpdateInfos: TList<TUpdateInfo>);
    // Write
    procedure Write(AUpdateListFile: string; AUpdateInfos: TList<TUpdateInfo>);
  end;

implementation

uses
  Utils;

{ TUpdateReadWrite }

constructor TUpdateReadWrite.Create;
begin
  inherited;

end;

destructor TUpdateReadWrite.Destroy;
begin

  inherited;
end;

procedure TUpdateReadWrite.Initialize(AContext: IUpdateAppContext);
begin
  FUpdateAppContext := AContext;
end;

procedure TUpdateReadWrite.UnInitialize;
begin
  FUpdateAppContext := nil;
end;

procedure TUpdateReadWrite.Read(AUpdateListFile: string; AUpdateInfos: TList<TUpdateInfo>);
var
  LNodes: TList;
  LIndex: Integer;
  LXML: TNativeXml;
  LRoot, LNode: TXmlNode;
  LUpdateInfo: TUpdateInfo;
begin
  if FileExists(AUpdateListFile) then begin
    LXML := TNativeXml.Create(nil);
    try
      LXML.LoadFromFile(AUpdateListFile);
      LXML.XmlFormat := xfReadable;
      LRoot := LXML.Root;
      if LRoot <> nil then begin
        LNodes := TList.Create;
        try
          LRoot.FindNodes('Update', LNodes);
          for LIndex := 0 to LNodes.Count - 1 do begin
            LNode := LNodes.Items[LIndex];
            if LNode <> nil then begin
              LUpdateInfo := GetUpdateInfo(LNode);
              if LUpdateInfo <> nil then begin
                AUpdateInfos.Add(LUpdateInfo);
              end;
            end;
          end;
        finally
          LNodes.Free;
        end;
      end;
    finally
      LXML.Free;
    end;
  end;
end;

procedure TUpdateReadWrite.Write(AUpdateListFile: string; AUpdateInfos: TList<TUpdateInfo>);
const
  UPDATE_XML = '<?xml version="1.0" encoding="UTF-8"?>'
               + #13#10 + '<Updates />';
var
  LIndex: Integer;
  LXML: TNativeXml;
  LRoot, LNode: TXmlNode;
  LUpdateInfo: TUpdateInfo;
begin
  LXML := TNativeXml.Create(nil);
  try
    LXML.ReadFromString(UPDATE_XML);
    LXML.XmlFormat := xfReadable;
    LRoot := LXML.Root;
    for LIndex := 0 to AUpdateInfos.Count - 1 do begin
      LUpdateInfo := AUpdateInfos.Items[LIndex];
      if LUpdateInfo <> nil then begin
        LNode := LRoot.NodeNew('Update');
        SetNode(LNode, LUpdateInfo);
      end;
    end;
    LXML.SaveToFile(AUpdateListFile);
  finally
    LXML.Free;
  end;
end;

function TUpdateReadWrite.GetUpdateInfo(ANode: TXMlNode): TUpdateInfo;
begin
  Result := TUpdateInfo(FUpdateAppContext.GetUpdateInfoPool.Allocate);
  if Result = nil then Exit;
  
  Result.Size := Utils.GetInt64ByChildNodeName(ANode, 'Size', 0);
  Result.Name := Utils.GetStringByChildNodeName(ANode, 'Name');
  Result.CrcValue := Utils.GetStringByChildNodeName(ANode, 'CrcValue');
  Result.MD5Value := Utils.GetStringByChildNodeName(ANode, 'MD5Value');
  Result.RelativePath := Utils.GetStringByChildNodeName(ANode, 'RelativePath');
  Result.UpgradeType := Result.IntToUpgradeType(Utils.GetIntegerByChildNodeName(ANode, 'UpgradeType', 0));
end;

procedure TUpdateReadWrite.SetNode(ANode: TXMlNode; AUpdateFileInfo: TUpdateInfo);
var
  LNode: TXmlNode;
begin
  LNode := ANode.NodeNew('Name');
  if LNode <> nil then begin
    LNode.Value := UTF8String(AUpdateFileInfo.Name);
  end;
  LNode := ANode.NodeNew('Size');
  if LNode <> nil then begin
    LNode.Value := UTF8String(IntToStr(AUpdateFileInfo.Size));
  end;
  LNode := ANode.NodeNew('CrcValue');
  if LNode <> nil then begin
    LNode.Value := UTF8String(AUpdateFileInfo.CrcValue);
  end;
  LNode := ANode.NodeNew('MD5Value');
  if LNode <> nil then begin
    LNode.Value := UTF8String(AUpdateFileInfo.MD5Value);
  end;
  LNode := ANode.NodeNew('RelativePath');
  if LNode <> nil then begin
    LNode.Value := UTF8String(AUpdateFileInfo.RelativePath);
  end;
  LNode := ANode.NodeNew('UpgradeType');
  if LNode <> nil then begin
    LNode.Value := UTF8String(IntToStr(AUpdateFileInfo.UpgradeTypeToInt(AUpdateFileInfo.UpgradeType)));
  end;
end;

end.
