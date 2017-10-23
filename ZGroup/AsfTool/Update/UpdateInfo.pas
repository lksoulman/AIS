unit UpdateInfo;

////////////////////////////////////////////////////////////////////////////////
//
// Description： Update File Information
// Author：      lksoulman
// Date：        2017-10-12
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  CommonRefCounter;

type

  // Upgrade Type
  TUpgradeType = (utCustom,       // 普通升级类型
                  utForce         // 强制升级类型
                  );

  // Update Information
  TUpdateInfo = class(TAutoObject)
  private
    // File Name
    FName: string;
    // File Size
    FSize: Int64;
    // File MD5 Value
    FMD5Value: string;
    // File Crc Value
    FCrcValue: string;
    // Relative Path
    FRelativePath: string;
    // Upgrade Type
    FUpgradeType: TUpgradeType;
  protected
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;
    // Reset Value
    procedure ResetValue;
    // Assign
    procedure Assign(AUpdateInfo: TUpdateInfo);
    // Int 转 UpdateType
    function IntToUpgradeType(AValue: Integer): TUpgradeType;
    // UpdateType 转 Int
    function UpgradeTypeToInt(AUpgradeType: TUpgradeType): Integer;

    property Size: Int64 read FSize write FSize;
    property Name: string read FName write FName;
    property CrcValue: string read FCrcValue write FCrcValue;
    property MD5Value: string read FMD5Value write FMD5Value;
    property RelativePath: string read FRelativePath write FRelativePath;
    property UpgradeType: TUpgradeType read FUpgradeType write FUpgradeType;
  end;

implementation

{ TUpdateInfo }

constructor TUpdateInfo.Create;
begin
  inherited;
  ResetValue;
end;

destructor TUpdateInfo.Destroy;
begin

  inherited;
end;

procedure TUpdateInfo.ResetValue;
begin
  FName := '';
  FSize := 0;
  FCrcValue := '';
  FMD5Value := '';
  FRelativePath := '';
end;

procedure TUpdateInfo.Assign(AUpdateInfo: TUpdateInfo);
begin
  if AUpdateInfo = nil then Exit;

  FName := AUpdateInfo.Name;
  FSize := AUpdateInfo.Size;
  FCrcValue := AUpdateInfo.CrcValue;
  FMD5Value := AUpdateInfo.CrcValue;
  FRelativePath := AUpdateInfo.RelativePath;
end;

function TUpdateInfo.IntToUpgradeType(AValue: Integer): TUpgradeType;
begin
  case AValue of
    0:
      begin
        Result := utCustom;
      end;
    1:
      begin
        Result := utForce;
      end;
  end;
end;

function TUpdateInfo.UpgradeTypeToInt(AUpgradeType: TUpgradeType): Integer;
begin
  case AUpgradeType of
    utCustom:
      begin
        Result := 0;
      end;
    utForce:
      begin
        Result := 1;
      end;
  end;
end;

end.
