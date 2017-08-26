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
    // �ǲ����и۹�ʵʱȨ��
    FIsHasHKReal: Boolean;
    // �ǲ����� LevelII Ȩ��
    FIsHasLevelII: Boolean;
    // LevelII ��¼�û���
    FLevelIIUserName: string;
    // LevelII ��¼����
    FLevelIIPassword: string;
    // Ӧ�ó��������Ľӿ�
    FAppContext: IAppContext;
    // Ȩ���ֵ�
    FUserPermissionDic: TDictionary<Integer, TPermission>;
  protected
    // ��ȡ�۹�ʵʱȨ������
    procedure DoGetHKReal;
    //  ��ȡLevelIIȨ������
    procedure DoGetLevelII;
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

    // �ǲ����и۹�ʵʱȨ��
    function IsHasHKReal: Boolean; safecall;
    // �ǲ����� LevelII Ȩ��
    function IsHasLevelII: Boolean; safecall;
    // ��ȡ LevelII �û���
    function GetLevelIIUserName: WideString; safecall;
    // ��ȡ LevelII �û�����
    function GetLevelIIPassword: WideString; safecall;
    // �ж��ǲ�����Ȩ��
    function IsHasPermission(APermNo: Integer): Boolean; safecall;
  end;

implementation

uses
  LoginMgr,
  ServiceType,
  LoginGFType,
  FastLogLevel;

{ TPermissionMgrImpl }

constructor TPermissionMgrImpl.Create;
begin
  inherited;
  FIsHasHKReal := False;
  FIsHasLevelII := False;
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
    if (FAppContext.GetLoginMgr as ILoginMgr).IsLoginGF(lGFBase) then begin
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

function TPermissionMgrImpl.IsHasHKReal: Boolean;
begin
  Result := FIsHasHKReal;
end;

function TPermissionMgrImpl.IsHasLevelII: Boolean;
begin
  Result := FIsHasLevelII;
end;

function TPermissionMgrImpl.GetLevelIIUserName: WideString;
begin
  Result := '';
end;

function TPermissionMgrImpl.GetLevelIIPassword: WideString;
begin
  Result := '';
end;

function TPermissionMgrImpl.IsHasPermission(APermNo: Integer): Boolean;
begin
  Result := FUserPermissionDic.ContainsKey(APermNo);
end;

procedure TPermissionMgrImpl.DoGetHKReal;
var
{$IFDEF DEBUG}
  LTick: Cardinal;
{$ENDIF}
  LDataSet: IWNDataSet;
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
{$ENDIF}

  FIsHasHKReal := False;
  LDataSet := FAppContext.GFSyncQueryHighData(stBase, 'USER_QX_HK()', 0, 5000);
  if LDataSet <> nil then begin
    if LDataSet.RecordCount > 0 then begin
      LDataSet.First;
      if (LDataSet.FieldCount > 0)
        and (not LDataSet.Fields(0).IsNull) then begin
        FIsHasHKReal := (LDataSet.Fields(0).AsInteger > 0);
      end else begin
        FAppContext.IndicatorLog(llERROR, Format('[TPermissionMgrImpl][DoGetHKReal] [Indicator][%s] Return data fieldcount is 0 or field data is nil.', ['USER_QX_HK()']));
      end;
    end else begin
      FAppContext.IndicatorLog(llERROR, Format('[TPermissionMgrImpl][DoGetHKReal] [Indicator][%s] Return data is nil.', ['USER_QX_HK()']));
    end;
  end else begin
    FAppContext.IndicatorLog(llERROR, Format('[TPermissionMgrImpl][DoGetHKReal] [Indicator][%s] Return data is nil.', ['USER_QX_HK()']));
  end;

{$IFDEF DEBUG}
  LTick := GetTickCount - LTick;
  FAppContext.AppLog(llSLOW, Format('[TPermissionMgrImpl][DoGetHKReal] Load HKReal data to dictionary use time is %d ms.', [LTick]), LTick);
{$ENDIF}
end;

procedure TPermissionMgrImpl.DoGetLevelII;
var
{$IFDEF DEBUG}
  LTick: Cardinal;
{$ENDIF}
  LDataSet: IWNDataSet;
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
{$ENDIF}

  FIsHasLevelII := False;
  LDataSet := FAppContext.GFSyncQueryHighData(stBase, 'USER_LEVEL2_INFO()', 0, 5000);
  if LDataSet <> nil then begin
    if LDataSet.RecordCount > 0 then begin
      LDataSet.First;
      if (LDataSet.FieldCount > 2) then begin
        FLevelIIUserName := LDataSet.Fields(0).AsString;
        FLevelIIPassword := LDataSet.Fields(1).AsString;
        FIsHasLevelII := True;
      end else begin
        FAppContext.IndicatorLog(llERROR, Format('[TPermissionMgrImpl][DoGetLevelII] [Indicator][%s] Return data fieldcount low 2.', ['USER_LEVEL2_INFO()']));
      end;
    end else begin
      FAppContext.IndicatorLog(llERROR, Format('[TPermissionMgrImpl][DoGetLevelII] [Indicator][%s] Return data is nil.', ['USER_LEVEL2_INFO()']));
    end;
  end else begin
    FAppContext.IndicatorLog(llERROR, Format('[TPermissionMgrImpl][DoGetLevelII] [Indicator][%s] Return data is nil.', ['USER_LEVEL2_INFO()']));
  end;

{$IFDEF DEBUG}
  LTick := GetTickCount - LTick;
  FAppContext.AppLog(llSLOW, Format('[TPermissionMgrImpl][DoGetLevelII] Load LevelII data to dictionary use time is %d ms.', [LTick]), LTick);
{$ENDIF}
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

  LDataSet := FAppContext.GFSyncQueryHighData(stBase, 'USER_QX', 0, 100000);
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
