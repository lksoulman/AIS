unit CommonRefCounter;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-7-11
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  SysUtils,
  Variants,
  Classes,
  Types,
  SyncObjs;

type

  // 自动计数对象基类
  TAutoObject = class
  public
    // 构造函数
    constructor Create; virtual;
    // 析构函数
    destructor Destroy; override;
  end;

  // 自动计数接口实现基类(接口自动管理，自动释放)
  TAutoInterfacedObject = class(TInterfacedObject)
  protected
    // 构造函数
    constructor Create; virtual;
  public
    // 析构函数
    destructor Destroy; override;
  end;

  // 自动计数接口实现基类(接口手动管理，手动释放)
  TAutoUserInterfacedObject = class(TAutoObject, IInterface)
  protected
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  end;

  // 增加内存检查点(参数：内存指针;描述文字)
  // 如创建检查点时指定内存指针，则删除检查点时也必须传入内存指针参数
  procedure IncMem(pPointer:Pointer = nil;strDesc:string = '');
  // 删除内存检查点(参数：内存指针)
  procedure DecMem(pPointer:Pointer = nil);

  // 带有内存计数功能的分配内存方法
  procedure GetMemEx(var P: Pointer; Size: Integer);
  // 带有内存计数功能的释放内存方法
  procedure FreeMemEx(var P: Pointer); overload;

implementation

var
  {$IFDEF DEBUG}
  g_nObjCounter: Integer;        //对象实例计数
  {$ENDIF}
  g_lstObjects:TStringList;     //对象键值对列表(指针-描述)
  g_Mutex:TMutex;                //互斥锁

{$REGION '自动计数对象基类'}

//构造函数
constructor TAutoObject.Create;
{$IFDEF DEBUG}
var
  strObjAddr:string;
  strClassName:string;
  szObjName:PChar;
  {$ENDIF}
begin
  {$IFDEF DEBUG}
  g_Mutex.Acquire;
  //将指针和类名键值对加入到列表中
  strObjAddr := IntToStr(Integer(self));
  strClassName := self.ClassName;
  GetMem(szObjName, 60 * sizeof(Char));
  ZeroMemory(szObjName, 60 * sizeof(Char));
  if Length(strClassName) < 60 then
  begin
    lstrcpy(szObjName, PWideChar(strClassName));
  end;
  g_lstObjects.AddObject(strObjAddr, TObject(szObjName));
  //将对象计数器加一
  InterlockedIncrement(g_nObjCounter);
  g_Mutex.Release;
  {$ENDIF}
end;

//析构函数
destructor TAutoObject.Destroy;
{$IFDEF DEBUG}
var
  strObjAddr:string;
  szObjName:PChar;
  nIndex:Integer;
{$ENDIF}
begin
  {$IFDEF DEBUG}
  g_Mutex.Acquire;
  //将对应指针和类名键值对从列表中删除
  strObjAddr := IntToStr(Integer(self));
  if g_lstObjects.Find(strObjAddr, nIndex) then
  begin
    szObjName := PChar(g_lstObjects.Objects[nIndex]);
    FreeMem(szObjName);
    g_lstObjects.Delete(nIndex);
  end
  //如果没有找到指定的指针，则表示多次释放
  else
  begin
    MessageBox(GetDesktopWindow(), PChar('释放对象时，在对象列表中没有找到对应的对象！'), '对象析构检测', MB_OK or MB_ICONWARNING);
  end;
  //对象计数器减一
  InterlockedDecrement(g_nObjCounter);
  g_Mutex.Release;
  {$ENDIF}
end;

{$ENDREGION}

{$REGION '自动计数接口实现基类(接口自动管理，自动释放)'}

//构造函数
constructor TAutoInterfacedObject.Create;
{$IFDEF DEBUG}
var
  strObjAddr:string;
  strClassName:string;
  szObjName:PChar;
  {$ENDIF}
begin
  {$IFDEF DEBUG}
  g_Mutex.Acquire;
  //将指针和类名键值对加入到列表中
  strObjAddr := IntToStr(Integer(self));
  strClassName := self.ClassName;
  GetMem(szObjName, 60 * sizeof(Char));
  ZeroMemory(szObjName, 60 * sizeof(Char));
  if Length(strClassName) < 60 then
  begin
    lstrcpy(szObjName, PWideChar(strClassName));
  end;
  g_lstObjects.AddObject(strObjAddr, TObject(szObjName));
  //将对象计数器加一
  InterlockedIncrement(g_nObjCounter);
  g_Mutex.Release;
  {$ENDIF}
end;

//析构函数
destructor TAutoInterfacedObject.Destroy;
{$IFDEF DEBUG}
var
  strObjAddr:string;
  szObjName:PChar;
  nIndex:Integer;
{$ENDIF}
begin
  {$IFDEF DEBUG}
  g_Mutex.Acquire;
  //将对应指针和类名键值对从列表中删除
  strObjAddr := IntToStr(Integer(self));
  if g_lstObjects.Find(strObjAddr, nIndex) then
  begin
    szObjName := PChar(g_lstObjects.Objects[nIndex]);
    FreeMem(szObjName);
    g_lstObjects.Delete(nIndex);
  end
  //如果没有找到指定的指针，则表示多次释放
  else
  begin
    MessageBox(GetDesktopWindow(), PChar('释放对象时，在对象列表中没有找到对应的对象！'), '对象析构检测', MB_OK or MB_ICONWARNING);
  end;
  //对象计数器减一
  InterlockedDecrement(g_nObjCounter);
  g_Mutex.Release;
  {$ENDIF}
