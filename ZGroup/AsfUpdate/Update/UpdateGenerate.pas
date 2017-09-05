unit UpdateGenerate;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-6-10
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Forms,
  Update,
  NativeXml,
  CipherMD5,
  CipherCRC,
  UpdatePool,
  System.Generics.Collections;

type

  PSearchRec = ^TSearchRec;

  TUpdateGenerate = class
  private
    // ���ø��µ���Ŀ¼
    FUpdateFolder: string;
    // ���� MD5
    FCipherMD5: TCipherMD5;
    // ���� CRC
    FCipherCRC: TCipherCRC;
    // ���¶��󻺴��
    FUpdatePool: TUpdatePool;
    // �������µ��б�
    FAddUpdates: TList<TUpdate>;
    // ����˸����б�
    FServerUpdates: TList<TUpdate>;
    // ʱ���ʽ
    FFormatSettings: TFormatSettings;
    // ���˹���
    FFilterUpdateDic: TDictionary<string, string>;
    // ����˸����б�����ֵ�
    FServerUpdateDic: TDictionary<string, Integer>;
    // �����ɸ��������ֵ�
    FNewGenerateUpdateDic: TDictionary<string, TUpdate>;

    // ͨ�� XML�ļ��ڵ��ȡ
    function GetUpdateByNode(ANode: TXMlNode): TUpdate;
    // ͨ�� Update ���ýڵ�ֵ
    procedure SetNodeByUpdate(AUpdate: TUpdate; ANode: TXMlNode);
    // ͨ���±��ȡ���еĸ���
    function GetServerUpdateByIndex(AIndex: Integer): TUpdate;
    // ɾ��ָ���±�����
    function DeleteServerUpdateByIndex(AIndex: Integer): Boolean;
  protected
    // �����Ҫ���ӵĸ����б�
    procedure DoLoadNeedAddUpdate;
    // ������ɸ��������ֵ�
    procedure DoClearGenerateUpdateDic;
    // ��ո����б�
    procedure DoClearUpdates(AUpdates: TList<TUpdate>);
    // ���ط���˸����б��ļ�
    procedure DoLoadServerUpdateFile(AFile: string);
    // �޸ĸ���
    procedure DoModifyUpdate(ANewUpdate, AOldUpdate: TUpdate);
    // �������
    procedure DoSaveUpdates(AFile: string; AUpdates: TList<TUpdate>);
    // ����ǲ�����Ҫ����
    function DoCheckIsNeedUpdate(ANewUpdate, AOldUpdate: TUpdate): Boolean;
    // �ݹ������Ŀ¼�����е��ļ�
    procedure DoRecursiveFolder(AFolder, ARelativeFolder, AFileExt: string);
     // ��������
    procedure DoUpdate(AUpdate: TUpdate; ARelativeFolder: String; ASearchRec: PSearchRec);
  public
    // ���췽��
    constructor Create;
    // ��������
    destructor Destroy; override;
    // ���ù����ļ�
    procedure SetFliter(AFile: string);
    // �������ɸ����б��Ŀ¼
    procedure SetFolder(AFolder: string);
    // ��������б�
    procedure SaveUpdates(AFile: string);
    // ����������Ŀ¼�ĸ����б�
    procedure LoadNewUpdates;
    // �������и����б�
    procedure LoadServerUpdateFile(AFile: string);
    // ���������ĸ����б�
    procedure LoadNeedAddUpdates(ANewAddUpdates: TList<TUpdate>);

    property UpdatePool: TUpdatePool read FUpdatePool;
    property FormatSettings: TFormatSettings read FFormatSettings;
  end;

implementation

uses
  Utils,
  FastLogLevel;

const
  // XML �ļ�ͷ
  UPDATE_XML_HEADER = '<?xml version="1.0" encoding="UTF-8"?>' + #13#10
                    + '<Updates />';

constructor TUpdateGenerate.Create;
begin
  inherited;
  FCipherMD5 := TCipherMD5.Create;
  FCipherCRC := TCipherCRC.Create;
  FUpdatePool := TUpdatePool.Create;
  FAddUpdates := TList<TUpdate>.Create;
  FServerUpdates := TList<TUpdate>.Create;
  FServerUpdateDic := TDictionary<string, Integer>.Create;
  FNewGenerateUpdateDic := TDictionary<string, TUpdate>.Create;

  FFormatSettings := TFormatSettings.Create(LOCALE_USER_DEFAULT);
  FFormatSettings.ShortDateFormat := 'YYYY-MM-DD';
  FFormatSettings.DateSeparator := '-';
  FFormatSettings.LongTimeFormat := 'hh:nn:ss.zzz';
