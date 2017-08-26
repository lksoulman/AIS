unit HqTickData;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-25
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  //分笔数据项
  THqTickItem = packed record
    Time: Integer;                //时间
    Price: Double;                //价格
    Volume: Double;               //成交量
    Turnover: Double;             //成交额
    Direction: Word;              //成交方向(0卖 1买)
    Count: Integer;               //成交笔数
    DealProperty: Word;           //股指期货成交性质 1: 空开; 2: 空平; 3: 空换; 4: 多开 5: 多平; 6: 多换; 7: 双开; 8: 双平
    PositionChange: Integer;      //股指期货持仓量变化
  end;

  // 分笔数据项指针
  PHqTickItem = ^THqTickItem;

  // 分笔数据接口
  IHqTickData = Interface(IInterface)
    ['{4B38F694-EE2C-4C3B-8B49-76A6D1220CBC}']
    //获取证券代码
    function GetCode: string;
    //获取分笔项数量
    function GetItemCount: Integer;
    //根据序号获取分笔项
    function GetItem(AIndex: Integer): PHqTickItem;

    //证券代码
    property Code: string read GetCode;
    //分笔项数量
    property ItemCount: Integer read GetItemCount;
    //分笔项索引
    property Items[AIndex: Integer]: PHqTickItem read GetItem;
  end;

implementation

end.
