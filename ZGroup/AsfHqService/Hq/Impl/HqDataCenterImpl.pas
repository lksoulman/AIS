unit HqDataCenterImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-25
// Comments��
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

  // ���鶩������
  THqDataCenterImpl = class(TAutoInterfacedObject, IHqDataCenter)
  private
    // Ӧ�ó��������Ľӿ�
    FAppContext: IAppContext;
    // ʵʱ���ݽӿ��ֵ�
    FHqRealDataDic: TDictionary<string, IHqRealData>;
    // �ֱ����ݽӿ��ֵ�
    FHqTickDataDic: TDictionary<string, IHqTickData>;
    // K �����ݽӿ��ֵ�
    FHqKLineDataDic: TDictionary<string, IHqKLineData>;
    // ��ʱ���ݽӿ��ֵ�
    FHqMinuteDataDic: TDictionary<string, IHqMinuteData>;
  protected
  public
    // ���캯��
    constructor Create; override;
    // ��������
    destructor Destroy; override;

    { IHqDataCenter }

    // ��ʼ����Ҫ����Դ
    procedure Initialize(AContext: IAppContext); safecall;
    // �ͷŲ���Ҫ����Դ
    procedure UnInitialize; safecall;
    // ��ȡʵʱ���ݽӿ�
    function GetRealData(ACode: string): IHqRealData; safecall;
    // ��ȡ�ֱ����ݽӿ�
    function GetTickData(ACode: string): IHqTickData; safecall;
    // ��ȡK�����ݽӿ�
    function GetKLineData(ACode: string): IHqKLineData; safecall;
    // ��ȡ��ʱ���ݽӿ�
    function GetMinuteData(ACode: string): IHqMinuteData; safecall;

    // ʵʱ����
    property RealData[Code: string]: IHqRealData read GetRealData;
    // �ֱ�����
    property TickData[Code: string]: IHqTickData read GetTickData;
    // K������
    property KLineData[Code: string]: IHqKLineData read GetKLineData;
    // ��ʱ����
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
