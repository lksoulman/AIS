unit CompanyInfoImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Company Info Interface Implementation
// Author£º      lksoulman
// Date£º        2017-7-20
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  IniFiles,
  AppContext,
  CompanyInfo,
  CommonRefCounter;

type

  // Company Info Interface Implementation
  TCompanyInfoImpl = class(TAutoInterfacedObject, ICompanyInfo)
  private
    // Application Context
    FAppContext: IAppContext;
    // Company Info
    FCompanyInfo: TCompanyInfo;
  protected
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;

    { ICompanyInfo }

    // Init
    procedure Initialize(AContext: IInterface);
    // UnInit
    procedure UnInitialize;
    // Load Cache
    procedure LoadCache;
    // Read
    procedure Read(AFile: TIniFile);
    // Get Company Info
    function GetCompanyInfo: PCompanyInfo;
  end;

implementation

{ TCompanyInfoImpl }

constructor TCompanyInfoImpl.Create;
begin
  inherited;
  FCompanyInfo.FEmail := 'service@gildata.com';
  FCompanyInfo.FPhone := '400-820-7887';
  FCompanyInfo.FWebsite := 'http://www.gildata.com';
  FCompanyInfo.FCopyright := '';
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

procedure TCompanyInfoImpl.Read(AFile: TIniFile);
begin
  if AFile = nil then Exit;
  FCompanyInfo.FEmail := AFile.ReadString('CompanyInfo', 'Email', FCompanyInfo.FEmail);
  FCompanyInfo.FPhone := AFile.ReadString('CompanyInfo', 'Phone', FCompanyInfo.FPhone);
  FCompanyInfo.FWebsite := AFile.ReadString('CompanyInfo', 'Website', FCompanyInfo.FWebsite);
  FCompanyInfo.FCopyright := AFile.ReadString('CompanyInfo', 'Copyright', FCompanyInfo.FCopyright);
end;

procedure TCompanyInfoImpl.LoadCache;
begin

end;

function TCompanyInfoImpl.GetCompanyInfo: PCompanyInfo;
begin
  Result := @FCompanyInfo;
end;

end.
