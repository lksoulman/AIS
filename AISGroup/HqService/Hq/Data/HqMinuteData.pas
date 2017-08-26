unit HqMinuteData;

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
  SysUtils,
  HqMinute,
  HqAuction;

type

  // 分时数据接口
  IHqMinuteData = Interface(IInterface)
    ['{0116AD98-9408-44F7-B12C-E90BCF9929FA}']
    //获取证券代码
    function GetCode: string;
    //获取集合竞价数据
    function GetHqAuction: IHqAuction;
    //根据日期获取当日分时数据
    function GetHqMinute(ADate: Integer): IHqMinute;
    //获取多日分时数据(当日为0，向前递减-1,-2...)
    function GetMultiHqMinute(AIndex: Integer): IHqMinute;

    //证券代码
    property Code: string read GetCode;
    //集合竞价数据
    property HqAuction: IHqAuction read GetHqAuction;
    //分时数据索引器
    property HqMinutes[ADate: Integer]: IHqMinute read GetHqMinute;
    //分时数据索引器(按序号，当日为0，向前递减-1,-2...)
    property MultiHqMinutes[AIndex: Integer]: IHqMinute read GetMultiHqMinute;
  end;

implementation

end.
