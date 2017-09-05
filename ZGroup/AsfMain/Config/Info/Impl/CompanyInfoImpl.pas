unit CompanyInfoImpl;

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
  AppContext,
  CompanyInfo;

type

  TCompanyInfoImpl = class(TInterfacedObject, ICompanyInfo)
  private
    // ��˾�ʼ�
    FEmail: string;
    // ��˾�绰
    FPhone: string;
    // ��˾��վ
    FWebsite: string;
    // ��˾��Ȩ
    FCopyright: string;
    // Ӧ�ó��������Ľӿ�
    FAppContext: IAppContext;
  protected

  public
    // ���췽��
    constructor Create;
    // ��������
    destructor Destroy; override;

    { ICompanyInfo }

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

{ TCompanyInfoImpl }

constructor TCompanyInfoImpl.Create;
begin
  inherited;
  FEmail := 'service@gildata.com';
  FPhone := '400-820-7887';
  FWebsite := 'http://www.gildata.com';
  FCopyright := '';
end;

destructor TCompanyInfoImpl.Destroy;
begin

  inherited;
end;

procedure TCompanyInfoImpl.Initialize(AContext: IInterface);
begin
  FAppContext := AContext as IAppContext;

end;

procedure TCompanyInfoImpl.UnInitialize;
begin
  FAppContext := nil;
end;

procedure TCompanyInfoImpl.LoadByIniFile(AFile: TIniFile);
begin
  if AFile = nil then Exit;
  FEmail := AFile.ReadString('CompanyInfo', 'Email', FEmail);
  FPhone := AFile.ReadString('CompanyInfo', 'Phone', FPhone);
  FWebsite := AFile.ReadString('CompanyInfo', 'Website', FWebsite);
  FCopyright := AFile.ReadString('CompanyInfo', 'Copyright', FCopyright);
end;

procedure TCompanyInfoImpl.LoadCache;
begin

end;

end.
