unit CacheGF;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-11
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  WNDataSetInf,
  CacheOperateType;

type

  // 缓存 GF 对象
  TCacheGF = class
  private
    // 关联 ID
    FID: Integer;
    // 是不是更新操作(除了首次创建表和查询所有数据放入表中不是更新操作)
    FIsUpdate: Boolean;
    // 数据集
    FDataSet: IWNDataSet;
    // 缓存操作类型
    FOperateType: TCacheOperateType;
  protected
  public
    // 构造方法
    constructor Create;
    // 析构函数
    destructor Destroy; override;

    property ID: Integer read FID write FID;
    property IsUpdate: Boolean read FIsUpdate write FIsUpdate;
    property DataSet: IWNDataSet read FDataSet write FDataSet;
    property OperateType: TCacheOperateType read FOperateType write FOperateType;
  end;

implementation

{ TCacheGF }

constructor TCacheGF.Create;
begin
  FID := 0;
  FDataSet := nil;
  FIsUpdate := False;
end;

destructor TCacheGF.Destroy;
begin
  if FDataSet <> nil then begin
    FDataSet := nil;
  end;
  inherited;
end;

end.
