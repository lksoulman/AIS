unit CacheTable;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-8
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  CommonLock,
  Generics.Collections;

type

  TCacheTable = class
  private
    // 表名称
    FName: string;
    // 表 ID
    FIndexID: Integer;
    // 存储方式
    FStorage: Integer;
    // 表版本
    FVersion: Integer;
    // 更新最大 JSID
    FMaxJSID: Int64;
    // 删除最大 JSID
    FDelJSID: Int64;
    // 表是不是已经创建
    FIsCreate: Boolean;
    // 创建表 Sql
    FCreateSql: string;
    // 插入数据 sql
    FInsertSql: string;
    // 删除数据 sql
    FDeleteSql: string;
    // 请求数据的指标
    FIndicator: string;
    // 请求删除数据的指标
    FDeleteIndicator: string;
    // 存储列明的
    FColFields: TStringList;
    // 数据锁
    FLock: TCSLock;
    // 更新表的时候更新内存的数据 (0: 表示不更新; 1: 表示更新内存数据)
    FUpdateMem: Integer;
    // 更新的数据集 key 对应的列明
    FUpdateMemFieldKey: string;
    // 存放内存需要更新的数据
    FUpdateMemDic: TDictionary<string, string>;
  protected
    // 获取临时表名称
    function GetTempTableName: string;
    // 获取临时删除表名称
    function GetTempDelTableName: string;
  public
    // 构造方法
    constructor Create;
    // 析构函数
    destructor Destroy; override;
    // 设置数据的列名
    procedure SetColFields(AColFields: string);
    // 添加更新数据的 Key
    procedure AddUpdateMem(AUpdateKey: string);
    // 获取更新数据的 Key
    function GetUpdateMemKeys: string;
    // 获取更新数据的 Key 的个数
    function GetUpdateMemKeyCount: Integer;

    property Name: string read FName write FName;
    property TempName: string read GetTempTableName;
    property TempDelName: string read GetTempDelTableName;
    property IndexID: Integer read FIndexID write FIndexID;
    property Storage: Integer read FStorage write FStorage;
    property Version: Integer read FVersion write FVersion;
    property MaxJSID: Int64 read FMaxJSID write FMaxJSID;
    property DelJSID: Int64 read FDelJSID write FDelJSID;
    property IsCreate: Boolean read FIsCreate write FIsCreate;
    property CreateSql: string read FCreateSql write FCreateSql;
    property InsertSql: string read FInsertSql write FInsertSql;
    property DeleteSql: string read FDeleteSql write FDeleteSql;
    property Indicator: string read FIndicator write FIndicator;
    property DeleteIndicator: string read FDeleteIndicator write FDeleteIndicator;
    property ColFields: TStringList read FColFields;
    property UpdateMem: Integer read FUpdateMem write FUpdateMem;
    property UpdateMemFieldKey: string read FUpdateMemFieldKey write FUpdateMemFieldKey;
  end;

implementation

{ TCacheTable }

constructor TCacheTable.Create;
begin
  FIndexID := 0;
  FStorage := 0;
  FVersion := 0;
  FMaxJSID := 0;
  FDelJSID := 0;
  FUpdateMem := 0;
  FLock := TCSLock.Create;
  FColFields := TStringList.Create;
  FUpdateMemDic := TDictionary<string, string>.Create;
end;

destructor TCacheTable.Destroy;
begin
  FUpdateMemDic.Free;
  FColFields.Free;
  FLock.Free;
  inherited;
end;

function TCacheTable.GetTempTableName: string;
begin
  Result := 'Temp_' + FName;
end;

function TCacheTable.GetTempDelTableName: string;
begin
  Result := 'TempDel_' + FName;
end;

procedure TCacheTable.SetColFields(AColFields: string);
begin
  FColFields.DelimitedText := AColFields;
end;

procedure TCacheTable.AddUpdateMem(AUpdateKey: string);
begin
  if AUpdateKey = '' then Exit;
  
  FLock.Lock;
  try
    FUpdateMemDic.AddOrSetValue(AUpdateKey, AUpdateKey);
  finally
    FLock.UnLock;
  end;
end;

function TCacheTable.GetUpdateMemKeys: string;
var
  LEnum: TDictionary<string, string>.TPairEnumerator;
begin
  FLock.Lock;
  try
    Result := '';
    if FUpdateMemDic.Count <= 0 then begin
      Exit;
    end;

    LEnum := FUpdateMemDic.GetEnumerator;
    while LEnum.MoveNext do begin
      if Result = '' then begin
        Result := LEnum.Current.Key;
      end else begin
        Result := LEnum.Current.Key + ',' + Result;
      end;
    end;
  finally
    FLock.UnLock;
  end;
end;

function TCacheTable.GetUpdateMemKeyCount: Integer;
begin
  FLock.Lock;
  try
    Result := FUpdateMemDic.Count;
  finally
    FLock.UnLock;
  end;
end;

end.
