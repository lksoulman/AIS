unit UpdateGenerate;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-6-10
// Comments：
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
    // 设置更新的主目录
    FUpdateFolder: string;
    // 生成 MD5
    FCipherMD5: TCipherMD5;
    // 生成 CRC
    FCipherCRC: TCipherCRC;
    // 更新对象缓存池
    FUpdatePool: TUpdatePool;
    // 增量更新的列表
    FAddUpdates: TList<TUpdate>;
    // 服务端更新列表
    FServerUpdates: TList<TUpdate>;
    // 时间格式
    FFormatSettings: TFormatSettings;
    // 过滤规则
    FFilterUpdateDic: TDictionary<string, string>;
    // 服务端更新列表对象字典
    FServerUpdateDic: TDictionary<string, Integer>;
    // 新生成更新数据字典
    FNewGenerateUpdateDic: TDictionary<string, TUpdate>;

    // 通过 XML文件节点获取
    function GetUpdateByNode(ANode: TXMlNode): TUpdate;
    // 通过 Update 设置节点值
    procedure SetNodeByUpdate(AUpdate: TUpdate; ANode: TXMlNode);
    // 通过下表获取已有的更新
    function GetServerUpdateByIndex(AIndex: Integer): TUpdate;
    // 删除指定下表数据
    function DeleteServerUpdateByIndex(AIndex: Integer): Boolean;
  protected
    // 检查需要增加的更新列表
    procedure DoLoadNeedAddUpdate;
    // 清空生成更新数据字典
    procedure DoClearGenerateUpdateDic;
    // 清空更新列表
    procedure DoClearUpdates(AUpdates: TList<TUpdate>);
    // 加载服务端更新列表文件
    procedure DoLoadServerUpdateFile(AFile: string);
    // 修改更新
    procedure DoModifyUpdate(ANewUpdate, AOldUpdate: TUpdate);
    // 保存更新
    procedure DoSaveUpdates(AFile: string; AUpdates: TList<TUpdate>);
    // 检查是不是需要更新
    function DoCheckIsNeedUpdate(ANewUpdate, AOldUpdate: TUpdate): Boolean;
    // 递归遍历出目录下所有的文件
    procedure DoRecursiveFolder(AFolder, ARelativeFolder, AFileExt: string);
     // 更新数据
    procedure DoUpdate(AUpdate: TUpdate; ARelativeFolder: String; ASearchRec: PSearchRec);
  public
    // 构造方法
    constructor Create;
    // 析构函数
    destructor Destroy; override;
    // 设置过滤文件
    procedure SetFliter(AFile: string);
    // 设置生成更新列表的目录
    procedure SetFolder(AFolder: string);
    // 保存更新列表
    procedure SaveUpdates(AFile: string);
    // 生成所设置目录的更新列表
    procedure LoadNewUpdates;
    // 加载已有更新列表
    procedure LoadServerUpdateFile(AFile: string);
    // 生成增量的更新列表
    procedure LoadNeedAddUpdates(ANewAddUpdates: TList<TUpdate>);

    property UpdatePool: TUpdatePool read FUpdatePool;
    property FormatSettings: TFormatSettings read FFormatSettings;
  end;

implementation

uses
  Utils,
  FastLogLevel;

const
  // XML 文件头
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
      // 让出CPU
      Application.ProcessMessages;

      // 如果是当前目录 和 上一个目录继续查找下一个文件
      if (LSearchRec.Name = '.') or (LSearchRec.Name <> '..') then Continue;

      //如果某个目录存在，则进入这个目录递归找到文件
      if DirectoryExists(AFolder + LSearchRec.Name) then begin
        ARelativeFolder := ARelativeFolder + LSearchRec.Name + '\';
        DoRecursiveFolder(AFolder + LSearchRec.Name, ARelativeFolder, AFileExt);
      end else begin


        // 过滤更新文件字典
        if FFilterUpdateDic.ContainsKey(LName) then Continue;

        // 如果某个目录存在，则进入这个目录递归找到文件
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