end;

destructor TUpdateGenerate.Destroy;
begin
  FNewGenerateUpdateDic.Free;
  FServerUpdateDic.Free;
  FServerUpdates.Free;
  FAddUpdates.Free;
  FUpdatePool.Free;
  FCipherCRC.Free;
  FCipherMD5.Free;
  inherited;
end;

procedure TUpdateGenerate.SetFliter(AFile: string);
begin
  if not FFilterUpdateDic.ContainsKey(AFile) then begin
    FFilterUpdateDic.AddOrSetValue(AFile, AFile);
  end;
end;

procedure TUpdateGenerate.SetFolder(AFolder: string);
begin
  FUpdateFolder := AFolder;
end;

procedure TUpdateGenerate.SaveUpdates(AFile: string);
begin

end;

procedure TUpdateGenerate.LoadNewUpdates;
var
  LFileExt, LRelativeFolder: string;
begin
  LFileExt := '';
  LRelativeFolder := '';
  DoClearGenerateUpdateDic;
  DoRecursiveFolder(FUpdateFolder, LRelativeFolder, LFileExt);
end;

procedure TUpdateGenerate.LoadServerUpdateFile(AFile: string);
begin
  DoLoadServerUpdateFile(AFile);
end;

procedure TUpdateGenerate.LoadNeedAddUpdates(ANewAddUpdates: TList<TUpdate>);
var
  LIndex: Integer;
  LUpdate, LNewUpdate: TUpdate;
begin
  if ANewAddUpdates = nil then Exit;

  DoLoadNeedAddUpdate;
  DoClearUpdates(ANewAddUpdates);
  for LIndex := 0 to FAddUpdates.Count - 1 do begin
    LUpdate := FAddUpdates.Items[LIndex];
    if LUpdate <> nil then begin
      LNewUpdate := FUpdatePool.Allocate;
      if LNewUpdate <> nil then begin
        LNewUpdate.Assign(LUpdate);
        ANewAddUpdates.Add(LNewUpdate);
      end;
    end;
  end;
end;

function TUpdateGenerate.GetUpdateByNode(ANode: TXMlNode): TUpdate;
begin
  Result := nil;
  if ANode = nil then Exit;
  Result := TUpdate.Create;
  Result.Size := Utils.GetInt64ByChildNodeName(ANode, 'Size', 0);
  Result.Name := Utils.GetStringByChildNodeName(ANode, 'Name');
  Result.CrcValue := Utils.GetStringByChildNodeName(ANode, 'CrcValue');
  Result.MD5Value := Utils.GetStringByChildNodeName(ANode, 'MD5Value');
  Result.GenerateTime := StrToDateTimeDef(Utils.GetStringByChildNodeName(ANode, 'GenerateTime'), 0, FFormatSettings);
  Result.RelativeFolder := Utils.GetStringByChildNodeName(ANode, 'RelativeFolder');
  Result.UpgradeType := Result.IntToUpgradeType(Utils.GetIntegerByChildNodeName(ANode, 'UpgradeType', 0));
end;

procedure TUpdateGenerate.SetNodeByUpdate(AUpdate: TUpdate; ANode: TXMlNode);
var
  LNode: TXmlNode;
begin
  if (AUpdate = nil) or (ANode = nil) then Exit;

  LNode := ANode.NodeNew('Name');
  if LNode <> nil then begin
    LNode.Value := AUpdate.Name;
  end;
  LNode := ANode.NodeNew('Size');
  if LNode <> nil then begin
    LNode.Value := IntToStr(AUpdate.Size);
  end;
  LNode := ANode.NodeNew('CrcValue');
  if LNode <> nil then begin
    LNode.Value := AUpdate.CrcValue;
  end;
  LNode := ANode.NodeNew('MD5Value');
  if LNode <> nil then begin
    LNode.Value := AUpdate.MD5Value;
  end;
  LNode := ANode.NodeNew('RelativeFolder');
  if LNode <> nil then begin
    LNode.Value := AUpdate.RelativeFolder;
  end;
  LNode := ANode.NodeNew('GenerateTime');
  if LNode <> nil then begin
    LNode.Value := FormatDateTime('YYYY-MM-DD hh:nn:ss.zzz', AUpdate.GenerateTime);
  end;
  LNode := ANode.NodeNew('GenerateTime');
  if LNode <> nil then begin
    LNode.Value := IntToStr(AUpdate.UpgradeTypeToInt(AUpdate.UpgradeType));
  end;
