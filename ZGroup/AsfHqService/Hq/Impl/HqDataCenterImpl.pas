unit HqDataCenterImpl;

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
  AppContext,
  HqRealData,
  HqTickData,
  HqKLineData,
  HqMinuteData,
  HqDataCenter,
  CommonRefCounter,
  Generics.Collections;

type

  // 行情订阅适配
  THqDataCenterImpl = class(TAutoInterfacedObject, IHqDataCenter)
  private
    // 应用程序上下文接口
    FAppContext: IAppContext;
    // 实时数据接口字典
    FHqRealDataDic: TDictionary<string, IHqRealData>;
    // 分笔数据接口字典
    FHqTickDataDic: TDictionary<string, IHqTickData>;
    // K 线数据接口字典
    FHqKLineDataDic: TDictionary<string, IHqKLineData>;
    // 分时数据接口字典
    FHqMinuteDataDic: TDictionary<string, IHqMinuteData>;
  protected
  public
    // 构造函数
    constructor Create; override;
    // 析构函数
    destructor Destroy; override;

    { IHqDataCenter }

    // 初始化需要的资源
    procedure Initialize(AContext: IAppContext); safecall;
    // 释放不需要的资源
    procedure UnInitialize; safecall;
    // 获取实时数据接口
    function GetRealData(ACode: string): IHqRealData; safecall;
    // 获取分笔数据接口
    function GetTickData(ACode: string): IHqTickData; safecall;
    // 获取K线数据接口
    function GetKLineData(ACode: string): IHqKLineData; safecall;
    // 获取分时数据接口
    function GetMinuteData(ACode: string): IHqMinuteData; safecall;

    // 实时数据
    property RealData[Code: string]: IHqRealData read GetRealData;
    // 分笔数据
    property TickData[Code: string]: IHqTickData read GetTickData;
    // K线数据
    property KLineData[Code: string]: IHqKLineData read GetKLineData;
    // 分时数据
    property MinuteData[Code: string]: IHqMinuteData read GetMinuteData;
  end;

implementation

{ THqDataCenterImpl }

constructor THqDataCenterImpl.Create;
begin
  inherited;
  FHqRealDataDic := TDictionary<string, IHqRealData>.Create(500);
  FHqTickDataDic := TDictionary<string, IHqTickData>.Create(100);
  FHqKLineDataDic := TDictionary<string, IHqKLineData>.Create(100);
  FHqMinuteDataDic := TDictionary<string, IHqMinuteData>.Create(100);
end;

destructor THqDataCenterImpl.Destroy;
begin
  FHqRealDataDic.Free;
  FHqTickDataDic.Free;
  FHqKLineDataDic.Free;
  FHqMinuteDataDic.Free;
  inherited;
end;

procedure THqDataCenterImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
end;

procedure THqDataCenterImpl.UnInitialize;
begin
  FAppContext := nil;
end;

function THqDataCenterImpl.GetRealData(ACode: string): IHqRealData;
begin
  if not (FHqRealDataDic.TryGetValue(ACode, Result)
    and (Result <> nil)) then begin
    Result := nil;
  end;
end;

function THqDataCenterImpl.GetTickData(ACode: string): IHqTickData;
begin
  if not (FHqTickDataDic.TryGetValue(ACode, Result)
    and (Result <> nil)) then begin
    Result := nil;
  end;
end;

function THqDataCenterImpl.GetKLineData(ACode: string): IHqKLineData;
begin
  if not (FHqKLineDataDic.TryGetValue(ACode, Result)
    and (Result <> nil)) then begin
    Result := nil;
  end;
end;

function THqDataCenterImpl.GetMinuteData(ACode: string): IHqMinuteData;
begin
  if not (FHqMinuteDataDic.TryGetValue(ACode, Result)
    and (Result <> nil)) then begin
    Result := nil;
  end;
end;

end.
