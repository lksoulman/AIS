unit UpdateInfoImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-7-22
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  IniFiles,
  UpdateInfo,
  AppContext;

type

  TUpdateInfoImpl = class(TInterfacedObject, IUpdateInfo)
  private
//    // Ӧ�ó�������
//    FAppExeName: string;
//    // ���³�������
//    FUpdateExeName: string;
    // Ӧ�ó��������Ľӿ�
    FAppContext: IAppContext;
  protected
  public
    // ���췽��
    constructor Create;
    // ��������
    destructor Destroy; override;

    { ISyscfgInfo }

    // ��ʼ����Ҫ����Դ
    procedure Initialize(AContext: IInterface); safecall;
    // �ͷŲ���Ҫ����Դ
    procedure UnInitialize; safecall;
    // ���ػ���
    procedure LoadCache; safecall;
    // ͨ��Ini�������
    procedure LoadByIniFile(AFile: TIniFile); safecall;
  end;

implementation

{ TUpdateInfoImpl }

constructor TUpdateInfoImpl.Create;
begin

end;

destructor TUpdateInfoImpl.Destroy;
begin

  inherited;
end;

procedure TUpdateInfoImpl.Initialize(AContext: IInterface);
begin
  FAppContext := AContext as IAppContext;

end;

procedure TUpdateInfoImpl.UnInitialize;
begin
  FAppContext := nil;
end;

procedure TUpdateInfoImpl.LoadByIniFile(AFile: TIniFile);
begin

end;

procedure TUpdateInfoImpl.LoadCache;
begin

end;

end.
