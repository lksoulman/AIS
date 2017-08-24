unit CacheGFData;

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
  WNDataSetInf;

type

  // 指标数据操作类型
  TCacheGFDataType = (GFInsert,    // 插入数据
                      GFDelete     // 删除数据
                      );

  TCacheGFData = class
  private
    // 关联 ID
    FID: Integer;
    // 是不是更新操作(除了首次创建表和查询所有数据放入表中不是更新操作)
    FIsUpdate: Boolean;
    // 数据集
    FDataSet: IWNDataSet;
    // 数据类型
    FDataType: TCacheGFDataType;
  protected
  public
    // 构造方法
    constructor Create;
    // 析构函数
    destructor Destroy; override;

    property ID: Integer read FID write FID;
    property IsUpdate: Boolean read FIsUpdate write FIsUpdate;
    property DataSet: IWNDataSet read FDataSet write FDataSet;
    property DataType: TCacheGFDataType read FDataType write FDataType;
  end;

implementation

{ TCacheGFData }

constructor TCacheGFData.Create;
begin
  FID := 0;
  FDataSet := nil;
  FIsUpdate := False;
end;

destructor TCacheGFData.Destroy;
begin
  if FDataSet <> nil then begin
    FDataSet := nil;
  end;
  inherited;
end;

end.
