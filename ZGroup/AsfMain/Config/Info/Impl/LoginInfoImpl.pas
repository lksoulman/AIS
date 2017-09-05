unit LoginInfoImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-7-20
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  IniFiles,
  LoginInfo,
  AppContext;

type

  TLoginInfoImpl = class(TInterfacedObject, ILoginInfo)
  private
//    // ��¼ģʽ
//    FLoginType: Integer;
    // Ӧ�ó��������Ľӿ�
    FAppContext: IAppContext;
  protected
  public
    // ���췽��
    constructor Create;
    // ��������
    destructor Destroy; override;

    { ILoginInfo }

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

{ TLoginInfoImpl }

constructor TLoginInfoImpl.Create;
begin
  inherited;

end;

destructor TLoginInfoImpl.Destroy;
begin

  inherited;
end;

procedure TLoginInfoImpl.Initialize(AContext: IInterface);
begin
//  FAppContext := AContext;

end;

procedure TLoginInfoImpl.UnInitialize;
begin
  FAppContext := nil;
end;

procedure TLoginInfoImpl.LoadByIniFile(AFile: TIniFile);
begin

end;

procedure TLoginInfoImpl.LoadCache;
begin

end;

end.