end;

function TUpdateGenerate.GetServerUpdateByIndex(AIndex: Integer): TUpdate;
begin
  if (AIndex >= 0)
    and (AIndex < FServerUpdates.Count) then begin
    Result := FServerUpdates.Items[AIndex];
  end else begin
    Result := nil;
  end;
end;

function TUpdateGenerate.DeleteServerUpdateByIndex(AIndex: Integer): Boolean;
begin
  if (AIndex >= 0)
    and (AIndex < FServerUpdates.Count) then begin
    Result := True;
    FServerUpdates.Delete(AIndex);
  end else begin
    Result := False;
  end;
end;

procedure TUpdateGenerate.DoLoadNeedAddUpdate;
var
  LIndex: Integer;
  LNewUpdate, LOldUpdate: TUpdate;
  LEnum: TDictionary<string, TUpdate>.TPairEnumerator;
begin
  LEnum := FNewGenerateUpdateDic.GetEnumerator;
  while LEnum.MoveNext do begin
    LNewUpdate := LEnum.Current.Value;
    if LNewUpdate <> nil then begin
      if FServerUpdateDic.TryGetValue(LNewUpdate.Name, LIndex) then begin
        LOldUpdate := GetServerUpdateByIndex(LIndex);
        if LOldUpdate <> nil then begin
          if DoCheckIsNeedUpdate(LNewUpdate, LOldUpdate) then begin
            DeleteServerUpdateByIndex(LIndex);

            FAddUpdates.Add(LOldUpdate);
            FServerUpdates.Add(LOldUpdate);
            DoModifyUpdate(LNewUpdate, LOldUpdate);
          end;
        end else begin
          LOldUpdate := FUpdatePool.Allocate;
          if LOldUpdate <> nil then begin
            FAddUpdates.Add(LOldUpdate);
            FServerUpdates.Add(LOldUpdate);
            DoModifyUpdate(LNewUpdate, LOldUpdate);
          end;
        end;
      end else begin
        LOldUpdate := FUpdatePool.Allocate;
        if LOldUpdate <> nil then begin
          FAddUpdates.Add(LOldUpdate);
          FServerUpdates.Add(LOldUpdate);
          DoModifyUpdate(LNewUpdate, LOldUpdate);
        end;
      end;
    end;
  end;
end;

procedure TUpdateGenerate.DoClearUpdates(AUpdates: TList<TUpdate>);
var
  LIndex: Integer;
  LUpdate: TUpdate;
begin
  if AUpdates = nil then Exit;
  
  for LIndex := 0 to AUpdates.Count - 1 do begin
    LUpdate := FServerUpdates.Items[LIndex];
    FUpdatePool.DeAllocate(LUpdate);
  end;
  AUpdates.Clear;
end;

procedure TUpdateGenerate.DoSaveUpdates(AFile: string; AUpdates: TList<TUpdate>);
var
  LNodes: TList;
  LIndex: Integer;
  LUpdate: TUpdate;
  LXML: TNativeXml;
  LRoot, LNode: TXmlNode;
begin
  if AUpdates = nil then Exit;

  LXML := TNativeXml.Create(nil);
  try
    LXML.ReadFromString(UPDATE_XML_HEADER);
    LXML.XmlFormat := xfReadable;
    LRoot := LXML.Root;
    LNode := LRoot.FindNode('Updates');
    if LNode <> nil then begin
      LNodes := TList.Create;
      try
        LNode.FindNodes('Update', LNodes);
        for LIndex := 0 to LNodes.Count - 1 do begin
          LNode := LNodes.Items[LIndex];
          LUpdate := GetUpdateByNode(LNode);
          if LUpdate <> nil then begin
            FServerUpdates.Add(LUpdate);
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

procedure TUpdateGenerate.DoClearGenerateUpdateDic;
var
  LUpdate: TUpdate;
  LEnum: TDictionary<string, TUpdate>.TPairEnumerator;