end;

{$ENDREGION}

{ $REGION '自动计数接口实现对象基类' }

function TAutoUserInterfacedObject.QueryInterface(const IID: TGUID;out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

function TAutoUserInterfacedObject._AddRef: Integer;
begin
  Result := 1;
end;

function TAutoUserInterfacedObject._Release: Integer;
begin
  Result := 1;
end;

{$ENDREGION}

{$REGION '内存计数方法'}

// 增加内存检查点(参数：内存指针;描述文字)
procedure IncMem(pPointer:Pointer;strDesc:string);
{$IFDEF DEBUG}
var
  strObjAddr:string;
  szObjName:PChar;
{$ENDIF}
begin
  {$IFDEF DEBUG}
  //如果内存指针不为空，则将内存指针加入到对象列表中
  if pPointer <> nil then
  begin
    g_Mutex.Acquire;
    strObjAddr := IntToStr(Integer(pPointer));
    GetMem(szObjName, 40 * sizeof(Char));
    ZeroMemory(szObjName, 40 * sizeof(Char));
    if Length(strDesc) < 40 then
    begin
      lstrcpy(szObjName, PWideChar(strDesc));
    end;
    g_lstObjects.AddObject(strObjAddr, TObject(szObjName));
    g_Mutex.Release;
  end;

  //将内存计数器加一
  InterlockedIncrement(g_nObjCounter);
  {$ENDIF}
end;

// 删除内存检查点(参数：内存指针)
procedure DecMem(pPointer:Pointer);
{$IFDEF DEBUG}
var
  strObjAddr:string;
  szObjName:PChar;
  nIndex:Integer;
{$ENDIF}
begin
  {$IFDEF DEBUG}
  //如果内存指针不为空，则将对应的内存指针从对象列表中删除
  if pPointer <> nil then
  begin
    g_Mutex.Acquire;
    strObjAddr := IntToStr(Integer(pPointer));
    if g_lstObjects.Find(strObjAddr, nIndex) then
    begin
      szObjName := PChar(g_lstObjects.Objects[nIndex]);
      FreeMem(szObjName);
      g_lstObjects.Delete(nIndex);
    end
    else
    begin
      MessageBox(GetDesktopWindow(), PChar('释放对象时，在对象列表中没有找到对应的对象！'), '对象析构检测', MB_OK or MB_ICONWARNING);
    end;
    g_Mutex.Release;
  end;

  //内存计数器减一
  InterlockedDecrement(g_nObjCounter);
  {$ENDIF}
end;

// 带有内存计数功能的分配内存方法
procedure GetMemEx(var P: Pointer; Size: Integer);
begin
  GetMem(P, Size);
  {$IFDEF DEBUG}
  InterlockedIncrement(g_nObjCounter);
  {$ENDIF}
end;

// 带有内存计数功能的释放内存方法
procedure FreeMemEx(var P: Pointer);
begin
  FreeMem(P);
  {$IFDEF DEBUG}
  InterlockedDecrement(g_nObjCounter);
  {$ENDIF}
end;

{$ENDREGION}

//检查对象列表中有无对象还未释放
procedure CheckObjectList();
var
  I : Integer;
  LError:string;
  pDesc:PChar;
begin
  g_Mutex.Acquire;

  //如果对象列表中仍有对象未释放，则给出提示
  if g_lstObjects.Count > 0 then
  begin
    LError := '没有释放的对象列表: ' + #13;
    for I := 0 to g_lstObjects.Count - 1 do
    begin
      pDesc := PChar(g_lstObjects.Objects[I]);
      LError := LError + pDesc + #13;
      FreeMem(pDesc);
    end;
    MessageBoxW(GetDesktopWindow(), PChar(LError), '对象析构检测', MB_OK or MB_ICONWARNING);
  end;

  g_Mutex.Release;
end;



initialization
  {$IFDEF DEBUG}
  g_nObjCounter := 0;
  {$ENDIF}
  g_lstObjects := TStringList.Create;
  g_lstObjects.Sorted := True;
  g_Mutex := TMutex.Create;

finalization

  {$IFDEF DEBUG}
  //检查未释放对象列表
  CheckObjectList();

  //检查计数器是否为0
  if g_nObjCounter > 0 then
  begin
    MessageBox(GetDesktopWindow(), PChar('存在 ' + InttoStr(g_nObjCounter) + ' 处对象没有析构，请检查！'), '对象析构检测', MB_OK or MB_ICONWARNING);
  end
  else if g_nObjCounter < 0 then
  begin
    MessageBox(GetDesktopWindow(), PChar('存在 ' + InttoStr(g_nObjCounter) + ' 处对象的Destroy函数没有加入inherited，请检查！'), '对象析构检测', MB_OK OR MB_ICONWARNING);
  end;
  {$ENDIF}

  //释放全局对象
  FreeAndNil(g_lstObjects);
  g_Mutex.Free;

end.
