unit CompanyInfoImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-7-20
// Comments：
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
    // 公司邮件
    FEmail: string;
    // 公司电话
    FPhone: string;
    // 公司网站
    FWebsite: string;
    // 公司版权
    FCopyright: string;
    // 应用程序上下文接口
    FAppContext: IAppContext;
  protected

  public
    // 构造方法
    constructor Create;
    // 析构函数
    destructor Destroy; override;

    { ICompanyInfo }

    // 初始化需要的资源
    procedure Initialize(AContext: IInterface); safecall;
    // 释放不需要的资源
    procedure UnInitialize; safecall;
    // 加载缓存
    procedure LoadCache; safecall;
    // 通过Ini对象加载
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