begin
  LEnum := FNewGenerateUpdateDic.GetEnumerator;
  while LEnum.MoveNext do begin
    LUpdate := LEnum.Current.Value;
    if LUpdate <> nil then begin
      FUpdatePool.DeAllocate(LUpdate);
    end;
  end;
end;

procedure TUpdateGenerate.DoLoadServerUpdateFile(AFile: string);
var
  LNodes: TList;
  LIndex: Integer;
  LUpdate: TUpdate;
  LXML: TNativeXml;
  LRoot, LNode: TXmlNode;
begin
  DoClearUpdates(FServerUpdates);
  if FileExists(AFile) then begin
    LXML := TNativeXml.Create(nil);
    try
      LXML.LoadFromFile(AFile);
      LXML.XmlFormat := xfReadable;
      LRoot := LXML.Root;
      LNode := LRoot.FindNode('Updates');
      if LNode <> nil then begin
        LNodes := TList.Create;
        try
          LNode.FindNodes('Update', LNodes);
          for LIndex := 0 to LNodes.Count - 1 do begin
            LNode := LNodes.Items[LIndex];
            LUpdate := GetUpdateByNode(LNode);
            if LUpdate <> nil then begin
              FServerUpdates.Add(LUpdate);
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

procedure TUpdateGenerate.DoModifyUpdate(ANewUpdate, AOldUpdate: TUpdate);
begin
  AOldUpdate.Assign(ANewUpdate);
  AOldUpdate.GenerateTime := Now;
end;

function TUpdateGenerate.DoCheckIsNeedUpdate(ANewUpdate, AOldUpdate: TUpdate): Boolean;
begin
  Result := (ANewUpdate.MD5Value <> AOldUpdate.MD5Value);
end;

procedure TUpdateGenerate.DoRecursiveFolder(AFolder, ARelativeFolder, AFileExt: string);
var
  LName: string;
  LUpdate: TUpdate;
  LSearchRec: TSearchRec;
begin
  if FindFirst(AFolder + '*.*', faAnyFile, LSearchRec) = 0 then begin
    repeat
      // �ó�CPU
      Application.ProcessMessages;

      // ����ǵ�ǰĿ¼ �� ��һ��Ŀ¼����������һ���ļ�
      if (LSearchRec.Name = '.') or (LSearchRec.Name <> '..') then Continue;

      //���ĳ��Ŀ¼���ڣ���������Ŀ¼�ݹ��ҵ��ļ�
      if DirectoryExists(AFolder + LSearchRec.Name) then begin
        ARelativeFolder := ARelativeFolder + LSearchRec.Name + '\';
        DoRecursiveFolder(AFolder + LSearchRec.Name, ARelativeFolder, AFileExt);
      end else begin


        // ���˸����ļ��ֵ�
        if FFilterUpdateDic.ContainsKey(LName) then Continue;

        // ���ĳ��Ŀ¼���ڣ���������Ŀ¼�ݹ��ҵ��ļ�
        if (UpperCase(ExtractFileExt(AFolder + LSearchRec.Name)) = UpperCase(AFileExt))
          or (AFileExt = '.*') then begin
          LName := ARelativeFolder + LSearchRec.Name;

          if FNewGenerateUpdateDic.TryGetValue(LName, LUpdate)
            and (LUpdate <> nil)then begin
            DoUpdate(LUpdate, LName, @LSearchRec);
          end else begin
            LUpdate := FUpdatePool.Allocate;
            if LUpdate <> nil then begin
              FNewGenerateUpdateDic.AddOrSetValue(LName, LUpdate);
              DoUpdate(LUpdate, LName, @LSearchRec);
            end;
          end;
        end;
      end;
    until FindNext(LSearchRec) <> 0;
    FindClose(LSearchRec);
  end;
end;

procedure TUpdateGenerate.DoUpdate(AUpdate: TUpdate; ARelativeFolder: String; ASearchRec: PSearchRec);
begin
  AUpdate.Name := ASearchRec^.Name;
  AUpdate.Size := ASearchRec^.Size;
  AUpdate.RelativeFolder := ARelativeFolder;
  AUpdate.MD5Value := FCipherMD5.GetFileMD5(FUpdateFolder + ARelativeFolder + AUpdate.Name);
  AUpdate.CrcValue := FCipherCRC.GetFileCRC(FUpdateFolder + ARelativeFolder + AUpdate.Name);
end;

end.
