unit PermissionMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-17
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  SyncAsync,
  AppContext,
  Permission,
  WNDataSetInf,
  PermissionMgr,
  Generics.Collections;

type

  // Ȩ�޽ӿ�ʵ�� (�˵�Ȩ��)
  TPermissionMgrImpl = class(TInterfacedObject, ISyncAsync, IPermissionMgr)
  private
    // Ӧ�ó��������Ľӿ�
    FAppContext: IAppContext;
    // Ȩ���ֵ�
    FUserPermissionDic: TDictionary<Integer, TPermission>;
  protected
    // ��ȡȨ������
    procedure DoGetPermissionData;
    // ����Ȩ������
    procedure DoLoadData(ADataSet: IWNDataSet; APermNoField, APermNameField, AEndDateField, AStartDateField: IWNField);
  public
    // ���췽��
    constructor Create;
    // ��������
    destructor Destroy; override;

    { ISyncAsync }

    // ��ʼ����Ҫ����Դ
    procedure Initialize(AContext: IAppContext); safecall;
    // �ͷŲ���Ҫ����Դ
    procedure UnInitialize; safecall;
    // �ǲ��Ǳ���ͬ��ִ��
    function IsNeedSync: WordBool; safecall;
    // ͬ��ִ�з���
    procedure SyncExecute; safecall;
    // �첽ִ�з���
    procedure AsyncExecute; safecall;

    { IPermission }

    // �ж��ǲ�����Ȩ��
    function IsHasPermission(APermNo: Integer): Boolean; safecall;
  end;

implementation

uses
  LoginMgr,
  LoginGFType,
  FastLogLevel;

{ TPermissionMgrImpl }

constructor TPermissionMgrImpl.Create;
begin
  inherited;
  FUserPermissionDic := TDictionary<Integer, TPermission>.Create;
end;

destructor TPermissionMgrImpl.Destroy;
begin
  FUserPermissionDic.Free;
  inherited;
end;

procedure TPermissionMgrImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;

end;

procedure TPermissionMgrImpl.UnInitialize;
begin
  FAppContext := nil;
end;

function TPermissionMgrImpl.IsNeedSync: WordBool;
begin
  Result := True;
end;

procedure TPermissionMgrImpl.SyncExecute;
begin
  if (FAppContext.GetLoginMgr <> nil) then begin
    if FAppContext.GetLoginMgr.IsLoginGF(lGFBase) then begin
      DoGetPermissionData;
    end else begin
      FAppContext.AppLog(llERROR, '[TPermissionMgrImpl][SyncExecute] GetLoginMgr.IsLoginGF(lGFBase) return is false, permission is not load.');
    end;
  end else begin
    FAppContext.AppLog(llERROR, '[TPermissionMgrImpl][SyncExecute] GetLoginMgr is nil');
  end;
end;

procedure TPermissionMgrImpl.AsyncExecute;
begin

end;

function TPermissionMgrImpl.IsHasPermission(APermNo: Integer): Boolean;
begin
  Result := FUserPermissionDic.ContainsKey(APermNo);
end;

procedure TPermissionMgrImpl.DoGetPermissionData;
var
{$IFDEF DEBUG}
  LTick: Cardinal;
{$ENDIF}
  LDataSet: IWNDataSet;
  LPermNoField, LPermNameField, LEndDateField, LStartDateField: IWNField;
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
{$ENDIF}
  LDataSet := FAppContext.GFSyncQueryHighData(gtBaseData, 'USER_QX', 0, 100000);
  if (LDataSet <> nil) and (LDataSet.RecordCount > 0) then begin
    LPermNoField := LDataSet.FieldByName('mkid');
    LPermNameField := LDataSet.FieldByName('qx');
    LEndDateField := LDataSet.FieldByName('jzrq');
    LStartDateField := LDataSet.FieldByName('qsrq');

    if (LPermNoField = nil) then begin
      FAppContext.IndicatorLog(llERROR, Format('[TPermissionMgrImpl][DoGetPermissionData] [Indicator][USER_QX] Return field %s is nil.', ['PermNo']));
      Exit;
    end;
    if (LPermNameField = nil) then begin
      FAppContext.IndicatorLog(llERROR, Format('[TPermissionMgrImpl][DoGetPermissionData] [Indicator][USER_QX] Return field %s is nil.', ['PermName']));
      Exit;
    end;

    if (LEndDateField = nil) then begin
      FAppContext.IndicatorLog(llERROR, Format('[TPermissionMgrImpl][DoGetPermissionData] [Indicator][USER_QX] Return field %s is nil.', ['EndDate']));
      Exit;
    end;

    if (LStartDateField = nil) then begin
      FAppContext.IndicatorLog(llERROR, Format('[TPermissionMgrImpl][DoGetPermissionData] [Indicator][USER_QX] Return field %s is nil.', ['StartDate']));
      Exit;
    end;
    DoLoadData(LDataSet, LPermNoField, LPermNameField, LEndDateField, LStartDateField);
    LDataSet := nil;
  end;
{$IFDEF DEBUG}
  LTick := GetTickCount - LTick;
  FAppContext.AppLog(llSLOW, Format('[TPermissionMgrImpl][DoGetPermissionData] Load permissions data to dictionary use time is %d ms.', [LTick]), LTick);
{$ENDIF}
end;

procedure TPermissionMgrImpl.DoLoadData(ADataSet: IWNDataSet; APermNoField, APermNameField, AEndDateField, AStartDateField: IWNField);
var
  LPermNo: Integer;
  LPermission: TPermission;
begin
  ADataSet.First;
  try
    while not ADataSet.Eof do begin
      LPermNo := APermNoField.AsInteger;
      if FUserPermissionDic.TryGetValue(LPermNo, LPermission)
        and (LPermission <> nil) then begin
        FAppContext.IndicatorLog(llERROR, Format('[TPermissionMgrImpl][DoLoadData] [Indicator][USER_QX] return dataset PermNo(%d) is repeated.', [LPermNo]));
      end else begin
        LPermission := TPermission.Create;
      end;
      LPermission.PermNo := LPermNo;
      LPermission.PermName := APermNameField.AsString;
      LPermission.EndDate := AEndDateField.AsDateTime;
      LPermission.StartDate := AStartDateField.AsDateTime;
      ADataSet.Next;
    end;
  except
    on Ex: Exception do begin
      FAppContext.AppLog(llError, Format('[TPermissionMgrImpl][DoLoadData] Load data is exception, exception is %s.', [Ex.Message]));
    end;
  end;
end;

end.
